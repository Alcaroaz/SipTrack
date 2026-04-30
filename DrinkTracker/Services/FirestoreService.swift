import Foundation
import FirebaseFirestore
import UIKit

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {
        createImageDirectoryIfNeeded()
    }

    // MARK: - Local Image Storage

    private var imageDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("drink_images")
    }

    private func createImageDirectoryIfNeeded() {
        let fm = FileManager.default
        if !fm.fileExists(atPath: imageDirectory.path) {
            try? fm.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
        }
    }

    func saveImageLocally(_ image: UIImage, drinkId: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.6) else { return nil }
        let fileName = "\(drinkId).jpg"
        let fileURL = imageDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }

    func deleteLocalImage(drinkId: String) {
        let fileURL = imageDirectory.appendingPathComponent("\(drinkId).jpg")
        try? FileManager.default.removeItem(at: fileURL)
    }

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
}
