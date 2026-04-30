import Foundation
import FirebaseFirestore

struct Drink: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var category: DrinkCategory
    var imageURL: String?
    var isFavorite: Bool

    var localImagePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case imageURL
        case isFavorite
        case localImagePath
    }

    static func == (lhs: Drink, rhs: Drink) -> Bool {
        lhs.id == rhs.id
    }
}
