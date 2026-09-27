import Motor
import SwiftUI

/// Medidas de la escena (la franja de abajo de la pantalla), en puntos.
enum Escena {
    static let alto: CGFloat = 240
    /// Tamaño de un píxel base (escala 1). Cada personaje lo multiplica por su
    /// `escala`, redondeado a puntos enteros para que el pixel art siga nítido.
    static let ladoBase: CGFloat = 5
    /// El del personaje actual (y su utilería). Lo fija `Mascota` al cambiar
    /// de personaje; solo se toca desde el hilo principal.
    nonisolated(unsafe) static var lado: CGFloat = ladoBase
    static var anchoPersonaje: CGFloat { CGFloat(Sprite.ancho) * lado }
    static var altoPersonaje: CGFloat { CGFloat(Sprite.alto) * lado }
    static var piso: CGFloat { alto }
}

struct VistaEscena: View {
    let mascota: Mascota

    var body: some View {
        let marco = mascota.marcoPersonaje
        let lado = Escena.lado

        ZStack(alignment: .topLeading) {
            Color.clear

            // Los muebles van detrás del personaje.
            ForEach(Mueble.allCases, id: \.self) { tipo in
                if let mx = mascota.muebles[tipo] {
                    let c = tipo.cuadro(hornoPrendido: mascota.hornoPrendido)
                    Pixeles(cuadro: c)
                        .position(x: mx, y: Escena.piso - CGFloat(c.alto) * lado / 2)
                }
            }

            // Decorados libres (caja, arco, aro, maceta…), detrás del personaje.
            ForEach(mascota.decorados.keys.sorted(), id: \.self) { id in
                if let d = mascota.decorados[id] {
                    Pixeles(cuadro: d.cuadro, espejo: d.espejo).position(d.centro)
                }
            }

            // Lo que hay encima de la mesa (la pizza).
            if let encima = mascota.sobreMesa, let mx = mascota.muebles[.mesa] {
                let alto = CGFloat(Utileria.mesa.alto + encima.alto) * lado
                Pixeles(cuadro: encima)
                    .position(x: mx, y: Escena.piso - alto + CGFloat(encima.alto) * lado / 2)
            }

            // A la espalda: detrás del cuerpo, del lado contrario a donde mira.
            if let espalda = mascota.espalda {
                let atras: CGFloat = mascota.mirandoIzquierda ? 1 : -1
                Pixeles(cuadro: espalda)
                    .position(x: marco.midX + atras * 6 * lado, y: marco.minY + 11 * lado)
            }

            Pixeles(cuadro: mascota.cuadro, espejo: mascota.mirandoIzquierda, paleta: mascota.personaje.paleta)
                .position(x: marco.midX, y: marco.midY)

            // Acostado, la cobija lo tapa hasta los ojos.
            if mascota.postura == .acostado, let camaX = mascota.muebles[.cama] {
                let manta = Utileria.manta
                Pixeles(cuadro: manta)
                    .position(x: camaX, y: Escena.piso - 3 * lado - CGFloat(manta.alto) * lado / 2)
            }

            if mascota.libro {
                // Cada tanto pasa la página.
                Pixeles(cuadro: Utileria.libro(hojeando: mascota.destello % 30 < 2))
                    .position(x: marco.midX, y: marco.minY + 16 * lado)
            }

            if mascota.laptop {
                Pixeles(cuadro: Utileria.laptop(tecleando: mascota.tecleando && mascota.destello % 2 == 0))
                    .position(x: marco.midX, y: marco.minY + 16 * lado)
            }

            if let frente = mascota.enFrente {
                Pixeles(cuadro: frente)
                    .position(x: marco.midX, y: marco.minY + 14 * lado)
            }

            // En la cabeza: la base del accesorio queda en la fila de la cabeza.
            if let sombrero = mascota.accesorio {
                let base = CGFloat(mascota.personaje.cabeza + Sprite.margen.fila) * lado
                Pixeles(cuadro: sombrero, espejo: mascota.mirandoIzquierda)
                    .position(x: marco.midX, y: marco.minY + base - CGFloat(sombrero.alto) * lado / 2)
            }

            if let objeto = mascota.objeto {
                Pixeles(cuadro: objeto.cuadro).position(objeto.centro)
            }

            // Decorados que van delante del personaje (binoculares, cámara).
            ForEach(mascota.delante.keys.sorted(), id: \.self) { id in
                if let d = mascota.delante[id] {
                    Pixeles(cuadro: d.cuadro, espejo: mascota.mirandoIzquierda).position(d.centro)
                }
            }

            // Chispas: en la punta de lo que tiene en la mano y alrededor del objeto.
            if mascota.magia {
                let grande = mascota.destello % 2 == 0
                if let cosa = mascota.cosa {
                    let punta = CGPoint(x: cosa.centro.x, y: cosa.centro.y - CGFloat(cosa.cuadro.alto) * lado / 2 - lado)
                    Pixeles(cuadro: Utileria.destello(grande: grande)).position(punta)
                }
                if let objeto = mascota.objeto {
                    let r = CGFloat(objeto.cuadro.ancho) * lado / 2 + 2 * lado
                    Pixeles(cuadro: Utileria.destello(grande: !grande))
                        .position(x: objeto.centro.x - r, y: objeto.centro.y - r / 2)
                    Pixeles(cuadro: Utileria.destello(grande: grande))
                        .position(x: objeto.centro.x + r, y: objeto.centro.y + r / 3)
                }
            }

            if let cosa = mascota.cosa {
                Pixeles(cuadro: cosa.cuadro, espejo: cosa.espejo).position(cosa.centro)
            }

            if let texto = mascota.globo {
                Globo(texto: texto)
                    .position(
                        x: min(max(marco.midX, 150), mascota.anchoEscena - 150),
                        y: marco.minY - 30
                    )
            }
        }
        .frame(width: mascota.anchoEscena, height: Escena.alto)
    }
}

/// Dibuja un cuadro de píxeles, sin suavizado. La paleta cambia colores
/// puntuales (la del personaje); el resto usa los de `Tinta`.
struct Pixeles: View {
    let cuadro: Cuadro
    var espejo = false
    var paleta: [Tinta: UInt32] = [:]

    var body: some View {
        Canvas { ctx, _ in
            for (rect, tinta) in cuadro.rectangulos(lado: Escena.lado, espejo: espejo) {
                ctx.fill(Path(rect), with: .color(Color(cgColor: Tinta.cgColor(paleta[tinta] ?? tinta.rgb))))
            }
        }
        .frame(width: CGFloat(cuadro.ancho) * Escena.lado, height: CGFloat(cuadro.alto) * Escena.lado)
    }
}

/// Globo de texto tipo cómic, con borde grueso y colita hacia el personaje.
struct Globo: View {
    let texto: String

    var body: some View {
        VStack(spacing: -2) {
            Text(texto)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(white: 0.1))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 6).fill(.white))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(white: 0.1), lineWidth: 2))
            Colita()
                .fill(.white)
                .overlay(Colita().stroke(Color(white: 0.1), lineWidth: 2))
                .frame(width: 14, height: 9)
        }
        .frame(maxWidth: 280)
        .fixedSize()
    }
}

private struct Colita: Shape {
    func path(in r: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: r.minX, y: r.minY))
            p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
            p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        }
    }
}
