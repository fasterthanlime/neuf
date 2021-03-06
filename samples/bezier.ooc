
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
    BezierTest new() run(60.0)
}

BezierTest: class extends App {
    canvas: Canvas

    init: func {
        super("Bezier test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)
    }

    update: func {
        canvas clear()

        mousePos := dye input getMousePos()

        p1 := vec2i(100, 100)
        p2 := vec2i(mousePos x, mousePos y)
        p3 := vec2i(dye width - 100, dye height - 100)

        canvas plotLine(p1 x, p1 y, p2 x, p2 y)
        canvas plotLine(p2 x, p2 y, p3 x, p3 y)
        canvas plotQuadBezierSeg(
            p1 x, p1 y, 
            p2 x, p2 y,
            p3 x, p3 y)
    }
}




