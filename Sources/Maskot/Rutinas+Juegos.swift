import Foundation
import Motor

/// Magia y deportes.
extension Biblioteca {
    static let juegos: [Rutina] = [
        // MARK: Magia

        Rutina(nombre: "Mago", peso: 2, lugar: .cerca) { c in
            // Aparece una caja: adentro está el disfraz. Hace levitar una silla,
            // la baja con cuidado… y con el balón ya no le sale tan bien.
            let dir = c.haciaDondeCabe
            let izq = dir < 0
            let cajaX = c.dentro(c.x + dir * 150)
            let junto = cajaX - dir * (Escena.anchoPersonaje / 2 + 40)
            let cosaX = c.dentro(cajaX + dir * 110)
            let varita = Utileria.varita
            return [
                .decorado("caja", Utileria.caja(abierta: false), x: cajaX),
                .mirar(izquierda: izq), .cara(.sorprendido), .decir(FrasesJuegos.mago.caja.randomElement()),
                .esperar(2), .decir(nil), .cara(.pensando), .irA(junto), .mirar(izquierda: izq), .esperar(1),
                .decorado("caja", Utileria.caja(abierta: true), x: cajaX), .cara(.sorprendido), .esperar(0.8),
                .cara(.feliz), .decir(FrasesJuegos.mago.disfraz), .esperar(1.5),
                .accesorio(Utileria.sombrero), .esperar(0.6),
                .herramienta(varita, arriba: true), .cara(.guino), .esperar(0.8), .decir(nil),
                // La silla.
                .cara(.neutro), .objeto(Utileria.silla, x: cosaX), .esperar(0.8),
                .magia(true), .cara(.pensando), .decir(FrasesJuegos.mago.hechizo), .levitar(segundos: 4.5),
                .decir(nil), .cara(.feliz), .esperar(0.8),
                .herramienta(varita, arriba: false), .caer, .magia(false),
                .cara(.celebrando), .decir(FrasesJuegos.mago.bien.randomElement()), .esperar(2), .decir(nil),
                // Ahora el balón: se le va.
                .objeto(Utileria.balonBasket, x: cosaX), .cara(.guino), .decir(FrasesJuegos.mago.otraVez), .esperar(1.2),
                .herramienta(varita, arriba: true), .magia(true), .cara(.pensando), .decir(nil),
                .levitar(segundos: 3.5), .magia(false), .herramienta(varita, arriba: false),
                .cara(.sorprendido), .caer, .decir(FrasesJuegos.mago.ups), .saltar, .esperar(1.5),
                .cara(.guino), .decir(FrasesJuegos.mago.fin), .esperar(2.5), .decir(nil),
                // Guarda todo en la caja.
                .cara(.neutro), .objeto(nil), .herramienta(nil, arriba: false), .esperar(0.4),
                .accesorio(nil), .esperar(0.5),
                .decorado("caja", Utileria.caja(abierta: false), x: cajaX), .esperar(1),
                .decorado("caja", nil, x: cajaX), .esperar(0.5),
            ]
        },

        // MARK: Deportes

        Rutina(nombre: "Fútbol", peso: 2, lugar: .cerca) { c in
            // Arco lejos, balón a los pies: lo conduce, apunta y patea.
            let dir = c.haciaDondeCabe
            let izq = dir < 0
            let arcoX = c.dentro(c.x + dir * 430)
            let tiro = arcoX - dir * 230
            let balon = Utileria.balonFutbol
            let redY = Escena.piso - 7 * Escena.lado
            var pasos: [Accion] = [
                .decorado("arco", Utileria.arco, x: arcoX),
                .mirar(izquierda: izq), .cara(.feliz), .objeto(balon),
                .decir(FrasesJuegos.futbol.inicio.randomElement()), .esperar(2), .decir(nil),
                // Unos jueguitos antes de arrancar.
                .cara(.feliz), .toque(altura: 45), .toque(altura: 55), .toque(altura: 45),
                .decir(FrasesJuegos.futbol.jueguitos), .toque(altura: 60), .esperar(0.6), .decir(nil),
                .cara(.gafas), .conducir(tiro), .mirar(izquierda: izq),
                .cara(.pensando), .esperar(1), .cara(.sorprendido), .saltar,
                .volar(x: arcoX + dir * 10, y: redY, altura: 50, segundos: 0.8),
                .caer, .cara(.celebrando), .decir(FrasesJuegos.futbol.gol),
            ]
            for _ in 0..<4 { pasos += [.brazos(derecho: true, izquierdo: true), .saltar, .esperar(0.15)] }
            pasos += [
                .brazos(derecho: false, izquierdo: false), .esperar(1.5), .decir(nil),
                .cara(.feliz), .irA(arcoX - dir * 60), .objeto(nil), .esperar(0.5),
                .decorado("arco", nil, x: arcoX), .cara(.neutro),
            ]
            return pasos
        },

        Rutina(nombre: "Basket", peso: 2, lugar: .cerca) { c in
            // Dribla y tira al aro dos o tres veces: a veces entra, a veces no.
            let dir = c.haciaDondeCabe
            let izq = dir < 0
            let lado = Escena.lado
            let aro = Utileria.aro
            let aroX = c.dentro(c.x + dir * 260)
            let aroY = Escena.piso - CGFloat(aro.alto) * lado + (CGFloat(Utileria.filaDelAro) + 0.5) * lado
            let tiro = aroX - dir * 220
            let balon = Utileria.balonBasket
            let pisoBalon = Escena.piso - CGFloat(balon.alto) * lado / 2
            let aSusPies = tiro + dir * 45

            var pasos: [Accion] = [
                .decorado("aro", aro, x: aroX), .irA(tiro), .mirar(izquierda: izq),
                .cara(.feliz), .objeto(balon), .decir(FrasesJuegos.basket.inicio.randomElement()),
                .rebotar(veces: 4), .decir(nil),
            ]
            let tiros = Int.random(in: 2...3)
            var encestadas = 0
            for i in 0..<tiros {
                // Al menos una entra.
                let entra = (i == tiros - 1 && encestadas == 0) || Bool.random()
                pasos += [.cara(.neutro), .rebotar(veces: 3), .levantarObjeto, .cara(.pensando), .esperar(0.8),
                          .brazo(false), .volar(x: aroX, y: aroY - 3 * lado, altura: 90, segundos: 1.1)]
                if entra {
                    encestadas += 1
                    pasos += [.caer, .cara(.celebrando), .decir(FrasesJuegos.basket.swish.randomElement()), .saltar,
                              .esperar(1.2), .decir(nil)]
                } else {
                    // Pega en el aro y sale para un lado.
                    let rebote: CGFloat = Bool.random() ? 1 : -1
                    pasos += [.volar(x: aroX + rebote * 150, y: pisoBalon, altura: 45, segundos: 0.8),
                              .cara(.sorprendido), .decir(FrasesJuegos.basket.casi.randomElement()), .esperar(1.5), .decir(nil)]
                }
                // El balón vuelve rodando a sus pies.
                pasos += [.cara(.neutro), .volar(x: aSusPies, y: pisoBalon, altura: 25, segundos: 1)]
            }
            pasos += [.cara(.feliz), .decir(FrasesJuegos.basket.fin), .esperar(2), .decir(nil),
                      .objeto(nil), .decorado("aro", nil, x: aroX), .cara(.neutro)]
            return pasos
        },

        Rutina(nombre: "Vóley", peso: 2, lugar: .cerca) { c in
            // Toquecitos con los brazos arriba y un remate por encima de la red.
            let dir = c.haciaDondeCabe
            let izq = dir < 0
            let redX = c.dentro(c.x + dir * 170)
            let balon = Utileria.balonVoley
            let pisoBalon = Escena.piso - CGFloat(balon.alto) * Escena.lado / 2
            let caida = c.dentro(redX + dir * 180)

            var pasos: [Accion] = [
                .decorado("red", Utileria.red, x: redX), .mirar(izquierda: izq), .cara(.feliz),
                .decir(FrasesJuegos.voley.inicio.randomElement()), .esperar(1.8), .decir(nil),
                .objeto(balon), .brazos(derecho: true, izquierdo: true), .objetoArriba, .esperar(0.4),
            ]
            let toques = Int.random(in: 5...8)
            for i in 1...toques {
                pasos += [.toque(altura: .random(in: 50...80)),
                          .brazos(derecho: false, izquierdo: false), .esperar(0.05),
                          .brazos(derecho: true, izquierdo: true)]
                if i == 3 { pasos += [.decir("\(i)… \(FrasesJuegos.voley.contar.randomElement()!)")] }
                if i == 5 { pasos += [.decir(nil)] }
            }
            pasos += [
                .decir(nil), .toque(altura: 90), .cara(.sorprendido), .saltar,
                .brazos(derecho: true, izquierdo: false),
                .volar(x: caida, y: pisoBalon, altura: 130, segundos: 1.1),
                .brazos(derecho: false, izquierdo: false),
                .cara(.celebrando), .decir(FrasesJuegos.voley.punto), .saltar, .saltar, .esperar(1.5), .decir(nil),
                .cara(.neutro), .objeto(nil), .decorado("red", nil, x: redX),
            ]
            return pasos
        },

        Rutina(nombre: "Tenis", peso: 2, lugar: .cerca) { c in
            // Raqueta en mano contra un rival imaginario fuera de la pantalla.
            let dir = c.haciaDondeCabe
            let izq = dir < 0
            let lado = Escena.lado
            let rivalX = dir > 0 ? c.anchoEscena + 60 : -60
            let raqueta = Utileria.raqueta
            let pelota = Utileria.pelotaTenis
            let pegada = CGPoint(x: c.x + dir * 45, y: Escena.piso - 12 * lado)
            func swing() -> [Accion] {
                [.herramienta(raqueta, arriba: false), .esperar(0.12), .herramienta(raqueta, arriba: true)]
            }
            func devolverla(_ segundos: Double) -> Accion {
                .volar(x: rivalX, y: Escena.piso - 110, altura: 70, segundos: segundos)
            }

            var pasos: [Accion] = [
                .mirar(izquierda: izq), .cara(.gafas), .herramienta(raqueta, arriba: false),
                .decir(FrasesJuegos.tenis.inicio.randomElement()), .esperar(2), .decir(nil),
                // Saque: la tira arriba y le pega.
                .objeto(pelota), .cara(.pensando), .rebotar(veces: 3), .esperar(0.4), .objetoArriba, .esperar(0.5),
                .toque(altura: 70), .cara(.sorprendido),
            ]
            pasos += swing() + [devolverla(1.1), .cara(.neutro), .herramienta(raqueta, arriba: false)]
            let peloteos = Int.random(in: 2...3)
            for _ in 0..<peloteos {
                pasos += [.esperar(.random(in: 0.6...1.2)),
                          .objetoEn(x: rivalX, y: Escena.piso - 100),
                          .volar(x: pegada.x, y: pegada.y, altura: 80, segundos: 1.3),
                          .cara(.sorprendido)]
                pasos += swing() + [devolverla(1.0), .cara(.neutro), .herramienta(raqueta, arriba: false)]
            }
            if Bool.random() {
                pasos += [.esperar(1.2), .cara(.celebrando), .decir(FrasesJuegos.tenis.ace), .saltar, .saltar]
            } else {
                // El rival la devuelve… y cae afuera, detrás de él (o se va de la
                // pantalla si está pegado al borde).
                let atras = c.x - dir * 220
                let afuera = atras > 40 && atras < c.anchoEscena - 40 ? atras : (dir > 0 ? -60 : c.anchoEscena + 60)
                pasos += [.esperar(0.8), .objetoEn(x: rivalX, y: Escena.piso - 100),
                          .volar(x: afuera, y: Escena.piso - 2 * lado, altura: 110, segundos: 1.4),
                          .mirar(izquierda: !izq), .herramienta(raqueta, arriba: false),
                          .cara(.sorprendido), .decir(FrasesJuegos.tenis.out), .esperar(1.2),
                          .cara(.pensando), .mirar(izquierda: izq), .herramienta(raqueta, arriba: false)]
            }
            pasos += [.esperar(2), .decir(nil), .objeto(nil), .herramienta(nil, arriba: false), .cara(.neutro)]
            return pasos
        },
    ]
}

/// Los globos de las rutinas de magia y deportes.
private enum FrasesJuegos {
    enum mago {
        static let caja = ["¿Y esta caja? 📦", "¿Qué habrá aquí? 🤔"]
        static let disfraz = "¡Un disfraz de mago!"
        static let hechizo = "Wingardium leviosa ✨"
        static let bien = ["¡Soy un mago! 🧙", "¡Funciona! ✨"]
        static let otraVez = "Ahora el balón…"
        static let ups = "¡Ups!"
        static let fin = "Travesura realizada 🪄"
    }

    enum futbol {
        static let inicio = ["¡Un partidito! ⚽", "Soy el diez 😎"]
        static let jueguitos = "¡Jueguito! 🦶"
        static let gol = "¡GOOOL! ⚽"
    }

    enum basket {
        static let inicio = ["¡A encestar! 🏀", "Tiros libres…"]
        static let swish = ["¡Swish! 🏀", "¡Adentro! 🏀"]
        static let casi = ["¡Uy! Casi 😅", "Ese no contaba 😅"]
        static let fin = "Soy un crack 🏆"
    }

    enum voley {
        static let inicio = ["¡Vóley! 🏐", "A ver cuántos toques…"]
        static let contar = ["¡va bien!", "¡no se cae!"]
        static let punto = "¡Punto! 🏐"
    }

    enum tenis {
        static let inicio = ["¿Un partidito de tenis? 🎾", "Saco yo 🎾"]
        static let ace = "¡Ace! 🎾"
        static let out = "¡Out! 😤"
    }
}
