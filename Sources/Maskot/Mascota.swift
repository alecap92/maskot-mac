import Foundation
import Observation
import Characters
import Motor

/// Una cosa suelta en la escena (la hoja, la bola de papel, la pesa).
struct Cosa {
    var cuadro: Cuadro
    var centro: CGPoint
    /// Dibujada al revés (p. ej. el avión cuando vuela hacia la izquierda).
    var espejo = false
    /// La lleva en la mano baja (el bastón): al caminar la sigue.
    var enManoAbajo = false
}

/// Los muebles que aparecen para una rutina (puede haber varios a la vez).
enum Mueble: Sendable, CaseIterable {
    case caneca, banca, cama, mesa, horno

    func cuadro(hornoPrendido: Bool = false) -> Cuadro {
        switch self {
        case .caneca: Utileria.caneca
        case .banca: Utileria.banca
        case .cama: Utileria.cama
        case .mesa: Utileria.mesa
        case .horno: Utileria.horno(prendido: hornoPrendido)
        }
    }
}

enum Postura: Sendable {
    case dePie, sentado, acostado
}

/// Un paso de lo que la mascota está haciendo. Las rutinas (ver `Rutinas.swift`)
/// son colas de acciones: las instantáneas se resuelven en el mismo tick, las
/// que duran (caminar, esperar, lanzar, saltar) ocupan varios.
enum Accion: Sendable {
    case esperar(TimeInterval)
    /// Camina esa distancia (el signo es la dirección); si se sale por un
    /// borde, aparece por el otro.
    case pasear(CGFloat)
    /// Camina hasta esa x, sin salirse de la pantalla.
    case irA(CGFloat)
    case saltar
    /// Aparece en esa x sin caminar (p. ej. detrás del borde de la pantalla).
    case ubicar(CGFloat)
    /// Voltea a mirar hacia un lado sin moverse.
    case mirar(izquierda: Bool)
    case cara(Expresion)
    case decir(String?)
    case gorra(Gorra)
    /// El brazo derecho (el que carga cosas).
    case brazo(Bool)
    case brazos(derecho: Bool, izquierdo: Bool)
    case postura(Postura)
    case mueble(Mueble, CGFloat)
    /// Quita todos los muebles.
    case quitarMueble
    case quitar(Mueble)
    /// Lo que hay encima de la mesa (`nil` = nada).
    case sobreMesa(Cuadro?)
    /// Una herramienta en la mano (el cuchillo): arriba o abajo; `nil` la suelta.
    case herramienta(Cuadro?, arriba: Bool)
    /// Levanta algo y lo carga en alto.
    case cargarCosa(Cuadro)
    /// Prende o apaga el horno. Al prenderlo, lo que cargaba queda adentro.
    case horno(Bool)
    case libro(Bool)
    case laptop(Bool)
    /// Golosina junto a la cara (con la lengua afuera si está lamiendo);
    /// `nil` se la termina.
    case golosina(Utileria.Golosina?, lamiendo: Bool)
    /// La pesa del gym: `true` arriba, `false` abajo, `nil` la suelta.
    case pesa(Bool?)
    case dejarHoja(CGFloat)
    case arrugarHoja
    case cargar
    case lanzarALaCaneca
    /// Lanza lo que carga (el avión de papel) hacia donde mira: planea y aterriza lejos.
    case lanzarAvion
    /// Suelta (y desaparece) lo que tenga en la mano o por ahí.
    case soltar

    // MARK: Piezas genéricas (para armar rutinas sin tocar el motor)

    /// Un decorado libre: se identifica por nombre y va en `x`; `y` es su
    /// centro (nil = apoyado en el piso). Cuadro `nil` lo quita.
    case decorado(String, Cuadro?, x: CGFloat, y: CGFloat? = nil)
    /// Como `decorado`, pero dibujado delante del personaje (binoculares en
    /// los ojos, la cámara frente a la cara).
    case delante(String, Cuadro?, x: CGFloat, y: CGFloat)
    /// Algo sostenido al frente del cuerpo (guitarra, periódico); `nil` lo guarda.
    case enFrente(Cuadro?)
    /// Algo puesto en la cabeza (sombrero); `nil` se lo quita.
    case accesorio(Cuadro?)
    /// Algo colgado a la espalda (mochila); `nil` se lo quita.
    case espalda(Cuadro?)
    /// Chispas de magia en la punta de lo que tiene en la mano y alrededor del objeto.
    case magia(Bool)

    /// El objeto suelto (balón, silla que levita…): aparece en el piso en `x`
    /// (nil = frente a sus pies). Cuadro `nil` lo quita.
    case objeto(Cuadro?, x: CGFloat? = nil)
    /// Pone el objeto en un punto exacto de la escena.
    case objetoEn(x: CGFloat, y: CGFloat)
    /// Pone el objeto justo encima de la cabeza.
    case objetoArriba
    /// Levanta el objeto a la mano en alto.
    case levantarObjeto
    /// El objeto vuela en parábola hasta (x, y) con esa altura de arco.
    case volar(x: CGFloat, y: CGFloat, altura: CGFloat, segundos: Double)
    /// El objeto cae al piso desde donde esté.
    case caer
    /// Dribla: el objeto rebota entre la mano y el piso, frente a él.
    case rebotar(veces: Int)
    /// El objeto sube y vuelve a bajar (un toque de vóley, lanzar la pelota).
    case toque(altura: CGFloat)
    /// El objeto se eleva y flota meciéndose; mientras, agita lo que tenga en la mano.
    case levitar(segundos: Double)
    /// Camina hasta esa x llevando el objeto con los pies (fútbol).
    case conducir(CGFloat)
    /// Cambia el dibujo de lo que carga, sin soltarlo (doblar la hoja).
    case cambiarCosa(Cuadro)
}

extension Accion {
    /// Las acciones que animan el objeto suelto (y no lo que tiene en la mano).
    var mueveElObjeto: Bool {
        switch self {
        case .volar, .caer, .rebotar, .toque, .levitar, .conducir: true
        default: false
        }
    }
}

@MainActor @Observable
final class Mascota {
    // MARK: Lo que se ve
    var personaje: any Personaje = Catalogo.porDefecto {
        didSet { Escena.lado = (Escena.ladoBase * personaje.escala).rounded() }
    }
    var x: CGFloat = 400
    var mirandoIzquierda = false
    var expresion: Expresion = .neutro
    var gorra: Gorra = .haciaAtras
    var brazoArriba = false
    var brazoIzquierdoArriba = false
    var postura: Postura = .dePie
    var globo: String?
    var cosa: Cosa?
    var muebles: [Mueble: CGFloat] = [:]
    var sobreMesa: Cuadro?
    var hornoPrendido = false
    var decorados: [String: Cosa] = [:]
    var delante: [String: Cosa] = [:]
    var enFrente: Cuadro?
    var accesorio: Cuadro?
    var espalda: Cuadro?
    var magia = false
    /// El objeto suelto (balón, silla que levita…), aparte de lo que tiene en la mano.
    var objeto: Cosa?
    var libro = false
    var laptop = false
    /// Altura del salto, en puntos.
    var altura: CGFloat = 0
    var dormido = false { didSet { if dormido { hacer(nil) } } }
    var anchoEscena: CGFloat = 1440
    let pomodoro = Pomodoro()
    /// Nombre de la rutina en curso (para `GET /estado`).
    private(set) var rutinaActual: String?
    /// Días en que se ha usado la app; se revisa cada tanto por si cambió el día.
    private(set) var diasDeUso = DiasDeUso.registrar()

    private(set) var paso = 0
    private(set) var destello = 0

    var cuadro: Cuadro {
        let cara: Expresion = dormido ? .dormido : (parpadeando && expresion == .neutro ? .parpadeo : expresion)
        return Sprite.cuadro(
            personaje, cara, gorra: gorra, paso: paso, destello: destello,
            brazoArriba: brazoArriba, brazoIzquierdoArriba: brazoIzquierdoArriba,
            tecleo: tecleando ? (ticks / 2) % 2 + 1 : 0
        )
    }

    /// Escribe a ráfagas: teclea un rato y hace una pausa, como pensando.
    var tecleando: Bool { laptop && (destello / 8) % 3 != 2 }

    /// Cuánto se sube el personaje sobre el piso (sentado o acostado queda
    /// encima del mueble; saltando, en el aire).
    var elevacion: CGFloat {
        (postura == .dePie ? 0 : 3 * Escena.lado) + altura
    }

    /// El rectángulo del personaje en la escena (origen arriba a la izquierda).
    var marcoPersonaje: CGRect {
        CGRect(
            x: x - Escena.anchoPersonaje / 2,
            y: Escena.piso - Escena.altoPersonaje - elevacion,
            width: Escena.anchoPersonaje,
            height: Escena.altoPersonaje
        )
    }

    // MARK: Motor
    private let velocidad: CGFloat = 60 // puntos por segundo
    private var cola: [Accion] = []
    private var actual: (accion: Accion, t: TimeInterval, restante: CGFloat, desde: CGPoint)?
    private var ticks = 0
    private var parpadeando = false
    private var parpadeoHasta: TimeInterval = 0
    private var reloj: TimeInterval = 0
    private var proximoAviso: TimeInterval = .random(in: 90...180)
    private var sentado = ContadorSentado()
    /// Hasta cuándo se ve un globo suelto (que no es parte de una rutina).
    private var globoHasta: TimeInterval?

    func tick(dt: TimeInterval) {
        ticks += 1
        reloj += dt
        if ticks % 6 == 0 { destello += 1 }
        if ticks % (20 * 60) == 0 { diasDeUso = DiasDeUso.registrar() }
        if dormido { return }

        parpadear()
        if let h = globoHasta, reloj >= h {
            globo = nil
            globoHasta = nil
        }

        // Con el Pomodoro corriendo, el reloj manda: nada de rutinas al azar
        // ni avisos. Si algo lo interrumpe (un clic), vuelve a lo de la fase.
        if pomodoro.activo {
            if let evento = pomodoro.avanzar(dt: dt) { reaccionar(a: evento) }
            if actual == nil && cola.isEmpty { hacerFase(anuncia: false) }
            avanzar(dt: dt)
            return
        }

        // Lleva mucho rato sin pausa: esto sí interrumpe lo que esté haciendo.
        if sentado.avanzar(dt: dt) {
            hacer(Biblioteca.llamada("Estiramiento"))
        }
        if actual == nil && cola.isEmpty {
            if reloj >= proximoAviso {
                proximoAviso = reloj + .random(in: 180...360)
                hacer(Biblioteca.llamada("Aviso"))
            } else {
                // La regla de oro: casi todo lo que sale solo es tranquilo.
                hacer(Biblioteca.alAzar())
            }
        }
        avanzar(dt: dt)
    }

    // MARK: Rutinas

    /// Arranca una rutina de la biblioteca, cortando lo que estuviera haciendo
    /// (se levanta, desaparecen los muebles). `nil` solo lo deja quieto.
    func hacer(_ rutina: Rutina?) {
        rutinaActual = rutina?.nombre
        if rutina != nil { dormido = false }
        brazoArriba = false
        brazoIzquierdoArriba = false
        postura = .dePie
        cosa = nil
        muebles = [:]
        sobreMesa = nil
        hornoPrendido = false
        decorados = [:]
        delante = [:]
        enFrente = nil
        accesorio = nil
        espalda = nil
        magia = false
        objeto = nil
        libro = false
        laptop = false
        gorra = .haciaAtras
        altura = 0
        globo = nil
        expresion = .neutro
        paso = 0
        actual = nil
        guard let rutina else { cola = []; return }
        // Camina unos pasos a otro lugar (a un lado o al otro) antes de empezar.
        var lugar = x
        switch rutina.lugar {
        case .aqui:
            break
        case .cerca:
            let pasos = CGFloat.random(in: 80...450) * (Bool.random() ? 1 : -1)
            lugar = min(max(x + pasos, 120), anchoEscena - 120)
        case .esquina:
            let margen = CGFloat.random(in: 110...170)
            lugar = x < anchoEscena / 2 ? margen : anchoEscena - margen
        }
        let contexto = Contexto(x: lugar, anchoEscena: anchoEscena, enEsquina: rutina.lugar == .esquina, diasDeUso: diasDeUso)
        cola = (lugar == x ? [] : [.irA(lugar)]) + rutina.pasos(contexto)
    }

    /// Clic sobre la mascota: salta y pasa a otra cosa. Si estaba dormido o
    /// descansando, se levanta.
    func alClic() {
        let estabaDescansando = dormido || postura != .dePie || expresion == .dormido
        hacer(Biblioteca.llamada("Saltar"))
        if estabaDescansando {
            cola.insert(contentsOf: [.decir(Frases.despertar.randomElement()), .cara(.sorprendido)], at: 0)
            cola.append(.decir(nil))
        }
    }

    // MARK: Pomodoro

    func iniciarPomodoro() {
        pomodoro.iniciar()
        hacerFase(anuncia: true)
    }

    func detenerPomodoro() {
        pomodoro.detener()
        hacer(Rutina(nombre: "Fin del pomodoro", peso: 0) { _ in
            [.cara(.feliz), .decir(Frases.pomodoro.fin), .esperar(3), .decir(nil), .cara(.neutro)]
        })
    }

    private func hacerFase(anuncia: Bool) {
        hacer(Biblioteca.pomodoro(pomodoro.fase, duracion: pomodoro.restante, tomate: pomodoro.tomate, anuncia: anuncia))
    }

    private func reaccionar(a evento: Pomodoro.Evento) {
        switch evento {
        case .empieza: hacerFase(anuncia: true)
        case .mitad: anunciar(Frases.pomodoro.mitad.randomElement()!)
        case .faltanCinco: anunciar(Frases.pomodoro.faltanCinco.randomElement()!)
        }
    }

    /// Un globo que no interrumpe lo que está haciendo.
    func anunciar(_ texto: String, segundos: TimeInterval = 5) {
        globo = texto
        globoHasta = reloj + segundos
    }

    func mostrar(_ cara: Expresion) {
        dormido = false
        cola = [.cara(cara), .esperar(4), .cara(.neutro)]
        actual = nil
    }

    // MARK: Ejecución

    private func avanzar(dt: TimeInterval) {
        // Resuelve las acciones instantáneas seguidas en el mismo tick.
        while actual == nil, !cola.isEmpty {
            let accion = cola.removeFirst()
            if !iniciar(accion) {
                let desde = accion.mueveElObjeto ? objeto?.centro : cosa?.centro
                actual = (accion, 0, 0, desde ?? .zero)
            }
        }
        guard var a = actual else { return }
        a.t += dt
        var terminada = false

        switch a.accion {
        case .esperar(let s):
            terminada = a.t >= s
        case .pasear(let distancia):
            if a.t == dt { a.restante = abs(distancia) }
            let avance = min(velocidad * dt, a.restante)
            caminar(avance * (distancia < 0 ? -1 : 1))
            a.restante -= avance
            // Sale por un borde, entra por el otro.
            let medio = Escena.anchoPersonaje / 2
            if x > anchoEscena + medio { x = -medio }
            if x < -medio { x = anchoEscena + medio }
            terminada = a.restante <= 0
        case .irA(let destino):
            let falta = destino - x
            let avance = min(velocidad * dt, abs(falta))
            caminar(falta < 0 ? -avance : avance)
            terminada = abs(destino - x) < 0.5
        case .saltar:
            let t = min(a.t / 0.45, 1)
            altura = 45 * 4 * t * (1 - t)
            terminada = t >= 1
            if terminada { altura = 0 }
        case .volar(let vx, let vy, let altura, let s):
            let t = min(a.t / s, 1)
            objeto?.centro = CGPoint(
                x: a.desde.x + (vx - a.desde.x) * t,
                y: a.desde.y + (vy - a.desde.y) * t - altura * 4 * t * (1 - t)
            )
            terminada = t >= 1
        case .caer:
            let t = min(a.t / 0.35, 1)
            let piso = pisoDelObjeto
            objeto?.centro.y = a.desde.y + (piso - a.desde.y) * t * t
            terminada = t >= 1
        case .rebotar(let veces):
            // Entre la mano (abajo) y el piso, frente a él.
            let fase = (a.t / 0.45).truncatingRemainder(dividingBy: 1)
            let arriba = manoAbajo.y, piso = pisoDelObjeto, fx = frente
            objeto?.centro = CGPoint(x: fx, y: arriba + (piso - arriba) * sin(.pi * fase))
            terminada = a.t >= Double(veces) * 0.45
        case .toque(let altura):
            let t = min(a.t / 0.9, 1)
            objeto?.centro.y = a.desde.y - altura * 4 * t * (1 - t)
            terminada = t >= 1
        case .levitar(let s):
            // Sube, flota meciéndose y la varita (o lo que tenga) se agita.
            let subida = min(a.t / 1.2, 1)
            let vaiven = subida >= 1 ? 1.0 : 0.0
            objeto?.centro = CGPoint(
                x: a.desde.x + 20 * sin(2 * .pi * a.t / 2.4) * vaiven,
                y: a.desde.y - 70 * subida + 8 * sin(2 * .pi * a.t / 1.2) * vaiven
            )
            brazoArriba = Int(a.t / 0.35) % 2 == 0
            if cosa != nil {
                let m = brazoArriba ? mano : manoAbajo
                cosa?.centro = m
            }
            terminada = a.t >= s
            if terminada { brazoArriba = true; let m = mano; cosa?.centro = m }
        case .conducir(let destino):
            let falta = destino - x
            let avance = min(velocidad * 0.8 * dt, abs(falta))
            caminar(falta < 0 ? -avance : avance)
            // El balón va rodando un poco por delante de los pies.
            let rodar = 4 * sin(a.t * 12)
            let pie = CGPoint(x: frente + rodar, y: pisoDelObjeto)
            objeto?.centro = pie
            terminada = abs(destino - x) < 0.5
        case .lanzarAvion:
            // Sube un poco, planea y baja hasta el piso.
            let t = min(a.t / 3.2, 1)
            let dir: CGFloat = mirandoIzquierda ? -1 : 1
            let piso = Escena.piso - 10
            let px = a.desde.x + dir * 560 * t
            let py = a.desde.y + (piso - a.desde.y) * t * t - 70 * sin(.pi * min(t * 1.3, 1))
            cosa?.centro = CGPoint(x: px, y: py)
            terminada = t >= 1
        case .lanzarALaCaneca:
            let t = min(a.t / 0.7, 1)
            let meta = CGPoint(x: muebles[.caneca] ?? a.desde.x, y: Escena.piso - 55)
            let px = a.desde.x + (meta.x - a.desde.x) * t
            let py = a.desde.y + (meta.y - a.desde.y) * t - 110 * 4 * t * (1 - t) // parábola
            cosa?.centro = CGPoint(x: px, y: py)
            if t >= 1 { cosa = nil; terminada = true }
        default:
            terminada = true
        }

        if terminada {
            paso = 0
            actual = nil
        } else {
            actual = a
        }
    }

    /// Ejecuta una acción instantánea; `false` si es de las que duran.
    private func iniciar(_ accion: Accion) -> Bool {
        switch accion {
        case .cara(let e): expresion = e
        case .ubicar(let nx): x = nx
        case .mirar(let izquierda):
            mirandoIzquierda = izquierda
            // Lo que tiene en la mano se voltea con él.
            if brazoArriba, cosa != nil {
                let m = mano
                cosa?.centro = m
            } else if cosa?.enManoAbajo == true {
                let m = manoAbajo
                cosa?.centro = m
            }
        case .decir(let t): globo = t
        case .gorra(let g): gorra = g
        case .brazo(let b): brazoArriba = b
        case .brazos(let d, let i):
            brazoArriba = d
            brazoIzquierdoArriba = i
        case .libro(let l): libro = l
        case .laptop(let l): laptop = l
        case .mueble(let tipo, let mx): muebles[tipo] = mx
        case .quitarMueble: muebles = [:]
        case .quitar(let tipo): muebles[tipo] = nil
        case .sobreMesa(let c): sobreMesa = c
        case .herramienta(let c, let arriba):
            guard let c else { cosa = nil; brazoArriba = false; break }
            brazoArriba = arriba
            cosa = Cosa(cuadro: c, centro: .zero, enManoAbajo: !arriba)
            let centro = arriba ? mano : manoAbajo
            cosa?.centro = centro
        case .cargarCosa(let c):
            brazoArriba = true
            cosa = Cosa(cuadro: c, centro: .zero)
            let m = mano
            cosa?.centro = m
        case .horno(let prendido):
            hornoPrendido = prendido
            if prendido { cosa = nil; brazoArriba = false }
        case .postura(let p):
            postura = p
            // Se acomoda: en la banca al centro, en la cama con la cabeza hacia la cabecera.
            if p != .dePie, let mx = muebles[p == .acostado ? .cama : .banca] { x = mx + (p == .acostado ? 10 : 0) }
            mirandoIzquierda = false
        case .golosina(let g, let lamiendo):
            guard let g else { cosa = nil; brazoArriba = false; break }
            brazoArriba = true
            let cuadro = g.cuadro(lamiendo: lamiendo)
            cosa = Cosa(cuadro: cuadro, centro: junto(a: cuadro))
        case .pesa(let arriba):
            guard let arriba else { cosa = nil; brazoArriba = false; break }
            brazoArriba = arriba
            cosa = Cosa(cuadro: Utileria.pesa, centro: .zero)
            let centro = arriba ? mano : manoAbajo
            cosa?.centro = centro
        case .dejarHoja(let hx):
            let h = Utileria.hoja
            cosa = Cosa(cuadro: h, centro: CGPoint(x: hx, y: Escena.piso - CGFloat(h.alto) * Escena.lado / 2))
        case .arrugarHoja:
            guard let c = cosa else { break }
            let b = Utileria.bola
            cosa = Cosa(cuadro: b, centro: CGPoint(x: c.centro.x, y: Escena.piso - CGFloat(b.alto) * Escena.lado / 2))
        case .cargar:
            let m = mano
            cosa?.centro = m
        case .soltar:
            cosa = nil
            brazoArriba = false
        case .decorado(let id, let c, let dx, let dy):
            if let c {
                let y = dy ?? Escena.piso - CGFloat(c.alto) * Escena.lado / 2
                decorados[id] = Cosa(cuadro: c, centro: CGPoint(x: dx, y: y))
            } else {
                decorados[id] = nil
            }
        case .delante(let id, let c, let dx, let dy):
            delante[id] = c.map { Cosa(cuadro: $0, centro: CGPoint(x: dx, y: dy)) }
        case .enFrente(let c): enFrente = c
        case .accesorio(let c): accesorio = c
        case .espalda(let c): espalda = c
        case .magia(let m): magia = m
        case .objeto(let c, let ox):
            if let c {
                let piso = Escena.piso - CGFloat(c.alto) * Escena.lado / 2
                objeto = Cosa(cuadro: c, centro: CGPoint(x: ox ?? frente, y: piso))
            } else {
                objeto = nil
            }
        case .objetoEn(let ox, let oy): objeto?.centro = CGPoint(x: ox, y: oy)
        case .objetoArriba:
            let marco = marcoPersonaje
            let alto = CGFloat(objeto?.cuadro.alto ?? 0) * Escena.lado
            objeto?.centro = CGPoint(x: marco.midX, y: marco.minY + 2 * Escena.lado - alto / 2)
        case .levantarObjeto:
            brazoArriba = true
            let m = mano
            objeto?.centro = m
        case .cambiarCosa(let c):
            cosa?.cuadro = c
            if brazoArriba {
                let m = mano
                cosa?.centro = m
            }
        case .esperar, .pasear, .irA, .saltar, .lanzarALaCaneca,
             .volar, .caer, .rebotar, .toque, .levitar, .conducir: return false
        case .lanzarAvion:
            cosa?.espejo = mirandoIzquierda
            brazoArriba = false
            return false
        }
        return true
    }

    private func caminar(_ dx: CGFloat) {
        guard dx != 0 else { return }
        x += dx
        mirandoIzquierda = dx < 0
        if ticks % 4 == 0 { paso = paso == 1 ? 2 : 1 }
        if brazoArriba, cosa != nil {
            let m = mano
            cosa?.centro = m
        } else if cosa?.enManoAbajo == true {
            let m = manoAbajo
            cosa?.centro = m
        }
    }

    /// Justo encima de la mano en alto, donde va lo que carga.
    private var mano: CGPoint {
        let marco = marcoPersonaje
        let mano = personaje.brazos.mano
        let col = CGFloat(mano.col) + CGFloat(Sprite.margen.col)
        let fila = CGFloat(mano.fila) + CGFloat(Sprite.margen.fila)
        let alto = CGFloat(cosa?.cuadro.alto ?? 0) * Escena.lado
        return CGPoint(
            x: marco.minX + (mirandoIzquierda ? CGFloat(Sprite.ancho) - col : col) * Escena.lado,
            y: marco.minY + fila * Escena.lado - alto / 2
        )
    }

    /// Dónde va la golosina: pegada a la cara del lado del brazo en alto,
    /// con la lengua (columna 0 del cuadro) a la altura de la boca.
    private func junto(a cuadro: Cuadro) -> CGPoint {
        let marco = marcoPersonaje
        // La lengua (fila 3 del cuadro) arranca en la boca del personaje.
        let boca = personaje.boca
        let izquierda = CGFloat(boca.col + Sprite.margen.col)
        let centroCol = izquierda + CGFloat(cuadro.ancho) / 2
        let arriba = CGFloat(boca.fila - 3 + Sprite.margen.fila)
        return CGPoint(
            x: marco.minX + (mirandoIzquierda ? CGFloat(Sprite.ancho) - centroCol : centroCol) * Escena.lado,
            y: marco.minY + (arriba + CGFloat(cuadro.alto) / 2) * Escena.lado
        )
    }

    /// Frente a sus pies, hacia donde mira.
    private var frente: CGFloat {
        x + (mirandoIzquierda ? -1 : 1) * Escena.anchoPersonaje * 0.45
    }

    /// La y del centro del objeto apoyado en el piso.
    private var pisoDelObjeto: CGFloat {
        Escena.piso - CGFloat(objeto?.cuadro.alto ?? 0) * Escena.lado / 2
    }

    /// Colgando de la punta del brazo derecho, en reposo.
    private var manoAbajo: CGPoint {
        let marco = marcoPersonaje
        let mano = personaje.brazos.manoAbajo
        let col = CGFloat(mano.col) + CGFloat(Sprite.margen.col)
        let fila = CGFloat(mano.fila) + CGFloat(Sprite.margen.fila)
        return CGPoint(
            x: marco.minX + (mirandoIzquierda ? CGFloat(Sprite.ancho) - col : col) * Escena.lado,
            y: marco.minY + fila * Escena.lado
        )
    }

    private func parpadear() {
        if parpadeando {
            if reloj >= parpadeoHasta { parpadeando = false }
        } else if Int.random(in: 0..<70) == 0 {
            parpadeando = true
            parpadeoHasta = reloj + 0.15
        }
    }
}
