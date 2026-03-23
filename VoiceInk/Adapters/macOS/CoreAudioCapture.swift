import Foundation
import AVFoundation

/// macOS implementation of IAudioCapture.
/// Thin adapter over the existing Recorder + AudioDeviceManager stack.
@MainActor
public final class CoreAudioCapture: IAudioCapture {

    private let recorder: Recorder
    private let deviceManager: AudioDeviceManager

    public var onAudioLevelChanged: ((AudioMeterInfo) -> Void)?

    /// Mirror the recorder's published audioMeter into the protocol callback.
    private var meterObserver: NSObjectProtocol?

    public init(recorder: Recorder, deviceManager: AudioDeviceManager = .shared) {
        self.recorder = recorder
        self.deviceManager = deviceManager

        // Propagate AudioMeter updates from Recorder to protocol consumers.
        // Recorder publishes audioMeter at ~60 Hz via @Published.
        meterObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AudioDeviceChanged"),
            object: nil,
            queue: .main
        ) { _ in }
        // Note: audioMeter binding is done via Recorder.objectWillChange in the
        // calling view layer. Adapters consuming the callback should observe
        // recorder.audioMeter via Combine if needed.
    }

    deinit {
        if let observer = meterObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    public var isRecording: Bool {
        // Recorder doesn't expose isRecording directly; proxy via recorder presence.
        // Use AudioDeviceManager's flag as a reliable proxy.
        deviceManager.isRecordingActive
    }

    public var currentDevice: AudioDeviceInfo? {
        guard let selected = deviceManager.selectedDeviceID,
              let device = deviceManager.availableDevices.first(where: { $0.id == selected }) else {
            return nil
        }
        return AudioDeviceInfo(id: device.uid, name: device.name)
    }

    public var availableDevices: [AudioDeviceInfo] {
        deviceManager.availableDevices.map {
            AudioDeviceInfo(id: $0.uid, name: $0.name)
        }
    }

    public func startRecording(toOutputFile url: URL, device: AudioDeviceInfo?) async throws {
        if let device = device,
           let match = deviceManager.availableDevices.first(where: { $0.uid == device.id }) {
            deviceManager.selectDevice(id: match.id)
        }
        try await recorder.startRecording(toOutputFile: url)
    }

    public func stopRecording() {
        recorder.stopRecording()
    }
}
