import Motor

/// Brio, la abeja eficiente de la familia Koru — ver `characters/FAMILIA.md`.
/// Cuerpo redondo que flota, alas grandes azul claro, antenitas con punta,
/// franjas azul marino y patitas cortas colgando hasta el piso.
struct Brio: Personaje {
    let id = "brio"
    let nombre = "Brio"
    /// Con contorno: un poco más grande para verse del tamaño de Clawd.
    let escala = 1.2
    let paleta: [Tinta: UInt32] = [
        .cuerpo: 0xF5D338,      // amarillo
        .contorno: 0x163A63,    // contorno, franjas y antenas
        .detalle1: 0xA7DDF8,    // alas
    ]

    /// Antenas en las filas 0–2, alas inclinadas detrás de la cabeza (filas
    /// 0–5), cuerpo redondo de las filas 3 a 13 con dos franjas abajo, patitas
    /// delanteras (brazos) en las columnas 1 y 14, y dos patitas colgando
    /// hasta la fila 15.
    let cuerpo = [
        "OOO..c....c..OOO",
        "O11O..O..O..O11O",
        "O151O.O..O.O151O",
        ".O111OOOOOO111O.",
        "..O1OccccccO1O..",
        "..OOccccccccOO..",
        "..OccccccccccO..",
        ".OccccccccccccO.",
        ".OccccccccccccO.",
        ".OccccccccccccO.",
        "OOccccccccccccOO",
        "OcOOOOOOOOOOOOcO",
        "OcOccccccccccOcO",
        ".O.OOOOOOOOOO.O.",
        "......O..O......",
        ".....OO..OO.....",
    ]

    /// La cara vive en las filas 5–9: ojos en las columnas 4–5 y 10–11
    /// (filas 6–7), sonrisa en U debajo, entre los dos.
    func cara(_ expresion: Expresion) -> [Int: String]? {
        let sonrisa = [8: "......O..O......", 9: "......OOOO......"]
        let ojos = [6: "....5o....5o....", 7: "....oo....oo...."]
        switch expresion {
        case .neutro:
            return ojos.merging(sonrisa) { a, _ in a }
        case .parpadeo:
            return [7: "....oo....oo...."].merging(sonrisa) { a, _ in a }
        case .feliz:
            // Ojos en arco y boca abierta de "¡vamos!".
            return [6: "....oo....oo....",
                    7: "...o..o..o..o...",
                    8: "......OOOO......",
                    9: ".......OO......."]
        case .guino:
            return [6: "....5o..........", 7: "....oo...ooo...."].merging(sonrisa) { a, _ in a }
        case .celebrando:
            return ojos.merging([8: "...r..O..O..r...", 9: "......OOOO......"]) { a, _ in a }
        case .sorprendido:
            return [5: "....5o....5o....",
                    6: "....oo....oo....",
                    7: "....oo....oo....",
                    8: ".......OO.......",
                    9: ".......OO......."]
        case .pensando:
            // Mira hacia arriba, a un lado.
            return [5: ".....5o....5o...",
                    6: ".....oo....oo...",
                    9: "........OO......"]
        case .dormido:
            return [7: "...ooo....ooo...", 9: ".......OO......."]
        case .gafas:
            return [6: "..oooooooooooo..",
                    7: "...o5oo..o5oo...",
                    8: "....oo....oo....",
                    9: "......OOOO......"]
        case .leyendo:
            // Mirada hacia abajo, al libro o a la pantalla.
            return [7: "....5o....5o....", 8: "....oo....oo....", 9: ".......OO......."]
        case .nerd:
            // Gafas de marco grueso con lentes blancos.
            return [5: "...oooo..oooo...",
                    6: "...o55oooo55o...",
                    7: "...o5oo..o5oo...",
                    8: "...oooo..oooo...",
                    9: ".......OO......."]
        }
    }

    let brazos = Brazos(
        // La patita sube por fuera del cuerpo, por debajo del ala, con su
        // contorno: la mano queda en las columnas 15–16, filas 6–7.
        arriba: Cambio(
            quita: [(12, 14), (12, 15), (13, 14)],
            pone: [(10, 15), (9, 15), (8, 15), (7, 15), (7, 16), (6, 15), (6, 16)],
            pinta: [(11, 14, .contorno), (11, 15, .contorno),
                    (10, 16, .contorno), (9, 16, .contorno), (8, 16, .contorno),
                    (5, 15, .contorno), (5, 16, .contorno), (6, 17, .contorno), (7, 17, .contorno)]
        ),
        // Tecleando la patita sube o baja un píxel y el contorno la sigue.
        teclearArriba: Cambio(quita: [(13, 14)], pone: [(10, 14)], pinta: [(12, 14, .contorno)]),
        teclearAbajo: Cambio(
            quita: [],
            pone: [(13, 14)],
            pinta: [(11, 14, .contorno), (13, 15, .contorno), (14, 14, .contorno)]
        ),
        mano: (col: 16, fila: 6),
        manoAbajo: (col: 14.5, fila: 13)
    )

    /// La boca está en las filas 8–9; lo que sostiene junto a la cara (taza,
    /// paleta) arranca justo después del contorno, en la columna 15.
    let boca = (col: 14, fila: 9)

    /// Las patitas cuelgan en las columnas 6 y 9 con el pie hacia afuera.
    let patas = Patas(fila: 15, paso1: [5, 6], paso2: [9, 10])
}
