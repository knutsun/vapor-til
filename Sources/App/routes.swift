import Vapor
import Fluent

/// register routes
public func routes(_ router: Router) throws {
    
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)
}
