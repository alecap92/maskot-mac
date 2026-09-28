import Foundation
import Motor

/// La biblioteca de rutinas: todo lo que la mascota sabe hacer. Cada rutina es una
/// cola de `Accion`es. Para enseñarle algo nuevo basta agregar una entrada en
/// `Biblioteca.rutinas`; aparece sola en el menú 🧢 → Rutinas.
struct Rutina: Sendable {
    let nombre: String
    /// Qué tan seguido sale sola cuando está desocupado (relativo a las demás).
    /// 0 = nunca sola, solo desde el menú, el clic o el código.
    let peso: Double
    /// Dónde la hace: donde está, unos pasos más allá, o en una esquina.
    var lugar: Lugar = .aqui
    let pasos: @Sendable (Contexto) -> [Accion]
}

/// Antes de empezar una rutina, la mascota camina hasta su lugar.
enum Lugar: Sendable {
    /// Donde está.
    case aqui
    /// Unos pasos a un lado o al otro, para no hacer todo en el mismo sitio.
    case cerca
    /// La esquina más cercana: para lo que dura mucho (leer, dormir, el
    /// Pomodoro), así no se queda en el centro, que es lo más visible.
    case esquina
}

/// Lo que una rutina necesita saber de la escena para armar sus pasos.
struct Contexto: Sendable {
    let x: CGFloat
    let anchoEscena: CGFloat
    var enEsquina = false
    /// Días distintos en que se ha usado la app (la matica crece con esto).
    var diasDeUso = 1

    /// Dónde poner un mueble: en la esquina, justo donde está parado; si no,
    /// a `distancia` hacia donde quepa.
    func sitio(_ dir: CGFloat, _ distancia: CGFloat) -> CGFloat {
        enEsquina ? x : dentro(x + dir * distancia)
    }

    /// Hacia dónde poner un mueble u objeto: 1 derecha, -1 izquierda. Al azar,
    /// salvo cerca de un borde, donde va hacia adentro.
    var haciaDondeCabe: CGFloat {
        if x < 450 { return 1 }
        if x > anchoEscena - 450 { return -1 }
        return Bool.random() ? 1 : -1
    }

    func dentro(_ v: CGFloat) -> CGFloat { min(max(v, 110), anchoEscena - 110) }
}

private func minutos(_ rango: ClosedRange<Double>) -> TimeInterval {
    .random(in: rango) * 60
}

enum Biblioteca {
    // Los pesos están pensados para un día de 8 horas: las rutinas largas
    // (leer, dormir) salen poco pero duran mucho, así que la mascota pasa la mayor
    // parte del tiempo tranquilo, y las gracias cortas son la excepción.
    /// Todas: las de este archivo más las de cada grupo (cada grupo vive en
    /// su propio `Rutinas+<Grupo>.swift`).
    static let rutinas: [Rutina] = basicas + juegos + calma + hobbies + aventura + movimiento

    static let basicas: [Rutina] = [
        // MARK: Cortas
        Rutina(nombre: "Pasear", peso: 30) { _ in
            [.pasear(.random(in: 150...600) * (Bool.random() ? 1 : -1))]
        },
        Rutina(nombre: "Quedarse quieto", peso: 30, lugar: .cerca) { _ in
            [.esperar(.random(in: 5...30))]
        },
        Rutina(nombre: "Poner una cara", peso: 8, lugar: .cerca) { _ in
            let cara = [Expresion.feliz, .guino, .pensando, .gafas].randomElement()!
            return [.cara(cara), .esperar(.random(in: 2...3)), .cara(.neutro)]
        },
        Rutina(nombre: "Gorra de lado un rato", peso: 4, lugar: .cerca) { _ in
            [.gorra(.deLado), .esperar(.random(in: 15...40)), .gorra(.haciaAtras)]
        },
        Rutina(nombre: "Quedarse dormido caminando", peso: 4) { _ in
            [
                .pasear(.random(in: 120...300) * (Bool.random() ? 1 : -1)),
                .cara(.parpadeo), .esperar(0.5), .cara(.neutro), .esperar(0.4),
                .cara(.parpadeo), .esperar(0.8),
                .cara(.dormido), .esperar(.random(in: 10...25)),
                .cara(.sorprendido), .decir(Frases.siesta.randomElement()), .esperar(2.5),
                .decir(nil), .cara(.neutro),
            ]
        },
        Rutina(nombre: "Tomar café", peso: 4, lugar: .cerca) { _ in
            var pasos: [Accion] = [
                .cara(.feliz), .golosina(.cafe, lamiendo: false),
                .decir(Frases.cafe.inicio.randomElement()), .esperar(2.5), .decir(nil), .cara(.neutro),
            ]
            for _ in 0..<Int.random(in: 6...14) {
                pasos += [.golosina(.cafe, lamiendo: true), .cara(.feliz), .esperar(0.9),
                          .golosina(.cafe, lamiendo: false), .cara(.neutro), .esperar(.random(in: 3...7))]
            }
            pasos += [.golosina(nil, lamiendo: false), .cara(.feliz),
                      .decir(Frases.cafe.fin.randomElement()), .esperar(2.5), .decir(nil), .cara(.neutro)]
            return pasos
        },
        Rutina(nombre: "Cocinar pizza", peso: 2, lugar: .cerca) { c in
            // Aparece la mesa, prepara la pizza cortando entre ingrediente e
            // ingrediente, la lleva al horno, espera el ding y se la come.
            let dir = c.haciaDondeCabe
            let mesaX = c.dentro(c.x + dir * 120)
            let hornoX = c.dentro(mesaX + dir * 150)
            let junto = { (mx: CGFloat) in mx - dir * 75 }
            func picar(_ veces: Int) -> [Accion] {
                (0..<veces).flatMap { _ in
                    [Accion.herramienta(Utileria.cuchillo, arriba: false), .esperar(0.22),
                     .herramienta(Utileria.cuchillo, arriba: true), .esperar(0.22)]
                }
            }

            var pasos: [Accion] = [
                .cara(.feliz), .decir(Frases.pizza.inicio), .esperar(2), .decir(nil),
                .mueble(.mesa, mesaX), .irA(junto(mesaX)), .mirar(izquierda: dir < 0),
                .sobreMesa(Utileria.pizza(etapa: 0)), .cara(.pensando), .esperar(1),
                .cara(.neutro), .herramienta(Utileria.cuchillo, arriba: true), .decir(Frases.pizza.cortar),
            ]
            pasos += picar(5) + [.decir(nil), .sobreMesa(Utileria.pizza(etapa: 1))]
            pasos += picar(4) + [.sobreMesa(Utileria.pizza(etapa: 2))]
            pasos += picar(4) + [.sobreMesa(Utileria.pizza(etapa: 3)), .herramienta(nil, arriba: false)]
            pasos += [
                .cara(.feliz), .esperar(0.6),
                .mueble(.horno, hornoX), .sobreMesa(nil), .cargarCosa(Utileria.pizza(etapa: 3)),
                .decir(Frases.pizza.horno), .irA(junto(hornoX)), .mirar(izquierda: dir < 0), .decir(nil),
                .horno(true), .cara(.pensando), .decir(Frases.pizza.esperando), .esperar(3), .decir(nil),
                .cara(.neutro), .esperar(.random(in: 5...9)),
                .horno(false), .cara(.sorprendido), .saltar, .decir(Frases.pizza.ding), .esperar(1.2), .decir(nil),
                .cargarCosa(Utileria.pizza(etapa: 3, horneada: true)), .cara(.feliz),
                .irA(junto(mesaX)), .mirar(izquierda: dir < 0), .brazo(false),
                .sobreMesa(Utileria.pizza(etapa: 3, horneada: true)), .quitar(.horno),
                .cara(.celebrando), .decir(Frases.pizza.comer), .esperar(1.5), .decir(nil),
            ]
            // Tres porciones, a mordiscos.
            for porcion in 0..<3 {
                pasos += [.golosina(.pizza, lamiendo: false), .cara(.neutro), .esperar(0.6)]
                for _ in 0..<4 {
                    pasos += [.golosina(.pizza, lamiendo: true), .cara(.feliz), .esperar(0.4),
                              .golosina(.pizza, lamiendo: false), .cara(.neutro), .esperar(0.7)]
                }
                pasos += [.golosina(nil, lamiendo: false), .esperar(0.8)]
                if porcion == 2 { pasos += [.sobreMesa(nil)] }
            }
            pasos += [.cara(.feliz), .decir(Frases.pizza.fin), .esperar(2.5), .decir(nil),
                      .cara(.parpadeo), .esperar(1.5), .cara(.neutro), .quitarMueble]
            return pasos
        },
        Rutina(nombre: "Avión de papel", peso: 3, lugar: .cerca) { c in
            // Dobla una hoja en avión, apunta y lo lanza hacia donde hay espacio.
            let dir = c.haciaDondeCabe
            return [
                .mirar(izquierda: dir < 0), .cara(.feliz),
                .cargarCosa(Utileria.hoja), .decir(Frases.avion.inicio.randomElement()), .esperar(2), .decir(nil),
                .cara(.pensando), .esperar(1.2), .cambiarCosa(Utileria.hojaDoblada), .esperar(1),
                .cambiarCosa(Utileria.avion), .cara(.guino), .esperar(1),
                .cara(.sorprendido), .decir(Frases.avion.lanzar), .lanzarAvion, .decir(nil),
                .cara(.celebrando), .saltar, .decir(Frases.avion.fin.randomElement()), .esperar(2.5),
                // El avión se queda un momento en el piso y desaparece.
                .decir(nil), .cara(.neutro), .esperar(0.5), .soltar,
            ]
        },
        Rutina(nombre: "Asomarse", peso: 3) { c in
            // Se va por el borde más cercano, se asoma de lado saludando con
            // la pinza, se vuelve a esconder y al rato entra caminando.
            let porIzquierda = c.x < c.anchoEscena / 2
            let medio = Escena.anchoPersonaje / 2
            let afuera = porIzquierda ? -medio - 20 : c.anchoEscena + medio + 20
            // Asomado: solo se ve el ojo de adentro y la pinza que saluda.
            let asomado = porIzquierda ? -Escena.lado : c.anchoEscena + Escena.lado
            let adentro = porIzquierda ? CGFloat.random(in: 150...350) : c.anchoEscena - .random(in: 150...350)

            var pasos: [Accion] = [.irA(afuera), .esperar(.random(in: 1.5...3))]
            pasos += [.mirar(izquierda: !porIzquierda), .ubicar(asomado), .cara(.feliz), .esperar(0.5),
                      .decir(Frases.asomarse.randomElement())]
            for _ in 0..<4 { pasos += [.brazo(true), .esperar(0.3), .brazo(false), .esperar(0.3)] }
            pasos += [.cara(.guino), .esperar(0.6), .decir(nil), .cara(.neutro),
                      .ubicar(afuera), .esperar(.random(in: 2...4)), .irA(adentro)]
            return pasos
        },
        Rutina(nombre: "Botar una hoja", peso: 3, lugar: .cerca) { c in
            // Aparece una hoja: la mira, la arruga, la levanta y la bota a la caneca.
            let dir = c.haciaDondeCabe
            let hojaX = c.dentro(c.x + dir * 170)
            let canecaX = c.dentro(hojaX + dir * 220)
            return [
                .dejarHoja(hojaX), .cara(.sorprendido), .decir(Frases.botarHoja.encuentra), .esperar(1.8),
                .decir(nil), .cara(.neutro),
                .irA(hojaX - dir * 45),
                .cara(.pensando), .esperar(1.2),
                .arrugarHoja, .cara(.guino), .esperar(0.6),
                .brazo(true), .cargar, .mueble(.caneca, canecaX), .cara(.neutro), .esperar(0.4),
                .irA(canecaX - dir * 115),
                .esperar(0.3), .lanzarALaCaneca, .brazo(false),
                .cara(.celebrando), .decir(Frases.botarHoja.celebra), .esperar(2.2),
                .decir(nil), .cara(.neutro), .esperar(1), .quitarMueble,
            ]
        },
        Rutina(nombre: "Gym", peso: 3, lugar: .cerca) { _ in
            var pasos: [Accion] = [.cara(.gafas), .decir(Frases.gym.inicio), .esperar(1.5), .decir(nil), .pesa(false), .esperar(0.6)]
            for rep in 1...Int.random(in: 6...10) {
                pasos += [.pesa(true), .decir("💪 \(rep)"), .esperar(0.5), .pesa(false), .esperar(0.5)]
            }
            pasos += [.pesa(nil), .decir("Ahora saltos…"), .esperar(1)]
            for _ in 1...Int.random(in: 4...6) { pasos += [.saltar, .esperar(0.15)] }
            pasos += [.cara(.feliz), .decir(Frases.gym.fin), .esperar(2.5), .decir(nil), .cara(.neutro)]
            return pasos
        },

        Rutina(nombre: "Comer golosina", peso: 3, lugar: .cerca) { _ in
            // Paleta de espiral o helado: la sostiene junto a la cara y la lame.
            let g = Utileria.Golosina.dulces.randomElement()!
            var pasos: [Accion] = [
                .cara(.feliz), .golosina(g, lamiendo: false),
                .decir(Frases.golosina.inicio.randomElement()), .esperar(1.8), .decir(nil), .cara(.neutro),
            ]
            for i in 0..<Int.random(in: 12...25) {
                pasos += [.cara(.feliz), .golosina(g, lamiendo: true), .esperar(0.35),
                          .golosina(g, lamiendo: false), .cara(.neutro), .esperar(.random(in: 0.4...1.4))]
                if i == 6 { pasos += [.decir(Frases.golosina.durante.randomElement()), .esperar(1.5), .decir(nil)] }
            }
            pasos += [.golosina(nil, lamiendo: false), .cara(.sorprendido), .decir(Frases.golosina.fin),
                      .esperar(2), .decir(nil), .cara(.neutro)]
            return pasos
        },

        // MARK: Largas (descanso)
        Rutina(nombre: "Siesta de pie", peso: 4, lugar: .esquina) { _ in
            [
                .cara(.parpadeo), .esperar(1), .cara(.dormido), .esperar(minutos(5...20)),
                .cara(.sorprendido), .decir(Frases.siesta.randomElement()), .esperar(2.5),
                .decir(nil), .cara(.neutro),
            ]
        },
        Rutina(nombre: "Leer en la banca", peso: 5, lugar: .esquina) { c in
            let dir = c.haciaDondeCabe
            let bancaX = c.sitio(dir, 150)
            return [
                .mueble(.banca, bancaX), .cara(.feliz), .decir(Frases.leer.inicio), .esperar(2), .decir(nil),
                .cara(.neutro), .irA(bancaX), .postura(.sentado), .esperar(0.5),
                .libro(true), .cara(.leyendo), .esperar(minutos(10...40)),
                .libro(false), .cara(.feliz), .decir(Frases.leer.fin), .esperar(2.5), .decir(nil),
                .postura(.dePie), .cara(.neutro), .irA(c.dentro(bancaX + dir * 160)), .quitarMueble,
            ]
        },
        Rutina(nombre: "Echar código", peso: 4, lugar: .esquina) { c in
            // Gorra de lado, gafas de nerd, se sienta en la banca con la laptop.
            // Cada par de minutos suelta un chiste de programador.
            let dir = c.haciaDondeCabe
            let bancaX = c.sitio(dir, 150)
            var pasos: [Accion] = [
                .gorra(.deLado), .cara(.nerd), .mueble(.banca, bancaX),
                .decir(Frases.codigo.inicio), .esperar(2), .decir(nil),
                .irA(bancaX), .postura(.sentado), .laptop(true),
            ]
            for _ in 0..<Int.random(in: 5...15) {
                pasos += [.esperar(minutos(1.5...3)), .decir(Frases.codigo.durante.randomElement()), .esperar(3.5), .decir(nil)]
            }
            pasos += [
                .laptop(false), .cara(.feliz), .decir(Frases.codigo.fin), .esperar(2.5), .decir(nil),
                .postura(.dePie), .cara(.neutro), .gorra(.haciaAtras),
                .irA(c.dentro(bancaX + dir * 160)), .quitarMueble,
            ]
            return pasos
        },
        Rutina(nombre: "Dormir en la cama", peso: 2, lugar: .esquina) { c in
            let dir = c.haciaDondeCabe
            let camaX = c.sitio(dir, 170)
            return [
                .cara(.parpadeo), .mueble(.cama, camaX), .decir(Frases.cama.inicio), .esperar(2), .decir(nil),
                .cara(.neutro), .irA(camaX), .postura(.acostado), .cara(.dormido), .esperar(minutos(20...60)),
                .cara(.sorprendido), .esperar(1), .postura(.dePie), .cara(.feliz),
                .decir(Frases.cama.fin), .esperar(2), .decir(nil),
                .cara(.neutro), .irA(c.dentro(camaX - dir * 170)), .quitarMueble,
            ]
        },

        // MARK: Solo a mano
        Rutina(nombre: "Saltar", peso: 0) { _ in
            [.cara(.feliz), .saltar, .esperar(0.1), .saltar, .cara(.neutro), .esperar(0.3)]
        },
        urgente(Frases.urgente.randomElement()!),
        Rutina(nombre: "Aviso", peso: 0) { _ in
            let (texto, cara) = Frases.avisos.randomElement()!
            return [.cara(cara), .decir(texto), .esperar(5), .decir(nil), .cara(.neutro)]
        },
        Rutina(nombre: "Saludar", peso: 0) { _ in
            [.cara(.feliz), .decir(Frases.saludos.randomElement()), .esperar(3.5), .decir(nil), .cara(.neutro)]
        },
        // Sale sola a los 15 minutos sin teclado ni mouse (ver `ContadorSentado`).
        // Se acuesta y el reloj de la app baja al mínimo; el primer toque la
        // despierta. Desde el menú sirve para mandarla a dormir hasta que vuelvas.
        Rutina(nombre: "Dormir hasta que vuelvas", peso: 0, lugar: .esquina) { c in
            let dir = c.haciaDondeCabe
            let camaX = c.sitio(dir, 170)
            return [
                .cara(.parpadeo), .mueble(.cama, camaX), .decir(Frases.hastaQueVuelvas), .esperar(2), .decir(nil),
                .cara(.neutro), .irA(camaX), .postura(.acostado), .esperar(1.5), .dormirse,
            ]
        },
    ]

    // MARK: Pomodoro

    /// Lo que hace en cada fase del Pomodoro, durante `duracion` segundos.
    /// `anuncia` = acaba de empezar la fase (dice algo); si no, es que se
    /// retoma tras una interrupción (un clic) y sigue callado.
    static func pomodoro(_ fase: Pomodoro.Fase, duracion: TimeInterval, tomate: Int, anuncia: Bool) -> Rutina {
        Rutina(nombre: "Pomodoro", peso: 0, lugar: .esquina) { c in
            let dir = c.haciaDondeCabe
            var pasos: [Accion] = []
            switch fase {
            case .trabajo:
                if anuncia {
                    pasos += [.cara(.feliz), .decir(Frases.pomodoro.trabajo(tomate)), .esperar(4), .decir(nil)]
                }
                // Programa o lee en la banca todo el bloque.
                let bancaX = c.sitio(dir, 150)
                let conLaptop = Bool.random()
                pasos += [.mueble(.banca, bancaX), .cara(.neutro), .irA(bancaX), .postura(.sentado)]
                pasos += conLaptop
                    ? [.gorra(.deLado), .cara(.nerd), .laptop(true)]
                    : [.libro(true), .cara(.leyendo)]
                pasos += [.esperar(duracion)]
            case .descanso:
                if anuncia {
                    pasos += [.cara(.celebrando), .saltar, .decir(Frases.pomodoro.descanso), .esperar(4), .decir(nil)]
                }
                // Un tinto a sorbos.
                pasos += [.cara(.feliz), .golosina(.cafe, lamiendo: false)]
                for _ in 0..<max(1, Int(duracion / 6)) {
                    pasos += [.golosina(.cafe, lamiendo: true), .cara(.feliz), .esperar(0.9),
                              .golosina(.cafe, lamiendo: false), .cara(.neutro), .esperar(.random(in: 4...6))]
                }
            case .descansoLargo:
                if anuncia {
                    pasos += [.cara(.celebrando), .saltar, .saltar, .decir(Frases.pomodoro.descansoLargo), .esperar(5), .decir(nil)]
                }
                // Cuatro tomates después, se gana la siesta.
                let camaX = c.sitio(dir, 170)
                pasos += [.mueble(.cama, camaX), .cara(.parpadeo), .irA(camaX), .postura(.acostado),
                          .cara(.dormido), .esperar(duracion)]
            }
            return pasos
        }
    }

    // MARK: Avisos con mensaje propio (los usa la API local)

    /// Pide auxilio: brinca agitando los brazos, uno y otro, para que lo vean
    /// sí o sí. Al final se queda un rato con el mensaje.
    static func urgente(_ mensaje: String) -> Rutina {
        Rutina(nombre: "Recordatorio urgente", peso: 0) { _ in
            var pasos: [Accion] = [.cara(.sorprendido), .decir(mensaje)]
            for i in 0..<10 {
                pasos += [.brazos(derecho: i % 2 == 0, izquierdo: i % 2 == 1), .saltar]
                if i == 4 { pasos += [.brazos(derecho: true, izquierdo: true), .esperar(0.3)] }
            }
            pasos += [.brazos(derecho: true, izquierdo: true), .esperar(0.4)]
            for i in 0..<6 { pasos += [.brazos(derecho: i % 2 == 0, izquierdo: i % 2 == 1), .esperar(0.25)] }
            pasos += [.brazos(derecho: false, izquierdo: false), .esperar(8), .decir(nil), .cara(.neutro)]
            return pasos
        }
    }

    /// El "sigue llamando" de un aviso que espera clic: se repite hasta que lo
    /// descarten. Urgente: brinca agitando los brazos; normal: un saltico
    /// cada pocos segundos. El globo no se quita.
    static func insistir(_ mensaje: String, urgente: Bool) -> Rutina {
        Rutina(nombre: urgente ? "Recordatorio urgente" : "Aviso", peso: 0) { _ in
            if urgente {
                var pasos: [Accion] = [.cara(.sorprendido), .decir(mensaje)]
                for i in 0..<6 { pasos += [.brazos(derecho: i % 2 == 0, izquierdo: i % 2 == 1), .saltar] }
                return pasos + [.brazos(derecho: true, izquierdo: true), .esperar(0.8)]
            }
            return [.cara(.sorprendido), .decir(mensaje), .saltar, .cara(.feliz), .esperar(4)]
        }
    }

    /// Un aviso normal: da un saltico para llamar la atención y deja el globo
    /// un buen rato (`segundos`).
    static func aviso(_ mensaje: String, cara: Expresion = .sorprendido, segundos: TimeInterval = 8) -> Rutina {
        Rutina(nombre: "Aviso", peso: 0) { _ in
            [.cara(cara), .saltar, .decir(mensaje), .esperar(segundos), .decir(nil), .cara(.neutro)]
        }
    }

    static func llamada(_ nombre: String) -> Rutina {
        rutinas.first { $0.nombre == nombre }!
    }

    /// Una rutina al azar, según los pesos.
    static func alAzar() -> Rutina {
        let candidatas = rutinas.filter { $0.peso > 0 }
        var r = Double.random(in: 0..<candidatas.reduce(0) { $0 + $1.peso })
        for rutina in candidatas {
            r -= rutina.peso
            if r < 0 { return rutina }
        }
        return candidatas[0]
    }
}
