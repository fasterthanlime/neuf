
// third-party stuff
use dye
import dye/[core, sprite, app, math]
import dye/gritty/[texture]

// sdk
import math

main: func {
    CircleTest new() run(60.0)
}

CircleTest: class extends App {

    sprite: GlSprite

    buffer: Buffer
    texture: Texture

    init: func {
        super("Circle test", 1280, 720)
        dye setClearColor(Color black())
    }

    setup: func {
        texture = Texture new(64, 64, "<circle>", TextureFilter NEAREST)

        buffer = Buffer new(texture width, texture height)
        buffer update()
        texture upload(buffer data)

        sprite = GlSprite new(texture)
        sprite pos set!(dye width * 0.5, dye height * 0.5)
        sprite scale set!(8, 8)

        dye add(sprite)
    }

    update: func {
        buffer update()
        texture update(buffer data)

        sprite angle = buffer angle toDegrees() * -1.0
    }

}

Buffer: class {

    data: UInt8*
    width, height: Int

    angle := 0.0
    incr := 0.0
    offset: Vec2

    radius, maxRadius, radiusVar: Float

    baseColor := Color new(128, 128, 128)
    redIncr := 0.004
    greenIncr := 0.002
    blueIncr := 0.003

    r, g, b: Float

    init: func (=width, =height) {
        size := width * height * 4
        data = gc_malloc(size)

        for (i in 0..size) {
            data[i] = 0
        }

        offset = vec2(width * 0.5, height * 0.5)
        maxRadius = width * 0.4
        radius = 0

        radiusVar = 0.0

        r = g = b = 0.5
    }

    update: func {
        radius = sin(radiusVar) * maxRadius
        radiusVar += (PI * 0.01)

        angle += (PI * 0.005)
        point := offset add(Vec2 fromAngle(angle) mul(radius))

        thickness := 4
        max := vec2(thickness, thickness) norm()

        r += redIncr
        g += greenIncr
        b += blueIncr

        if (r > 0.95 || r < 0.3) {
            redIncr = -redIncr
        }

        if (g > 0.95 || g < 0.4) {
            greenIncr = -greenIncr
        }

        if (b > 0.95 || b < 0.2) {
            blueIncr = -blueIncr
        }

        for (x in -thickness..thickness) {
            for (y in -thickness..thickness) {
                brightness := 1.0 - (vec2(x, y) norm() / max)
                draw(point add(x, y), r * brightness, g * brightness, b * brightness, brightness)
            }
        }
    }

    draw: func (coord: Vec2, r, g, b, a: Float) {
        x := coord x as Int
        y := coord y as Int

        index := offset(x, y)

        // red, green, blue
        blend(index + 0, r, a)
        blend(index + 1, g, a)
        blend(index + 2, b, a)
        data[index + 3] = a
    }

    blend: func (index: Int, newColor, alpha: Float) {
        oldColor := (data[index] as Float) / 255.0
        result := oldColor * (1.0 - alpha) + newColor * alpha
        data[index] = result * 255.0
    }

    offset: func (x, y: Int) -> Int {
        (x + y * height) * 4
    }

}

