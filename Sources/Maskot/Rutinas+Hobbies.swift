import Foundation
import Motor

/// Hobbies: guitarra, pescar, yoyo, selfie, periódico.
extension Biblioteca {
    static let hobbies: [Rutina] = [
        // MARK: Guitarra
        Rutina(nombre: "Tocar guitarra", peso: 2.5, lugar: .esquina) { c in
            // Se sienta en la banca (o se queda de pie) y rasguea canciones
            // mientras las notitas flotan hacia arriba.
            let dir = c.haciaDondeCabe
            let lado = Escena.lado
            let sentado = Bool.random()
            var pasos: [Accion] = []
            var posX = c.x
            if sentado {
                posX = c.sitio(dir, 150)
                pasos += [.mueble(.banca, posX), .irA(posX), .postura(.sentado)]
            } else {
                pasos += [.mirar(izquierda: dir < 0)]
            }
            let elevacion: CGFloat = sentado ? 3 * lado : 0
            // Las notas nacen a la altura de los ojos, a los lados, y suben.
            let base = Escena.piso - elevacion - 14 * lado
            let ids = ["nota0", "nota1"]
            let quitarNotas: [Accion] = ids.map { .decorado($0, nil, x: 0) }

            pasos += [
                .enFrente(Utileria.guitarra(vibrando: false)), .cara(.feliz),
                .decir(FrasesHobbies.guitarra.inicio.randomElement()), .esperar(2.5), .decir(nil),
            ]
            let total = TimeInterval.random(in: 120...300)
            var tiempo: TimeInterval = 0
            var cancion = 0
            while tiempo < total {
                pasos += [.cara(.feliz)]
                let golpes = Int.random(in: 60...140)
                for i in 0..<golpes {
                    // Cada tanto cierra los ojos, sintiendo la canción.
                    if i % 16 == 11 { pasos += [.cara(.parpadeo)] }
                    if i % 16 == 15 { pasos += [.cara(.feliz)] }
                    pasos += [
                        .enFrente(Utileria.guitarra(vibrando: i % 2 == 0)),
                        .brazos(derecho: i % 2 == 0, izquierdo: i % 2 == 1),
                    ]
                    // Dos notas desfasadas: cada una sube 6 golpes y vuelve a nacer.
                    for (n, id) in ids.enumerated() {
                        let fase = (i + n * 3) % 6
                        let lateral: CGFloat = n == 0 ? -1 : 1
                        let x = posX + lateral * 11 * lado + (fase % 2 == 0 ? lado : -lado)
                        let y = base - CGFloat(fase) * 2 * lado
                        let dibujo = Utileria.nota(doble: (i / 6 + n) % 2 == 0, tinta: n == 0 ? "P" : "x")
                        pasos += [.decorado(id, dibujo, x: x, y: y)]
                    }
                    pasos += [.esperar(0.3)]
                }
                tiempo += Double(golpes) * 0.3
                cancion += 1
                // Entre canción y canción, un comentario.
                pasos += quitarNotas + [
                    .brazos(derecho: false, izquierdo: false), .enFrente(Utileria.guitarra(vibrando: false)),
                    .cara(.guino), .decir(FrasesHobbies.guitarra.entre.randomElement()), .esperar(3.5), .decir(nil),
                ]
                tiempo += 3.5
            }
            pasos += [
                .enFrente(nil), .cara(.celebrando), .decir(FrasesHobbies.guitarra.fin.randomElement()),
                .esperar(2.5), .decir(nil), .cara(.neutro),
            ]
            if sentado {
                pasos += [.postura(.dePie), .irA(c.dentro(posX + dir * 160)), .quitarMueble]
            }
            return pasos
        },

        // MARK: Pescar
        Rutina(nombre: "Pescar", peso: 2.5, lugar: .esquina) { c in
            // Aparece un laguito, lanza el corcho y espera… y espera. Cuando
            // pica, jala y sale un pez (o una bota vieja) que devuelve al agua.
            let dir = c.haciaDondeCabe
            let izquierda = dir < 0
            let lado = Escena.lado
            let lago = Utileria.lago
            let anchoLago = CGFloat(lago.ancho) * lado
            let lagoX = c.x + dir * (Escena.anchoPersonaje / 2 + anchoLago / 2 - 2 * lado)
            let superficie = Escena.piso - 3 * lado
            let corchoX = lagoX + dir * 3 * lado
            let corchoY = superficie - lado
            let hundidoY = superficie - lado / 2
            // La punta de la caña, más o menos (depende de la mano del personaje).
            let punta = CGPoint(x: c.x + dir * 15 * lado, y: Escena.piso - 18 * lado)
            // El sedal va de la punta de la caña a la cabeza del corcho.
            let desdeSedal = CGPoint(x: c.x + dir * 15.5 * lado, y: Escena.piso - 17.5 * lado)
            let hastaSedal = CGPoint(x: corchoX, y: corchoY - lado)
            let sedal = Utileria.sedal(
                ancho: Int((abs(hastaSedal.x - desdeSedal.x) / lado).rounded()),
                alto: Int(((hastaSedal.y - desdeSedal.y) / lado).rounded()),
                haciaIzquierda: izquierda
            )
            let ponerSedal = Accion.decorado(
                "x_sedal", sedal, x: (desdeSedal.x + hastaSedal.x) / 2, y: (desdeSedal.y + hastaSedal.y) / 2
            )
            let cana = Utileria.cana(haciaIzquierda: izquierda)
            let tensa = Utileria.cana(haciaIzquierda: izquierda, tensa: true)
            let esBota = Int.random(in: 0..<4) == 0
            let premio = esBota ? Utileria.bota : Utileria.pez
            let salpicar: [Accion] = [
                .decorado("z_salpicon", Utileria.salpicon(grande: true), x: corchoX, y: superficie - lado),
                .esperar(0.25),
                .decorado("z_salpicon", Utileria.salpicon(grande: false), x: corchoX, y: superficie - lado),
                .esperar(0.25),
                .decorado("z_salpicon", nil, x: 0),
            ]

            var pasos: [Accion] = [
                .mirar(izquierda: izquierda), .decorado("lago", lago, x: lagoX),
                .cara(.feliz), .decir(FrasesHobbies.pesca.inicio.randomElement()), .esperar(2.5), .decir(nil),
                .herramienta(cana, arriba: true), .cara(.pensando), .esperar(1.2), .cara(.guino),
                // Lanza: el corcho sale de la punta y cae al agua.
                .objeto(Utileria.corcho), .objetoEn(x: punta.x, y: punta.y),
                .volar(x: corchoX, y: corchoY, altura: 12 * lado, segundos: 1.1),
                .objeto(nil), .decorado("y_corcho", Utileria.corcho, x: corchoX, y: corchoY), ponerSedal,
            ]
            pasos += salpicar + [.cara(.neutro)]

            // La espera larga: el corcho se mece; cada tanto un comentario y
            // una falsa alarma.
            let espera = TimeInterval.random(in: 110...330)
            var tiempo: TimeInterval = 0
            var proximaFrase = TimeInterval.random(in: 30...60)
            var falsaAlarma = Bool.random()
            while tiempo < espera {
                pasos += [
                    .decorado("y_corcho", Utileria.corcho, x: corchoX, y: corchoY + lado), .esperar(0.8),
                    .decorado("y_corcho", Utileria.corcho, x: corchoX, y: corchoY), .esperar(0.8),
                ]
                tiempo += 1.6
                if tiempo >= proximaFrase {
                    if falsaAlarma {
                        pasos += [
                            .decorado("y_corcho", Utileria.corchoHundido, x: corchoX, y: hundidoY),
                            .cara(.sorprendido), .esperar(0.4),
                            .decorado("y_corcho", Utileria.corcho, x: corchoX, y: corchoY),
                            .esperar(0.8), .cara(.pensando), .decir(FrasesHobbies.pesca.falsaAlarma.randomElement()),
                            .esperar(3), .decir(nil), .cara(.neutro),
                        ]
                        falsaAlarma = false
                    } else {
                        let cara: Expresion = [.parpadeo, .pensando, .neutro].randomElement()!
                        pasos += [.cara(cara), .decir(FrasesHobbies.pesca.esperando.randomElement()),
                                  .esperar(3.5), .decir(nil), .cara(.neutro)]
                    }
                    tiempo += 4
                    proximaFrase = tiempo + .random(in: 40...80)
                }
            }

            // ¡Picó!
            pasos += [
                .decorado("y_corcho", Utileria.corchoHundido, x: corchoX, y: hundidoY),
                .herramienta(tensa, arriba: true), .cara(.sorprendido), .decir(FrasesHobbies.pesca.pico),
            ]
            for _ in 0..<4 {
                pasos += [
                    .decorado("y_corcho", Utileria.corcho, x: corchoX, y: corchoY), .esperar(0.2),
                    .decorado("y_corcho", Utileria.corchoHundido, x: corchoX, y: hundidoY), .esperar(0.3),
                ]
            }
            // Jala: sale volando lo que picó y cae sobre su cabeza.
            pasos += [
                .decir(nil), .herramienta(cana, arriba: true), .decorado("y_corcho", nil, x: 0),
                .decorado("x_sedal", nil, x: 0), .objeto(premio), .objetoEn(x: corchoX, y: superficie - lado),
                .volar(x: c.x, y: Escena.piso - 21 * lado, altura: 14 * lado, segundos: 1.1),
                .objetoArriba,
            ]
            pasos += salpicar
            if esBota {
                pasos += [.cara(.pensando), .decir(FrasesHobbies.pesca.bota.randomElement()), .esperar(3), .decir(nil)]
            } else {
                pasos += [.cara(.celebrando), .decir(FrasesHobbies.pesca.pez.randomElement()), .esperar(3), .decir(nil),
                          .cara(.feliz), .esperar(1)]
            }
            // Lo devuelve al agua.
            pasos += [
                .decir(FrasesHobbies.pesca.devolver(esBota)),
                .volar(x: corchoX, y: superficie - lado, altura: 10 * lado, segundos: 1), .objeto(nil),
            ]
            pasos += salpicar
            pasos += [
                .esperar(1.5), .decir(nil), .herramienta(nil, arriba: false), .cara(.feliz), .esperar(1),
                .decorado("lago", nil, x: 0), .cara(.neutro),
            ]
            return pasos
        },

        // MARK: Yoyo
        Rutina(nombre: "Yoyo", peso: 2.5, lugar: .cerca) { c in
            // Sube y baja el yoyo, lo pasea por el piso y remata con un truco.
            let dir = c.haciaDondeCabe
            let lado = Escena.lado
            var pasos: [Accion] = [
                .mirar(izquierda: dir < 0), .cara(.feliz),
                .objeto(Utileria.yoyo), .levantarObjeto,
                .decir(FrasesHobbies.yoyo.inicio.randomElement()), .esperar(1.5), .decir(nil),
            ]
            for i in 0..<Int.random(in: 4...7) {
                pasos += [.cara(i % 2 == 0 ? .neutro : .feliz), .toque(altura: -6 * lado), .esperar(0.1)]
            }
            pasos += [
                .cara(.guino), .caer, .decir(FrasesHobbies.yoyo.perrito),
                .conducir(c.dentro(c.x + dir * .random(in: 90...150))), .decir(nil),
                .levantarObjeto, .esperar(0.3),
            ]
            for _ in 0..<Int.random(in: 2...3) { pasos += [.toque(altura: -6 * lado), .esperar(0.1)] }
            // Truco final: lo lanza hacia arriba bien alto y lo recoge.
            pasos += [
                .cara(.sorprendido), .toque(altura: 9 * lado), .cara(.celebrando),
                .decir(FrasesHobbies.yoyo.fin.randomElement()), .esperar(2.2), .decir(nil),
                .objeto(nil), .brazo(false), .cara(.neutro),
            ]
            return pasos
        },

        // MARK: Selfie
        Rutina(nombre: "Selfie", peso: 2.5, lugar: .cerca) { c in
            // Celular en alto, varias poses y un flash en cada foto.
            let dir = c.haciaDondeCabe
            let lado = Escena.lado
            let fx = c.x + dir * 13 * lado
            let fy = Escena.piso - 15 * lado
            var pasos: [Accion] = [
                .mirar(izquierda: dir < 0), .herramienta(Utileria.celular, arriba: true), .cara(.feliz),
                .decir(FrasesHobbies.selfie.inicio.randomElement()), .esperar(1.5), .decir(nil),
            ]
            let poses: [Expresion] = Array([Expresion.gafas, .guino, .feliz, .celebrando, .sorprendido]
                .shuffled().prefix(Int.random(in: 3...4)))
            for pose in poses {
                pasos += [
                    .cara(pose), .esperar(1.2),
                    .decorado("flash", Utileria.flash(grande: true), x: fx, y: fy), .esperar(0.15),
                    .decorado("flash", Utileria.flash(grande: false), x: fx, y: fy), .esperar(0.1),
                    .decorado("flash", nil, x: 0), .esperar(0.7),
                ]
            }
            // Revisa cómo quedaron.
            pasos += [
                .herramienta(Utileria.celular, arriba: false), .cara(.pensando), .esperar(1.5),
                .cara(.celebrando), .decir(FrasesHobbies.selfie.fin.randomElement()), .esperar(2.5), .decir(nil),
                .herramienta(nil, arriba: false), .cara(.neutro),
            ]
            return pasos
        },

        // MARK: Periódico
        Rutina(nombre: "Leer el periódico", peso: 2.5, lugar: .esquina) { c in
            // En la banca con el periódico abierto; pasa la página cada tanto
            // y lee en voz alta los titulares más raros.
            let dir = c.haciaDondeCabe
            let bancaX = c.sitio(dir, 150)
            var pasos: [Accion] = [
                .mueble(.banca, bancaX), .cara(.feliz), .decir(FrasesHobbies.periodico.inicio), .esperar(2),
                .decir(nil), .cara(.neutro), .irA(bancaX), .postura(.sentado), .esperar(0.5),
                .enFrente(Utileria.periodico(pagina: 0)), .cara(.leyendo),
            ]
            let total = TimeInterval.random(in: 180...600)
            var tiempo: TimeInterval = 0
            var pagina = 0
            var proximoTitular = TimeInterval.random(in: 40...80)
            var titulares = FrasesHobbies.periodico.titulares.shuffled()
            while tiempo < total {
                let lectura = TimeInterval.random(in: 20...40)
                pasos += [.esperar(lectura)]
                tiempo += lectura
                if tiempo >= proximoTitular, let titular = titulares.popLast() {
                    pasos += [.cara(.sorprendido), .decir(titular), .esperar(4.5), .decir(nil), .cara(.leyendo)]
                    tiempo += 4.5
                    proximoTitular = tiempo + .random(in: 90...150)
                }
                pagina += 1
                pasos += [
                    .enFrente(Utileria.periodico(pagina: pagina - 1, pasando: true)), .esperar(0.3),
                    .enFrente(Utileria.periodico(pagina: pagina)),
                ]
            }
            pasos += [
                .enFrente(nil), .cara(.feliz), .decir(FrasesHobbies.periodico.fin), .esperar(2.5), .decir(nil),
                .postura(.dePie), .cara(.neutro), .irA(c.dentro(bancaX + dir * 160)), .quitarMueble,
            ]
            return pasos
        },
    ]
}

/// Los textos de los hobbies.
private enum FrasesHobbies {
    enum guitarra {
        static let inicio = [
            "🎸 Esta se llama 'Commit a las 3am'",
            "🎸 Un temita que compuse en el daily…",
            "🎸 ¡Uno, dos, tres, cuatro!",
        ]
        static let entre = [
            "🎶 Esta otra es 'Merge conflict en Re menor'",
            "🎵 Gracias, gracias, son muy amables",
            "🎶 Pidan otra, sin miedo",
            "🎵 Ahora una baladita: 'Funciona en mi máquina'",
        ]
        static let fin = [
            "🤘 ¡Gracias, escritorio, son lo máximo!",
            "🎸 Y con eso cierro el concierto",
            "🤘 ¡Rock and roll!",
        ]
    }

    enum pesca {
        static let inicio = ["🎣 Hoy sí pico algo grande", "🎣 A pescar, que el código espera", "🎣 Shhh… que se asustan"]
        static let esperando = [
            "🎣 Paciencia…",
            "🎣 …¿habrá peces en este lago?",
            "🎣 Los peces también tienen reuniones",
            "🎣 Pescar es como depurar: esperar y esperar",
        ]
        static let falsaAlarma = ["🎣 …nada. Falsa alarma", "🎣 Era el viento", "🎣 Casi…"]
        static let pico = "❗ ¡Picó!"
        static let pez = ["🐟 ¡Mira este animal!", "🐟 ¡Uno de este tamaño!", "🐟 ¡Lo saqué!"]
        static let bota = ["🥾 …una bota. Otra vez.", "🥾 Esto no es un pez", "🥾 ¿Alguien perdió una bota?"]
        static func devolver(_ bota: Bool) -> String {
            bota ? "🥾 Pa' dentro, que no es mi talla" : "🐟 ¡Vuelve con tu familia!"
        }
    }

    enum yoyo {
        static let inicio = ["🪀 Miren esto", "🪀 Hora del yoyo", "🪀 Arriba, abajo…"]
        static let perrito = "🪀 ¡Paseando al perrito!"
        static let fin = ["🪀 ¡Ta-dá!", "🪀 Campeón mundial de yoyo", "🪀 ¿Vieron eso?"]
    }

    enum selfie {
        static let inicio = ["📱 Una fotico pa' las redes", "📱 Sonrían…", "📱 Día de selfie"]
        static let fin = ["📸 ¡Salí divino!", "📸 Esta va de perfil", "📸 Cero filtros, pura belleza"]
    }

    enum periodico {
        static let inicio = "🗞️ A ver qué pasó hoy…"
        static let fin = "🗞️ Bueno, suficientes noticias"
        static let titulares = [
            "🗞️ 'Programador encuentra el bug… era un punto y coma'",
            "🗞️ 'Récord: reunión que pudo ser un correo duró 3 horas'",
            "🗞️ 'Desarrollador cierra 47 pestañas; su RAM se lo agradece'",
            "🗞️ 'Estudio confirma: el código de ayer lo escribió otra persona'",
            "🗞️ 'Hombre sale a producción un viernes. Sigue desaparecido'",
            "🗞️ 'Nadie sabe qué hace el script legacy, pero nadie lo toca'",
            "🗞️ 'Reiniciar arregló el problema, dicen expertos'",
            "🗞️ 'Café sube de precio; productividad nacional en alerta'",
        ]
    }
}
