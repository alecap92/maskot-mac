import Foundation
import Motor

/// Salidas: la excursión de montañista.
extension Biblioteca {
    static let aventura: [Rutina] = [
        Rutina(nombre: "Excursión", peso: 2) { c in
            // Disfrazado de montañista le da la vuelta completa a la pantalla:
            // sale por un borde, entra por el otro y vuelve a donde empezó.
            let dir: CGFloat = Bool.random() ? 1 : -1
            let vuelta = c.anchoEscena + Escena.anchoPersonaje
            return [
                .mirar(izquierda: dir < 0), .cara(.feliz),
                .accesorio(Utileria.sombreroMontana), .espalda(Utileria.mochila),
                .herramienta(Utileria.baston, arriba: false),
                .decir(Excursion.salida.randomElement()), .esperar(2.5), .decir(nil), .cara(.neutro),
                .pasear(dir * vuelta / 2),
                .cara(.feliz), .decir(Excursion.mitad.randomElement()), .esperar(3), .decir(nil), .cara(.neutro),
                .pasear(dir * vuelta / 2),
                .cara(.celebrando), .decir(Excursion.llegada.randomElement()), .esperar(2.5), .decir(nil),
                .cara(.neutro), .herramienta(nil, arriba: false), .espalda(nil), .accesorio(nil),
            ]
        },
        fogata,
        Rutina(nombre: "Binoculares", peso: 2, lugar: .cerca) { c in
            // Se los pone en los ojos con las dos manos y mira a un lado y al otro.
            let ojos = alturaDeLosOjos
            var pasos: [Accion] = [
                .cara(.pensando), .decir(Excursion.binoculares.randomElement()), .esperar(1.8), .decir(nil),
                .brazos(derecho: true, izquierdo: true), .cara(.neutro),
            ]
            for vez in 0..<Int.random(in: 3...5) {
                let izquierda = vez % 2 == 0
                pasos += [
                    .mirar(izquierda: izquierda),
                    .delante("binoculares", Utileria.binoculares, x: c.x + (izquierda ? -1 : 1) * 6 * Escena.lado, y: ojos),
                    .esperar(.random(in: 1.5...3)),
                ]
                if vez == 1 { pasos += [.cara(.sorprendido), .decir(Excursion.avistamiento.randomElement()), .esperar(2), .decir(nil), .cara(.neutro)] }
            }
            pasos += [.delante("binoculares", nil, x: 0, y: 0), .brazos(derecho: false, izquierdo: false),
                      .cara(.feliz), .decir("Todo en orden por aquí 🫡"), .esperar(2), .decir(nil), .cara(.neutro)]
            return pasos
        },
        Rutina(nombre: "Tomar fotos", peso: 2, lugar: .cerca) { c in
            // Cámara frente a la cara; apunta a un lado y al otro y dispara con flash.
            let ojos = alturaDeLosOjos
            var pasos: [Accion] = [
                .cara(.feliz), .decir(Excursion.camara.randomElement()), .esperar(1.8), .decir(nil),
                .brazo(true), .cara(.guino),
            ]
            for vez in 0..<Int.random(in: 3...5) {
                let dir: CGFloat = vez % 2 == 0 ? 1 : -1
                let camaraX = c.x + dir * 5 * Escena.lado
                pasos += [
                    .mirar(izquierda: dir < 0),
                    .delante("camara", Utileria.camara, x: camaraX, y: ojos),
                    .esperar(.random(in: 1...2)),
                    .delante("flash", Utileria.flash, x: camaraX + dir * 4 * Escena.lado, y: ojos - 2 * Escena.lado),
                    .esperar(0.15), .delante("flash", nil, x: 0, y: 0), .decir("📸 ¡Clic!"), .esperar(0.8), .decir(nil),
                ]
            }
            pasos += [.delante("camara", nil, x: 0, y: 0), .brazo(false), .cara(.celebrando),
                      .decir(Excursion.fotos.randomElement()), .esperar(2.5), .decir(nil), .cara(.neutro)]
            return pasos
        },
    ]

    static let fogata = Rutina(nombre: "Fogata", peso: 2, lugar: .esquina) { c in
        // Se sienta en un tronco, prende la fogata y asa un malvavisco en un palito.
        let dir = c.haciaDondeCabe
        let lado = Escena.lado
        let fuegoX = c.x + dir * 13 * lado
        // El palito cruza hacia el fuego: la punta (el malvavisco) queda justo
        // encima de las llamas y el mango cerca de la mano.
        let palito = (x: c.x + dir * 10.5 * lado, y: Escena.piso - 7 * lado)
        let quemado = Int.random(in: 0..<4) == 0
        var pasos: [Accion] = [
            .mirar(izquierda: dir < 0),
            .decorado("tronco", Utileria.tronco, x: c.x),
            .decorado("fuego", Utileria.fogata(prendida: false), x: fuegoX),
            .cara(.feliz), .decir(Excursion.fogata.randomElement()), .esperar(2), .decir(nil),
            .cara(.pensando), .esperar(1.5),
            .decorado("fuego", Utileria.fogata(prendida: true), x: fuegoX),
            .cara(.celebrando), .saltar, .decir("¡Fuego! 🔥"), .esperar(1.5), .decir(nil),
            .postura(.sentado), .cara(.neutro),
            .delante("palito", Utileria.malvavisco(etapa: 0), x: palito.x, y: palito.y),
        ]
        // Las llamas titilan todo el rato; a mitad de camino el malvavisco se dora.
        let vueltas = Int.random(in: 90...240) // 1,5 a 4 minutos
        for i in 0..<vueltas {
            pasos += [.decorado("fuego", Utileria.fogata(prendida: true, cuadro: i), x: fuegoX), .esperar(0.5)]
            if i == vueltas / 2 {
                pasos += [.delante("palito", Utileria.malvavisco(etapa: 1), x: palito.x, y: palito.y), .cara(.feliz)]
            }
        }
        pasos += quemado
            ? [.delante("palito", Utileria.malvavisco(etapa: 2), x: palito.x, y: palito.y),
               .cara(.sorprendido), .decir("¡Se me quemó! 😅"), .esperar(2.5)]
            : [.cara(.celebrando), .decir("¡Doradito perfecto! 🤤"), .esperar(2)]
        pasos += [
            .delante("palito", nil, x: 0, y: 0), .cara(.feliz),
            .decir(quemado ? "Igual me lo como 😋" : "Mmm 😋"), .esperar(2), .decir(nil),
            .decorado("fuego", Utileria.fogata(prendida: false), x: fuegoX), .esperar(1),
            .postura(.dePie), .cara(.neutro),
            .decorado("fuego", nil, x: 0), .decorado("tronco", nil, x: 0),
        ]
        return pasos
    }

    /// A la altura de los ojos del personaje (aprox.), para lo que se pone en la cara.
    private static var alturaDeLosOjos: CGFloat {
        Escena.piso - Escena.altoPersonaje + CGFloat(Sprite.margen.fila + 9) * Escena.lado
    }
}

private enum Excursion {
    static let binoculares = ["🔭 ¿Qué hay por allá?", "Modo explorador 🧭"]
    static let fogata = ["🏕️ Noche de fogata", "¿Alguien trajo malvaviscos? 🍡"]
    static let avistamiento = ["¡Un pájaro! 🐦", "Veo, veo… ¡un bug! 🐛", "¿Eso es un unicornio? 🦄", "¡Tierra a la vista! 🏝️"]
    static let camara = ["📷 ¡Hora de las fotos!", "Sonrían… 📷"]
    static let fotos = ["¡Esta va para Instagram! ✨", "Salieron divinas 😎", "Me gané un premio de fotografía 🏆"]
    static let salida = ["🏔️ ¡Me voy de excursión!", "🥾 A conquistar la pantalla", "🎒 Mochila lista, ¡vámonos!"]
    static let mitad = ["¡Qué vista! 🌄", "Uff, ¿cuánto falta? 😮‍💨", "Aquí hay buena señal 📶"]
    static let llegada = ["¡Vuelta completa! 🏁", "¡Volví! Traje fotos mentales 📸", "Cumbre conquistada ⛰️"]
}
