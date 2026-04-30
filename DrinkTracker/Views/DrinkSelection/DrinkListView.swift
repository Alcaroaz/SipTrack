import SwiftUI
import Combine

struct DrinkListView: View {
    let category: DrinkCategory
    @StateObject private var viewModel: DrinksViewModel
    @State private var showAddDrink = false
    @State private var selectedDrink: Drink?
    @State private var showSizeSelection = false

    init(category: DrinkCategory) {
        self.category = category
        self._viewModel = StateObject(wrappedValue: DrinksViewModel(category: category))
    }

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Cargando...")
                    .padding(.top, 40)
            } else if viewModel.drinks.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.drinks) { drink in
                        DrinkCardView(
                            drink: drink,
                            isEditing: viewModel.isEditing,
                            onTap: {
                                if viewModel.isEditing { return }
                                selectedDrink = drink
                                showSizeSelection = true
                            },
                            onFavorite: {
                                Task { await viewModel.toggleFavorite(drink) }
                            },
                            onDelete: {
                                Task { await viewModel.deleteDrink(drink) }
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle(category.displayName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { viewModel.isEditing.toggle() }) {
                        Text(viewModel.isEditing ? "Listo" : "Editar")
                            .fontWeight(.medium)
                    }

                    Button(action: { showAddDrink = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddDrink) {
            AddDrinkView(category: category) {
                Task { await viewModel.loadDrinks() }
            }
        }
        .sheet(isPresented: $showSizeSelection) {
            if let drink = selectedDrink {
                SizeSelectionView(drink: drink) { size in
                    Task {
                        await viewModel.recordDrink(drink, size: size)
                        showSizeSelection = false
                        selectedDrink = nil
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .task {
            await viewModel.loadDrinks()
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "wineglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No tienes bebidas")
                .font(.title3)
                .fontWeight(.medium)

            Text("Pulsa + para añadir tu primera bebida")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 60)
    }
}

#Preview {
    NavigationStack {
        DrinkListView(category: .cubata)
    }
}
