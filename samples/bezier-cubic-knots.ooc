
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk
import math, math/Random
import structs/[ArrayList]

// ours
use neuf
import neuf/[canvas, knot, pen]

main: func (argc: Int, argv: CString*) {
    BezierKnotsTest new() run(60.0)
}

BezierKnotsTest: class extends App {
    canvas: Canvas
    shibari: Shibari
    pen: Pen

    knot1, knot2, knot3, knot4: Knot

    init: func {
        super("BezierKnots test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)

        pen = Pen new(canvas)

        shibari = Shibari new(dye getScene())
        knot1 = shibari add(100, 100)
        knot2 = shibari add(50, 150)
        knot3 = shibari add(100, 250)
        knot4 = shibari add(500, 500)
    }

    update: func {
        canvas clear()
        shibari update()

        p1 := knot1 pos
        p2 := knot2 pos
        p3 := knot3 pos
        p4 := knot4 pos

        pen setColor(180, 20, 20)

        pen line(p1, p2)
        pen line(p2, p3)
        pen line(p3, p4)
        pen line(p4, p1)

        pen setColor(180, 100, 100)

        pen line(p1, p3)
        pen line(p2, p4)

        pen setColor(255, 255, 255)

        pen cubicBezier(p1, p2, p3, p4)

        shibari draw(pen)
    }
}





