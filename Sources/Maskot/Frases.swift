import Motor

/// Lo que dice. Los avisos son GENÉRICOS de muestra, con datos inventados:
/// todavía no leen ningún calendario ni fuente real.
enum Frases {
    static let saludos = [
        "¡Quiubo! 🧢",
        "¡Llegué! ¿Qué hacemos hoy?",
        "Buenas, buenas. Aquí cuidándote el escritorio.",
    ]

    static let avisos: [(String, Expresion)] = [
        ("📅 Tienes una reunión en 10 minutos", .sorprendido),
        ("📅 Reunión en 5 min… ¡peínate! 😅", .guino),
        ("💧 ¿Ya tomaste agua? Te estoy vigilando", .gafas),
        ("📦 Entró un pedido nuevo", .celebrando),
        ("💸 ¡Te llegó un pago! 🎉", .celebrando),
        ("☕ ¿Un tintico?", .feliz),
        ("📧 Tienes 3 correos sin leer", .pensando),
    ]

    static let siesta = [
        "¡Ay! ¿Me quedé dormido? 😳",
        "Yo no estaba dormido… estaba pensando 😅",
        "¿Qué pasó? ¿Me perdí de algo?",
    ]

    static let urgente = [
        "🚨 ¡AUXILIO! Tu reunión empieza YA",
        "🚨 ¡Oye! ¡Oye! ¡Es urgente!",
        "🚨 ¡Se te va a pasar! ¡Mírame!",
    ]

    static let codigo = (
        inicio: "Modo programador 🤓",
        durante: [
            "git commit -m \"arreglado\" 😎",
            "Funciona en mi máquina 🤷",
            "// TODO: dormir",
            "¿Por qué funciona? No sé. No lo toquen.",
            "404: café not found ☕",
            "Un bug menos… tres bugs más 🐛",
            "git push --force 😈",
        ],
        fin: "Ship it 🚀"
    )

    static let golosina = (
        inicio: ["¡Una paletica! 🍭", "¡Hora del helado! 🍦", "Nadie me ve… 🤫"],
        durante: ["Mmm 😋", "Slurp", "Qué rico…"],
        fin: "¡Se acabó! 😢"
    )

    static let asomarse = ["👋 ¡Hola!", "¡Ya vuelvo!", "¿Me extrañaste? 😄", "¡Buh! 👀"]

    /// Pomodoro = tomate en italiano 🍅
    enum pomodoro {
        static func trabajo(_ tomate: Int) -> String {
            let chistes = tomate > 1 ? [
                "¡Se acabó el recreo! De vuelta al tomate.",
                "Tomate nuevo, energía nueva.",
                "Recargado. A cocinar otro tomate.",
            ] : [
                "¡A enfocarse! Nada de redes, solo tú y el tomate.",
                "Modo tomate: activado.",
                "Una sola tarea. El tomate te está mirando.",
                "Silencio… el tomate se está cocinando.",
            ]
            return "🍅 Tomate \(tomate) de \(Pomodoro.tomatesPorCiclo). " + chistes.randomElement()!
        }

        static var descanso: String { [
            "☕ ¡Tomate listo! Descansa, estírate, tómate algo.",
            "☕ ¡Tomatazo terminado! Recreo.",
            "☕ Aléjate de la pantalla un ratico. Yo me tomo un tinto.",
        ].randomElement()! }

        static let descansoLargo = "🍅🍅🍅🍅 ¡4 tomates! Te ganaste un descanso largo. Yo me voy a dormir 😴"

        static let mitad = [
            "🍅 Vas por la mitad. ¡Sigue así!",
            "🍅 Medio tomate. No te distraigas 👀",
        ]

        static let faltanCinco = [
            "🍅 Últimos 5 minutos, ¡remata!",
            "🍅 5 minuticos más y es recreo.",
        ]

        static let fin = "🍅 Pomodoro detenido. ¡Buen trabajo!"
    }

    static let cafe = (
        inicio: ["☕ Un tintico…", "☕ Hora del cafecito", "☕ Sin café no hay código"],
        fin: ["Ahora sí, despierto 👀", "Recargado ⚡"]
    )

    static let pizza = (
        inicio: "¡Hoy cocino yo! 🍕",
        cortar: "Chop chop 🔪",
        horno: "¡Al horno! 🔥",
        esperando: "⏲️ Huele delicioso…",
        ding: "¡Ding! 🔔",
        comer: "¡Pizza! 🍕",
        fin: "Estoy lleno 😮‍💨"
    )

    static let avion = (
        inicio: ["Voy a hacer un avioncito ✈️", "¿Cuánto volará este? 🤔"],
        lanzar: "¡Vuela! ✈️",
        fin: ["¡Récord mundial! 🏆", "Nada mal 😎", "Aterrizaje perfecto 🛬"]
    )

    static let despertar = [
        "¡Ya voy, ya voy! 😵‍💫",
        "¡Epa! ¿Qué pasó?",
        "Ay, qué susto 😳",
    ]

    static let gym = (inicio: "Hora del gym 💪", fin: "¡Uff! Mañana no me paro 😮‍💨")
    static let leer = (inicio: "Voy a leer un ratico 📖", fin: "Qué buen libro…")
    static let cama = (inicio: "Me voy a echar una siestica 😴", fin: "¡Como nuevo! ✨")
    static let hastaQueVuelvas = "¿Te fuiste? Me acuesto hasta que vuelvas 😴"

    static let botarHoja = (encuentra: "¿Y esta hoja qué? 🤨", celebra: "¡Canasta! 🏀")
}
