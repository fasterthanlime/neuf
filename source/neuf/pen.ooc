
// third-party
import dye/[core, math]

// ours
import neuf/[canvas]

Pen: class {

    yInvert := false
    offset := vec2(0, 0)

    canvas: Canvas

    init: func (=canvas)

    setYInverted: func (=yInvert)

    setColor: func ~rgb (r, g, b: UInt8) {
        setColor(r, g, b, 255)
    }

    setColor: func ~rgba (r, g, b, a: UInt8) {
        canvas color set!(r, g, b, a)
    }

    setColor: func ~color3 (c: Color) {
        canvas color set!(c)
    }

    setColor: func ~color4 (c: Color4) {
        canvas color set!(c)
    }

    _x: func (x: Float) -> Float {
        offset x + x
    }

    _y: func (y: Float) -> Float {
        offset y + match yInvert {
            case true =>
                canvas height - y
            case =>
                y
        }
    }

    quadBezier: func (p1, c, p2: Vec2) {
        canvas plotQuadBezierSeg(
            _x(p1 x), _y(p1 y),
            _x(c  x), _y(c  y),
            _x(p2 x), _y(p2 y)
        )
    }

    cubicBezier: func (p1, c1, c2, p2: Vec2) {
        canvas plotCubicBezierSeg(
            _x(p1 x), _y(p1 y),
            _x(c1 x), _y(c1 y),
            _x(c2 x), _y(c2 y),
            _x(p2 x), _y(p2 y)
        )
    }

    line: func (p1, p2: Vec2) {
        canvas plotLine(
            p1 x, _y(p1 y),
            p2 x, _y(p2 y)
        )
    }

    rectangle: func (pos, size: Vec2) {
        line(
            vec2(pos x,          pos y),
            vec2(pos x + size x, pos y)
        )
        line(
            vec2(pos x + size x, pos y),
            vec2(pos x + size x, pos y + size y)
        )
        line(
            vec2(pos x + size x, pos y + size y),
            vec2(pos x,          pos y + size y)
        )
        line(
            vec2(pos x, pos y + size y),
            vec2(pos x, pos y)
        )
    }

    circle: func (pos: Vec2, radius: Float) {
        canvas plotCircle(pos x, _y(pos y), radius)
    }

}

