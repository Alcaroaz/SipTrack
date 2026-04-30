import SwiftUI

enum DrinkCategory: String, Codable, CaseIterable, Identifiable {
    case cubata
    case chupito
    case bajaGraduacion

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cubata: return "CUBATAS"
        case .chupito: return "CHUPITOS"
        case .bajaGraduacion: return "BAJA º"
        }
    }

    var color: Color {
        switch self {
        case .cubata: return .red
        case .chupito: return .blue
        case .bajaGraduacion: return .yellow
        }
    }

    var firestoreCollection: String {
        switch self {
        case .cubata: return "cubatas"
        case .chupito: return "chupitos"
        case .bajaGraduacion: return "baja_graduacion"
        }
    }
}
