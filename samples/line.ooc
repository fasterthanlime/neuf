
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk
import math, math/Random
import structs/[ArrayList]

// ours
import common/canvas

main: func (argc: Int, argv: CString*) {
    LineTest new() run(60.0)
}

LineTest: class extends App {
    canvas: Canvas

    init: func {
        super("Line test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)
    }

    update: func {
        canvas clear()

        mousePos := dye input getMousePos()
        plotLine(canvas, 0, 0, mousePos x, mousePos y)
    }

    abs: func (a: Int) -> Int {
        if (a < 0) {
            return -a
        }

        a
    }

    plotLine: func (canvas: Canvas, x0, y0, x1, y1: Int) {
        dx :=  abs(x1-x0)
        sx := x0 < x1 ? 1 : -1

        dy := -abs(y1-y0)
        sy := y0 < y1 ? 1 : -1

        err := dx + dy
        e2: Int /* error value e_xy */
        
        while (true) {
            canvas put(x0, y0);
            if (x0 == x1 && y0 == y1) {
                break
            }
            e2 = 2 * err

            if (e2 >= dy) {
               err += dy
               x0 += sx
            } /* e_xy+e_x > 0 */

            if (e2 <= dx) {
               err += dx
               y0 += sy
            } /* e_xy+e_y < 0 */
        }
    }
}

