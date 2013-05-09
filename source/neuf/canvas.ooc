
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk stuff
import math

/**
 * A canvas you can draw on.
 */
Canvas: class extends GlDrawable {

    pixels: UInt8*
    numBytes: Int
    width, height: Int

    color := Color4 new(255, 255, 255, 255)

    texture: Texture
    sprite: GlSprite

    init: func (=width, =height) {
        numBytes = width * height * 4
        pixels = gc_malloc(numBytes)
        clear()

        texture = Texture new(width, height, "<canvas>")
        texture upload(null)

        sprite = GlSprite new(texture)
        sprite center = false
    }

    clear: func {
        for (i in 0..numBytes) {
            pixels[i] = 0
        }
    }

    put: func (x, y: Int) {
        if (x < 0 || x >= width ) return
        if (y < 0 || y >= height) return
        
        index := (x + (y * width)) * 4
        pixels[index + 0] = color r
        pixels[index + 1] = color g
        pixels[index + 2] = color b
        pixels[index + 3] = color a
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        texture update(pixels)
        sprite draw(dye, modelView)
    }

    /**
     * Non-antialiased, straight-Bresenham line plotting
     * http://members.chello.at/~easyfilter/bresenham.html
     */
    plotLine: func (x0, y0, x1, y1: Int) {
        dx :=  abs(x1 - x0)
        sx := x0 < x1 ? 1 : -1

        dy := -abs(y1 - y0)
        sy := y0 < y1 ? 1 : -1

        err := dx + dy
        e2: Int /* error value e_xy */
        
        while (true) {
            put(x0, y0);
            if (x0 == x1 && y0 == y1) {
                break
            }
            e2 = 2 * err

            if (e2 >= dy) {
               err += dy
               x0 += sx
            } /* e_xy+e_x > 0 */

            if (e2 <= dx) {
               err += dx
               y0 += sy
            } /* e_xy+e_y < 0 */
        }
    }
}


