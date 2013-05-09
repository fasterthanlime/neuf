
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

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

}

