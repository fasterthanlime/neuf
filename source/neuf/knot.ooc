
// third-party stuff
use dye
import dye/[core, primitives, app, input, math]

// sdk stuff
import math

Knot: class extends GlDrawable {

    rect: GlRectangle
    hover: Bool

    side := 8

    init: func (pos: Vec2) {
        super()
        rect = GlRectangle new(vec2(side, side))
        this pos set!(pos)
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        rect render(dye, modelView)
    }

    update: func (dye: DyeContext) {
        dist := dye input getMousePos() dist(pos)
        hover = (dist < side)

        if (hover) {
            rect opacity = 0.5
        } else {
            rect opacity = 1.0
        }
    }

}
