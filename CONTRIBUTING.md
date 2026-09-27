# Contribuir a Maskot

¡Gracias por querer sumar! Maskot es un proyecto pequeño y juguetón; las
contribuciones más valiosas suelen ser **personajes nuevos** y **rutinas nuevas**.

## Antes de empezar

- Necesitas macOS 14+ y Swift 6 (Xcode o las Command Line Tools).
- Lee [`CLAUDE.md`](CLAUDE.md): tiene el mapa del código y los principios del proyecto.
- El código y los comentarios están en **español**. Mantén ese idioma y el estilo del
  archivo que tocas.

## Principios (no negociables)

1. **No estorbar.** La mascota nunca debe interrumpir sin algo útil que decir. Las
   rutinas largas van a las esquinas; las gracias son la excepción.
2. **Todo local.** Nada sale de la máquina: sin telemetría, sin red, sin permisos extra.
3. **Pixel art en código.** Los personajes y la utilería se dibujan con letras en una
   grilla; nada de imágenes generadas en tiempo de ejecución.
4. **Nada personal.** No subas nombres, rutas, cuentas ni datos de nadie.

## Agregar un personaje

Sigue [`characters/README.md`](characters/README.md). En resumen: una carpeta
`characters/<id>/` con tu `struct` que cumple `Personaje`, su entrada en
`characters/Catalogo.swift` y la hoja de poses generada con `swift run Hoja <id>`.
Si es de la familia Koru, respeta [`characters/FAMILIA.md`](characters/FAMILIA.md).

Solo aceptamos personajes **originales** o con licencia que permita su uso. No
envíes mascotas o marcas de terceros.

## Agregar una rutina

1. Ubica el grupo que le toca (`Sources/Maskot/Rutinas+<Grupo>.swift`) o crea uno.
2. Arma la rutina con las acciones de `Accion` (en `Mascota.swift`); casi siempre
   alcanzan las piezas genéricas (`.decorado`, `.objeto`, `.volar`, `.herramienta`…).
3. Si necesitas un objeto nuevo, dibújalo en `Sources/Motor/Utileria<Grupo>.swift`.
4. Revísala **sin capturas de pantalla**, con la simulación:

   ```bash
   MASKOT_FOTOS="Tu rutina" swift run Maskot                  # docs/fotos/Tu rutina.png
   MASKOT_FOTOS="Tu rutina" MASKOT_PERSONAJE=brio swift run Maskot
   ```

   Pruébala al menos con Clawd y con un personaje de la familia (son más grandes).

## Pull requests

- Un PR por idea (un personaje, una rutina, un arreglo).
- `swift build` debe compilar sin errores ni warnings nuevos.
- Incluye en la descripción una imagen de la hoja o de la simulación.
- Al enviar código aceptas publicarlo bajo la licencia MIT del proyecto.
