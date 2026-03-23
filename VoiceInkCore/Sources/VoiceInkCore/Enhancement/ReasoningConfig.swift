import Foundation

public struct ReasoningConfig {
    public static func getReasoningEffort(for modelID: String) -> String? {
        if modelID.starts(with: "o1-") || modelID.starts(with: "o3-") {
            return "medium"
        }
        return nil
    }
    
    public static func getExtraBody(for modelID: String) -> [String: Any]? {
        if modelID.starts(with: "o1-") || modelID.starts(with: "o3-") {
            return ["reasoning_effort": "medium"]
        }
        return nil
    }
    
    public static func supportsReasoning(_ modelID: String) -> Bool {
        return modelID.starts(with: "o1-") || modelID.starts(with: "o3-")
    }
}
