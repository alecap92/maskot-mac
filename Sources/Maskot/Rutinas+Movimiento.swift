import Foundation
import Motor

/// Moverse: bailar y el estiramiento guiado (que también lanza la pausa activa).
extension Biblioteca {
    static let movimiento: [Rutina] = [
        Rutina(nombre: "Bailar", peso: 3, lugar: .cerca) { c in
            // Bola disco arriba, notas flotando y pasos al ritmo (un tiempo = 0,35 s).
            let lado = Escena.lado
            let arriba = Escena.piso - Escena.altoPersonaje
            let pasosDeBaile: [[Accion]] = [
                [.brazos(derecho: true, izquierdo: false), .mirar(izquierda: false)],
                [.brazos(derecho: false, izquierdo: true), .mirar(izquierda: true)],
                [.brazos(derecho: true, izquierdo: true), .saltar],
                [.brazos(derecho: false, izquierdo: false), .cara(.guino)],
                [.irA(c.x + 4 * lado), .cara(.feliz)],
                [.irA(c.x - 4 * lado)],
                [.brazos(derecho: true, izquierdo: true), .cara(.celebrando)],
                [.brazos(derecho: false, izquierdo: false), .cara(.feliz), .irA(c.x)],
            ]
            var pasos: [Accion] = [
                .decorado("bola", Utileria.bolaDisco(brillo: false), x: c.x, y: 36),
                .cara(.feliz), .decir(Baile.inicio.randomElement()), .esperar(1.5), .decir(nil),
            ]
            let compases = Int.random(in: 4...6)
            for tiempo in 0..<(compases * pasosDeBaile.count) {
                if tiempo == pasosDeBaile.count * 2 {
                    pasos += [.cara(.gafas), .decir("Modo disco 😎")]
                }
                if tiempo == pasosDeBaile.count * 2 + 4 { pasos.append(.decir(nil)) }
                pasos += pasosDeBaile[(tiempo + Int.random(in: 0...1)) % pasosDeBaile.count]
                // Las notas suben y vuelven a empezar; la bola titila.
                let subida = CGFloat(tiempo % 6) * 2 * lado
                pasos += [
                    .decorado("bola", Utileria.bolaDisco(brillo: tiempo % 2 == 0), x: c.x, y: 36),
                    .decorado("nota1", Utileria.nota(doble: false), x: c.x + 13 * lado, y: arriba + 8 * lado - subida),
                    .decorado("nota2", Utileria.nota(doble: true, tinta: "x"), x: c.x - 13 * lado,
                              y: arriba + 8 * lado - CGFloat((tiempo + 3) % 6) * 2 * lado),
                    .esperar(0.35),
                ]
            }
            pasos += [
                .brazos(derecho: true, izquierdo: true), .cara(.celebrando), .saltar,
                .decir(Baile.fin.randomElement()), .esperar(2.5), .decir(nil),
                .brazos(derecho: false, izquierdo: false), .cara(.neutro),
                .decorado("bola", nil, x: 0), .decorado("nota1", nil, x: 0), .decorado("nota2", nil, x: 0),
            ]
            return pasos
        },

        Rutina(nombre: "Estiramiento", peso: 2, lugar: .cerca) { _ in
            // Una serie corta para que el usuario la imite, con cuenta regresiva
            // en el globo. También la lanza `ContadorSentado` tras mucho rato sentado.
            func ejercicio(_ texto: String, _ pose: [Accion], segundos: Int = 5) -> [Accion] {
                var p: [Accion] = [.decir(texto)] + pose + [.esperar(1.2)]
                for n in stride(from: segundos, through: 1, by: -1) {
                    p += [.decir("\(texto)\n\(n)…"), .esperar(1)]
                }
                return p
            }
            var pasos: [Accion] = [
                .cara(.sorprendido), .saltar, .decir(Estirar.aviso.randomElement()), .esperar(3),
                .cara(.feliz), .decir("¿Listo? 3…"), .esperar(1), .decir("¿Listo? 2…"), .esperar(1),
                .decir("¿Listo? 1…"), .esperar(1), .decir("¡Vamos! 💪"), .saltar, .esperar(0.6),
            ]
            pasos += ejercicio("🙆 Brazos arriba, bien estirados",
                               [.brazos(derecho: true, izquierdo: true), .cara(.feliz)])
            pasos += ejercicio("↘️ Inclínate a la derecha",
                               [.mirar(izquierda: false), .brazos(derecho: false, izquierdo: true)])
            pasos += ejercicio("↙️ Ahora a la izquierda",
                               [.mirar(izquierda: true), .brazos(derecho: true, izquierdo: false)])
            pasos += [.brazos(derecho: false, izquierdo: false), .decir("🙂 Gira el cuello despacio…")]
            for _ in 0..<3 {
                pasos += [.mirar(izquierda: false), .cara(.parpadeo), .esperar(1.2),
                          .mirar(izquierda: true), .esperar(1.2)]
            }
            pasos += [.cara(.feliz), .decir("🤷 Sube y baja los hombros")]
            for _ in 0..<5 {
                pasos += [.brazos(derecho: true, izquierdo: true), .esperar(0.5),
                          .brazos(derecho: false, izquierdo: false), .esperar(0.5)]
            }
            pasos += [.decir("👐 Sacude las manos")]
            for i in 0..<12 {
                pasos += [.brazos(derecho: i % 2 == 0, izquierdo: i % 2 == 1), .esperar(0.18)]
            }
            pasos += [.brazos(derecho: false, izquierdo: false)]
            pasos += ejercicio("🫁 Respira profundo", [.cara(.parpadeo)], segundos: 4)
            pasos += [
                .cara(.celebrando), .saltar, .decir(Estirar.fin.randomElement()), .esperar(3.5),
                .decir(nil), .cara(.neutro),
            ]
            return pasos
        },
    ]
}

private enum Baile {
    static let inicio = ["🎶 ¡Pónganme música!", "🕺 Este es mi paso prohibido", "💃 ¡A la pista!"]
    static let fin = ["¡Gracias, gracias! 🕺", "¡Nadie me vio, ¿cierto?! 😅", "¡Otra, otra! 🎶"]
}

private enum Estirar {
    static let aviso = [
        "🧘 ¡Hora de estirar! Imítame 👇",
        "🧍 Llevas mucho rato sentado. ¡Estira conmigo!",
        "🧘 Pausa activa: haz lo mismo que yo 👇",
    ]
    static let fin = [
        "¡Muy bien! Tu espalda te lo agradece 💪",
        "¡Eso! Ahora sí, a seguir 🚀",
        "¡Listo! Toma agüita y seguimos 💧",
    ]
}
