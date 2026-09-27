import Motor

/// Todos los personajes disponibles. Para agregar uno: crea su carpeta en
/// `characters/` y súmalo a esta lista (ver `characters/README.md`).
public enum Catalogo {
    public static let todos: [any Personaje] = [
        Clawd(),
        // La familia Koru (ver FAMILIA.md).
        Koru(),
        Tuno(),
        Nilo(),
        Brio(),
        Luma(),
        Mako(),
        Orbi(),
    ]

    public static var porDefecto: any Personaje { todos[0] }

    public static func buscar(_ id: String) -> (any Personaje)? {
        todos.first { $0.id == id }
    }
}
