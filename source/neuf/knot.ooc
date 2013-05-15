
// third-party stuff
use dye
import dye/[core, primitives, app, input, math]

// sdk stuff
import math
import structs/[ArrayList]

// ours
import neuf/[pen]

/**
 * A control point that you can drag around
 */
Knot: class {

    rect: GlRectangle
    hover := false
    drag := false

    pos := vec2(0, 0)
    color := Color white()

    RADIUS := 6.0
    THRESHOLD := 8.0

    init: func (pos: Vec2) {
        this pos set!(pos)
    }

    update: func (mousePos: Vec2) {
        dist := mousePos dist(pos)
        hover = (dist < THRESHOLD)

        if (hover) {
            color set!(180, 180, 180)
        } else {
            color set!(0, 255, 0)
        }
    }

    draw: func (pen: Pen) {
        pen setColor(color)
        pen circle(pos, RADIUS)
    }

}

/**
 * A set of knots, obviously :)
 */
Shibari: class {

    knots := ArrayList<Knot> new()
    selected: Knot = null

    // for mouse dragging
    prevPos: Vec2

    scene: Scene
    input: Input

    init: func (=scene) {
        input = scene input sub()

        input onMousePress(MouseButton LEFT, |mp|
            for (k in knots) {
                if (k hover) {
                    selected = k
                    prevPos = vec2(input getMousePos())
                }
            }
        )

        input onMouseRelease(MouseButton LEFT, |mp|
            selected = null
            prevPos = null
        )

        input onMouseMove(|mm|
            if (!selected) return

            diff := input getMousePos() sub(prevPos)
            selected pos add!(diff)
            prevPos set!(input getMousePos())
        )
    }

    add: func (x, y: Float) -> Knot {
        knot := Knot new(vec2(x, y))
        knots add(knot)
        knot
    }

    draw: func (pen: Pen) {
        for (k in knots) {
            k draw(pen)
        }
    }

    update: func {
        mousePos := input getMousePos()
        for (k in knots) {
            k update(mousePos)
        }

    }

}

