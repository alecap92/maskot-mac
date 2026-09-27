/// Utilería de la excursión.
public extension Utileria {
    /// Sombrero de montañista con cinta.
    static let sombreroMontana = dibujo([
        "...hhhhhh...",
        "...hhhhhh...",
        "...mmmmmm...",
        "hhhhhhhhhhhh",
    ])

    /// Mochila roja con la cobija enrollada arriba.
    static let mochila = dibujo([
        ".aaaaa.",
        "aaaaaaa",
        ".xxxxx.",
        "xxxxxxx",
        "xxEEExx",
        "xxxxxxx",
        "xxEEExx",
        "xxxxxxx",
        ".xxxxx.",
    ])

    /// Binoculares de perfil apuntando a la derecha: dos tubos apilados, el
    /// ocular negro pegado a la cara (izquierda) y el lente azul adelante.
    static let binoculares = dibujo([
        "..eeeeeeW",
        "EEeeeeeeW",
        "..eeeeeeW",
        "...jj.jj.",
        "..eeeeeeW",
        "EEeeeeeeW",
        "..eeeeeeW",
    ])

    /// Cámara de fotos con lente de metal.
    static let camara = dibujo([
        ".EE....",
        "EEEEEEE",
        "EEjjjEE",
        "EEjWjEE",
        "EEjjjEE",
        "EEEEEEE",
    ])

    /// El destello del flash.
    static let flash = dibujo([
        "..w..",
        ".www.",
        "wwwww",
        ".www.",
        "..w..",
    ])

    // MARK: Fogata

    /// Tronco para sentarse (mide 3 filas: lo que sube el personaje al sentarse).
    static let tronco = dibujo([
        "hmmmmmmmmmmmmh",
        "mmmmhmmmmmhmmm",
        "hmmmmmmmmmmmmh",
    ])

    /// La fogata: apagada (solo leña) o con llamas en dos cuadros que se alternan.
    static func fogata(prendida: Bool, cuadro: Int = 0) -> Cuadro {
        let llamas: [String] = !prendida ? Array(repeating: "..........", count: 6) : cuadro % 2 == 0 ? [
            "....u.....",
            "...uf..u..",
            "..ufff.f..",
            "..fiffff..",
            ".ffiiiff..",
            ".fiiiiif..",
        ] : [
            ".....u....",
            "..u..fu...",
            "..f.fffu..",
            "..ffffif..",
            "..ffiiiff.",
            "..fiiiiif.",
        ]
        return dibujo(llamas + ["mmhmmhmmhm", ".hmmhmmhm."])
    }

    /// Palito con el malvavisco en la punta (arriba a la derecha).
    /// Etapa 0 blanco, 1 dorado, 2 quemado.
    static func malvavisco(etapa: Int) -> Cuadro {
        let m = etapa >= 2 ? "E" : etapa == 1 ? "h" : "w"
        return dibujo([
            "......\(m)\(m)",
            "......\(m)\(m)",
            ".....m..",
            "...mm...",
            ".mm.....",
            "m.......",
        ])
    }

    /// Bastón de caminata, con la empuñadura clara arriba.
    static let baston = dibujo(["h", "h"] + Array(repeating: "m", count: 11))
}
