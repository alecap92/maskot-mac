import Motor

/// Tuno, el zorro ingenioso de la familia Koru — ver `characters/FAMILIA.md`.
/// Orejas grandes con interior cian, cachetes y pecho crema, sonrisa de medio
/// lado ("ya se me ocurrió algo") y la cola con punta crema asomando a la izquierda.
struct Tuno: Personaje {
    let id = "tuno"
    let nombre = "Tuno"
    /// Con contorno: un poco más grande para verse del tamaño de Clawd.
    let escala = 1.2
    let paleta: [Tinta: UInt32] = [
        .cuerpo: 0xF58A2A,
        .crema: 0xFFF2DD,
        .detalle1: 0x53C3D8,   // cian: interior de las orejas
        .detalle2: 0xD96E1A,   // naranja en sombra: la cola por dentro
        .contorno: 0x163A63,
    ]

    /// Cabeza en las columnas 3–14 (orejas en las filas 0–4), cuerpo en las 4–13
    /// y la cola, con la punta crema, en las 0–3. Patas en las columnas 5–6 y 11–12.
    let cuerpo = [
        "...O..........O.",
        "...OO........OO.",
        "...O1O......O1O.",
        "...O11O....O11O.",
        "...Oc11OOOO11cO.",
        "...OccccccccccO.",
        ".OOOccccccccccO.",
        "OCCOccccccccccO.",
        "OCcOCCccccccCCCO",
        "OccOCCCCCCCCCCO.",
        "Occ2OcCCCCCCcO..",
        "Occ2OcCCCCCCcO..",
        "Oc22OccCCCCccO..",
        "Oc22OccccccccO..",
        ".O22OccOOOOccO..",
        "..OOOccO..OccO..",
    ]

    /// Ojos 2×2 en las columnas 5–6 y 10–11 (filas 6–7); la boca va en las
    /// filas 8–9 y el cachete crema derecho sale un píxel (el izquierdo lo tapa
    /// la cola). Las columnas 0–2 van en `.` para no pisar la cola.
    func cara(_ expresion: Expresion) -> [Int: String]? {
        // Sonrisa de medio lado, la de "ya se me ocurrió algo": sube hacia la derecha.
        let boca = [8: "...OCCccccOcCCCO", 9: "...OCCCCOOCCCCO."]
        let ojos: [Int: String]
        switch expresion {
        case .neutro:
            ojos = [6: "...Oc5occc5occO.", 7: "...OcoocccooccO."]
        case .parpadeo:
            ojos = [6: "...OccccccccccO.", 7: "...OcoocccooccO."]
        case .feliz:
            ojos = [6: "...OcoocccooccO.", 7: "...OoccococcocO."]
        case .guino:
            ojos = [6: "...Oc5occcccccO.", 7: "...OcooccoooocO."]
        case .celebrando:
            ojos = [6: "...Oc5occc5occO.", 7: "...OcoocccooccO.",
                    8: "...OrrccccOcrrCO"]
        case .sorprendido:
            // Ojos de 3×3 y la boca en "o".
            return [5: "...O5ooccc5oocO.", 6: "...OooocccooocO.", 7: "...OooocccooocO.",
                    8: "...OCCcccOccCCCO", 9: "...OCCCCOCCCCCO."]
        case .pensando:
            // Mirando arriba a la derecha.
            ojos = [5: "...Occ5occc5ocO.", 6: "...OccoocccoocO.", 7: "...OccccccccccO."]
        case .dormido:
            ojos = [6: "...OccccccccccO.", 7: "...OooocccooocO."]
        case .gafas:
            ojos = [6: "...OooooooooooO.", 7: "...OooocccooocO."]
        case .leyendo:
            // Mirando abajo, al libro.
            ojos = [6: "...OccccccccccO.", 7: "...Oc5occc5occO.", 8: "...OCooccccooCCO"]
        case .nerd:
            // Marco grueso, lentes blancos y la pupila abajo por dentro.
            return [5: "...OoooocoooocO.", 6: "...Oo55ooo55ocO.", 7: "...Oo5oooo5oocO.",
                    8: "...OooooOoooocCO", 9: "...OCCCCOOCCCCO."]
        }
        return boca.merging(ojos) { _, ojo in ojo }
    }

    let brazos = Brazos(
        // La pata delantera derecha sube en diagonal desde el hombro, con su
        // contorno; la mano queda en las columnas 15–16, filas 7–8. Al levantar
        // la izquierda (el espejo) la pata pasa por delante de la cola.
        arriba: Cambio(
            quita: [],
            pone: [(11, 14), (10, 14), (10, 15), (9, 15), (8, 15), (8, 16), (7, 15), (7, 16)],
            pinta: [(6, 15, .contorno), (6, 16, .contorno), (7, 17, .contorno), (8, 17, .contorno),
                    (9, 16, .contorno), (10, 16, .contorno), (11, 15, .contorno), (12, 14, .contorno)]
        ),
        // Tecleando, la pata asoma al lado del cuerpo y sube o baja un píxel.
        teclearArriba: Cambio(
            quita: [],
            pone: [(11, 14), (12, 14)],
            pinta: [(10, 14, .contorno), (11, 15, .contorno), (12, 15, .contorno), (13, 14, .contorno)]
        ),
        teclearAbajo: Cambio(
            quita: [],
            pone: [(12, 14), (13, 14)],
            pinta: [(11, 14, .contorno), (12, 15, .contorno), (13, 15, .contorno), (14, 14, .contorno)]
        ),
        // La pesa (7 de ancho) se corre a la derecha para no tapar la oreja:
        // la barra queda en la mano.
        mano: (col: 17, fila: 7),
        manoAbajo: (col: 15, fila: 13.5)
    )

    let patas = Patas(fila: 15, paso1: [5, 6], paso2: [11, 12])
}
