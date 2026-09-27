/// Las cosas con las que el personaje juega: la hoja que aparece, la bola de
/// papel en que la convierte y la caneca donde la bota.
public enum Utileria {
    public static let hoja = dibujo([
        "kkkkk.",
        "kwwwkk",
        "kllllk",
        "kwwwwk",
        "kllllk",
        "kwwwwk",
        "kkkkkk",
    ])

    /// La hoja doblada a la mitad (camino a ser avión).
    public static let hojaDoblada = dibujo([
        "kkkkk",
        "kwwwk",
        "kwwwk",
        "kkkkk",
    ])

    /// Avión de papel visto de lado, con la punta hacia la derecha.
    public static let avion = dibujo([
        "k......",
        "wwk....",
        "wwwwwkk",
        ".kkkk..",
    ])

    public static let bola = dibujo([
        ".kk.",
        "kwlk",
        "klwk",
        ".kk.",
    ])

    public static let caneca = dibujo([
        ".dddddddd.",
        "dddddddddd",
        ".tttttttt.",
        ".ttdttdtt.",
        ".ttdttdtt.",
        ".ttdttdtt.",
        ".ttdttdtt.",
        ".ttdttdtt.",
        ".ttdttdtt.",
        ".ttdttdtt.",
        "..tttttt..",
        "..dddddd..",
    ])

    /// Banca vista de frente: espaldar arriba, asiento en la fila 4.
    public static let banca = dibujo([
        "hhhhhhhhhhhhhhhhhhhhhhhh",
        "mmmmmmmmmmmmmmmmmmmmmmmm",
        ".m....................m.",
        ".m....................m.",
        "hhhhhhhhhhhhhhhhhhhhhhhh",
        "mmmmmmmmmmmmmmmmmmmmmmmm",
        ".m....................m.",
        ".m....................m.",
        ".m....................m.",
    ])

    /// Cama con la cabecera a la derecha; el colchón arranca en la fila 4.
    public static let cama = dibujo([
        "............................mm",
        "............................mm",
        "............................mm",
        "mm..........................mm",
        "mmwwwwwwwwwwwwwwwwwwwwwwwwwwmm",
        "mmwwwwwwwwwwwwwwwwwwwwwwwwwwmm",
        "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm",
        ".m..........................m.",
        ".m..........................m.",
    ])

    /// La cobija que lo tapa hasta los ojos cuando está acostado.
    public static let manta = dibujo([
        "AAAAAAAAAAAAAAAAAAAAAAAAAA",
        "aaaaaaaaaaaaaaaaaaaaaaaaaa",
        "aaaaaaaaaaaaaaaaaaaaaaaaaa",
        "aaaaaaaaaaaaaaaaaaaaaaaaaa",
        "aaaaaaaaaaaaaaaaaaaaaaaaaa",
    ])

    /// Una golosina para lamer, sostenida junto a la cara. La columna 0–1 es
    /// la lengua (aparece al lamer) y la golosina empieza en la columna 2.
    public enum Golosina: String, Sendable, CaseIterable {
        case paleta, helado, cafe, pizza

        /// Las que se lamen (el café se toma a sorbos).
        public static let dulces: [Golosina] = [.paleta, .helado]

        public func cuadro(lamiendo: Bool) -> Cuadro {
            if self == .pizza {
                // Porción con la punta hacia la boca; al morder se va la punta.
                return dibujo([
                    "....uuh",
                    "..uuiuh",
                    lamiendo ? "..uiuuh" : "uuuiuuh",
                    "..uuuuh",
                    "....uuh",
                ])
            }
            if self == .cafe {
                // Taza roja con franja blanca y vapor que sube; al sorber, el
                // vapor se corre (se la acercó a la boca).
                let vapor = lamiendo ? ["..l.l..", ".l.l..."] : ["...l.l.", "..l.l.."]
                return dibujo(vapor + ["..xmmmx", "..xxxxx", "..xwwwx", "..xxxxx", "...xxx."])
            }
            let (arriba, abajo): ([String], [String]) = switch self {
            // Paleta redonda de espiral, con su palito.
            case .paleta: ([".sss.", "sswws", "swsws", "swwss", ".sss."], ["..w..", "..w..", "..w.."])
            // Bola de fresa sobre un cono de galleta.
            case .helado: ([".sss.", "swsss", "sssss", "sssss", "hhhhh"], [".hhh.", ".hhh.", "..h.."])
            case .cafe, .pizza: ([], []) // se dibujan arriba
            }
            // La lengua toca la golosina a la altura de la fila 3.
            let filas = arriba.enumerated().map { i, f in (lamiendo && i == 3 ? "rr" : "..") + f }
                + abajo.map { ".." + $0 }
            return dibujo(filas)
        }
    }

    // MARK: Cocina

    /// Mesa de cocina; encima van las cosas (su tapa está en la fila 0).
    public static let mesa = dibujo([
        "hhhhhhhhhhhhhhhhhh",
        "mmmmmmmmmmmmmmmmmm",
        ".m..............m.",
        ".m..............m.",
        ".m..............m.",
        ".m..............m.",
        ".m..............m.",
    ])

    /// Horno con ventana; prendido, la ventana brilla.
    public static func horno(prendido: Bool) -> Cuadro {
        let v = prendido ? "f" : "e"
        let adentro = "jE" + String(repeating: v, count: 10) + "Ej"
        let brasa = "jE" + (prendido ? "fnfnffnfnf" : String(repeating: "e", count: 10)) + "Ej"
        return dibujo([
            "jjjjjjjjjjjjjj",
            "jdjdjjjjjjjjjj",
            "jjjjjjjjjjjjjj",
            "jEEEEEEEEEEEEj",
            adentro, adentro, adentro, brasa,
            "jEEEEEEEEEEEEj",
            "jjjjjjjjjjjjjj",
            "jjddddddddddjj",
            "jjjjjjjjjjjjjj",
            ".d..........d.",
        ])
    }

    public static let cuchillo = dibujo(["j", "j", "j", "m", "m"])

    /// La pizza vista de lado, por etapas: 0 masa, 1 salsa, 2 queso,
    /// 3 pepperoni. Horneada, la masa se dora y el queso se tuesta.
    public static func pizza(etapa: Int, horneada: Bool = false) -> Cuadro {
        let arriba = etapa >= 3 ? ".i..i..i.." : ".........."
        let medio = etapa >= 2 ? (horneada ? "uufuuuufuu" : "uuuuuuuuuu") : etapa >= 1 ? "iiiiiiiiii" : ".........."
        return dibujo([arriba, medio, horneada ? "hhhhhhhhhh" : "yyyyyyyyyy"])
    }

    /// Mancuerna para el gym.
    public static let pesa = dibujo([
        "dd...dd",
        "ddddddd",
        "dd...dd",
    ])

    /// La laptop negra vista desde atrás (se ve la tapa). Tecleando, el
    /// brillo verde de la pantalla y las teclas titilan.
    public static func laptop(tecleando: Bool) -> Cuadro {
        dibujo([
            tecleando ? ".q..q...q..q" : "..q..q..q...",
            "EEEEEEEEEEEE",
            "EeeeeeeeeeeE",
            "EeeeekkeeeeE",
            "EeeeekkeeeeE",
            "EeeeeeeeeeeE",
            "EEEEEEEEEEEE",
            tecleando ? "EkEEkEkEEkEE" : "EEkEEEkEkEEk",
        ])
    }

    /// El libro visto desde el frente (se ve la tapa). `hojeando` asoma las páginas.
    public static func libro(hojeando: Bool) -> Cuadro {
        dibujo([
            hojeando ? "wwwwwwwwww" : "xxxxxxxxxx",
            "xxxxxxxxxx",
            "xxwwwwwwxx",
            "xxxxxxxxxx",
            "xxxxxxxxxx",
            "xxxxxxxxxx",
        ])
    }

    static func dibujo(_ filas: [String]) -> Cuadro {
        Cuadro(pixeles: filas.map { $0.map { $0 == "." ? nil : Tinta(rawValue: $0) } })
    }
}
