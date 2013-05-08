
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk
import math, math/Random
import structs/[ArrayList]

main: func {
    CircleTest new() run(60.0)
}

CircleTest: class extends App {
    stuffs := ArrayList<Stuff> new()

    settingsList := ArrayList<Setting> new()
    settingIndex := 0
    setting: Setting

    label: GlText

    init: func {
        super("Circle test", 1280, 720)
        dye setClearColor(Color black())
    }

    setup: func {
        add(Stuff new(dye, 64, 10.0, 0.0))
        label = GlText new("Harabara.ttf", "0.0", 40)
        label color set!(255, 255, 255)
        label pos set!(20, 20)
        dye add(label)

        setupSettings()
        setSetting(0)

        setupEvents()
    }

    setupEvents: func {
        dye input onKeyPress(KeyCode SPACE, |kp|
            nextSetting()
        )
    }

    setupSettings: func {
        settingsList add(Setting new(3.0, 3))
        settingsList add(Setting new(2.0, 3))
        settingsList add(Setting new(1.5, 3))
        settingsList add(Setting new(1.0, 3))
        settingsList add(Setting new(0.75, 3))
        settingsList add(Setting new(0.66666, 3))
        settingsList add(Setting new(0.5, 3))
        settingsList add(Setting new(0.3, 3))
        settingsList add(Setting new(0.25, 3))
        settingsList add(Setting new(0.1, 3))
        settingsList add(Setting new(0.05, 3))
        settingsList add(Setting new(0.03, 3))
        settingsList add(Setting new(0.02, 3))
        settingsList add(Setting new(0.01, 3))
        settingsList add(Setting new(0.002, 3))
        settingsList add(Setting new(0.001, 3))
        settingsList add(Setting new(0.0005, 3))
    }

    nextSetting: func { 
        settingIndex = (settingIndex + 1) % settingsList size
        setSetting(settingIndex)
    }

    setSetting: func (i: Int) {
        setting = settingsList get(i)

        stuff := stuffs get(0)
        stuff buffer clear()
        stuff buffer division = setting division
    }

    add: func (s: Stuff) {
        stuffs add(s)
        dye add(s)
    }

    update: func {
        label value = "%.6f" format(setting division)

        for (s in stuffs) {
            for (i in 0..setting step) {
                s update()
            }
        }
    }

}

Setting: class {
    division: Float
    step: Int

    init: func (=division, =step) {
    }
}

Stuff: class extends GlSprite {
    buffer: Buffer
    angleOffset: Float

    init: func (dye: DyeContext, side, scaleFactor: Float, =angleOffset) {
        texture := Texture new(side, side, "<circle>", TextureFilter NEAREST)

        buffer = Buffer new(texture width, texture height)
        buffer update()
        texture upload(buffer data)

        super(texture)
        pos set!(dye width * 0.5, dye height * 0.5)
        scale set!(scaleFactor, scaleFactor)
    }

    update: func {
        buffer update()
        texture update(buffer data)

        angle = angleOffset + (buffer angle toDegrees() * -1.0)
    }
}

Buffer: class {

    data: UInt8*
    width, height: Int
    size: Int

    angle := 0.0
    incr := 0.0
    offset: Vec2

    radius, maxRadius, radiusVar: Float

    redIncr := 0.004
    greenIncr := 0.002
    blueIncr := 0.003

    r, g, b: Float

    division := 0.003

    init: func (=width, =height) {
        r = (Random randInt(50, 225) as Float) / 255.0
        g = (Random randInt(50, 225) as Float) / 255.0
        b = (Random randInt(50, 225) as Float) / 255.0

        size = width * height * 4
        data = gc_malloc(size)
        clear()

        offset = vec2(width * 0.5, height * 0.5)
        maxRadius = width * 0.4
        radius = 0

        radiusVar = 0.0
    }

    clear: func {
        for (i in 0..size) {
            data[i] = 0
        }
    }

    update: func {
        radius = sin(radiusVar) * maxRadius
        radiusIncr := PI * 0.01
        radiusVar += radiusIncr

        angle += (radiusIncr / division)
        if (angle > 2 * PI) {
            angle -= 2 * PI
        }
        if (angle < 0) {
            angle += 2 * PI
        }


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

