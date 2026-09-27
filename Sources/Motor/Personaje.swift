/// Un píxel de la grilla del cuerpo (16×16), contado desde arriba a la izquierda.
public typealias Pixel = (fila: Int, col: Int)

/// Lo que hay que definir para crear una mascota nueva. Cada personaje vive en
/// su carpeta dentro de `characters/` (ver `characters/README.md`).
///
/// Todo se dibuja con letras en una grilla de **16×16** (una letra por píxel,
/// `.` = transparente). Las letras son las de `Tinta`. El motor pone encima la
/// cara según la expresión, el accesorio de la cabeza, los brazos y las patas,
/// y deja margen alrededor para los efectos (chispas, zetas, puntos).
public protocol Personaje: Sendable {
    /// Identificador corto, sin espacios. Es el nombre de su carpeta.
    var id: String { get }
    /// Como aparece en el menú.
    var nombre: String { get }
    /// Colores propios que reemplazan los de `Tinta` (p. ej. el del cuerpo).
    var paleta: [Tinta: UInt32] { get }
    /// El cuerpo en reposo, sin cara: 16 filas de 16 letras.
    var cuerpo: [String] { get }
    /// Filas que se pintan encima del cuerpo para cada expresión (ojos,
    /// cachetes, gafas…). `nil` = usa la de `.neutro`.
    func cara(_ expresion: Expresion) -> [Int: String]?
    /// Filas del accesorio de la cabeza según cómo lo lleve. `[:]` si no usa.
    func gorra(_ gorra: Gorra) -> [Int: String]
    var brazos: Brazos { get }
    var patas: Patas { get }
    /// Dónde está la boca (la lengua al lamer, la taza al tomar café): lo que
    /// se sostiene junto a la cara arranca en la columna siguiente.
    var boca: (col: Int, fila: Int) { get }
    /// Fila donde empieza la cabeza: ahí se apoya un sombrero.
    var cabeza: Int { get }
    /// Qué tan grande se dibuja (1 = píxeles de 5 puntos). Los personajes con
    /// contorno usan 1.2: el contorno se come parte de la grilla y sin esto se
    /// ven más chicos que uno sin contorno.
    var escala: Double { get }
}

/// Cómo se mueven los brazos. Se describe solo el **derecho**; el izquierdo
/// es su espejo (columna `c` ↔ `15 − c`).
public struct Brazos: Sendable {
    /// Levantar el brazo derecho (para cargar cosas o pedir auxilio).
    public var arriba: Cambio
    /// Tecleando: el brazo sube un poco…
    public var teclearArriba: Cambio
    /// …y baja un poco.
    public var teclearAbajo: Cambio
    /// Dónde queda la mano con el brazo en alto (lo que carga va encima).
    public var mano: (col: Double, fila: Double)
    /// Dónde queda la mano con el brazo abajo (de ahí cuelga la pesa).
    public var manoAbajo: (col: Double, fila: Double)

    public init(arriba: Cambio, teclearArriba: Cambio, teclearAbajo: Cambio,
                mano: (col: Double, fila: Double), manoAbajo: (col: Double, fila: Double)) {
        self.arriba = arriba
        self.teclearArriba = teclearArriba
        self.teclearAbajo = teclearAbajo
        self.mano = mano
        self.manoAbajo = manoAbajo
    }
}

/// Píxeles que se borran y píxeles que se pintan: `pone` con el color del
/// cuerpo y `pinta` con cualquier tinta (contorno, puntas, alas…).
public struct Cambio: Sendable {
    public var quita: [Pixel]
    public var pone: [Pixel]
    public var pinta: [(fila: Int, col: Int, tinta: Tinta)]

    public init(quita: [Pixel], pone: [Pixel], pinta: [(fila: Int, col: Int, tinta: Tinta)] = []) {
        self.quita = quita
        self.pone = pone
        self.pinta = pinta
    }
}

/// Las patas: al caminar se alternan dos grupos y se borra su punta.
public struct Patas: Sendable {
    /// Fila de la punta de las patas.
    public var fila: Int
    public var paso1: [Int]
    public var paso2: [Int]

    public init(fila: Int, paso1: [Int], paso2: [Int]) {
        self.fila = fila
        self.paso1 = paso1
        self.paso2 = paso2
    }
}

public extension Personaje {
    func color(_ tinta: Tinta) -> UInt32 { paleta[tinta] ?? tinta.rgb }

    /// Por defecto, sin accesorio en la cabeza.
    func gorra(_ gorra: Gorra) -> [Int: String] { [:] }

    /// Por defecto, la boca de un cuerpo que ocupa hasta la columna 13.
    var boca: (col: Int, fila: Int) { (13, 10) }

    /// Por defecto, una cabeza que empieza en la fila 6.
    var cabeza: Int { 6 }

    var escala: Double { 1 }
}
