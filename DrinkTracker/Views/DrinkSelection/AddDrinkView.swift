import SwiftUI

struct AddDrinkView: View {
    let category: DrinkCategory
    var onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedImage: UIImage?
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Image preview / selector
                Button(action: { showImageSourcePicker = true }) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)

                            Text("Añadir foto")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 180, height: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemGray6))
                                .strokeBorder(Color(.systemGray4), style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                    }
                }

                // Name field
                TextField("Nombre de la bebida", text: $name)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 32)

                Spacer()

                // Save button
                Button(action: saveDrink) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("GUARDAR")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(name.isEmpty ? Color.gray : category.color)
                )
                .foregroundColor(.white)
                .disabled(name.isEmpty || isSaving)
                .padding(.horizontal, 32)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)
            .navigationTitle("Nueva bebida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .confirmationDialog("Seleccionar foto", isPresented: $showImageSourcePicker) {
                Button("Cámara") { showCamera = true }
                Button("Galería") { showGallery = true }
                Button("Cancelar", role: .cancel) {}
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showGallery) {
                PhotoLibraryPicker(image: $selectedImage)
                    .ignoresSafeArea()
            }
        }
    }

    private func saveDrink() {
        guard !name.isEmpty else { return }
        isSaving = true

        let vm = DrinksViewModel(category: category)
        Task {
            await vm.addDrink(name: name, image: selectedImage)
            onSave()
            dismiss()
        }
    }
}

#Preview {
    AddDrinkView(category: .cubata, onSave: {})
}
