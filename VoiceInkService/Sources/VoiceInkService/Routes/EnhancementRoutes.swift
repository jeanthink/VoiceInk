import Vapor
import Foundation

struct EnhancementController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        
        api.post("enhance", use: enhance)
        api.get("prompts", use: listPrompts)
    }
    
    func enhance(req: Request) async throws -> EnhancementResponse {
        let coreBridge = req.coreBridge
        let request = try req.content.decode(EnhancementRequest.self)
        
        // Validate required fields
        guard !request.text.isEmpty else {
            throw Abort(.badRequest, reason: "Text is required")
        }
        
        guard !request.model.isEmpty else {
            throw Abort(.badRequest, reason: "Model is required")
        }
        
        // Call VoiceInkCore enhancement service
        let result = try await coreBridge.enhance(
            text: request.text,
            promptId: request.promptId,
            systemPrompt: request.systemPrompt,
            model: request.model,
            temperature: request.temperature,
            maxTokens: request.maxTokens
        )
        
        return EnhancementResponse(
            originalText: request.text,
            enhancedText: result.enhancedText,
            model: request.model,
            promptUsed: result.promptUsed,
            tokensUsed: result.tokensUsed
        )
    }
    
    func listPrompts(req: Request) async throws -> PromptsListResponse {
        let coreBridge = req.coreBridge
        let prompts = try await coreBridge.getAvailablePrompts()
        
        return PromptsListResponse(prompts: prompts)
    }
}
