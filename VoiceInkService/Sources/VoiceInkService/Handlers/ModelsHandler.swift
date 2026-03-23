import Foundation

public struct ModelsHandler {
    static func handle(bridge: CoreBridgeProtocol) async -> [ModelInfoResponse] {
        await bridge.listModels()
    }
}
