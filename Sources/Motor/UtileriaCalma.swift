/// Utilería de las rutinas de calma: la matica que crece con los días de uso,
/// la regadera y las gotas.
public extension Utileria {
    // MARK: La matica

    /// Las etapas de la matica, según cuántos días se ha usado la app.
    enum EtapaMatica: Int, Sendable, CaseIterable {
        case semilla, brote, plantita, conHojas, conBoton, florecida

        public init(dias: Int) {
            self = switch dias {
            case ..<2: .semilla
            case 2...3: .brote
            case 4...7: .plantita
            case 8...14: .conHojas
            case 15...29: .conBoton
            default: .florecida
            }
        }
    }

    /// La matica en su maceta de barro. Todas las etapas tienen el mismo
    /// ancho (11) y la maceta abajo, así crece hacia arriba sin moverse.
    static func matica(_ etapa: EtapaMatica) -> Cuadro {
        let planta: [String] = switch etapa {
        case .semilla: [
            // Desde el día 1 asoma un brotecito, para que se lea como planta
            // y no como una maceta olvidada.
            "....G.G....",
            ".....G.....",
            "....TqT....",
        ]
        case .brote: [
            "...GG.GG...",
            "....GqG....",
            ".....q.....",
        ]
        case .plantita: [
            "....GGG....",
            ".....q.....",
            "..GGGq.....",
            ".....qGGG..",
            ".....q.....",
            ".....q.....",
        ]
        case .conHojas: [
            "....GGG....",
            "...GGqGG...",
            ".....q.....",
            ".GGGGq.....",
            "..GG.qGGGG.",
            ".....q.GG..",
            "..GGGq.....",
            ".GG..q.....",
            ".....q.....",
        ]
        case .conBoton: [
            ".....s.....",
            "....sss....",
            "....GsG....",
            ".....q.....",
            ".GGGGq.....",
            "..GG.qGGGG.",
            ".....q.GG..",
            "..GGGq.....",
            ".GG..q.....",
            ".....q.....",
        ]
        case .florecida: [
            "....sss....",
            "...ssuss...",
            "..ssuuuss..",
            "...ssuss...",
            "....sGs....",
            ".....q.....",
            ".GGGGq.....",
            "..GG.qGGGG.",
            "s....q.GG..",
            "uGGGGq.....",
            ".GG..q.....",
            ".....q.....",
        ]
        }
        return dibujo(planta + maceta)
    }

    /// Maceta de barro con la tierra asomando.
    private static let maceta = [
        "mTTTTTTTTTm",
        "mmmmmmmmmmm",
        ".hhhhhhhhh.",
        ".hhhhhhhhh.",
        ".hhhhhhhhh.",
        "..hhhhhhh..",
    ]

    // MARK: Regar

    /// Regadera roja de lado, con el pico hacia la derecha. Inclinada, el
    /// pico apunta hacia abajo (regando).
    static func regadera(inclinada: Bool) -> Cuadro {
        inclinada
            ? dibujo([
                ".xx.......",
                "x..x......",
                "x.xxxx....",
                ".xxxxxxx..",
                "..xxxxxxx.",
                "...xxxx.x.",
                "....xx...x",
            ])
            : dibujo([
                "..xxx.....",
                ".x...x...x",
                "xxxxxxx.x.",
                "xxxxxxxx..",
                "xxxxxxx...",
                ".xxxxx....",
            ])
    }

    /// Una gota de agua cayendo.
    static let gota = dibujo(["W", "W"])

    /// El charquito de la tierra mojada (encima de la tierra de la maceta).
    static let tierraMojada = dibujo(["WTWTWTW"])
}
