import Motor

/// Nilo, la tortuga confiable de la familia Koru — ver `characters/FAMILIA.md`.
/// Vista de tres cuartos como en la referencia: el caparazón teal atrás a la
/// izquierda y la cabeza redonda adelante a la derecha, sobre patas cortas.
struct Nilo: Personaje {
    let id = "nilo"
    let nombre = "Nilo"
    /// Con contorno: un poco más grande para verse del tamaño de Clawd.
    let escala = 1.2
    let paleta: [Tinta: UInt32] = [
        .cuerpo: 0xA8DB55,     // piel verde lima
        .contorno: 0x163A63,   // azul marino de la familia
        .crema: 0xF6ECD7,      // panza
        .detalle1: 0x249CB8,   // caparazón teal
        .detalle2: 0x6CCFE0,   // placas claras del caparazón
        .detalle3: 0x17728C,   // borde oscuro del caparazón
        .detalle4: 0x86BD3C,   // sombra de la piel
    ]

    /// Caparazón en las columnas 0–5, cabeza en las 5–14 (filas 5–12), panza
    /// crema en la 13 y dos patas (columnas 1–4 y 11–14) en las filas 13–15.
    let cuerpo = [
        "................",
        "................",
        "....OOOO........",
        "...O2222O.......",
        "..O221111O......",
        ".O21311OOOOOO...",
        "O21311OccccccO..",
        "O3331OccccccccO.",
        "O1131OccccccccO.",
        "O1131OccccccccO.",
        "O3333OccccccccO.",
        "O1131OccccccccO.",
        "O33333OccccccO..",
        ".OccOCCCCCCOccO.",
        ".OccOOOOOOOOccO.",
        ".OOOO......OOOO.",
    ]

    /// La cara vive en las columnas 6–13, filas 6–10: cada expresión redibuja
    /// esa zona completa (5 filas de 8 letras).
    private func zona(_ filas: [String]) -> [Int: String] {
        var salida: [Int: String] = [:]
        for (i, f) in filas.enumerated() { salida[7 + i] = "......" + f + ".." }
        return salida
    }

    func cara(_ expresion: Expresion) -> [Int: String]? {
        switch expresion {
        case .neutro:
            zona(["cccccccc",
                  "c5occ5oc",
                  "cooccooc",
                  "ccOccOcc",
                  "cccOOccc"])
        case .parpadeo:
            zona(["cccccccc",
                  "cccccccc",
                  "cooccooc",
                  "ccOccOcc",
                  "cccOOccc"])
        case .feliz:
            zona(["cccccccc",
                  "coccccoc",
                  "ococcoco",
                  "ccOccOcc",
                  "cccOOccc"])
        case .guino:
            zona(["cccccccc",
                  "c5occccc",
                  "cooccooc",
                  "ccOccOcc",
                  "cccOOccc"])
        case .celebrando:
            zona(["cccccccc",
                  "c5occ5oc",
                  "cooccooc",
                  "rcOccOcr",
                  "cccOOccc"])
        case .sorprendido:
            zona(["5oocc5oo",
                  "oooccooo",
                  "oooccooo",
                  "cccOOccc",
                  "cccOOccc"])
        case .pensando:
            zona(["cc5occ5o",
                  "ccooccoo",
                  "cccccccc",
                  "cccccccc",
                  "ccccOOcc"])
        case .dormido:
            zona(["cccccccc",
                  "ococcoco",
                  "coccccoc",
                  "cccccccc",
                  "cccOOccc"])
        case .gafas:
            zona(["cccccccc",
                  "oooooooo",
                  "oooccooo",
                  "cooccooc",
                  "cccOOOcc"])
        case .leyendo:
            zona(["cccccccc",
                  "cccccccc",
                  "cooccooc",
                  "cooccooc",
                  "cccOOccc"])
        case .nerd:
            zona(["oooooooo",
                  "o55oo55o",
                  "o5ooo5oo",
                  "oooooooo",
                  "cccOOccc"])
        }
    }

    let brazos = Brazos(
        // La pata delantera se despega del piso y sube por el lado de la
        // cabeza, con su contorno; la punta queda en las columnas 15–16, filas 7–8.
        arriba: Cambio(
            quita: [(14, 11), (14, 12), (14, 13), (14, 14), (15, 11), (15, 12), (15, 13), (15, 14)],
            pone: [(13, 14), (13, 15), (12, 15), (11, 15), (10, 15), (9, 15), (8, 15), (8, 16), (7, 15), (7, 16)],
            pinta: [
                (6, 15, .contorno), (6, 16, .contorno), (7, 17, .contorno), (8, 17, .contorno),
                (9, 16, .contorno), (10, 16, .contorno), (11, 16, .contorno), (12, 16, .contorno),
                (13, 16, .contorno), (12, 14, .contorno),
                (14, 11, .contorno), (14, 12, .contorno), (14, 13, .contorno), (14, 14, .contorno), (14, 15, .contorno),
            ]
        ),
        // Tecleando, la pata se levanta un píxel del piso (con su planta).
        teclearArriba: Cambio(
            quita: [(15, 11), (15, 12), (15, 13), (15, 14)],
            pone: [],
            pinta: [(14, 12, .contorno), (14, 13, .contorno)]
        ),
        teclearAbajo: Cambio(quita: [], pone: []),
        mano: (col: 16, fila: 6),
        manoAbajo: (col: 15.5, fila: 14.5)
    )

    /// La boca está en la fila 11 (sonrisa en las columnas 9–10); lo que
    /// sostiene junto a la cara sale por el borde derecho de la cabeza.
    let boca = (col: 13, fila: 11)
    /// La cabeza empieza en la fila 5 (el domo del caparazón sube más, atrás).
    let cabeza = 5

    let patas = Patas(fila: 15, paso1: [1, 2, 3, 4], paso2: [11, 12, 13, 14])
}
