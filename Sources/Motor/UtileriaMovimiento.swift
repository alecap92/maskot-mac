/// Utilería del baile.
public extension Utileria {
    /// Bola disco colgando de su hilo; `brillo` alterna los reflejos.
    static func bolaDisco(brillo: Bool) -> Cuadro {
        let a = brillo ? "wW" : "Ww"
        let b = brillo ? "Ww" : "wW"
        return dibujo([
            "...k...",
            "...k...",
            "..kkk..",
            ".k\(a)\(a.first!)k.",
            "k\(b)\(b)\(b.first!)k",
            "k\(a)\(a)\(a.first!)k",
            ".k\(b)\(b.first!)k.",
            "..kkk..",
        ])
    }
}
