import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    // MARK: - Drinks

    func fetchDrinks(for category: DrinkCategory) async throws -> [Drink] {
        let snapshot = try await db.collection("drinks")
            .whereField("category", isEqualTo: category.rawValue)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Drink.self)
        }
        .sorted { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite {
                return lhs.isFavorite
            }
            return lhs.name < rhs.name
        }
    }

    func addDrink(_ drink: Drink) async throws -> String {
        let ref = try db.collection("drinks").addDocument(from: drink)
        return ref.documentID
    }

    func updateDrink(_ drink: Drink) async throws {
        guard let id = drink.id else { return }
        try db.collection("drinks").document(id).setData(from: drink)
    }

    func deleteDrink(_ drink: Drink) async throws {
        guard let id = drink.id else { return }
        try await db.collection("drinks").document(id).delete()
    }

    func toggleFavorite(_ drink: Drink) async throws {
        guard let id = drink.id else { return }
        try await db.collection("drinks").document(id).updateData([
            "isFavorite": !drink.isFavorite
        ])
    }

    // MARK: - Drink Records

    func addRecord(_ record: DrinkRecord) async throws {
        try db.collection("records").addDocument(from: record)
    }

    func fetchRecords(for date: Date) async throws -> [DrinkRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let snapshot = try await db.collection("records")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("timestamp", isLessThan: Timestamp(date: endOfDay))
            .order(by: "timestamp", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: DrinkRecord.self)
        }
    }

    func fetchRecords(from startDate: Date, to endDate: Date) async throws -> [DrinkRecord] {
        let snapshot = try await db.collection("records")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("timestamp", isLessThan: Timestamp(date: endDate))
            .order(by: "timestamp", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: DrinkRecord.self)
        }
    }

    func deleteRecord(_ record: DrinkRecord) async throws {
        guard let id = record.id else { return }
        try await db.collection("records").document(id).delete()
    }

    func updateRecord(_ record: DrinkRecord) async throws {
        guard let id = record.id else { return }
        try db.collection("records").document(id).setData(from: record)
    }

    // MARK: - Image Upload

    func uploadImage(_ image: UIImage, drinkId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "FirestoreService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No se pudo comprimir la imagen"])
        }

        let ref = storage.reference().child("drink_images/\(drinkId).jpg")
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    func deleteImage(drinkId: String) async throws {
        let ref = storage.reference().child("drink_images/\(drinkId).jpg")
        try await ref.delete()
    }
}
