# CLAUDE.md — Maskot 🧢

Mascota de escritorio para macOS en pixel art. Vive en una franja transparente en la
parte de abajo de la pantalla, hace rutinas durante el día y avisa cosas con globos de
texto. Proyecto open source: **no metas datos personales** (nombres, rutas, cuentas) en
el código ni en los docs.

## Correr

```bash
swift build
swift run Maskot                                          # dev
./scripts/app.sh                                          # build/Maskot.app (release)
swift run Hoja [id]                                       # characters/<id>/hoja.png + docs/utileria.png
MASKOT_FOTOS="<rutina>" [MASKOT_PERSONAJE=<id>] swift run Maskot   # docs/fotos/<rutina>.png
MASKOT_DEMO="<rutina>" swift run Maskot                   # arranca con esa rutina
```

Para revisar cómo se ve algo usa `Hoja` o `MASKOT_FOTOS`: simulan sin abrir ventanas.
**No tomes capturas de pantalla** para revisar: salen las ventanas privadas del usuario.

## Mapa del código

```
Sources/
  Motor/                el motor de dibujo, sin UI
    Personaje.swift     el contrato de una mascota (cuerpo, caras, gorra, brazos, patas)
    Sprite.swift        arma el cuadro de cualquier personaje: grilla 16×16 en un lienzo 20×18
    Expresion.swift     expresiones (con su efecto: chispas, zetas, puntos) y la gorra
    Tinta.swift         los colores; cada uno tiene una letra para dibujar como texto
    Utileria.swift      hoja, bola, caneca, pesa, banca, cama, cobija, libro, laptop, golosinas
  Maskot/
    App.swift           entrada, franja flotante, menú de la barra, clic, selector de personaje
    Mascota.swift       el motor de comportamiento: estado visible + cola de `Accion`es a 20 fps
    Rutinas.swift       ⭐ la biblioteca: rutinas básicas + la unión de los grupos
    Rutinas+Juegos.swift   magia y deportes (fútbol, basket, vóley, tenis)
    Rutinas+Calma.swift    la matica permanente (crece con los días de uso) y la respiración
    Rutinas+Hobbies.swift  guitarra, pescar, yoyo, selfie, periódico
    Rutinas+Aventura.swift excursión, binoculares, fotos, fogata
    Rutinas+Movimiento.swift bailar y el estiramiento guiado (lo lanza también la pausa activa)
    DiasDeUso.swift     días distintos en que se abrió la app (la matica)
    Frases.swift        textos de los globos
    Sentado.swift       cuánto lleva el usuario sin pausa (pausa activa) y sin tocar nada (se duerme)
    API.swift           API local HTTP (Network.framework) + Bonjour `_maskot._tcp` + token
    Pomodoro.swift      el reloj del Pomodoro (fases, tomates, avisos de mitad y 5 min)
    Escena.swift        la vista: mueble → personaje → cobija/libro/laptop/cosa → globo
    Fotos.swift         simulación sin ventanas (MASKOT_FOTOS)
  Hoja/main.swift       exporta hojas de poses
characters/             un personaje por carpeta (ver characters/README.md)
  Catalogo.swift        la lista que ve el menú
  FAMILIA.md            biblia de la familia Koru (estilo, paleta, personalidades)
  clawd/Clawd.swift     el primer personaje
```

- **Rutina nueva** → una entrada en `Rutinas.swift` o en su grupo `Rutinas+<Grupo>.swift`
  (nombre, peso, lugar, lista de acciones). Aparece sola en el menú → Rutinas.
- **Piezas genéricas** de `Accion` para armar rutinas sin tocar el motor: `.decorado` (detrás)
  y `.delante` (delante del personaje), `.enFrente` (sostenido al frente), `.accesorio`
  (cabeza), `.espalda`, `.herramienta` (mano), `.magia`, y el objeto suelto: `.objeto`,
  `.volar`, `.caer`, `.rebotar`, `.toque`, `.levitar`, `.conducir`. Los decorados se
  apilan en orden alfabético del nombre.
- **Objeto nuevo** → `Utileria.swift`. **Movimiento nuevo** → un caso en `Accion` (`Mascota.swift`).
- **Personaje nuevo** → carpeta en `characters/` + entrada en `Catalogo.swift`.

## Principios

1. **No estorbar (la lección de Clippy).** Solo habla por iniciativa propia cuando tiene
   algo útil. Los pesos de las rutinas se piensan por **tiempo**: las largas (leer,
   programar, dormir: 10–60 min) salen poco pero ocupan casi todo el día.
2. **Local.** Nada sale de la máquina. La API local solo recibe (nunca llama a nadie),
   está apagada por defecto y en modo red exige token. La pausa activa solo consulta a macOS hace cuánto
   fue el último evento de teclado/mouse.
3. **Pixel art en código.** Todo se dibuja con letras; nada de imágenes generadas en el
   runtime. Cambiar una expresión es cambiar unos píxeles.

## Detalles técnicos

- La franja es un `NSPanel` borderless, transparente, `.floating`, en todos los
  escritorios, a todo el ancho de la **pantalla principal** (`NSScreen.screens.first`).
  Se reacomoda con `didChangeScreenParametersNotification`.
- `ignoresMouseEvents` se prende y apaga en cada tick según si el mouse está sobre la
  mascota: el resto de la franja deja pasar los clics.
- El reloj (`Delegado.ajustarRitmo`) va a 20 ticks/s despierta, 5 dormida y se detiene
  con la pantalla apagada (5 si el Pomodoro está activo). Tiene tolerancia para que
  macOS agrupe los despertares. Los efectos (`destello`) van por tiempo de `reloj`, no
  por conteo de ticks, así se ven igual a cualquier ritmo.
- A los 15 min sin teclado ni mouse (`ContadorSentado.inactividadParaDormir`) sale la
  rutina "Dormir hasta que vuelvas": se acuesta y `.dormirse` la deja `dormido` con
  `dormidoHastaQueVuelva`; el primer evento de entrada la despierta. `dormido` ya no
  resetea la escena por sí solo: el menú usa `alternarSueno()`.
- Cada `Rutina` tiene un `lugar`: `.aqui`, `.cerca` (camina unos pasos) o `.esquina`
  (lo largo —leer, dormir, programar, Pomodoro— se va a un rincón para no estorbar en el centro).
- Con el Pomodoro activo, el reloj manda: no hay rutinas al azar, avisos ni pausa activa;
  si algo interrumpe (un clic), la mascota vuelve a la rutina de la fase.
- Una rutina interrumpida (clic, pausa activa) resetea todo en `Mascota.hacer(_:)`:
  postura, muebles, objetos, gorra.
- Swift 6 con concurrencia estricta: `Rutina` y `Accion` son `Sendable`; la UI es `@MainActor`.

## Pendientes

- [ ] Motor: `.enFrente` con altura ajustable (hoy tapa ojos bajos), herramientas que se
  voltean solas, `.cambiarObjeto` sin reiniciar su posición, una línea (hilo del yoyo,
  sedal), animación de patada/swing, más de un objeto suelto a la vez.
- [ ] Vehículos: que pase en avión, en bicicleta…
- [ ] Moverse por toda la pantalla (hoy solo la franja de abajo) y por varios monitores.
- [ ] Un aviso que llega mientras lee o duerme corta la rutina de golpe; mejor levantarse con calma.
- [ ] Avisos reales (calendario, recordatorios) en vez de los genéricos de muestra.
- [ ] Configuración: tiempo de la pausa activa, tamaño, frecuencia de avisos.
