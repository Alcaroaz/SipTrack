import SwiftUI

struct DrinkCardView: View {
    let drink: Drink
    let isEditing: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                // Drink image from local storage
                if let path = drink.localImagePath,
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 130)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    placeholderImage
                        .frame(height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Drink name
                HStack(spacing: 4) {
                    Text(drink.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    if drink.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            // Edit mode buttons
            if isEditing {
                HStack(spacing: 6) {
                    Button(action: onFavorite) {
                        Image(systemName: drink.isFavorite ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.red.opacity(0.8)))
                    }

                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.gray.opacity(0.8)))
                    }
                }
                .padding(4)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        )
    }

    private var placeholderImage: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "wineglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DrinkCardView(
        drink: Drink(name: "Gin Tonic", category: .cubata, imageFileName: nil, isFavorite: true),
        isEditing: true,
        onTap: {},
        onFavorite: {},
        onDelete: {}
    )
    .frame(width: 170)
    .padding()
}
