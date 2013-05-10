
// third-party
import dye/[core, math]

// sdk
import structs/[ArrayList]

// ours
import neuf/[canvas, svg]

SVGPathDrawer: class {

    parser: SVGParser
    canvas: Canvas

    currentPos: Vec2
    lastType: DrawType
    lastControl: Vec2

    init: func (=parser, =canvas)

    reset: func {
        currentPos = vec2(0, 0)
        lastType = DrawType OTHER
    }

    draw: func (path: SVGPath) {
        reset()

        i := 0
        for (elem in path elements) {
            drawElement(i, elem)
            i += 1
        }
    }

    drawElement: func (i: Int, elem: SVGPathElement) {
        match (elem type) {
            case SVGPathElementType M =>
                point := elem points first()
                move(absolute(point))
            case SVGPathElementType m =>
                // if first move, will do an absolute move, duh
                // Inkscape is really silly in that regard
                point := elem points first()
                move(relative(point))
            case SVGPathElementType Q =>
                j := 0
                while (elem points size - j >= 2) {
                    control := absolute(elem points get(j))
                    p2      := absolute(elem points get(j + 1))
                    quadBezier(control, p2)
                    j += 2
                }
            case SVGPathElementType T =>
                j := 0
                while (elem points size - j >= 1) {
                    c := currentPos
                    if (lastType == DrawType QUAD_BEZIER && lastControl) {
                        c = currentPos add(currentPos sub(lastControl))
                    }
                    p2 := absolute(elem points get(j))
                    quadBezier(c, p2)
                    j += 1
                }
        }
    }

    move: func (v: Vec2) {
        currentPos set!(v x, v y)
        lastType = DrawType OTHER
        lastControl = null
    }

    quadBezier: func (c, p2: Vec2) {
        p1 := currentPos
        canvas plotQuadBezierSeg(
            p1 x, p1 y,
            c  x, c  y,
            p2 x, p2 y
        )
        currentPos set!(p2 x, p2 y)
        lastType = DrawType QUAD_BEZIER
        lastControl = c
    }

    absolute: func (p: SVGPoint) -> Vec2 {
        vec2(
            p x * getXFactor(),
            p y * getYFactor()
        )
    }

    relative: func (p: SVGPoint) -> Vec2 {
        vec2(
            p x * getXFactor() + currentPos x,
            p y * getYFactor() + currentPos y
        )
    }

    getXFactor: func -> Float {
        parser width toPixels() / parser viewBox width
    }

    getYFactor: func -> Float {
        parser width toPixels() / parser viewBox width
    }

}

DrawType: enum {
    QUAD_BEZIER
    CUBIC_BEZIER
    OTHER
}

