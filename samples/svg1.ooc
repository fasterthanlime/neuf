
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk
import math, math/Random
import structs/[ArrayList]

// ours
use neuf
import neuf/[canvas, knot, svg]

main: func (argc: Int, argv: CString*) {
    SVGTest new() run(60.0)
}

SVGTest: class extends App {
    canvas: Canvas
    shibari: Shibari

    knot1, knot2, knot3, knot4: Knot

    init: func {
        super("SVG test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)
    
        parser := SVGParser new("assets/quad01.svg")
        "width, height = %dpx, %dpx" printfln(
          parser width toPixels(),
          parser height toPixels()
        )
    }

    update: func {
    }
}


