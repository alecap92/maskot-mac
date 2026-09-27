import AppKit
import Characters
import Motor

// Exporta hojas de referencia para revisar el look sin abrir la app:
//   characters/<id>/hoja.png   todas las poses de cada personaje
//   docs/utileria.png          los objetos y muebles
// Uso: `swift run Hoja` (todos) o `swift run Hoja clawd` (uno).

let lado: CGFloat = 10

struct Muestra {
    let titulo: String
    let cuadro: Cuadro
    var paleta: [Tinta: UInt32] = [:]
}

func poses(_ p: any Personaje) -> [Muestra] {
    var m = Expresion.allCases.map {
        Muestra(titulo: $0.nombre, cuadro: Sprite.cuadro(p, $0, destello: 1), paleta: p.paleta)
    }
    m += [
        Muestra(titulo: Gorra.deLado.nombre, cuadro: Sprite.cuadro(p, .neutro, gorra: .deLado), paleta: p.paleta),
        Muestra(titulo: "Caminando 1", cuadro: Sprite.cuadro(p, .neutro, paso: 1), paleta: p.paleta),
        Muestra(titulo: "Caminando 2", cuadro: Sprite.cuadro(p, .neutro, paso: 2), paleta: p.paleta),
        Muestra(titulo: "Brazo arriba", cuadro: Sprite.cuadro(p, .guino, brazoArriba: true), paleta: p.paleta),
        Muestra(titulo: "Auxilio", cuadro: Sprite.cuadro(p, .sorprendido, brazoArriba: true, brazoIzquierdoArriba: true), paleta: p.paleta),
        Muestra(titulo: "Tecleando", cuadro: Sprite.cuadro(p, .nerd, tecleo: 1), paleta: p.paleta),
    ]
    return m
}

let utileria = [
    Muestra(titulo: "Hoja", cuadro: Utileria.hoja),
    Muestra(titulo: "Bola de papel", cuadro: Utileria.bola),
    Muestra(titulo: "Caneca", cuadro: Utileria.caneca),
    Muestra(titulo: "Pesa", cuadro: Utileria.pesa),
    Muestra(titulo: "Café", cuadro: Utileria.Golosina.cafe.cuadro(lamiendo: false)),
    Muestra(titulo: "Porción de pizza", cuadro: Utileria.Golosina.pizza.cuadro(lamiendo: false)),
    Muestra(titulo: "Mesa", cuadro: Utileria.mesa),
    Muestra(titulo: "Horno prendido", cuadro: Utileria.horno(prendido: true)),
    Muestra(titulo: "Cuchillo", cuadro: Utileria.cuchillo),
    Muestra(titulo: "Pizza cruda", cuadro: Utileria.pizza(etapa: 3)),
    Muestra(titulo: "Pizza horneada", cuadro: Utileria.pizza(etapa: 3, horneada: true)),
    Muestra(titulo: "Paleta", cuadro: Utileria.Golosina.paleta.cuadro(lamiendo: true)),
    Muestra(titulo: "Helado", cuadro: Utileria.Golosina.helado.cuadro(lamiendo: true)),
    Muestra(titulo: "Banca", cuadro: Utileria.banca),
    Muestra(titulo: "Cama", cuadro: Utileria.cama),
    Muestra(titulo: "Libro", cuadro: Utileria.libro(hojeando: false)),
    Muestra(titulo: "Laptop", cuadro: Utileria.laptop(tecleando: true)),
]

func guardar(_ muestras: [Muestra], en ruta: String) throws {
    let columnas = 4
    let celda = CGSize(
        width: max(CGFloat(Sprite.ancho), CGFloat(muestras.map(\.cuadro.ancho).max() ?? 0)) * lado + 10,
        height: max(CGFloat(Sprite.alto), CGFloat(muestras.map(\.cuadro.alto).max() ?? 0)) * lado + 30
    )
    let filas = (muestras.count + columnas - 1) / columnas
    let ancho = Int(celda.width) * columnas
    let alto = Int(celda.height) * filas

    guard let ctx = CGContext(
        data: nil, width: ancho, height: alto, bitsPerComponent: 8, bytesPerRow: 0,
        space: CGColorSpace(name: CGColorSpace.sRGB)!,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { fatalError("No se pudo crear el lienzo") }

    // Origen arriba a la izquierda, como en SwiftUI.
    ctx.translateBy(x: 0, y: CGFloat(alto))
    ctx.scaleBy(x: 1, y: -1)
    ctx.setFillColor(CGColor(gray: 0.97, alpha: 1))
    ctx.fill(CGRect(x: 0, y: 0, width: ancho, height: alto))
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: true)

    for (i, muestra) in muestras.enumerated() {
        let origen = CGPoint(x: CGFloat(i % columnas) * celda.width, y: CGFloat(i / columnas) * celda.height)
        for (rect, tinta) in muestra.cuadro.rectangulos(lado: lado) {
            ctx.setFillColor(Tinta.cgColor(muestra.paleta[tinta] ?? tinta.rgb))
            ctx.fill(rect.offsetBy(dx: origen.x, dy: origen.y))
        }
        let texto = NSAttributedString(string: muestra.titulo, attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .medium),
            .foregroundColor: NSColor.darkGray,
        ])
        texto.draw(at: CGPoint(x: origen.x + 10, y: origen.y + celda.height - 26))
    }

    let destino = URL(fileURLWithPath: ruta)
    try FileManager.default.createDirectory(at: destino.deletingLastPathComponent(), withIntermediateDirectories: true)
    try NSBitmapImageRep(cgImage: ctx.makeImage()!).representation(using: .png, properties: [:])!.write(to: destino)
    print("✅ \(ruta)")
}

let pedido = CommandLine.arguments.dropFirst().first
for p in Catalogo.todos where pedido == nil || pedido == p.id {
    try guardar(poses(p), en: "characters/\(p.id)/hoja.png")
}
if pedido == nil {
    try guardar(utileria, en: "docs/utileria.png")
}
