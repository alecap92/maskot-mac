import Foundation
import Motor
import Network

/// La API local: un servidor HTTP mínimo (Network.framework, sin dependencias)
/// para que otros programas —un script, un cron, un agente de IA— le pidan
/// cosas a la mascota. Está apagada por defecto.
///
/// - Solo este Mac: escucha en 127.0.0.1 y no pide token.
/// - Red local: escucha en la LAN, se anuncia por Bonjour (`_maskot._tcp`, con
///   el nombre del equipo) y exige `Authorization: Bearer <token>`.
///
/// Endpoints (JSON):
///
///     GET  /estado                               cómo está la mascota
///     GET  /rutinas                              las rutinas que sabe hacer
///     POST /aviso    {"mensaje", "urgente"?, "hastaClic"?}
///                                                aviso normal o urgente; por defecto
///                                                insiste hasta que le den clic
///     POST /visto                                descarta el aviso pendiente (como el clic)
///     POST /decir    {"mensaje", "segundos"?}    solo un globo, sin interrumpir
///     POST /rutina   {"rutina"}                  hace esa rutina ya
///     POST /pomodoro {"accion": "iniciar" | "detener"}
final class ServidorAPI: @unchecked Sendable {
    struct Ajustes: Sendable {
        var puerto: UInt16
        var lan: Bool
        var token: String
        var nombre: String
    }

    private let ajustes: Ajustes
    private let mascota: Mascota
    private let cola = DispatchQueue(label: "maskot.api")
    private var oyente: NWListener?

    init(ajustes: Ajustes, mascota: Mascota) {
        self.ajustes = ajustes
        self.mascota = mascota
    }

    func iniciar() throws {
        let parametros = NWParameters.tcp
        parametros.allowLocalEndpointReuse = true
        let puerto = NWEndpoint.Port(rawValue: ajustes.puerto)!
        if !ajustes.lan {
            parametros.requiredLocalEndpoint = .hostPort(host: "127.0.0.1", port: puerto)
        }
        let oyente = try ajustes.lan ? NWListener(using: parametros, on: puerto) : NWListener(using: parametros)
        if ajustes.lan {
            // Bonjour: así un agente en la red encuentra todos los Maskot sin
            // una lista a mano. El TXT lleva el nombre legible del equipo.
            let txt = NWTXTRecord(["nombre": ajustes.nombre, "version": "1"])
            oyente.service = NWListener.Service(name: ajustes.nombre, type: "_maskot._tcp", txtRecord: txt)
        }
        oyente.newConnectionHandler = { [weak self] conexion in self?.atender(conexion) }
        oyente.start(queue: cola)
        self.oyente = oyente
    }

    func detener() {
        oyente?.cancel()
        oyente = nil
    }

    // MARK: - HTTP mínimo

    private func atender(_ conexion: NWConnection) {
        conexion.start(queue: cola)
        leer(conexion, acumulado: Data())
    }

    /// Lee hasta tener los encabezados y el cuerpo completo (Content-Length).
    private func leer(_ conexion: NWConnection, acumulado: Data) {
        conexion.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] datos, _, terminado, error in
            guard let self else { return }
            var total = acumulado
            if let datos { total.append(datos) }
            if error != nil || total.count > 256 * 1024 {
                conexion.cancel()
                return
            }
            if let pedido = Pedido(total) {
                self.responder(pedido, en: conexion)
            } else if terminado {
                self.enviar(400, ["error": "pedido HTTP incompleto"], en: conexion)
            } else {
                self.leer(conexion, acumulado: total)
            }
        }
    }

    private func responder(_ pedido: Pedido, en conexion: NWConnection) {
        if ajustes.lan, pedido.encabezados["authorization"] != "Bearer \(ajustes.token)" {
            enviar(401, ["error": "falta el token (Authorization: Bearer …)"], en: conexion)
            return
        }
        let mascota = self.mascota
        Task { @MainActor in
            let (codigo, cuerpo) = Self.manejar(pedido, mascota: mascota)
            self.enviar(codigo, cuerpo, en: conexion)
        }
    }

    private func enviar(_ codigo: Int, _ cuerpo: [String: Any], en conexion: NWConnection) {
        let json = (try? JSONSerialization.data(withJSONObject: cuerpo, options: [.sortedKeys])) ?? Data("{}".utf8)
        let estado = [200: "OK", 400: "Bad Request", 401: "Unauthorized", 404: "Not Found"][codigo] ?? "Error"
        var respuesta = Data("HTTP/1.1 \(codigo) \(estado)\r\nContent-Type: application/json; charset=utf-8\r\nContent-Length: \(json.count)\r\nConnection: close\r\n\r\n".utf8)
        respuesta.append(json)
        conexion.send(content: respuesta, completion: .contentProcessed { _ in conexion.cancel() })
    }

    // MARK: - Rutas

    @MainActor
    private static func manejar(_ pedido: Pedido, mascota: Mascota) -> (Int, [String: Any]) {
        let cuerpo = pedido.json
        let mensaje = (cuerpo["mensaje"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)

        switch (pedido.metodo, pedido.ruta) {
        case ("GET", "/estado"):
            let p = mascota.pomodoro
            var estado: [String: Any] = [
                "personaje": mascota.personaje.nombre,
                "rutina": mascota.rutinaActual ?? NSNull(),
                "dormido": mascota.dormido,
                "avisoPendiente": mascota.alerta != nil,
            ]
            estado["pomodoro"] = p.activo
                ? ["activo": true, "fase": p.fase.nombre, "tomate": p.tomate, "restante": p.reloj] as [String: Any]
                : ["activo": false]
            return (200, estado)

        case ("GET", "/rutinas"):
            return (200, ["rutinas": Biblioteca.rutinas.map(\.nombre)])

        case ("POST", "/aviso"):
            guard let mensaje, !mensaje.isEmpty else { return (400, ["error": "falta \"mensaje\""]) }
            let urgente = cuerpo["urgente"] as? Bool ?? false
            let hastaClic = cuerpo["hastaClic"] as? Bool ?? true
            mascota.avisar(mensaje, urgente: urgente, hastaClic: hastaClic)
            return (200, ["ok": true, "hastaClic": hastaClic])

        case ("POST", "/visto"):
            return (200, ["ok": true, "habiaAviso": mascota.descartarAviso()])

        case ("POST", "/decir"):
            guard let mensaje, !mensaje.isEmpty else { return (400, ["error": "falta \"mensaje\""]) }
            let segundos = cuerpo["segundos"] as? Double ?? 6
            mascota.anunciar(mensaje, segundos: min(max(segundos, 1), 60))
            return (200, ["ok": true])

        case ("POST", "/rutina"):
            guard let nombre = cuerpo["rutina"] as? String,
                  let rutina = Biblioteca.rutinas.first(where: { $0.nombre.localizedCaseInsensitiveCompare(nombre) == .orderedSame })
            else { return (404, ["error": "no existe esa rutina; mira GET /rutinas"]) }
            mascota.hacer(rutina)
            return (200, ["ok": true, "rutina": rutina.nombre])

        case ("POST", "/pomodoro"):
            switch cuerpo["accion"] as? String {
            case "iniciar": if !mascota.pomodoro.activo { mascota.iniciarPomodoro() }
            case "detener": if mascota.pomodoro.activo { mascota.detenerPomodoro() }
            default: return (400, ["error": "\"accion\" debe ser \"iniciar\" o \"detener\""])
            }
            return (200, ["ok": true, "activo": mascota.pomodoro.activo])

        default:
            return (404, ["error": "ruta desconocida", "rutas": ["GET /estado", "GET /rutinas", "POST /aviso", "POST /visto", "POST /decir", "POST /rutina", "POST /pomodoro"]])
        }
    }
}

/// Un pedido HTTP ya completo (encabezados + cuerpo). `nil` si faltan datos.
private struct Pedido {
    let metodo: String
    let ruta: String
    let encabezados: [String: String]
    let cuerpo: Data

    var json: [String: Any] {
        (try? JSONSerialization.jsonObject(with: cuerpo)) as? [String: Any] ?? [:]
    }

    init?(_ datos: Data) {
        guard let fin = datos.range(of: Data("\r\n\r\n".utf8)),
              let cabecera = String(data: datos[..<fin.lowerBound], encoding: .utf8) else { return nil }
        let lineas = cabecera.components(separatedBy: "\r\n")
        let primera = lineas.first?.split(separator: " ") ?? []
        guard primera.count >= 2 else { return nil }
        var encabezados: [String: String] = [:]
        for linea in lineas.dropFirst() {
            guard let dos = linea.firstIndex(of: ":") else { continue }
            encabezados[linea[..<dos].lowercased()] = linea[linea.index(after: dos)...].trimmingCharacters(in: .whitespaces)
        }
        let largo = Int(encabezados["content-length"] ?? "0") ?? 0
        let cuerpo = datos[fin.upperBound...]
        guard cuerpo.count >= largo else { return nil }
        metodo = String(primera[0]).uppercased()
        ruta = String(primera[1].split(separator: "?").first ?? "")
        self.encabezados = encabezados
        self.cuerpo = Data(cuerpo.prefix(largo))
    }
}
