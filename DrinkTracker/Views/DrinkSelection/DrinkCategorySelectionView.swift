import SwiftUI

struct DrinkCategorySelectionView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                ForEach(DrinkCategory.allCases) { category in
                    NavigationLink(destination: DrinkListView(category: category)) {
                        Text(category.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(category.color)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(category.color, lineWidth: 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(category.color.opacity(0.08))
                                    )
                            )
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Registrar")
        }
    }
}

#Preview {
    DrinkCategorySelectionView()
}
