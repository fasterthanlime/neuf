
// third-party stuff
use dye
import dye/[core, sprite, app, math, input, text]
import dye/gritty/[texture]

// sdk stuff
import math

/**
 * A canvas you can draw on.
 */
Canvas: class extends GlDrawable {

    pixels: UInt8*
    numBytes: Int
    width, height: Int

    color := Color4 new(255, 255, 255, 255)

    texture: Texture
    sprite: GlSprite

    init: func (=width, =height) {
        numBytes = width * height * 4
        pixels = gc_malloc(numBytes)
        clear()

        texture = Texture new(width, height, "<canvas>")
        texture upload(null)

        sprite = GlSprite new(texture)
        sprite center = false
    }

    clear: func {
        for (i in 0..numBytes) {
            pixels[i] = 0
        }
    }

    put: func (x, y: Int) {
        if (x < 0 || x >= width ) return
        if (y < 0 || y >= height) return
        
        index := (x + (y * width)) * 4
        pixels[index + 0] = color r
        pixels[index + 1] = color g
        pixels[index + 2] = color b
        pixels[index + 3] = color a
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        texture update(pixels)
        sprite draw(dye, modelView)
    }

    /**
     * Non-antialiased, straight-Bresenham line plotting
     * http://members.chello.at/~easyfilter/Bresenham.pdf
     */
    plotLine: func (x0, y0, x1, y1: Int) {
        dx :=  abs(x1 - x0)
        sx := x0 < x1 ? 1 : -1

        dy := -abs(y1 - y0)
        sy := y0 < y1 ? 1 : -1

        err := dx + dy
        e2: Int /* error value e_xy */
        
        while (true) {
            put(x0, y0)
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

    /**
     * Non-antialiased circle plotting
     * http://members.chello.at/~easyfilter/Bresenham.pdf
     */
    plotCircle: func (xm, ym, r: Int) {
        x := -r
        y := 0
        err := 2 - 2 * r /* II. Quadrant */ 

        while (true) {
            put(xm - x, ym + y) /*   I. Quadrant */
            put(xm - y, ym - x) /*  II. Quadrant */
            put(xm + x, ym - y) /* III. Quadrant */
            put(xm + y, ym + x) /*  IV. Quadrant */
            r = err

            if (r <= y) {
                y += 1
                err += y * 2 + 1 /* e_xy+e_y < 0 */
            }
            if (r > x || err > y) {
                x += 1
                err += x * 2 + 1 /* e_xy+e_x > 0 or no 2nd y-step */
            }
            if (x >= 0) break
        }
    }

    plotEllipseRect: func (x0, y0, x1, y1: Long) {
        a := abs(x1 - x0) as Long
        b := abs(y1 - y0) as Long
        b1 := (b & 1) as Long /* values of diameter */

        dx: Long = (4 as Long) * ((1 as Long) - a) * b * b
        dy: Long = (4 as Long) * (b1 + (1 as Long)) * a * a /* error increment */
        err: Long = dx + dy + b1 * a * a /* error of 1.step */
        e2: Long

        if (x0 > x1) {
            /* if called with swapped points */
            x0 = x1
            x1 += a
        }
        if (y0 > y1) {
            y0 = y1 /* .. exchange them */
        }
        y0 += (b + 1) / 2
        y1 = y0 - b1   /* starting pixel */
        a *= 8 * a
        b1 = 8 * b *b

        while(true) {
            put(x1, y0) /*   I. Quadrant */
            put(x0, y0) /*  II. Quadrant */
            put(x0, y1) /* III. Quadrant */
            put(x1, y1) /*  IV. Quadrant */
            e2 = 2 * err
            if (e2 <= dy) {
                y0 += 1
                y1 -= 1
                dy += a
                err += dy
            }  /* y step */ 
            if (e2 >= dx || 2*err > dy) {
                x0 += 1
                x1 -= 1
                dx += b1
                err += dx
            } /* x step */
            if (x0 > x1) break
        }
        
        while (y0 - y1 < b) {  /* too early stop of flat ellipses a=1 */
            put(x0 - 1, y0) /* -> finish tip of ellipse */
            y0 += 1
            put(x1 + 1, y0)
            put(x0 - 1, y1)
            y1 -= 1
            put(x1 + 1, y1)
        }
    }

    plotQuadBezierSeg: func (ix1, iy1, ix2, iy2, ix3, iy3: Int) {
        x1 := ix1 as Float
        y1 := iy1 as Float

        x2 := ix2 as Float
        y2 := iy2 as Float

        x3 := ix3 as Float
        y3 := iy3 as Float

        a := 0.0
        step := 0.01

        prevX := x1
        prevY := y1

        while (a < 1.0) {
            ai := 1.0 - a

            x12 := x1 * ai + x2 * a
            y12 := y1 * ai + y2 * a

            x23 := x2 * ai + x3 * a
            y23 := y2 * ai + y3 * a

            x123 := x12 * ai + x23 * a
            y123 := y12 * ai + y23 * a

            plotLine(prevX as Int, prevY as Int, x123 as Int, y123 as Int)

            prevX = x123
            prevY = y123

            a += step
        }
    }  

}


