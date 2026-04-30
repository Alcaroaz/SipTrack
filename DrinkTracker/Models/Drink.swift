import Foundation
import FirebaseFirestore

struct Drink: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var category: DrinkCategory
    var imageFileName: String?
    var isFavorite: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case imageFileName
        case isFavorite
    }

    var localImagePath: String? {
        guard let fileName = imageFileName else { return nil }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("drink_images/\(fileName)").path
    }

    static func == (lhs: Drink, rhs: Drink) -> Bool {
        lhs.id == rhs.id
    }
}
