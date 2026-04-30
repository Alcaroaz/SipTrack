import Foundation
import SwiftUI

@MainActor
class DrinksViewModel: ObservableObject {
    @Published var drinks: [Drink] = []
    @Published var isLoading = false
    @Published var isEditing = false
    @Published var errorMessage: String?

    private let service = FirestoreService.shared
    let category: DrinkCategory

    init(category: DrinkCategory) {
        self.category = category
    }

    func loadDrinks() async {
        isLoading = true
        errorMessage = nil
        do {
            drinks = try await service.fetchDrinks(for: category)
        } catch {
            errorMessage = "Error al cargar bebidas: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func addDrink(name: String, image: UIImage?) async {
        var drink = Drink(
            name: name,
            category: category,
            imageURL: nil,
            isFavorite: false
        )

        do {
            let drinkId = try await service.addDrink(drink)

            if let image = image {
                if let localPath = service.saveImageLocally(image, drinkId: drinkId) {
                    drink.id = drinkId
                    drink.localImagePath = localPath
                    try await service.updateDrink(drink)
                }
            }

            await loadDrinks()
        } catch {
            errorMessage = "Error al añadir bebida: \(error.localizedDescription)"
        }
    }

    func deleteDrink(_ drink: Drink) async {
        do {
            if let id = drink.id {
                service.deleteLocalImage(drinkId: id)
            }
            try await service.deleteDrink(drink)
            await loadDrinks()
        } catch {
            errorMessage = "Error al eliminar bebida: \(error.localizedDescription)"
        }
    }

    func toggleFavorite(_ drink: Drink) async {
        do {
            try await service.toggleFavorite(drink)
            await loadDrinks()
        } catch {
            errorMessage = "Error al actualizar favorito: \(error.localizedDescription)"
        }
    }

    func recordDrink(_ drink: Drink, size: DrinkSize) async {
        let record = DrinkRecord(
            drinkId: drink.id ?? "",
            drinkName: drink.name,
            category: category,
            size: size,
            timestamp: Date(),
            imageURL: drink.localImagePath
        )

        do {
            try await service.addRecord(record)
        } catch {
            errorMessage = "Error al registrar consumición: \(error.localizedDescription)"
        }
    }
}
