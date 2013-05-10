
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk
import math, math/Random
import structs/[ArrayList]

// ours
use neuf
import neuf/[canvas, knot]

main: func (argc: Int, argv: CString*) {
    BezierKnotsTest new() run(60.0)
}

BezierKnotsTest: class extends App {
    canvas: Canvas
    shibari: Shibari

    knot1, knot2, knot3: Knot

    init: func {
        super("BezierKnots test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)

        shibari = Shibari new(dye getScene())
        knot1 = shibari add(100, 100)
        knot2 = shibari add(50, 150)
        knot3 = shibari add(500, 500)
        dye add(shibari)
    }

    update: func {
        shibari update()
        canvas clear()

        p1 := knot1 pos round()
        p2 := knot2 pos round()
        p3 := knot3 pos round()

        canvas plotLine(p1 x, p1 y, p2 x, p2 y)
        canvas plotLine(p2 x, p2 y, p3 x, p3 y)
        canvas plotQuadBezierSeg(
            p1 x, p1 y, 
            p2 x, p2 y,
            p3 x, p3 y)
    }
}




