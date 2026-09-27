import Motor

/// Mako, el gecko de la familia Koru: el ágil, el que dice "hagamos una prueba
/// rápida". Ver `characters/FAMILIA.md`.
///
/// De 3/4: la cabeza grande a la derecha, el cuerpo bajito hacia atrás y la cola
/// con bandas lima que sube por detrás y se enrosca arriba. Tres patas a la vista
/// con los pies lima; la de adelante a la derecha es la que usa como "brazo".
struct Mako: Personaje {
    let id = "mako"
    let nombre = "Mako"
    /// Con contorno: un poco más grande para verse del tamaño de Clawd.
    let escala = 1.2
    let paleta: [Tinta: UInt32] = [
        .cuerpo: 0x44D0CF,    // turquesa
        .detalle1: 0xA6E34B,  // lima: bandas de la cola, manchas y pies
        .crema: 0xF8EFD8,     // garganta y vientre
        .contorno: 0x163A63,
    ]

    /// Cabeza en las columnas 5–15 (cara centrada en la 10), cola en la 0–4.
    let cuerpo = [
        ".OOOO...........",
        "Oc1cO...........",
        "O1OcO...........",
        "OcOOO..OOOOOOO..",
        "O1O...OcccccccO.",
        "OcO..OcccccccccO",
        "O1O..OcccccccccO",
        "OcOOOOcccccccccO",
        "O1cc1ccccccccccO",
        "Occcc1cccccccccO",
        "Oc1ccccc1CCCCcO.",
        ".OccccccCCCCCcO.",
        ".Oc1OOOOcOOOc1O.",
        "Occ1O..OcO.Oc1cO",
        "O111O..O1O.O111O",
        ".OOO...OOO..OOO.",
    ]

    func cara(_ expresion: Expresion) -> [Int: String]? {
        // Ojos de la familia: 2×2 con brillo arriba a la izquierda.
        let ojos = [5: ".......5o...5o..", 6: ".......oo...oo.."]
        let sonrisa = [8: ".........O.O....", 9: "..........O....."]
        let sonrisota = [8: "........O...O...", 9: ".........OOO...."]

        switch expresion {
        case .neutro:
            return ojos.merging(sonrisa) { a, _ in a }
        case .parpadeo:
            return [6: ".......oo...oo.."].merging(sonrisa) { a, _ in a }
        case .feliz:
            // Ojos en arco (∩).
            return [5: ".......oo...oo..", 6: "......o..o.o..o."].merging(sonrisota) { a, _ in a }
        case .guino:
            return [5: ".......5o.......", 6: ".......oo...oo..",
                    8: ".........O.O....", 9: "..........OO...."]
        case .celebrando:
            return ojos.merging([7: "......r.......r."]) { a, _ in a }.merging(sonrisota) { a, _ in a }
        case .sorprendido:
            return [4: ".......5o...5o..", 5: ".......oo...oo..", 6: ".......oo...oo..",
                    8: "..........O.....", 9: "..........O....."]
        case .pensando:
            // Mirando arriba a la derecha, boca de lado.
            return [4: "........5o...5o.", 5: "........oo...oo.", 9: "..........OO...."]
        case .dormido:
            // Ojos cerrados en arco hacia abajo (∪): duerme contento.
            return [5: "......o..o.o..o.", 6: ".......oo...oo..", 9: "..........O....."]
        case .gafas:
            // Gafas de sol negras con un brillito.
            return [5: "......o5ooooo5o.", 6: "......ooo...ooo."].merging(sonrisa) { a, _ in a }
        case .leyendo:
            // Párpados a media asta y la mirada abajo, al libro.
            return [6: ".......OO...OO..", 7: ".......oo...oo..", 9: "..........O....."]
        case .nerd:
            // Marco grueso, lentes blancos y la pupila abajo.
            return [4: "......oooo.oooo.", 5: "......o55ooo55o.",
                    6: "......o5oo.o5oo.", 7: "......oooo.oooo.",
                    9: ".........OOO...."]
        }
    }

    /// El "brazo" es la pata de adelante a la derecha (columnas 11–15).
    let brazos = Brazos(
        // La pata sale del hombro y sube pegada a la cabeza (comparte su contorno
        // de la columna 15), con contorno propio y el pie lima arriba, en la
        // columna 16, filas 5–6. Donde estaba la pata se cierra la barriga.
        arriba: Cambio(
            quita: [(13, 11), (13, 12), (13, 13), (13, 14), (13, 15),
                    (14, 11), (14, 12), (14, 13), (14, 14), (14, 15),
                    (15, 12), (15, 13), (15, 14)],
            pone: [(11, 14), (11, 15), (10, 15), (10, 16), (9, 16), (8, 16), (7, 16)],
            pinta: [(6, 16, .detalle1), (5, 16, .detalle1),
                    (4, 15, .contorno), (4, 16, .contorno),
                    (5, 17, .contorno), (6, 17, .contorno), (7, 17, .contorno),
                    (8, 17, .contorno), (9, 17, .contorno), (10, 17, .contorno),
                    (11, 16, .contorno), (12, 15, .contorno),
                    (12, 12, .contorno), (12, 13, .contorno)]
        ),
        // Tecleando: el pie sube una fila…
        teclearArriba: Cambio(
            quita: [(15, 12), (15, 13), (15, 14)], pone: [],
            pinta: [(13, 12, .detalle1), (13, 13, .detalle1), (13, 14, .detalle1),
                    (14, 12, .contorno), (14, 13, .contorno), (14, 14, .contorno)]
        ),
        // …y baja abriendo los deditos.
        teclearAbajo: Cambio(quita: [], pone: [],
                             pinta: [(15, 12, .detalle1), (15, 14, .detalle1)]),
        mano: (col: 16.5, fila: 4.5),
        manoAbajo: (col: 14, fila: 15)
    )

    /// La sonrisa va en las columnas 9–11, filas 8–9; la golosina arranca justo
    /// a su derecha y debajo de los ojos para no taparle la cara.
    let boca = (col: 12, fila: 10)

    /// Al caminar alterna la pata de atrás y la de adelante-derecha con la del medio.
    let patas = Patas(fila: 15, paso1: [1, 2, 3, 12, 13, 14], paso2: [7, 8, 9])
}
