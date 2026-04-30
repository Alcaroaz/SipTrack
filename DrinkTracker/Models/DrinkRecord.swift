import Foundation
import FirebaseFirestore

enum DrinkSize: String, Codable, CaseIterable, Identifiable {
    case grande = "Grande"
    case normal = "Normal"
    case pequeno = "Pequeño"

    var id: String { rawValue }
}

struct DrinkRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var drinkId: String
    var drinkName: String
    var category: DrinkCategory
    var size: DrinkSize
    var timestamp: Date
    var imageURL: String?

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: timestamp)
    }
}
