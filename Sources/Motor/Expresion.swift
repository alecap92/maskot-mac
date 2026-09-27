/// Lo que siente el personaje. El cuerpo casi no cambia: la emoción la cargan
/// los ojos, los cachetes y el efecto que flota alrededor.
public enum Expresion: String, Sendable, CaseIterable {
    case neutro, parpadeo, feliz, guino, celebrando, sorprendido, pensando, dormido, gafas, leyendo, nerd

    public var nombre: String {
        switch self {
        case .neutro: "Neutro"
        case .parpadeo: "Parpadeo"
        case .feliz: "Feliz"
        case .guino: "Guiño"
        case .celebrando: "Celebrando"
        case .sorprendido: "Sorprendido"
        case .pensando: "Pensando"
        case .dormido: "Dormido"
        case .gafas: "Gafas"
        case .leyendo: "Leyendo"
        case .nerd: "Nerd"
        }
    }

    var efecto: Efecto? {
        switch self {
        case .celebrando: .chispas
        case .dormido: .zetas
        case .pensando: .puntos
        default: nil
        }
    }
}

/// Cómo lleva el accesorio de la cabeza (si el personaje tiene uno).
/// Por defecto hacia atrás; a veces de lado.
public enum Gorra: String, Sendable, CaseIterable {
    case haciaAtras, deLado

    public var nombre: String {
        switch self {
        case .haciaAtras: "Gorra hacia atrás"
        case .deLado: "Gorra de lado"
        }
    }
}

enum Efecto {
    case chispas, zetas, puntos
}
