
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk
import math, math/Random
import structs/[ArrayList]

// ours
use neuf
import neuf/[canvas, knot, pen, svg, svg-draw]

main: func (argc: Int, argv: CString*) {
    path := "assets/quad-bezier-absolute.svg"
    if (argc > 1) {
        path = argv[1] toString()
    }

    SVGTest new(path) run(60.0)
}

SVGTest: class extends App {
    filePath: String
    canvas: Canvas
    shibari: Shibari

    knot1, knot2, knot3, knot4: Knot

    init: func (=filePath) {
        super("SVG test: %s" format(filePath), 1024, 1024)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(1024, 1024)
        dye add(canvas)
    
        parser := SVGParser new(filePath)
        "width, height = %dpx, %dpx" printfln(
          parser width toPixels(),
          parser height toPixels()
        )

        path := parser paths first()
        "<path>" println()
        for (elem in path elements) {
            "- %s" printfln(elem type toString())
            for (point in elem points) {
                "  %.2f, %.2f" printfln(point x, point y)
            }
        }
        "</path>" println()

        pen := Pen new(canvas)
        pen setYInverted(true) // SVG has its origin on the top-left
        drawer := SVGPathDrawer new(parser, pen)
        pen rectangle(vec2(0, 0), vec2(parser getWidth(), parser getHeight())) 

        drawer draw(path)
    }

    update: func {
    }
}

