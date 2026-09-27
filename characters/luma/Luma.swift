import Motor

/// Luma (búho) de la familia Koru, "la observadora" — ver `characters/FAMILIA.md`.
///
/// Letras: `c` morado (cuerpo), `1` azul (alas, corona y marcas en V),
/// `C` crema (discos faciales y pecho), `3`/`2` pico y patas, `O` contorno.
/// Los brazos son las alas: se pintan azules y con contorno usando `pinta`.
struct Luma: Personaje {
    let id = "luma"
    let nombre = "Luma"
    /// Con contorno: un poco más grande para verse del tamaño de Clawd.
    let escala = 1.2
    /// El pico queda al centro; lo que se lleva a la boca va pegado al disco facial.
    let boca = (col: 15, fila: 9)
    let paleta: [Tinta: UInt32] = [
        .cuerpo: 0x9B6AE3,   // c: morado, el color principal
        .detalle1: 0x4CA8F0, // 1: azul de las alas y detalles
        .crema: 0xFAF5E7,    // C: discos faciales y pecho
        .detalle3: 0xF7C948, // 3: amarillo del pico y las patas
        .detalle2: 0xF08A3C, // 2: naranja de la punta del pico
        .contorno: 0x163A63,
    ]

    /// Penachos en las filas 0–2, discos faciales 4–9, alas en las filas 10–13
    /// a los lados, pecho crema con dos V azules, patas amarillas en 14–15.
    let cuerpo = [
        ".OO..........OO.",
        ".OcO........OcO.",
        ".OccOOOOOOOOccO.",
        ".Occcc1111ccccO.",
        ".OcccCCccCCcccO.",
        ".OccCCCCCCCCccO.",
        ".OccCCCCCCCCccO.",
        ".OccCCCCCCCCccO.",
        ".OccCCC33CCCccO.",
        ".OcccCC22CCcccO.",
        "O11ccCCCCCCcc11O",
        "O11cC1C11C1Cc11O",
        "O11cCC1CC1CCc11O",
        ".O1ccCCCCCCcc1O.",
        "..OOO3OOOO3OOO..",
        "...O333OO333O...",
    ]

    /// Filas 4–9: discos faciales, ojos y pico. Se redibujan completas.
    func cara(_ expresion: Expresion) -> [Int: String]? {
        var f: [Int: String] = [
            4: "..cccCCccCCccc..",
            5: "..ccCCCCCCCCcc..",
            6: "..ccCCCCCCCCcc..",
            7: "..ccCCCCCCCCcc..",
            8: "..ccCCC33CCCcc..",
            9: "..cccCC22CCccc..",
        ]
        switch expresion {
        case .neutro:
            f[6] = "..ccC5oCC5oCcc.."
            f[7] = "..ccCooCCooCcc.."
        case .parpadeo:
            f[7] = "..ccCooCCooCcc.."
        case .feliz:
            // Ojos en arco (^ ^).
            f[5] = "..ccCoCCCCoCcc.."
            f[6] = "..ccoCoCCoCocc.."
        case .guino:
            f[6] = "..ccC5oCCCCCcc.."
            f[7] = "..ccCooCCooCcc.."
        case .celebrando:
            f[6] = "..ccC5oCC5oCcc.."
            f[7] = "..ccCooCCooCcc.."
            f[8] = "..ccrCC33CCrcc.."
        case .sorprendido:
            // El búho los abre hasta 3×3.
            f[5] = "..cc5ooCC5oocc.."
            f[6] = "..ccoooCCooocc.."
            f[7] = "..ccoooCCooocc.."
        case .pensando:
            // Mira arriba a la derecha.
            f[5] = "..ccCC5oCC5occ.."
            f[6] = "..ccCCooCCoocc.."
        case .dormido:
            f[7] = "..ccooCCCCoocc.."
        case .gafas:
            // Gafas de sol negras con puente.
            f[5] = "..cooooooooooc.."
            f[6] = "..ccoooCCooocc.."
            f[7] = "..ccCooCCooCcc.."
        case .leyendo:
            // Mirada abajo, al libro.
            f[7] = "..ccCooCCooCcc.."
            f[8] = "..ccCoo33ooCcc.."
        case .nerd:
            // Marco grueso, lentes blancos y pupila.
            f[5] = "..cooooooooooc.."
            f[6] = "..co55oCCo55oc.."
            f[7] = "..co5ooCCo5ooc.."
            f[8] = "..coooo33ooooc.."
        }
        return f
    }

    /// El ala derecha (columnas 13–15, filas 10–13). Levantada sale del hombro
    /// en diagonal y la punta queda en las columnas 15–16, fila 6.
    let brazos = Brazos(
        arriba: Cambio(
            quita: [(10, 15), (11, 15), (12, 15)],
            pone: [(11, 13), (12, 13), (13, 13)],
            pinta: [
                // El costado queda morado con su contorno.
                (11, 14, .contorno), (12, 14, .contorno), (13, 14, .contorno),
                // El ala sube en diagonal desde el hombro.
                (10, 14, .detalle1), (9, 14, .detalle1), (9, 15, .detalle1),
                (8, 15, .detalle1), (8, 16, .detalle1), (7, 15, .detalle1), (7, 16, .detalle1),
                (6, 16, .detalle1), (5, 16, .detalle1),
                (6, 15, .contorno), (5, 15, .contorno), (4, 16, .contorno), (5, 17, .contorno),
                (6, 17, .contorno), (7, 17, .contorno), (8, 17, .contorno),
                (9, 16, .contorno), (10, 15, .contorno),
            ]
        ),
        teclearArriba: Cambio(
            quita: [(12, 15)],
            pone: [(12, 13), (13, 13)],
            pinta: [(9, 13, .detalle1), (9, 14, .detalle1), (9, 15, .contorno), (8, 15, .contorno),
                    (12, 14, .contorno)]
        ),
        teclearAbajo: Cambio(
            quita: [(10, 15)],
            pone: [(10, 13)],
            pinta: [(10, 14, .contorno), (13, 13, .detalle1), (13, 14, .detalle1), (13, 15, .contorno),
                    (14, 13, .contorno), (14, 14, .contorno)]
        ),
        mano: (col: 16.5, fila: 5),
        manoAbajo: (col: 14.5, fila: 14)
    )

    let patas = Patas(fila: 15, paso1: [3, 4, 5, 6, 7], paso2: [8, 9, 10, 11, 12])
}
