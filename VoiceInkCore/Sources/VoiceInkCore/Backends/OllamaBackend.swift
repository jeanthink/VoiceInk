import Foundation

public protocol AIBackend {
    func enhance(text: String, systemPrompt: String?, temperature: Double) async throws -> String
}

public struct OllamaBackend: AIBackend {
    public let baseURL: String
    public let model: String
    
    public init(baseURL: String, model: String) {
        self.baseURL = baseURL
        self.model = model
    }
    
    public func enhance(text: String, systemPrompt: String?, temperature: Double) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "model": model,
            "prompt": text,
            "stream": false,
            "options": [
                "temperature": temperature
            ]
        ]
        
        if let systemPrompt = systemPrompt {
            body["system"] = systemPrompt
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIError.providerError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseText = json["response"] as? String else {
            throw AIError.invalidResponse
        }
        
        return responseText
    }
}
