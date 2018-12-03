import Vapor
import Fluent

/// register routes
public func routes(_ router: Router) throws {

    // adds a model instance to the database
    router.post("api", "acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                return acronym.save(on: req)
        }
    }
    
    // returns all model instances
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    
    // returns one model instance with ID as the final path parameter
    // e.g. /api/acronyms/<ID>
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    // updates a model instance with ID as the final path parameter
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self,
                            req.parameters.next(Acronym.self),
                            req.content.decode(Acronym.self)) {
                                acronym, updatedAcronym in
                                acronym.short = updatedAcronym.short
                                acronym.long = updatedAcronym.long
            
            return acronym.save(on: req)
        }
    }
    
    // deletes a model instance with ID as the final path parameter
    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    // searches model instances at /api/acronyms/search
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        guard
        let searchTerm = req.query[String.self, at: "term"]
            else {
                throw Abort(.badRequest)
            }
        // returns matches of the short
//        return Acronym.query(on: req)
//            .filter(\.short == searchTerm)
//            .all()
        
        // returns matches of short or long
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
    
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym
                
                    else {
                        throw Abort(.notFound)
                    }
                return acronym
            }
    }
    
    //returns model instances sorted by 'short' in ascending order
    router.get("api", "acronyms", "sorted") {
        req -> Future<[Acronym]> in
        return Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
}
