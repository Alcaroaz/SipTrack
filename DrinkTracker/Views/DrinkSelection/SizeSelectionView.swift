import SwiftUI

struct SizeSelectionView: View {
    let drink: Drink
    let onSelect: (DrinkSize) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 4) {
                Text(drink.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Selecciona el tamaño")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)

            // Size buttons
            VStack(spacing: 12) {
                ForEach(DrinkSize.allCases) { size in
                    Button(action: { onSelect(size) }) {
                        HStack {
                            Image(systemName: iconFor(size))
                                .font(.title3)

                            Text(size.rawValue.uppercased())
                                .fontWeight(.semibold)

                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(drink.category.color, lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(drink.category.color.opacity(0.08))
                                )
                        )
                        .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func iconFor(_ size: DrinkSize) -> String {
        switch size {
        case .grande: return "cup.and.saucer.fill"
        case .normal: return "cup.and.saucer"
        case .pequeno: return "drop.fill"
        }
    }
}

#Preview {
    SizeSelectionView(
        drink: Drink(name: "Gin Tonic", category: .cubata, imageURL: nil, isFavorite: false),
        onSelect: { _ in }
    )
}
