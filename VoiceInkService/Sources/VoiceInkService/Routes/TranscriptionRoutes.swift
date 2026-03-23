import Vapor
import Foundation

struct TranscriptionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        
        api.post("transcribe", use: transcribe)
        api.get("models", use: listModels)
    }
    
    func transcribe(req: Request) async throws -> TranscriptionResponse {
        let coreBridge = req.coreBridge
        
        // Try to get audio data from multipart form or raw body
        let audioData: Data
        if let contentType = req.headers.contentType,
           contentType.type == "multipart" {
            // Handle multipart form data
            let formData = try req.content.decode(TranscriptionRequest.self)
            guard let data = formData.audioData else {
                throw Abort(.badRequest, reason: "No audio data provided")
            }
            audioData = data
        } else {
            // Handle raw body
            guard let bodyData = req.body.data else {
                throw Abort(.badRequest, reason: "No audio data provided")
            }
            audioData = Data(buffer: bodyData)
        }
        
        let request = try req.content.decode(TranscriptionRequest.self)
        let language = request.language
        let model = request.model ?? "whisper-default"
        
        // Call VoiceInkCore transcription service
        let startTime = Date()
        let result = try await coreBridge.transcribe(
            audioData: audioData,
            language: language,
            model: model
        )
        let duration = Date().timeIntervalSince(startTime)
        
        return TranscriptionResponse(
            text: result.text,
            language: result.language,
            duration: duration,
            model: model
        )
    }
    
    func listModels(req: Request) async throws -> ModelsListResponse {
        let coreBridge = req.coreBridge
        let models = try await coreBridge.getAvailableModels()
        
        return ModelsListResponse(models: models)
    }
}
