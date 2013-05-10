
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
        super("SVG test", 1024, 768)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(1280, 900)
        dye add(canvas)
    
        parser := SVGParser new("assets/quad02.svg")
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

        drawPath(path)
    }

    drawPath: func (path: SVGPath) {
        currentPos := vec2(0, 0)

        i := 0
        for (elem in path elements) {
            match (elem type) {
                case SVGPathElementType m =>
                    point := elem points first()
                    currentPos set!(point x, point y)
                case SVGPathElementType M =>
                    point := elem points first()
                    currentPos set!(point x, point y)
                case SVGPathElementType Q =>
                    p1 := vec2(currentPos x, currentPos y)
                    p2 := vec2(elem points get(0) x,
                               elem points get(0) y)
                    p3 := vec2(elem points get(1) x,
                               elem points get(1) y)
                    canvas plotQuadBezierSeg(
                        p1 x, p1 y,
                        p2 x, p2 y,
                        p3 x, p3 y
                    )
                    currentPos set!(p3 x, p3 y)
                case SVGPathElementType T =>
                    p1 := vec2(currentPos x, currentPos y)
                    p2 := vec2(currentPos x, currentPos y)
                    if (i > 0) {
                        prev := path elements get(i - 1)
                        if ((!prev points empty?()) && (prev type == SVGPathElementType Q)) {
                            point := prev points get(0)
                            diffX := currentPos x - point x
                            diffY := currentPos y - point y

                            p2 set!(currentPos x + diffX, currentPos y + diffY) 
                            "got p2 %s from previous!" printfln(p2 _)
                        }
                    }
                    p3 := vec2(elem points get(0) x,
                               elem points get(0) y)
                    "p1, p2, p3 = %s, %s, %s" printfln(p1 _, p2 _, p3 _)

                    canvas plotQuadBezierSeg(
                        p1 x, p1 y,
                        p2 x, p2 y,
                        p3 x, p3 y
                    )
                    currentPos set!(p3 x, p3 y)
            }
            i += 1
        }
    }

    update: func {
    }
}


