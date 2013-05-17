
// third-party
import dye/[core, math]

// sdk
import structs/[ArrayList]

// ours
import neuf/[pen, canvas, svg]

SVGPathDrawer: class {

    parser: SVGParser
    pen: Pen

    currentPos: Vec2
    lastType: DrawType
    lastControl: Vec2
    firstPoint: Vec2

    init: func (=parser, =pen)

    reset: func {
        currentPos = vec2(0, 0)
        firstPoint = vec2(0, 0)
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

            // Move

            case SVGPathElementType M =>
                point := elem points first()
                coord := absolute(point)
                move(coord)
                if (i == 0) {
                    firstPoint set!(coord)
                }

            case SVGPathElementType m =>
                point := elem points first()
                coord := relative(point)
                move(coord)
                if (i == 0) {
                    firstPoint set!(coord)
                }

            // Close path

            case SVGPathElementType Z =>
                p1 := currentPos
                p2 := firstPoint
                pen line(p1, p2)
                currentPos set!(p2)

            // Line

            case SVGPathElementType L =>
                eachLine(CoordType ABSOLUTE, elem)
            case SVGPathElementType l =>
                eachLine(CoordType RELATIVE, elem)

            // Quad bezier

            case SVGPathElementType Q =>
                eachQuadBezier(CoordType ABSOLUTE, elem)
            case SVGPathElementType q =>
                eachQuadBezier(CoordType RELATIVE, elem)
            case SVGPathElementType T =>
                eachQuadBezierSmooth(CoordType ABSOLUTE, elem)
            case SVGPathElementType t =>
                eachQuadBezierSmooth(CoordType RELATIVE, elem)

            // Cubic bezier

            case SVGPathElementType C =>
                eachCubicBezier(CoordType ABSOLUTE, elem)
            case SVGPathElementType c =>
                eachCubicBezier(CoordType RELATIVE, elem)
            case SVGPathElementType S =>
                eachCubicBezierSmooth(CoordType ABSOLUTE, elem)
            case SVGPathElementType s =>
                eachCubicBezierSmooth(CoordType RELATIVE, elem)

            // Cubic bezier

            case =>
                "Unknown element type: %s" printfln(elem type toString())
        }
    }

    eachLine: func (coord: CoordType, elem: SVGPathElement) {
        j := 0
        while (elem points size - j >= 1) {
            p1 := currentPos
            p2 := convert(elem points get(j), coord)
            pen line(p1, p2)
            currentPos set!(p2)
            j += 1
        }
    }

    eachQuadBezier: func (coord: CoordType, elem: SVGPathElement) {
        j := 0
        while (elem points size - j >= 2) {
            c  := convert(elem points get(j    ), coord)
            p2 := convert(elem points get(j + 1), coord)
            quadBezier(c, p2)
            j += 2
        }
    }

    eachQuadBezierSmooth: func (coord: CoordType, elem: SVGPathElement) {
        j := 0
        while (elem points size - j >= 1) {
            c := currentPos
            if (lastType == DrawType QUAD_BEZIER && lastControl) {
                c = currentPos add(currentPos sub(lastControl))
            }
            p2 := convert(elem points get(j), coord)
            quadBezier(c, p2)
            j += 1
        }
    }

    eachCubicBezier: func (coord: CoordType, elem: SVGPathElement) {
        j := 0
        while (elem points size - j >= 3) {
            c1 := convert(elem points get(j    ), coord)
            c2 := convert(elem points get(j + 1), coord)
            p2 := convert(elem points get(j + 2), coord)
            cubicBezier(c1, c2, p2)
            j += 3
        }
    }

    eachCubicBezierSmooth: func (coord: CoordType, elem: SVGPathElement) {
        j := 0
        while (elem points size - j >= 2) {
            c1 := currentPos
            if (lastType == DrawType CUBIC_BEZIER && lastControl) {
                c1 = currentPos add(currentPos sub(lastControl))
            }
            c2 := convert(elem points get(j    ), coord)
            p2 := convert(elem points get(j + 1), coord)
            cubicBezier(c1, c2, p2)
            j += 2
        }
    }

    move: func (v: Vec2) {
        currentPos set!(v x, v y)
        lastType = DrawType OTHER
        lastControl = null
    }

    quadBezier: func (c, p2: Vec2) {
        p1 := currentPos
        pen quadBezier(p1, c, p2)
        currentPos set!(p2 x, p2 y)
        lastType = DrawType QUAD_BEZIER
        lastControl = c
    }

    cubicBezier: func (c1, c2, p2: Vec2) {
        p1 := currentPos
        pen cubicBezier(p1, c1, c2, p2)
        currentPos set!(p2 x, p2 y)
        lastType = DrawType CUBIC_BEZIER
        lastControl = c2
    }

    convert: func (p: SVGPoint, coord: CoordType) -> Vec2 {
        match coord {
            case CoordType ABSOLUTE =>
                absolute(p)
            case =>
                relative(p)
        }
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
        parser getWidth() / parser viewBox width
    }

    getYFactor: func -> Float {
        parser getHeight() / parser viewBox height
    }

}

CoordType: enum {
    RELATIVE
    ABSOLUTE
}

DrawType: enum {
    QUAD_BEZIER
    CUBIC_BEZIER
    OTHER
}

