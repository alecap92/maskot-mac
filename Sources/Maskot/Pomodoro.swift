import Foundation
import Observation

/// El reloj del Pomodoro: bloques de trabajo con descansos cortos, y uno largo
/// cada 4 tomates. Solo cuenta el tiempo y avisa los cambios; qué hace la
/// mascota en cada fase lo decide `Mascota` con las rutinas de `Rutinas.swift`.
@MainActor @Observable
final class Pomodoro {
    enum Fase: Equatable {
        case trabajo, descanso, descansoLargo

        var nombre: String {
            switch self {
            case .trabajo: "Trabajo"
            case .descanso: "Descanso"
            case .descansoLargo: "Descanso largo"
            }
        }
    }

    struct Formato: Equatable {
        let nombre: String
        let trabajo: TimeInterval
        let descanso: TimeInterval
        let largo: TimeInterval

        static let todos = [
            Formato(nombre: "25 / 5 (clásico)", trabajo: 25 * 60, descanso: 5 * 60, largo: 20 * 60),
            Formato(nombre: "45 / 10", trabajo: 45 * 60, descanso: 10 * 60, largo: 20 * 60),
            Formato(nombre: "50 / 10 (trabajo profundo)", trabajo: 50 * 60, descanso: 10 * 60, largo: 20 * 60),
        ]
    }

    /// Lo que pasó en este tick y la mascota tiene que contar.
    enum Evento {
        case empieza(Fase)
        case mitad
        case faltanCinco
    }

    nonisolated static let tomatesPorCiclo = 4

    var formato = Formato.todos[0]
    private(set) var activo = false
    private(set) var fase: Fase = .trabajo
    /// Qué tomate del ciclo va (1…4).
    private(set) var tomate = 1
    private(set) var restante: TimeInterval = 0

    private var dijoMitad = false
    private var dijoCinco = false

    var duracionFase: TimeInterval {
        switch fase {
        case .trabajo: formato.trabajo
        case .descanso: formato.descanso
        case .descansoLargo: formato.largo
        }
    }

    /// "12:34"
    var reloj: String {
        let s = max(0, Int(restante.rounded(.up)))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    func iniciar() {
        activo = true
        tomate = 1
        empezar(.trabajo)
    }

    func detener() {
        activo = false
    }

    func avanzar(dt: TimeInterval) -> Evento? {
        guard activo else { return nil }
        restante -= dt

        if restante <= 0 {
            switch fase {
            case .trabajo:
                empezar(tomate >= Self.tomatesPorCiclo ? .descansoLargo : .descanso)
            case .descanso:
                tomate += 1
                empezar(.trabajo)
            case .descansoLargo:
                tomate = 1
                empezar(.trabajo)
            }
            return .empieza(fase)
        }

        // Los recordatorios de mitad y de 5 minutos son solo para el trabajo.
        guard fase == .trabajo else { return nil }
        if !dijoMitad, restante <= duracionFase / 2 {
            dijoMitad = true
            return .mitad
        }
        if !dijoCinco, restante <= 5 * 60, duracionFase > 10 * 60 {
            dijoCinco = true
            return .faltanCinco
        }
        return nil
    }

    private func empezar(_ nueva: Fase) {
        fase = nueva
        restante = duracionFase
        dijoMitad = false
        dijoCinco = false
    }
}
