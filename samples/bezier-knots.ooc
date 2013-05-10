
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

    knots := ArrayList<Knot> new()

    init: func {
        super("BezierKnots test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)

        addKnot(100, 100)
        addKnot(50, 150)
        addKnot(500, 500)
    }

    addKnot: func (x, y: Float) {
        knot := Knot new(vec2(x, y))
        knots add(knot)
        dye add(knot)
    }

    update: func {
        for (k in knots) {
            k update(dye)
        }

        canvas clear()

        p1 := knots get(0) pos
        p2 := knots get(1) pos
        p3 := knots get(2) pos

        canvas plotLine(p1 x, p1 y, p2 x, p2 y)
        canvas plotLine(p2 x, p2 y, p3 x, p3 y)
        canvas plotQuadBezierSeg(
            p1 x, p1 y, 
            p2 x, p2 y,
            p3 x, p3 y)
    }
}




