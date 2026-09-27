import Foundation

/// Utilería de los hobbies: guitarra, pesca, yoyo, selfie y periódico.
public extension Utileria {
    // MARK: Guitarra

    /// Guitarra roja vista de frente, acostada: la caja a la izquierda y el
    /// mástil a la derecha. `vibrando` mueve las cuerdas (rasgueo).
    static func guitarra(vibrando: Bool) -> Cuadro {
        let cuerdas = vibrando ? "jwjwjwjwjwjwj" : "jjjjjjjjjjjjj"
        // Dos filas vacías arriba: la escena centra lo de enfrente en la fila
        // 14 del lienzo y así la guitarra baja a la panza y deja ver la cara.
        let aire = [String](repeating: String(repeating: ".", count: 20), count: 2)
        return dibujo(aire + [
            "..EEEE..............",
            ".ExxxxE..........EjE",
            "ExxxxxxEmmmmmmmmmEEE",
            "ExxEE" + cuerdas + "EE",
            "ExxEExxEmmmmmmmmmEEE",
            ".ExxxxE..........EjE",
            "..EEEE..............",
        ])
    }

    /// Notita musical que flota: ♪ (sencilla) o ♫ (doble).
    static func nota(doble: Bool, tinta: Character = "P") -> Cuadro {
        let filas = doble
            ? [".PPPP", ".P..P", ".P..P", "PP.PP", "PP.PP"]
            : ["..PP.", "..P.P", "..P..", "PPP..", "PP..."]
        return dibujo(filas.map { String($0.map { $0 == "P" ? tinta : $0 }) })
    }

    // MARK: Pesca

    /// Laguito visto de lado, con juncos en las orillas. La superficie del
    /// agua es la fila 2 (tres filas por encima del piso).
    static let lago = dibujo([
        "..G.............................G..",
        ".GG.............................GG.",
        "GGWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWGG",
        "TWWWWlWWWWWWWWWWWlWWWWWWWWWWlWWWWWT",
        ".TTTWWWWWWWWWWWWWWWWWWWWWWWWWWWTTT.",
    ])

    /// Caña de pescar: el mango queda abajo al centro del cuadro (en la mano)
    /// y la punta arriba hacia donde mira. `tensa`: la punta se dobla (picó).
    static func cana(haciaIzquierda: Bool, tensa: Bool = false) -> Cuadro {
        let ancho = 16, alto = 9
        var filas = [[Character]](repeating: [Character](repeating: ".", count: ancho), count: alto)
        for f in 0..<alto {
            // Diagonal desde el mango (col 8, fila 8) hasta la punta (col 15, fila 0).
            let col = 8 + Int((Double(alto - 1 - f) * 7 / 8).rounded())
            let tinta: Character = f >= 6 ? "E" : f >= 3 ? "m" : "j"
            filas[f][col] = tinta
        }
        if tensa {
            // La punta se arquea hacia abajo, jalada por el pez.
            filas[0] = [Character](repeating: ".", count: ancho)
            filas[1] = [Character](repeating: ".", count: ancho)
            filas[1][13] = "j"; filas[1][14] = "j"
            filas[2] = [Character](repeating: ".", count: ancho)
            filas[2][12] = "j"; filas[2][15] = "j"
            filas[3][15] = "j"
        }
        let texto = filas.map { String(haciaIzquierda ? $0.reversed() : $0) }
        return dibujo(texto)
    }

    /// El sedal, de la punta de la caña (arriba) al corcho (abajo), un poco
    /// colgado. Sin espejo va de izquierda a derecha.
    static func sedal(ancho: Int, alto: Int, haciaIzquierda: Bool) -> Cuadro {
        let ancho = max(ancho, 2), alto = max(alto, 2)
        var filas = [[Character]](repeating: [Character](repeating: ".", count: ancho), count: alto)
        var anterior = 0
        for col in 0..<ancho {
            let t = Double(col) / Double(ancho - 1)
            let fila = min(alto - 1, Int((Double(alto - 1) * pow(t, 1.6)).rounded()))
            // Rellena los saltos para que la línea no quede punteada.
            for f in min(anterior, fila)...max(anterior, fila) { filas[f][col] = "k" }
            anterior = fila
        }
        return dibujo(filas.map { String(haciaIzquierda ? $0.reversed() : $0) })
    }

    /// El corcho flotando: rojo arriba, blanco abajo.
    static let corcho = dibujo([".x.", "xxx", "www"])

    /// El corcho hundido: solo asoma la puntica y el agua hace ondas.
    static let corchoHundido = dibujo([
        "...x...",
        "l.xxx.l",
    ])

    /// Salpicón de agua (al caer el corcho o al devolver el pez).
    static func salpicon(grande: Bool) -> Cuadro {
        grande
            ? dibujo(["W.....W", ".W.W.W.", "..lWl.."])
            : dibujo([".......", "..W.W..", "...l..."])
    }

    /// Un pececito naranja (mirando a la izquierda).
    static let pez = dibujo([
        "...nnn...",
        ".nnnnnn.f",
        "nEnnnnnff",
        ".nnnnnn.f",
        "...nnn...",
    ])

    /// La bota vieja que sale a veces en vez del pez (goteando).
    static let bota = dibujo([
        ".mmmm...",
        ".mhhm...",
        ".mmmm...",
        ".mmmm...",
        ".mmmmmmm",
        ".mmmmmmm",
        ".EEEEEEE",
        "W.....W.",
    ])

    // MARK: Yoyo

    static let yoyo = dibujo([".xx.", "xjjx", "xjjx", ".xx."])

    // MARK: Selfie

    /// El celular visto por detrás: la cámara arriba.
    static let celular = dibujo([
        "EEEE",
        "EjeE",
        "EeeE",
        "EeeE",
        "EeeE",
        "EEEE",
    ])

    /// El flash de la foto: un destello grande con rayos (y el que se apaga).
    static func flash(grande: Bool) -> Cuadro {
        let n = 13, c = n / 2
        var filas = [[Character]](repeating: [Character](repeating: ".", count: n), count: n)
        let radio = grande ? 6 : 3
        for f in 0..<n {
            for k in 0..<n {
                let dx = abs(k - c), dy = abs(f - c)
                if dx + dy <= (grande ? 2 : 1) {
                    filas[f][k] = "w"
                } else if (dx == 0 || dy == 0) && max(dx, dy) <= radio {
                    filas[f][k] = max(dx, dy) <= radio - 2 ? "w" : "u"
                } else if dx == dy && dx <= radio - 2 {
                    filas[f][k] = "u"
                }
            }
        }
        return dibujo(filas.map { String($0) })
    }

    // MARK: Periódico

    /// El periódico abierto visto de frente, por páginas (0, 1, 2).
    /// `pasando` = a mitad de pasar la hoja (la derecha levantada).
    static func periodico(pagina: Int, pasando: Bool = false) -> Cuadro {
        let paginas: [[String]] = [
            [
                "wwwwwwwwwwwwwwww",
                "wEEEEEEEEEEEEEEw",
                "wwwwwwwwwwwwwwww",
                "wkkkkkwlwllllllw",
                "wkjjjkwlwwwwwwww",
                "wkjjjkwlwllllllw",
                "wkkkkkwlwwwwwwww",
                "wwwwwwwlwllllllw",
                "wllllwwlwwwwwwww",
            ],
            [
                "wwwwwwwwwwwwwwww",
                "wxxxxxxlwxxxxxxw",
                "wwwwwwwlwwwwwwww",
                "wllllllwlwkkkkkw",
                "wwwwwwwlwwkqqqkw",
                "wllllllwlwkqqqkw",
                "wwwwwwwlwwkkkkkw",
                "wllllllwlwwwwwww",
                "wwwwwwwlwwllllww",
            ],
            [
                "wwwwwwwwwwwwwwww",
                "wEEEEEElwEEEEEEw",
                "wwwwwwwlwwwwwwww",
                "wllllllwlkkkkkkw",
                "wwwwwwwlwkuuuukw",
                "wkkkkkwwlkuuuukw",
                "wkiiikwlwkkkkkkw",
                "wkkkkkwwlwwwwwww",
                "wwwwwwwlwllllllw",
            ],
        ]
        // Cuatro filas vacías arriba bajan el periódico hasta la panza (la
        // escena centra lo de enfrente en la fila 14) para que asomen los ojos.
        let aire = [String](repeating: String(repeating: ".", count: 16), count: 4)
        let hoja = paginas[((pagina % 3) + 3) % 3]
        guard pasando else { return dibujo(aire + hoja) }
        // La hoja derecha se levanta (dos filas más arriba) y se ve su revés en blanco.
        let revés = ["wwwwwwww", "wllllllw", "wwwwwwww", "wllllllw", "wwwwwwww", "wllllllw", "wwwwwwww"]
        var filas = aire + hoja.map { String($0.prefix(8)) + "........" }
        for (i, r) in revés.enumerated() {
            let f = aire.count - 2 + i
            filas[f] = String(filas[f].prefix(8)) + r
        }
        return dibujo(filas)
    }
}
