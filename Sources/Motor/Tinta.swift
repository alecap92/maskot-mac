import CoreGraphics

/// Los colores. Cada tinta tiene una letra para poder dibujar los sprites como
/// texto. `rgb` es el color por defecto; cada personaje puede cambiar los
/// suyos con `Personaje.paleta` (p. ej. el del cuerpo).
public enum Tinta: Character, Sendable, CaseIterable {
    case cuerpo = "c"
    case ojo = "o"
    case cachete = "r"
    case gorra = "g"
    case visera = "v"
    case correa = "b"
    case chispaRosa = "s"
    case chispaNaranja = "n"
    case zeta = "z"
    case punto = "p"
    case papel = "w"
    case renglon = "l"
    case borde = "k"
    case caneca = "t"
    case canecaOscura = "d"
    case madera = "m"
    case maderaClara = "h"
    case manta = "a"
    case mantaOscura = "A"
    case tapa = "x"
    case codigo = "q"
    case laptop = "e"
    case laptopBorde = "E"

    // Cocina.
    case masa = "y"
    case queso = "u"
    case salsa = "i"
    case fuego = "f"
    case metal = "j"
    case mago = "P"
    case planta = "G"
    case tierra = "T"
    case agua = "W"

    // Colores genéricos para personajes: cada uno los ajusta con su `paleta`.
    // Los valores por defecto son la paleta madre de la familia Koru.
    case contorno = "O"
    case crema = "C"
    case detalle1 = "1"
    case detalle2 = "2"
    case detalle3 = "3"
    case detalle4 = "4"
    case brillo = "5"

    public var rgb: UInt32 {
        switch self {
        case .cuerpo: 0xD97757
        case .ojo: 0x141414
        case .cachete: 0xF28E9B
        case .gorra: 0x2B4C7E
        case .visera: 0x1C3456
        case .correa: 0x5B7FB5
        case .chispaRosa: 0xF2A0B5
        case .chispaNaranja: 0xF4A261
        case .zeta, .punto: 0x8A94A6
        case .papel: 0xF7F5EE
        case .renglon: 0xB9C3D3
        case .borde: 0x7D8696
        case .caneca: 0x8C95A5
        case .canecaOscura: 0x5A6272
        case .madera: 0x8B5A3C
        case .maderaClara: 0xB07A52
        case .manta: 0x7FA7D9
        case .mantaOscura: 0x5E88BF
        case .tapa: 0xC0443B
        case .codigo: 0x3FB950
        case .laptop: 0x2A2A2F
        case .laptopBorde: 0x0E0E10
        case .masa: 0xE8C27A
        case .queso: 0xFFD34E
        case .salsa: 0xD2462F
        case .fuego: 0xFF8A1F
        case .metal: 0xC9CED6
        case .mago: 0x5B3FA0
        case .planta: 0x5DBB63
        case .tierra: 0x6B4A2E
        case .agua: 0x5AB0F0
        case .contorno: 0x163A63
        case .crema: 0xF7F2E8
        case .detalle1: 0x77BCE8
        case .detalle2: 0xCFE8F7
        case .detalle3: 0xF5D338
        case .detalle4: 0xA98AE8
        case .brillo: 0xFFFFFF
        }
    }

    public var cgColor: CGColor { Tinta.cgColor(rgb) }

    public static func cgColor(_ rgb: UInt32) -> CGColor {
        CGColor(
            srgbRed: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
