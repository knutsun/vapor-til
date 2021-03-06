import Vapor
import FluentPostgreSQL

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID //adding reference to user who owns the model instance
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym: PostgreSQLModel {}
extension Acronym: Content {}
extension Acronym: Parameter {} //type safety for parameters

extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
}
extension Acronym: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
