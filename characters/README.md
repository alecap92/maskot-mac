# Personajes

Cada mascota vive en su carpeta: `characters/<id>/`. Adentro va su código
(`<Nombre>.swift`) y su hoja de poses (`hoja.png`).

```
characters/
  Catalogo.swift        la lista de personajes que ve el menú
  FAMILIA.md            la biblia de la familia Koru (estilo, paleta, personalidades)
  clawd/
    Clawd.swift         el personaje
    hoja.png            todas sus poses (se genera con `swift run Hoja clawd`)
```

## Crear un personaje

1. Crea `characters/<id>/<Nombre>.swift` con un `struct` que cumpla `Personaje`
   (el contrato está en `Sources/Motor/Personaje.swift`; `clawd/Clawd.swift` es el ejemplo).
2. Dibújalo con letras en una grilla de **16×16**: una letra por píxel, `.` transparente.
   Las letras son los colores de `Sources/Motor/Tinta.swift` (`c` cuerpo, `o` ojo,
   `r` cachete, `g` gorra…). Con `paleta` cambias el color de cualquier letra para tu
   personaje (p. ej. `[.cuerpo: 0xF26A2E]`).
3. Define:
   - `cuerpo`: la silueta en reposo, sin cara.
   - `cara(_:)`: las filas que se pintan encima para cada `Expresion` (ojos, cachetes,
     gafas…). Las que devuelvas `nil` usan la de `.neutro`.
   - `gorra(_:)`: el accesorio de la cabeza, o `[:]` si no usa.
   - `brazos`: qué píxeles cambian al levantar el brazo derecho y al teclear (el
     izquierdo es el espejo), y dónde queda la mano.
   - `patas`: la fila de la punta de las patas y qué columnas se levantan al caminar.
   - `escala` (opcional): si tu personaje lleva contorno, usa `1.2` para que no se vea
     más chico que uno sin contorno (el contorno se come parte de la grilla).
   - `boca` (opcional): dónde van la lengua o la taza al comer y tomar; por defecto (13, 10).
   En los `Cambio` de los brazos, `pone` pinta con el color del cuerpo y `pinta` con
   cualquier tinta, para que el brazo levantado lleve su contorno y sus colores.
4. Súmalo a la lista de `Catalogo.swift` y su id a `personajes` en `Package.swift`
   (para que su `hoja.png` no se compile).
5. Revisa cómo quedó: `swift run Hoja <id>` genera `characters/<id>/hoja.png`, y
   `MASKOT_FOTOS="Gym" MASKOT_PERSONAJE=<id> swift run Maskot` simula una rutina.

Aparece solo en el menú de la barra → **Personaje**.

## Convenciones

- Las filas bajas del cuerpo son las patas, y las de arriba (0–5) quedan libres para el
  accesorio de la cabeza: así los muebles (banca, cama) y los objetos (libro, laptop,
  pesa) caen en su sitio.
- Para personajes de la familia Koru, sigue `FAMILIA.md`: mismos ojos, contorno azul
  marino y paleta de cada uno.
