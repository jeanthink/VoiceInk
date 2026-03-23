import Foundation

public struct OpenAICompatibleBackend: AIBackend {
    public let baseURL: String
    public let apiKey: String
    public let model: String
    public let provider: AIProvider
    
    public init(baseURL: String, apiKey: String, model: String, provider: AIProvider) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.model = model
        self.provider = provider
    }
    
    public func enhance(text: String, systemPrompt: String?, temperature: Double) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var messages: [[String: String]] = []
        
        if let systemPrompt = systemPrompt {
            messages.append([
                "role": "system",
                "content": systemPrompt
            ])
        }
        
        messages.append([
            "role": "user",
            "content": text
        ])
        
        var body: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": temperature
        ]
        
        // Add reasoning effort for supported models
        if let extraBody = ReasoningConfig.getExtraBody(for: model) {
            body.merge(extraBody) { (_, new) in new }
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw AIError.invalidAPIKey
            } else if httpResponse.statusCode == 429 {
                throw AIError.rateLimitExceeded
            }
            throw AIError.providerError("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return content
    }
}
