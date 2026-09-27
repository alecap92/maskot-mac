import Foundation
import Motor

/// La matica: aparece solo mientras la riega (para no dejar la pantalla
/// "sucia") y crece con los días de uso, así que cada vez se ve más grande.
enum Matica {
    static func cuadro(dias: Int) -> Cuadro { Utileria.matica(.init(dias: dias)) }
}

/// La matica y la pausa de respiración.
extension Biblioteca {
    static let calma: [Rutina] = [
        Rutina(nombre: "Regar la matica", peso: 3, lugar: .cerca) { c in
            // Camina hasta la matica, saca la regadera, la inclina y caen
            // gotitas sobre la tierra; la matica brilla y él cuenta los días.
            // Aparece a su derecha (la regadera vierte hacia la derecha).
            let mx = min(c.x + 140, c.anchoEscena - 60)
            let lado = Escena.lado
            let etapa = Utileria.EtapaMatica(dias: c.diasDeUso)
            let alto = CGFloat(Matica.cuadro(dias: c.diasDeUso).alto) * lado
            // Parado a la izquierda de la matica, con la regadera en alto sobre ella.
            let pie = mx - Escena.anchoPersonaje / 2 - 6 * lado
            let tierra = Escena.piso - 6 * lado + lado / 2
            let chorroX = mx - 2 * lado
            let desde = Escena.piso - Escena.altoPersonaje + 4 * lado

            var pasos: [Accion] = [
                .decorado("matica", Matica.cuadro(dias: c.diasDeUso), x: mx),
                .cara(.feliz), .decir(FrasesCalma.regar.inicio.randomElement()), .esperar(1.5), .decir(nil),
                .cara(.neutro), .irA(pie), .mirar(izquierda: false), .esperar(0.4),
                .herramienta(Utileria.regadera(inclinada: false), arriba: false), .esperar(0.8),
                .herramienta(Utileria.regadera(inclinada: false), arriba: true), .esperar(0.5),
                .herramienta(Utileria.regadera(inclinada: true), arriba: true), .cara(.feliz),
            ]
            // El chorrito: tres gotas escalonadas que caen una y otra vez.
            let cuadros = 6
            for k in 0..<(cuadros * 5) {
                for g in 0..<3 {
                    let t = CGFloat((k + 2 * g) % cuadros) / CGFloat(cuadros - 1)
                    let gx = chorroX + CGFloat(g - 1) * lado
                    pasos.append(.decorado("gota\(g)", Utileria.gota, x: gx, y: desde + (tierra - desde) * t))
                }
                if k == 8 { pasos.append(.decorado("mojada", Utileria.tierraMojada, x: mx, y: tierra)) }
                pasos.append(.esperar(0.12))
            }
            pasos += [
                .decorado("gota0", nil, x: 0), .decorado("gota1", nil, x: 0), .decorado("gota2", nil, x: 0),
                .herramienta(Utileria.regadera(inclinada: false), arriba: true), .esperar(0.4),
                .herramienta(Utileria.regadera(inclinada: false), arriba: false), .esperar(0.4),
                .herramienta(nil, arriba: false),
            ]
            // La matica brilla un momento, contenta.
            let arriba = Escena.piso - alto - 2 * lado
            for i in 0..<6 {
                let grande = i % 2 == 0
                pasos += [
                    .decorado("brillo0", Utileria.destello(grande: grande), x: mx - 5 * lado, y: arriba + 3 * lado),
                    .decorado("brillo1", Utileria.destello(grande: !grande), x: mx + 5 * lado, y: arriba),
                    .esperar(0.3),
                ]
            }
            pasos += [
                .decorado("brillo0", nil, x: 0), .decorado("brillo1", nil, x: 0),
                .cara(.celebrando), .decir(FrasesCalma.regar.dia(c.diasDeUso, etapa)), .esperar(4),
                .decir(nil), .cara(.feliz), .esperar(1), .cara(.neutro),
                // Se despide y la matica se va (vuelve la próxima vez, un poco más grande).
                .decorado("matica", nil, x: 0), .decorado("mojada", nil, x: 0),
            ]
            return pasos
        },

        Rutina(nombre: "Pausa de respiración", peso: 2, lugar: .esquina) { _ in
            // Respiración guiada 4-4-6: sube los brazos al inhalar, cierra los
            // ojos al sostener y los baja al exhalar. Cerca de minuto y medio.
            func contar(_ texto: String, _ segundos: Int) -> [Accion] {
                stride(from: segundos, through: 1, by: -1).flatMap { s in
                    [Accion.decir("\(texto) (\(s) s)"), .esperar(1)]
                }
            }
            var pasos: [Accion] = [
                .cara(.feliz), .decir(FrasesCalma.respirar.inicio.randomElement()), .esperar(3),
                .decir(FrasesCalma.respirar.sigueme), .esperar(2.5), .cara(.neutro),
            ]
            for _ in 0..<Int.random(in: 4...5) {
                pasos += [.brazos(derecho: true, izquierdo: true), .cara(.neutro)] + contar("Inhala…", 4)
                pasos += [.cara(.parpadeo)] + contar("Sostén…", 4)
                pasos += [.brazos(derecho: false, izquierdo: false), .cara(.feliz)] + contar("Exhala…", 6)
            }
            pasos += [
                .cara(.feliz), .decir(FrasesCalma.respirar.fin), .esperar(4),
                .decir(nil), .cara(.neutro),
            ]
            return pasos
        },
    ]
}

private enum FrasesCalma {
    enum regar {
        static let inicio = [
            "¡Uy, la matica tiene sed! 💧",
            "Hora de regar la matica 🪴",
            "A consentir la matica…",
        ]

        static func dia(_ n: Int, _ etapa: Utileria.EtapaMatica) -> String {
            let cuando = switch etapa {
            case .semilla: "Apenas una semilla… paciencia."
            case .brote: "¡Ya salió un brote!"
            case .plantita: "Va creciendo, poquito a poquito."
            case .conHojas: "¡Mira todas esas hojas!"
            case .conBoton: "¡Le salió un botón! Ya casi…"
            case .florecida: "¡Ya floreció! 🌸"
            }
            return "🌱 Día \(n) con la matica\n\(cuando)"
        }
    }

    enum respirar {
        static let inicio = [
            "¿Una pausa para respirar? 🌬️",
            "Respiremos un momento juntos…",
            "Un minuto de calma 🍃",
        ]
        static let sigueme = "Hombros sueltos. Sígueme…"
        static let fin = "¿Mejor? 😌"
    }
}
