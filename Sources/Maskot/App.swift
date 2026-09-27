import AppKit
import Characters
import Motor
import SwiftUI

@main
enum Principal {
    @MainActor static func main() {
        let app = NSApplication.shared
        if let rutina = ProcessInfo.processInfo.environment["MASKOT_FOTOS"] {
            Fotos.tomar(rutina)
            return
        }
        let delegado = Delegado()
        app.delegate = delegado
        app.setActivationPolicy(.accessory) // sin ícono en el Dock, solo 🧢 en la barra
        withExtendedLifetime(delegado) { app.run() }
    }
}

@MainActor
final class Delegado: NSObject, NSApplicationDelegate {
    let mascota = Mascota()
    private var panel: NSPanel?
    private var item: NSStatusItem?
    private var reloj: Timer?
    private var servidor: ServidorAPI?
    private var menuAPI: NSMenu?
    private var opcionPomodoro: NSMenuItem?
    private var estadoPomodoro: NSMenuItem?

    func applicationDidFinishLaunching(_ aviso: Notification) {
        if let id = UserDefaults.standard.string(forKey: "personaje"), let p = Catalogo.buscar(id) {
            mascota.personaje = p
        }
        armarPanel()
        armarMenu()
        prenderAPI()
        // Si cambia la resolución, se conecta otra pantalla o se mueve el Dock,
        // la franja se vuelve a acomodar.
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.acomodarPanel() }
        }
        let dt = 1.0 / 20
        let reloj = Timer(timeInterval: dt, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.mascota.tick(dt: dt)
                self?.dejarPasarElMouse()
                self?.mostrarPomodoro()
            }
        }
        RunLoop.main.add(reloj, forMode: .common) // sigue animando con el menú abierto
        self.reloj = reloj
        // Atajo de desarrollo: `MASKOT_DEMO="Botar una hoja" swift run Maskot`
        // arranca con esa rutina de la biblioteca.
        let demo = ProcessInfo.processInfo.environment["MASKOT_DEMO"]
        let inicial = Biblioteca.rutinas.first { $0.nombre == demo } ?? Biblioteca.llamada("Saludar")
        mascota.hacer(inicial)
    }

    /// Una franja transparente a **todo el ancho** de la pantalla principal,
    /// justo encima del Dock. La mascota camina de borde a borde y sale por un
    /// lado para entrar por el otro. Deja pasar el mouse a lo que está debajo,
    /// salvo justo encima de la mascota (ver `dejarPasarElMouse`).
    private func armarPanel() {
        let panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.ignoresMouseEvents = true
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]

        let vista = VistaAnfitriona(rootView: VistaEscena(mascota: mascota))
        vista.alClic = { [weak self] in self?.mascota.alClic() }
        panel.contentView = vista
        self.panel = panel
        acomodarPanel()
        mascota.x = .random(in: 150...max(151, mascota.anchoEscena - 150))
        panel.orderFrontRegardless()
    }

    /// Ajusta la franja a la pantalla principal (la de la barra de menú; con
    /// varios monitores, `NSScreen.main` sería la que tenga el foco).
    private func acomodarPanel() {
        guard let panel, let pantalla = NSScreen.screens.first else { return }
        let marco = NSRect(
            x: pantalla.frame.minX, y: pantalla.visibleFrame.minY,
            width: pantalla.frame.width, height: Escena.alto
        )
        panel.setFrame(marco, display: true)
        panel.contentView?.frame = NSRect(origin: .zero, size: marco.size)
        mascota.anchoEscena = marco.width
        mascota.x = min(mascota.x, marco.width)
    }

    /// La franja solo atrapa el mouse cuando está encima de la mascota; en el
    /// resto, los clics caen a las ventanas de abajo.
    private func dejarPasarElMouse() {
        guard let panel, panel.isVisible else { return }
        let m = NSEvent.mouseLocation
        let local = CGPoint(x: m.x - panel.frame.minX, y: panel.frame.maxY - m.y) // origen arriba
        let encima = mascota.marcoPersonaje.insetBy(dx: 8, dy: 8).contains(local)
        if panel.ignoresMouseEvents == encima { panel.ignoresMouseEvents = !encima }
    }

    // MARK: - Menú 🧢

    private func armarMenu() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "🧢"
        let menu = NSMenu()

        let personajes = NSMenu()
        for (i, p) in Catalogo.todos.enumerated() {
            let o = opcion(p.nombre, #selector(elegirPersonaje(_:)))
            o.tag = i
            o.state = p.id == mascota.personaje.id ? .on : .off
            personajes.addItem(o)
        }
        let submenuPersonajes = NSMenuItem(title: "Personaje", action: nil, keyEquivalent: "")
        submenuPersonajes.submenu = personajes
        menu.addItem(submenuPersonajes)
        menu.addItem(.separator())

        // Pomodoro: iniciar/detener, cómo va y cuánto dura cada bloque.
        let opcionPomodoro = opcion("🍅 Iniciar pomodoro", #selector(alternarPomodoro))
        menu.addItem(opcionPomodoro)
        let estadoPomodoro = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        estadoPomodoro.isEnabled = false
        estadoPomodoro.isHidden = true
        menu.addItem(estadoPomodoro)
        let formatos = NSMenu()
        for (i, f) in Pomodoro.Formato.todos.enumerated() {
            let o = opcion(f.nombre, #selector(elegirFormato(_:)))
            o.tag = i
            o.state = f == mascota.pomodoro.formato ? .on : .off
            formatos.addItem(o)
        }
        let submenuFormatos = NSMenuItem(title: "Duración del pomodoro", action: nil, keyEquivalent: "")
        submenuFormatos.submenu = formatos
        menu.addItem(submenuFormatos)
        menu.addItem(.separator())
        self.opcionPomodoro = opcionPomodoro
        self.estadoPomodoro = estadoPomodoro

        let rutinas = NSMenu()
        for (i, r) in Biblioteca.rutinas.enumerated() {
            let o = opcion(r.nombre, #selector(hacerRutina(_:)))
            o.tag = i
            rutinas.addItem(o)
        }
        let submenuRutinas = NSMenuItem(title: "Rutinas", action: nil, keyEquivalent: "")
        submenuRutinas.submenu = rutinas
        menu.addItem(submenuRutinas)

        let caras = NSMenu()
        for (i, e) in Expresion.allCases.enumerated() {
            let o = opcion(e.nombre, #selector(ponerCara(_:)))
            o.tag = i
            caras.addItem(o)
        }
        let submenuCaras = NSMenuItem(title: "Expresiones", action: nil, keyEquivalent: "")
        submenuCaras.submenu = caras
        menu.addItem(submenuCaras)

        let gorras = NSMenu()
        for (i, g) in Gorra.allCases.enumerated() {
            let o = opcion(g.nombre, #selector(ponerGorra(_:)))
            o.tag = i
            gorras.addItem(o)
        }
        let submenuGorra = NSMenuItem(title: "Gorra", action: nil, keyEquivalent: "")
        submenuGorra.submenu = gorras
        menu.addItem(submenuGorra)

        let menuAPI = NSMenu()
        let submenuAPI = NSMenuItem(title: "API local", action: nil, keyEquivalent: "")
        submenuAPI.submenu = menuAPI
        menu.addItem(submenuAPI)
        self.menuAPI = menuAPI
        armarMenuAPI()

        menu.addItem(.separator())
        menu.addItem(opcion("Dormir / Despertar", #selector(dormir)))
        menu.addItem(opcion("Ocultar / Mostrar", #selector(ocultar)))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Salir", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        item.menu = menu
        self.item = item
    }

    private func opcion(_ titulo: String, _ accion: Selector) -> NSMenuItem {
        let o = NSMenuItem(title: titulo, action: accion, keyEquivalent: "")
        o.target = self
        return o
    }

    @objc private func elegirPersonaje(_ o: NSMenuItem) {
        let p = Catalogo.todos[o.tag]
        mascota.personaje = p
        UserDefaults.standard.set(p.id, forKey: "personaje")
        o.menu?.items.forEach { $0.state = $0 == o ? .on : .off }
    }

    // MARK: - API local

    /// Modo guardado en las preferencias: 0 apagada, 1 solo este Mac, 2 red local.
    /// `MASKOT_API=local|lan` lo fuerza (para probar).
    private var modoAPI: Int {
        get {
            switch ProcessInfo.processInfo.environment["MASKOT_API"] {
            case "local": 1
            case "lan": 2
            default: UserDefaults.standard.integer(forKey: "apiModo")
            }
        }
        set { UserDefaults.standard.set(newValue, forKey: "apiModo") }
    }

    private var puertoAPI: UInt16 {
        UInt16(exactly: UserDefaults.standard.integer(forKey: "apiPuerto")).flatMap { $0 == 0 ? nil : $0 } ?? 7777
    }

    /// El token para la red local. Se genera la primera vez; para usar el mismo
    /// en varios Mac, cópialo de uno y pégalo en los demás (o `defaults write`).
    private var tokenAPI: String {
        get {
            if let t = UserDefaults.standard.string(forKey: "apiToken"), !t.isEmpty { return t }
            let nuevo = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
            UserDefaults.standard.set(nuevo, forKey: "apiToken")
            return nuevo
        }
        set { UserDefaults.standard.set(newValue, forKey: "apiToken") }
    }

    /// Cómo se anuncia en la red; por defecto, el nombre del Mac.
    private var nombreEquipo: String {
        get { UserDefaults.standard.string(forKey: "apiNombre") ?? Host.current().localizedName ?? "Mac" }
        set { UserDefaults.standard.set(newValue, forKey: "apiNombre") }
    }

    private func prenderAPI() {
        servidor?.detener()
        servidor = nil
        guard modoAPI != 0 else { return }
        let ajustes = ServidorAPI.Ajustes(puerto: puertoAPI, lan: modoAPI == 2, token: tokenAPI, nombre: nombreEquipo)
        let servidor = ServidorAPI(ajustes: ajustes, mascota: mascota)
        do {
            try servidor.iniciar()
            self.servidor = servidor
        } catch {
            NSLog("Maskot: no se pudo abrir la API en el puerto \(ajustes.puerto): \(error)")
        }
    }

    private func armarMenuAPI() {
        guard let menuAPI else { return }
        menuAPI.removeAllItems()
        for (i, titulo) in ["Apagada", "Solo este Mac", "Red local (con token)"].enumerated() {
            let o = opcion(titulo, #selector(elegirModoAPI(_:)))
            o.tag = i
            o.state = modoAPI == i ? .on : .off
            menuAPI.addItem(o)
        }
        menuAPI.addItem(.separator())
        let info = NSMenuItem(title: "Nombre: \(nombreEquipo) · puerto \(puertoAPI)", action: nil, keyEquivalent: "")
        info.isEnabled = false
        menuAPI.addItem(info)
        menuAPI.addItem(opcion("Cambiar nombre…", #selector(cambiarNombre)))
        menuAPI.addItem(opcion("Copiar token", #selector(copiarToken)))
        menuAPI.addItem(opcion("Pegar token (el de otro Mac)", #selector(pegarToken)))
        menuAPI.addItem(opcion("Copiar ejemplo con curl", #selector(copiarEjemplo)))
    }

    @objc private func elegirModoAPI(_ o: NSMenuItem) {
        modoAPI = o.tag
        prenderAPI()
        armarMenuAPI()
    }

    @objc private func cambiarNombre() {
        let alerta = NSAlert()
        alerta.messageText = "Nombre de este Mac en la red"
        alerta.informativeText = "Así lo verá quien le envíe avisos (por ejemplo, un agente en otro equipo)."
        let campo = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        campo.stringValue = nombreEquipo
        alerta.accessoryView = campo
        alerta.addButton(withTitle: "Guardar")
        alerta.addButton(withTitle: "Cancelar")
        NSApp.activate(ignoringOtherApps: true)
        guard alerta.runModal() == .alertFirstButtonReturn else { return }
        let nombre = campo.stringValue.trimmingCharacters(in: .whitespaces)
        guard !nombre.isEmpty else { return }
        nombreEquipo = nombre
        prenderAPI()
        armarMenuAPI()
    }

    @objc private func copiarToken() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(tokenAPI, forType: .string)
    }

    @objc private func pegarToken() {
        guard let texto = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines),
              texto.count >= 16, !texto.contains(" ") else { return }
        tokenAPI = texto
        prenderAPI()
    }

    @objc private func copiarEjemplo() {
        let lan = modoAPI == 2
        let host = lan ? ProcessInfo.processInfo.hostName : "127.0.0.1"
        let auth = lan ? " -H 'Authorization: Bearer \(tokenAPI)'" : ""
        let ejemplo = "curl -X POST http://\(host):\(puertoAPI)/aviso\(auth) -H 'Content-Type: application/json' -d '{\"mensaje\": \"📅 Reunión en 10 minutos\"}'"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(ejemplo, forType: .string)
    }

    @objc private func alternarPomodoro() {
        if mascota.pomodoro.activo { mascota.detenerPomodoro() } else { mascota.iniciarPomodoro() }
    }

    @objc private func elegirFormato(_ o: NSMenuItem) {
        mascota.pomodoro.formato = Pomodoro.Formato.todos[o.tag]
        o.menu?.items.forEach { $0.state = $0 == o ? .on : .off }
    }

    /// El reloj en la barra (🍅 18:42) y el estado en el menú. Solo toca la
    /// UI cuando el texto cambia.
    private func mostrarPomodoro() {
        let p = mascota.pomodoro
        let titulo = p.activo ? "🍅 \(p.reloj)" : "🧢"
        if item?.button?.title != titulo { item?.button?.title = titulo }

        let opcion = p.activo ? "⏹ Detener pomodoro" : "🍅 Iniciar pomodoro"
        if opcionPomodoro?.title != opcion { opcionPomodoro?.title = opcion }

        estadoPomodoro?.isHidden = !p.activo
        let estado = "Tomate \(p.tomate) de \(Pomodoro.tomatesPorCiclo) · \(p.fase.nombre) · \(p.reloj)"
        if p.activo, estadoPomodoro?.title != estado { estadoPomodoro?.title = estado }
    }

    @objc private func hacerRutina(_ o: NSMenuItem) { mascota.hacer(Biblioteca.rutinas[o.tag]) }
    @objc private func ponerCara(_ o: NSMenuItem) { mascota.mostrar(Expresion.allCases[o.tag]) }
    @objc private func ponerGorra(_ o: NSMenuItem) { mascota.gorra = Gorra.allCases[o.tag] }
    @objc private func dormir() { mascota.dormido.toggle() }
    @objc private func ocultar() {
        guard let panel else { return }
        if panel.isVisible { panel.orderOut(nil) } else { panel.orderFrontRegardless() }
    }
}

/// Recibe el clic sin tener que activar la app primero.
final class VistaAnfitriona: NSHostingView<VistaEscena> {
    var alClic: (() -> Void)?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        alClic?()
    }
}
