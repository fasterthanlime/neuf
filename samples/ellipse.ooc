
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
    EllipseTest new() run(60.0)
}

EllipseTest: class extends App {
    canvas: Canvas

    init: func {
        super("Ellipse test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)
    }

    update: func {
        canvas clear()

        mousePos := dye input getMousePos()
        canvas plotEllipseRect(dye center x, dye center y, 
            mousePos x, mousePos y)
    }
}



