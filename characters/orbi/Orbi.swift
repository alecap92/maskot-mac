import Motor

/// Orbi (pulpo) de la familia Koru — ver `characters/FAMILIA.md`.
/// "El versátil": cabeza redonda grande, dos tentáculos laterales que se
/// enroscan hacia arriba (sus brazos) y cuatro tentáculos cortos abajo (sus
/// patas), con las puntas lavanda.
struct Orbi: Personaje {
    let id = "orbi"
    let nombre = "Orbi"
    /// Con contorno: un poco más grande para verse del tamaño de Clawd.
    let escala = 1.2
    /// La cabeza arranca en la fila 1 (ahí se apoya un sombrero).
    let cabeza = 1
    /// La golosina y el café llegan a la altura de la boca (fila 9).
    let boca = (col: 13, fila: 9)
    let paleta: [Tinta: UInt32] = [
        .cuerpo: 0xF56B8A,   // coral rosado
        .detalle1: 0xF25A7A, // rosa fuerte: sombras
        .detalle2: 0x87D5F7, // azul claro: burbujas
        .detalle3: 0xFB9AB0, // brillo de la cabeza
        .detalle4: 0xA98AE8, // lavanda: puntas de los tentáculos
        .cachete: 0xFFB3C4,
    ]

    /// Cabeza en las filas 1–9, tentáculos laterales enroscados en 8–12,
    /// cuatro tentáculos abajo (13–14, puntas lavanda) y su contorno en la 15.
    let cuerpo = [
        "................",
        ".....OOOOOO.....",
        "....O33ccccO....",
        "...O3cccccccO...",
        "...O3cccccccO...",
        "...OccccccccO...",
        "...OccccccccO...",
        "...Occccccc1O...",
        ".OOOccccccc1OOO.",
        "O44Occccccc1O44O",
        "O4Occcccccc11O4O",
        "O4ccccccccccc14O",
        ".Occccccccccc1O.",
        ".OccOccOOccOc1O.",
        "O44OO44OO44OO44O",
        ".OO..OO..OO..OO.",
    ]

    func cara(_ expresion: Expresion) -> [Int: String]? {
        let boca = [9: ".......OO......."]
        let base: [Int: String]
        switch expresion {
        case .neutro:
            base = [6: ".....5o..5o.....", 7: ".....oo..oo....."]
        case .parpadeo:
            base = [7: ".....oo..oo....."]
        case .feliz:
            // Ojos en arco, sonrisa abierta y un par de burbujas.
            return [0: "...............2", 2: "..............2.",
                    6: ".....o....o.....", 7: "....o.o..o.o....",
                    8: "......O..O......", 9: ".......OO......."]
        case .guino:
            base = [6: ".........5o.....", 7: ".....oo..oo....."]
        case .celebrando:
            base = [6: ".....5o..5o.....", 7: ".....oo..oo.....", 8: "....r......r...."]
        case .sorprendido:
            return [5: "....5oo..5oo....", 6: "....ooo..ooo....", 7: "....ooo..ooo....",
                    9: ".......OO.......", 10: ".......OO......."]
        case .pensando:
            return [5: "......oo..oo....", 6: "......oo..oo....", 9: "........OO......"]
        case .dormido:
            base = [7: "....ooo..ooo...."]
        case .gafas:
            base = [5: "...oooooooooo...", 6: "....ooo..ooo....", 7: "....ooo..ooo...."]
        case .leyendo:
            return [8: ".....oo..oo.....", 9: ".....oo..oo.....", 10: ".......OO......."]
        case .nerd:
            base = [5: "...oooo..oooo...", 6: "...o55oooo55o...",
                    7: "...o5oo..o5oo...", 8: "...oooo..oooo..."]
        }
        return base.merging(boca) { a, _ in a }
    }

    /// El brazo derecho es el tentáculo lateral: en reposo se enrosca hacia
    /// arriba (filas 8–12, columnas 12–15) con la punta lavanda.
    let brazos = Brazos(
        // Se desenrosca y sube por el lado de la cabeza, con su contorno; la
        // punta lavanda queda en las columnas 15–16, filas 6–7.
        arriba: Cambio(
            quita: [(8, 13), (8, 14), (9, 13), (9, 14), (9, 15), (10, 13), (10, 14), (10, 15),
                    (11, 14), (11, 15)],
            pone: [(8, 15), (8, 16), (9, 14), (9, 15), (10, 13), (10, 14)],
            pinta: [(6, 15, .contorno), (6, 16, .contorno),
                    (7, 14, .contorno), (7, 15, .detalle4), (7, 16, .detalle4), (7, 17, .contorno),
                    (8, 14, .contorno), (8, 17, .contorno),
                    (9, 13, .contorno), (9, 16, .contorno),
                    (10, 15, .contorno), (11, 14, .contorno)]
        ),
        // Tecleando, el rizo entero sube o baja un píxel.
        teclearArriba: Cambio(
            quita: [(11, 15)],
            pone: [],
            pinta: [(7, 13, .contorno), (7, 14, .contorno),
                    (8, 13, .detalle4), (8, 14, .detalle4), (8, 15, .contorno),
                    (9, 13, .contorno), (9, 14, .detalle4), (9, 15, .contorno),
                    (10, 13, .detalle1), (10, 14, .detalle4), (10, 15, .contorno),
                    (11, 14, .contorno)]
        ),
        teclearAbajo: Cambio(
            quita: [(8, 13), (8, 14), (9, 15)],
            pone: [],
            pinta: [(9, 13, .contorno), (9, 14, .contorno),
                    (10, 13, .detalle4), (10, 14, .detalle4), (10, 15, .contorno),
                    (11, 13, .contorno), (11, 14, .detalle4), (11, 15, .contorno),
                    (12, 14, .detalle4), (12, 15, .contorno)]
        ),
        mano: (col: 16, fila: 6.5),
        manoAbajo: (col: 15, fila: 11.5)
    )

    /// Se desliza: alterna los tentáculos de abajo de dos en dos (el de afuera
    /// a la izquierda con el de adentro a la derecha, y viceversa).
    let patas = Patas(fila: 15, paso1: [1, 2, 9, 10], paso2: [5, 6, 13, 14])
}
