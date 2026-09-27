// swift-tools-version: 6.0
import PackageDescription

/// Lo que no es código dentro de `characters/` queda fuera de la compilación.
/// Al agregar un personaje, suma su id aquí (su `hoja.png` no se compila).
let personajes = ["clawd", "koru", "tuno", "nilo", "brio", "luma", "mako", "orbi"]
let noCodigo = ["README.md", "FAMILIA.md"] + personajes.map { "\($0)/hoja.png" }

let package = Package(
    name: "Maskot",
    platforms: [.macOS(.v14)],
    targets: [
        // El motor: píxeles, expresiones, utilería y el contrato `Personaje`. Sin UI.
        .target(name: "Motor", path: "Sources/Motor"),
        // Los personajes, uno por carpeta. Las imágenes de cada uno no se compilan.
        .target(
            name: "Characters",
            dependencies: ["Motor"],
            path: "characters",
            exclude: noCodigo
        ),
        // La mascota en el escritorio.
        .executableTarget(name: "Maskot", dependencies: ["Motor", "Characters"], path: "Sources/Maskot"),
        // Exporta la hoja de expresiones de cada personaje: `swift run Hoja`.
        .executableTarget(name: "Hoja", dependencies: ["Motor", "Characters"], path: "Sources/Hoja"),
    ]
)
