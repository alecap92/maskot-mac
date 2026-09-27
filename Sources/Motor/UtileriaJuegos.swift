/// Utilería de las rutinas de magia y deportes.
public extension Utileria {
    // MARK: Magia

    /// La caja de donde sale el disfraz de mago.
    static func caja(abierta: Bool) -> Cuadro {
        dibujo([
            abierta ? ".........." : "hhhhhhhhhh",
            abierta ? "mEEEEEEEEm" : "mmmmmmmmmm",
            "mhhhhhhhhm",
            "mhhhmmhhhm",
            "mhhhhhhhhm",
            "mhhhhhhhhm",
            "mmmmmmmmmm",
        ])
    }

    /// Sombrero de mago con estrellas; la punta se dobla.
    static let sombrero = dibujo([
        "......PP...",
        ".....PPP...",
        ".....PuP...",
        "....PPPPP..",
        "....PPuPP..",
        "...PPPPPPP.",
        "PPPPPPPPPPP",
    ])

    /// Varita con la punta brillante.
    static let varita = dibujo(["u", "E", "E", "E", "E"])

    /// Destello de magia: estrella grande o chiquita.
    static func destello(grande: Bool) -> Cuadro {
        grande ? dibujo([".u.", "usu", ".u."]) : dibujo(["...", ".u.", "..."])
    }

    /// Silla vista de lado (la que levita).
    static let silla = dibujo([
        "m......",
        "m......",
        "m......",
        "m......",
        "mhhhhhh",
        "mmmmmmm",
        "m.....m",
        "m.....m",
        "m.....m",
        "m.....m",
    ])

    // MARK: Balones

    static let balonFutbol = dibujo([".kkk.", "kwEwk", "kEEEk", "kwEwk", ".kkk."])
    static let balonBasket = dibujo([".fff.", "ffEff", "EEEEE", "ffEff", ".fff."])
    static let balonVoley = dibujo([
        "..kkk..",
        ".kuwwk.",
        "kuwwaak",
        "kwwaawk",
        "kaawwuk",
        ".kwwuk.",
        "..kkk..",
    ])
    static let pelotaTenis = dibujo([".q.", "qqq", ".q."])
    /// Raqueta: cabeza con cuerdas y mango de madera.
    static let raqueta = dibujo([
        ".EEE.",
        "EwlwE",
        "ElwlE",
        "EwlwE",
        "ElwlE",
        ".EEE.",
        "..m..",
        "..m..",
        "..m..",
    ])

    // MARK: Canchas

    /// Arco de fútbol visto de frente, con malla.
    static let arco: Cuadro = {
        let ancho = 20
        var filas = [String(repeating: "w", count: ancho)]
        for f in 0..<13 {
            let malla = (0..<(ancho - 2)).map { ($0 + f) % 2 == 0 ? "l" : "." }.joined()
            filas.append("w" + malla + "w")
        }
        return dibujo(filas)
    }()

    /// Aro de basket: tablero, aro naranja, malla y poste. El aro está en la fila 5.
    static let aro: Cuadro = {
        var filas = [
            "wwwwwwwwww",
            "wwwiiiiwww",
            "wwwiwwiwww",
            "wwwiiiiwww",
            "wwwwkkwwww",
            ".ffffffff.",
            "..wlwlwl..",
            "...wlwl...",
        ]
        filas += Array(repeating: "....kk....", count: 24)
        return dibujo(filas)
    }()

    /// Fila del aro dentro del dibujo de `aro`.
    static let filaDelAro = 5

    /// Red de vóley vista de lado: poste con la malla arriba.
    static let red: Cuadro = {
        var filas = (0..<8).map { $0 % 2 == 0 ? "kwk" : "klk" }
        filas += Array(repeating: ".k.", count: 18)
        return dibujo(filas)
    }()
}
