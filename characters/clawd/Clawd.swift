import Motor

/// Clawd: el cangrejito terracota de pixel art, con gorra.
/// Hoja de expresiones en `hoja.png`.
struct Clawd: Personaje {
    let id = "clawd"
    let nombre = "Clawd"
    let paleta: [Tinta: UInt32] = [.cuerpo: 0xD97757]

    /// Filas 0…5 vacías: ahí va la gorra. Patas en las columnas 3, 5, 10 y 12.
    let cuerpo = [
        "................",
        "................",
        "................",
        "................",
        "................",
        "................",
        "..cccccccccccc..",
        "..cccccccccccc..",
        "..cccccccccccc..",
        "..cccccccccccc..",
        "..cccccccccccc..",
        "cccccccccccccccc",
        "cccccccccccccccc",
        "..cccccccccccc..",
        "...c.c....c.c...",
        "...c.c....c.c...",
    ]

    func cara(_ expresion: Expresion) -> [Int: String]? {
        switch expresion {
        case .neutro:
            [9: "....o......o....", 10: "....o......o...."]
        case .parpadeo:
            [10: "....o......o...."]
        case .feliz:
            [8: "....o......o....", 9: ".....o....o.....", 10: "....o......o...."]
        case .guino:
            [9: "...........o....", 10: "....oo.....o...."]
        case .celebrando:
            [9: "....o......o....", 10: "....o......o....", 11: "...r........r..."]
        case .sorprendido:
            [9: "....oo....oo....", 10: "....oo....oo...."]
        case .pensando:
            [8: ".....o......o...", 9: ".....o......o..."]
        case .dormido:
            [10: "....oo....oo...."]
        case .gafas:
            [8: "..oooooooooooo..", 9: "....ooo..ooo....", 10: "....ooo..ooo...."]
        case .nerd:
            // Gafas de marco grueso con lentes blancos.
            [8: "...oooo..oooo...", 9: "...owwoooowwo...", 10: "...owoo..owoo...", 11: "...oooo..oooo..."]
        case .leyendo:
            // Mirada hacia abajo, al libro.
            [10: ".....o....o....."]
        }
    }

    /// Hacia atrás: la visera no se ve, pero sí el hueco de la correa en la
    /// frente. De lado: la visera sale a la derecha.
    func gorra(_ gorra: Gorra) -> [Int: String] {
        switch gorra {
        case .haciaAtras:
            [2: "......vvvv......",
             3: ".....gggggg.....",
             4: "....gggbbggg....",
             5: "...gggbccbggg..."]
        case .deLado:
            [3: ".....gggggg.....",
             4: "....gggggggg....",
             5: "...ggggggggggvvv"]
        }
    }

    let brazos = Brazos(
        // Sale del hombro y sube en diagonal; la mano queda en las columnas 15–16.
        arriba: Cambio(
            quita: [(11, 15), (12, 15)],
            pone: [(9, 14), (9, 15), (10, 14), (10, 15), (7, 15), (7, 16), (8, 15), (8, 16)]
        ),
        teclearArriba: Cambio(quita: [(12, 14), (12, 15)], pone: [(10, 14), (10, 15)]),
        teclearAbajo: Cambio(quita: [(11, 14), (11, 15)], pone: [(13, 14), (13, 15)]),
        mano: (col: 16, fila: 7),
        manoAbajo: (col: 15.5, fila: 14.5)
    )

    let patas = Patas(fila: 15, paso1: [3, 10], paso2: [5, 12])
}
