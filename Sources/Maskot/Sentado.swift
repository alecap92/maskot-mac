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

    private var activo: TimeInterval = 0

    /// Avanza el reloj; `true` cuando toca levantarse (y vuelve a contar).
    mutating func avanzar(dt: TimeInterval) -> Bool {
        let quieto = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
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
