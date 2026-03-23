import Vapor

struct HealthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let health = routes.grouped("api", "health")
        health.get(use: getHealth)
    }
    
    func getHealth(req: Request) async throws -> HealthResponse {
        return HealthResponse(
            status: "ok",
            version: "1.0.0",
            timestamp: Date()
        )
    }
}
