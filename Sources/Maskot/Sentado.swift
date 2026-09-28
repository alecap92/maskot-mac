import CoreGraphics
import Foundation

/// Cuenta cuánto tiempo seguido lleva el usuario usando el computador (teclado
/// o mouse). Si se aleja un rato, cuenta como pausa y vuelve a cero. Todo es
/// local: solo pregunta a macOS hace cuánto fue el último evento de entrada.
struct ContadorSentado {
    /// Cada cuánto sugerir la pausa activa.
    var limite: TimeInterval = 50 * 60
    /// Si no toca el computador este tiempo, ya hizo una pausa.
    var pausa: TimeInterval = 5 * 60
    /// Sin teclado ni mouse este tiempo, el usuario se fue: la mascota se
    /// acuesta a dormir (y el reloj baja al mínimo) hasta que vuelva.
    static let inactividadParaDormir: TimeInterval = 15 * 60

    private var activo: TimeInterval = 0

    /// Hace cuántos segundos fue el último evento de teclado o mouse.
    static func quieto() -> TimeInterval {
        CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
    }

    /// Avanza el reloj; `true` cuando toca levantarse (y vuelve a contar).
    mutating func avanzar(dt: TimeInterval) -> Bool {
        let quieto = Self.quieto()
        if quieto >= pausa {
            activo = 0
            return false
        }
        activo += dt
        guard activo >= limite else { return false }
        activo = 0
        return true
    }
}
