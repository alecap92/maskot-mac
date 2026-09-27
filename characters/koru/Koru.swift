import Motor

/// Koru, el curioso: cangrejo de la familia Koru — ver `characters/FAMILIA.md`.
/// Cuerpo ancho de bloque, dos pinzas gruesas en "C" (la mandíbula de arriba
/// suelta, la de abajo pegada al cuerpo) con puntas azul claro, cuatro patitas
/// y contorno azul marino.
struct Koru: Personaje {
    let id = "koru"
    let nombre = "Koru"
    /// Con contorno: un poco más grande para verse del tamaño de Clawd.
    let escala = 1.2
    let paleta: [Tinta: UInt32] = [
        .cuerpo: 0xF26A2E,     // terracota
        .detalle1: 0x77BCE8,   // azul claro: puntas de las pinzas
        .detalle2: 0xD2521C,   // terracota en sombra
        .detalle3: 0xFF9C66,   // terracota con luz
    ]

    /// Filas 0…2 libres. Pinzas en las columnas 0–3 y 12–15 (filas 3–10),
    /// cuerpo en las columnas 2–13 (filas 3–13), patas en 2, 5, 10 y 13.
    let cuerpo = [
        "................",
        "................",
        "................",
        ".OO.OOOOOOOO.OO.",
        "O1cO33ccccccOc1O",
        "OOcO3cccccccOcOO",
        "..OOccccccccOO..",
        "OOccccccccccccOO",
        "O1cccccccccccc1O",
        "OccccccccccccccO",
        ".OOccccccccccOO.",
        "..OccccccccccO..",
        "..O2222222222O..",
        "...OOOOOOOOOO...",
        "...O.O....O.O...",
        "..O..O....O..O..",
    ]

    let cabeza = 3
    /// La golosina va pegada al costado de la cara (con la pinza en alto).
    let boca = (col: 13, fila: 9)

    // MARK: Cara

    /// Las caras se dibujan como si los ojos fueran en las filas 0–1 y la boca
    /// en la 3; `con` las baja a su sitio (ojos 6–7, boca 9) sobre la cara limpia.
    private static let arriba = 6
    private let ojos: [Int: String] = [
        0: ".....5o..5o.....",
        1: ".....oo..oo.....",
    ]
    private let sonrisa: [Int: String] = [3: ".......OO......."]

    private func con(_ capas: [Int: String]...) -> [Int: String] {
        // La zona de la cara (filas 5–9, columnas 4–11) queda en color cuerpo.
        var salida: [Int: String] = [:]
        for fila in 5...9 { salida[fila] = "....cccccccc...." }
        for capa in capas {
            for (f, linea) in capa {
                let fila = f + Koru.arriba
                let base = Array(salida[fila] ?? "................")
                let nueva = Array(linea)
                salida[fila] = String((0..<16).map { nueva[$0] == "." ? base[$0] : nueva[$0] })
            }
        }
        return salida
    }

    func cara(_ expresion: Expresion) -> [Int: String]? {
        switch expresion {
        case .neutro:
            con(ojos, sonrisa)
        case .parpadeo:
            con([1: ".....oo..oo....."], sonrisa)
        case .feliz:
            // Ojos en arco (^ ^) y sonrisa más ancha.
            con([0: ".....o....o.....", 1: "....o.o..o.o...."], [3: "......OOOO......"])
        case .guino:
            con([0: ".........5o.....", 1: ".....oo..oo....."], [3: "........OO......"])
        case .celebrando:
            con(ojos, [2: "....r......r....", 3: "......OOOO......"])
        case .sorprendido:
            con([-1: "....5oo..5oo....", 0: "....ooo..ooo....", 1: "....ooo..ooo...."],
                [3: ".......OO......."])
        case .pensando:
            // Mira arriba a la derecha.
            con([-1: "......5o..5o....", 0: "......oo..oo...."], [3: "........OO......"])
        case .dormido:
            con([1: "....ooo..ooo...."], [3: ".......OO......."])
        case .gafas:
            con([0: "....oooooooo....", 1: "....ooo..ooo....", 2: ".....o....o....."], sonrisa)
        case .leyendo:
            // Mira abajo, al libro.
            con([1: ".....5o..5o.....", 2: ".....oo..oo....."], [3: "................"])
        case .nerd:
            // Marco grueso, lentes blancos con la pupila adentro.
            con([-1: "....oooooooo....", 0: "....o55oo55o....", 1: "....o5ooo5oo....", 2: "....oooooooo...."],
                [3: ".......OO......."])
        }
    }

    // MARK: Brazos

    /// La pinza derecha en reposo: columnas 13–15, filas 3–10.
    private static let pinza: [(fila: Int, col: Int, tinta: Tinta)] = {
        let filas = [
            3: "OO.",
            4: "c1O",
            5: "cOO",
            6: "O..",
            7: "cOO",
            8: "c1O",
            9: "ccO",
            10: "OO.",
        ]
        return filas.flatMap { fila, linea in
            linea.enumerated().compactMap { i, letra in
                letra == "." ? nil : (fila, 13 + i, Tinta(rawValue: letra)!)
            }
        }
    }()

    private static var todaLaPinza: [Pixel] {
        (3...10).flatMap { f in (13...15).map { (fila: f, col: $0) } }
    }

    /// La misma pinza corrida `df` filas (para teclear), cerrando el borde del cuerpo.
    private static func corrida(_ df: Int, borde: [(fila: Int, col: Int, tinta: Tinta)]) -> Cambio {
        Cambio(quita: todaLaPinza, pone: [],
               pinta: pinza.map { ($0.fila + df, $0.col, $0.tinta) } + borde)
    }

    let brazos = Brazos(
        // Sube por el costado (hombro en la fila 7) y abre la pinza en V arriba,
        // columnas 13–17: la mano queda en la 15.
        arriba: Cambio(
            quita: Koru.todaLaPinza,
            pone: [],
            pinta: [
                // El cuerpo cierra su borde donde estaba la pinza.
                (8, 13, .contorno), (9, 13, .contorno), (10, 13, .contorno),
                // La pinza abierta.
                (2, 13, .contorno), (2, 14, .contorno), (2, 16, .contorno),
                (3, 12, .contorno), (3, 13, .cuerpo), (3, 14, .detalle1), (3, 15, .contorno), (3, 16, .detalle1), (3, 17, .contorno),
                (4, 13, .cuerpo), (4, 14, .cuerpo), (4, 15, .cuerpo), (4, 16, .cuerpo), (4, 17, .contorno),
                (5, 13, .contorno), (5, 14, .cuerpo), (5, 15, .cuerpo), (5, 16, .cuerpo), (5, 17, .contorno),
                // Muñeca y hombro.
                (6, 13, .contorno), (6, 14, .contorno), (6, 15, .cuerpo), (6, 16, .contorno),
                (7, 13, .cuerpo), (7, 14, .cuerpo), (7, 15, .cuerpo), (7, 16, .contorno),
                (8, 14, .contorno), (8, 15, .contorno),
            ]
        ),
        // Tecleando: la pinza entera sube un píxel…
        teclearArriba: Koru.corrida(-1, borde: [(3, 12, .contorno), (10, 13, .contorno)]),
        // …y baja uno.
        teclearAbajo: Koru.corrida(1, borde: []),
        mano: (col: 15.5, fila: 2.5),
        manoAbajo: (col: 14.5, fila: 12)
    )

    let patas = Patas(fila: 15, paso1: [2, 10], paso2: [5, 13])
}
