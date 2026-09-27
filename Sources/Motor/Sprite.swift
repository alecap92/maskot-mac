import CoreGraphics

/// Un cuadro de la animación: una grilla de píxeles, `nil` = transparente.
public struct Cuadro: Sendable {
    public let pixeles: [[Tinta?]]
    public var ancho: Int { pixeles.first?.count ?? 0 }
    public var alto: Int { pixeles.count }

    /// Los píxeles como rectángulos, origen arriba a la izquierda.
    public func rectangulos(lado: CGFloat, espejo: Bool = false) -> [(CGRect, Tinta)] {
        var salida: [(CGRect, Tinta)] = []
        for (fila, linea) in pixeles.enumerated() {
            for (col, tinta) in linea.enumerated() {
                guard let tinta else { continue }
                let x = espejo ? ancho - 1 - col : col
                salida.append((CGRect(x: CGFloat(x) * lado, y: CGFloat(fila) * lado, width: lado, height: lado), tinta))
            }
        }
        return salida
    }
}

/// Arma los cuadros de cualquier `Personaje`. El cuerpo vive en una grilla de
/// 16×16 y el lienzo le deja margen alrededor para brazos en alto y efectos.
public enum Sprite {
    public static let ancho = 20
    public static let alto = 18
    /// Dónde cae la esquina del cuerpo dentro del lienzo.
    public static let margen = (col: 2, fila: 2)

    /// - Parameters:
    ///   - paso: 0 quieto, 1 y 2 levantan un grupo de patas distinto (caminar).
    ///   - destello: contador que anima los efectos (chispas, zetas, puntos).
    ///   - brazoArriba: levanta el brazo derecho (para cargar cosas).
    ///   - brazoIzquierdoArriba: levanta el izquierdo (para pedir auxilio).
    ///   - tecleo: 0 quieto; 1 y 2 suben un brazo y bajan el otro (escribiendo).
    public static func cuadro(
        _ personaje: any Personaje,
        _ expresion: Expresion,
        gorra: Gorra = .haciaAtras,
        paso: Int = 0,
        destello: Int = 0,
        brazoArriba: Bool = false,
        brazoIzquierdoArriba: Bool = false,
        tecleo: Int = 0
    ) -> Cuadro {
        var lienzo = [[Tinta?]](repeating: [Tinta?](repeating: nil, count: ancho), count: alto)

        func poner(_ fila: Int, _ col: Int, _ tinta: Tinta?) {
            let f = fila + margen.fila, c = col + margen.col
            guard lienzo.indices.contains(f), lienzo[f].indices.contains(c) else { return }
            lienzo[f][c] = tinta
        }
        func pintar(_ fila: Int, _ linea: String) {
            for (col, letra) in linea.enumerated() where letra != "." {
                if let tinta = Tinta(rawValue: letra) { poner(fila, col, tinta) }
            }
        }
        /// Aplica un cambio de brazo; `espejo` lo pasa al brazo izquierdo.
        func aplicar(_ cambio: Cambio, espejo: Bool) {
            let col = { (c: Int) in espejo ? 15 - c : c }
            for p in cambio.quita { poner(p.fila, col(p.col), nil) }
            for p in cambio.pone { poner(p.fila, col(p.col), .cuerpo) }
            for p in cambio.pinta { poner(p.fila, col(p.col), p.tinta) }
        }

        for (fila, linea) in personaje.cuerpo.enumerated() { pintar(fila, linea) }
        for (fila, linea) in personaje.gorra(gorra) { pintar(fila, linea) }
        let cara = personaje.cara(expresion) ?? personaje.cara(.neutro) ?? [:]
        for (fila, linea) in cara { pintar(fila, linea) }

        let brazos = personaje.brazos
        if brazoArriba { aplicar(brazos.arriba, espejo: false) }
        if brazoIzquierdoArriba { aplicar(brazos.arriba, espejo: true) }
        if tecleo != 0 {
            // Un brazo sube y el otro baja, alternando.
            aplicar(brazos.teclearArriba, espejo: tecleo == 1)
            aplicar(brazos.teclearAbajo, espejo: tecleo != 1)
        }

        // Al caminar se levanta un grupo de patas: se borra su punta.
        let patas = personaje.patas
        let levantadas = paso % 3 == 1 ? patas.paso1 : paso % 3 == 2 ? patas.paso2 : []
        for col in levantadas { poner(patas.fila, col, nil) }

        if let efecto = expresion.efecto {
            for (fila, col, tinta) in pixelesDe(efecto, destello: destello)
            where lienzo.indices.contains(fila) && lienzo[fila].indices.contains(col) {
                lienzo[fila][col] = tinta
            }
        }
        return Cuadro(pixeles: lienzo)
    }

    /// Coordenadas del lienzo completo (no del cuerpo).
    private static func pixelesDe(_ efecto: Efecto, destello: Int) -> [(Int, Int, Tinta)] {
        switch efecto {
        case .chispas:
            let centros: [(Int, Int, Tinta)] = [
                (3, 2, .chispaRosa), (1, 9, .chispaNaranja), (2, 16, .chispaRosa),
                (6, 18, .chispaNaranja), (7, 1, .chispaNaranja),
            ]
            // Titilan: en cada destello la mitad se encoge a un solo punto.
            return centros.enumerated().flatMap { i, c -> [(Int, Int, Tinta)] in
                let (f, col, t) = c
                if (i + destello) % 2 == 0 { return [(f, col, t)] }
                return [(f, col, t), (f - 1, col, t), (f + 1, col, t), (f, col - 1, t), (f, col + 1, t)]
            }
        case .zetas:
            // Una Z de 4×4 que va subiendo.
            let (f, col) = destello % 2 == 0 ? (2, 15) : (0, 16)
            let z = ["zzzz", "..z.", ".z..", "zzzz"]
            return z.enumerated().flatMap { df, linea in
                linea.enumerated().compactMap { dc, letra in
                    letra == "z" ? (f + df, col + dc, Tinta.zeta) : nil
                }
            }
        case .puntos:
            // Puntos suspensivos que aparecen de a uno.
            return (0..<(destello % 4)).map { (3, 14 + $0 * 2, .punto) }
        }
    }
}
