import AppKit
import Characters
import SwiftUI

/// Herramienta de desarrollo: simula una rutina sin abrir ventanas y guarda
/// una tira de fotos para revisarla, sin capturar la pantalla (que puede
/// tener cosas privadas).
///
///     MASKOT_FOTOS="Leer en la banca" swift run Maskot
///     MASKOT_FOTOS="Gym" MASKOT_PERSONAJE=clawd swift run Maskot
///
/// Deja `docs/fotos/<rutina>.png` (una foto cada 1,5 s durante 27 s).
/// `MASKOT_FOTOS=Pomodoro` corre un ciclo completo con bloques de segundos.
@MainActor
enum Fotos {
    static func tomar(_ nombre: String) {
        if nombre == "Pomodoro" { return tomarPomodoro() }
        guard let rutina = Biblioteca.rutinas.first(where: { $0.nombre == nombre }) else {
            print("❌ No existe la rutina «\(nombre)»")
            return
        }
        let mascota = Mascota()
        if let id = ProcessInfo.processInfo.environment["MASKOT_PERSONAJE"], let p = Catalogo.buscar(id) {
            mascota.personaje = p
        }
        mascota.anchoEscena = 1000
        mascota.x = 300
        mascota.hacer(rutina)
        // MASKOT_SEGUNDOS alarga la simulación para rutinas largas.
        let entorno = ProcessInfo.processInfo.environment
        let segundos = Int(entorno["MASKOT_SEGUNDOS"] ?? "") ?? 27
        // MASKOT_CADA fija cada cuántos segundos se toma una foto.
        let cada = Double(entorno["MASKOT_CADA"] ?? "") ?? Double(segundos) / 18
        guardar(simular(mascota, segundos: segundos, cada: cada), nombre: nombre)
    }

    /// Un ciclo de 4 tomates con bloques cortos: 8 s de trabajo, 6 de
    /// descanso y 10 del largo.
    private static func tomarPomodoro() {
        let mascota = Mascota()
        mascota.anchoEscena = 1000
        mascota.x = 500
        mascota.pomodoro.formato = .init(nombre: "prueba", trabajo: 8, descanso: 6, largo: 10)
        mascota.iniciarPomodoro()
        guardar(simular(mascota, segundos: 66, cada: 3), nombre: "Pomodoro")
    }

    private static func simular(_ mascota: Mascota, segundos: Int, cada: Double) -> [NSImage] {
        let dt = 1.0 / 20
        var fotos: [NSImage] = []
        for i in 0..<(segundos * 20) {
            mascota.tick(dt: dt)
            if i % max(1, Int(cada * 20)) == 0, let img = ImageRenderer(content: VistaEscena(mascota: mascota)
                .background(Color(white: 0.93))
                .frame(width: mascota.anchoEscena, height: Escena.alto)
                .clipped()).nsImage {
                fotos.append(img)
            }
        }
        return fotos
    }

    private static func guardar(_ fotos: [NSImage], nombre: String) {
        // MASKOT_CUADROS=<carpeta>: guarda cada foto por separado (para armar GIFs).
        if let carpeta = ProcessInfo.processInfo.environment["MASKOT_CUADROS"] {
            try? FileManager.default.createDirectory(atPath: carpeta, withIntermediateDirectories: true)
            for (i, f) in fotos.enumerated() {
                let png = NSBitmapImageRep(data: f.tiffRepresentation!)!.representation(using: .png, properties: [:])!
                try? png.write(to: URL(fileURLWithPath: carpeta).appendingPathComponent(String(format: "%04d.png", i)))
            }
            print("✅ \(fotos.count) cuadros en \(carpeta)")
            return
        }

        // Una columna con todas las fotos.
        let ancho = fotos[0].size.width, alto = fotos[0].size.height
        let tira = NSImage(size: NSSize(width: ancho, height: alto * CGFloat(fotos.count)))
        tira.lockFocus()
        for (i, f) in fotos.enumerated() {
            f.draw(at: NSPoint(x: 0, y: alto * CGFloat(fotos.count - 1 - i)), from: .zero, operation: .copy, fraction: 1)
        }
        tira.unlockFocus()

        let carpeta = URL(fileURLWithPath: "docs/fotos")
        try? FileManager.default.createDirectory(at: carpeta, withIntermediateDirectories: true)
        let destino = carpeta.appendingPathComponent("\(nombre).png")
        let png = NSBitmapImageRep(data: tira.tiffRepresentation!)!.representation(using: .png, properties: [:])!
        try? png.write(to: destino)
        print("✅ \(destino.path)")
    }
}
