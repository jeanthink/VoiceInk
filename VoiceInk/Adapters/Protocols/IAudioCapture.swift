import Foundation

/// Platform-agnostic audio capture interface.
/// macOS implementation: CoreAudioCapture (wraps Recorder.swift + CoreAudioRecorder.swift)
/// Windows implementation (future): WasapiAudioCapture
/// Linux implementation (future): PipeWireAudioCapture
public protocol IAudioCapture: AnyObject {
    var isRecording: Bool { get }
    var currentDevice: AudioDeviceInfo? { get }
    var availableDevices: [AudioDeviceInfo] { get }

    /// Start recording audio to the given output file URL.
    func startRecording(toOutputFile url: URL, device: AudioDeviceInfo?) async throws
    func stopRecording()

    /// Callback fired when audio meter levels update (~60 Hz).
    var onAudioLevelChanged: ((AudioMeterInfo) -> Void)? { get set }
}

public struct AudioDeviceInfo: Sendable, Identifiable, Hashable {
    public let id: String       // uid string (stable across reboots)
    public let name: String
    public let isDefault: Bool

    public init(id: String, name: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
    }
}

public struct AudioMeterInfo: Sendable {
    public let averagePower: Double
    public let peakPower: Double

    public init(averagePower: Double, peakPower: Double) {
        self.averagePower = averagePower
        self.peakPower = peakPower
    }
}
