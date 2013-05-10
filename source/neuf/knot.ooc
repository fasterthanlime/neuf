
// third-party stuff
use dye
import dye/[core, primitives, app, input, math]

// sdk stuff
import math
import structs/[ArrayList]

/**
 * A control point that you can drag around
 */
Knot: class extends GlDrawable {

    rect: GlRectangle
    hover := false
    drag := false

    side := 8.0

    init: func (pos: Vec2) {
        super()
        rect = GlRectangle new(vec2(side, side))
        this pos set!(pos)
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        rect render(dye, modelView)
    }

    update: func (mousePos: Vec2) {
        dist := mousePos dist(pos)
        hover = (dist < side)

        if (hover) {
            rect color set!(255, 255, 255)
        } else {
            rect color set!(0, 255, 0)
        }
    }

}

/**
 * A set of knots, obviously :)
 */
Shibari: class extends GlDrawable {

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

    update: func {
        mousePos := input getMousePos()
        for (k in knots) {
            k update(mousePos)
        }
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        for (k in knots) {
            k render(dye, modelView)
        }
    }

}

