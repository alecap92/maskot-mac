import Foundation

/// Cuenta los días distintos en que la app ha estado abierta (para la matica
/// que crece). Se guarda en las preferencias de la app, en este Mac.
enum DiasDeUso {
    private static let claveDias = "diasDeUso"
    private static let claveUltimo = "ultimoDiaDeUso"

    /// Registra hoy (si es un día nuevo) y devuelve cuántos días van.
    /// `MASKOT_DIAS` lo fuerza, para probar la matica en distintas etapas.
    static func registrar() -> Int {
        if let forzado = Int(ProcessInfo.processInfo.environment["MASKOT_DIAS"] ?? "") { return forzado }
        let hoy = ISO8601DateFormatter.string(from: .now, timeZone: .current, formatOptions: [.withFullDate])
        let d = UserDefaults.standard
        var dias = d.integer(forKey: claveDias)
        if d.string(forKey: claveUltimo) != hoy {
            dias += 1
            d.set(dias, forKey: claveDias)
            d.set(hoy, forKey: claveUltimo)
        }
        return max(dias, 1)
    }
}
