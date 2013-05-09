
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk
import math, math/Random
import structs/[ArrayList]

// ours
use neuf
import neuf/canvas

main: func (argc: Int, argv: CString*) {
    LineTest new() run(60.0)
}

LineTest: class extends App {
    canvas: Canvas

    init: func {
        super("Line test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)
    }

    update: func {
        canvas clear()

        mousePos := dye input getMousePos()
        canvas plotLine(0, 0, mousePos x, mousePos y)
    }
}

