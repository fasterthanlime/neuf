
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

    plotQuadBezierSeg: func (x0, y0, x1, y1, x2, y2: Int) {                            
        sx := x2 - x1
        sy := y2 - y1

        xx: Long = x0 - x1
        yy: Long = y0 - y1
        
        xy: Long  /* relative values for checks */
        dx, dy, err: Double
        cur: Double = xx * sy - yy * sx /* curvature */

        "sx = %d, sy = %d, cur = %.2f" printfln(sx, sy, cur)
        "xx * sx = %d, yy * sy = %d" printfln(xx * sx, yy * sy)

        if (xx * sx <= 0 && yy * sy <= 0) {
            // all good
        } else {
            /* sign of gradient must not change */
            "Sign of gradient must not change" println()
            return
        }

        if (sx * (sx as Long) +
            sy * (sy as Long) > xx * xx + yy * yy) { /* begin with longer part */ 
            x2 = x0
            x0 = sx + x1

            y2 = y0
            y0 = sy + y1

            cur = -cur  /* swap P0 P2 */

            "sx = %d, sy = %d, cur = %.2f" printfln(sx, sy, cur)
            "xx * sx = %d, yy * sy = %d" printfln(xx * sx, yy * sy)

            "swapping P0 and P2" println()
        }  

        if (cur != 0) {                                    /* no straight line */
            "no straight line. xx = %d, yy = %d" printfln(xx, yy)

            xx += sx

            sx = x0 < x2 ? 1 : -1
            xx *= sx           /* x step direction */

            yy += sy

            sy = y0 < y2 ? 1 : -1
            yy *= sy           /* y step direction */

            xy = 2 * xx * yy

            xx *= xx
            yy *= yy          /* differences 2nd degree */

            "sx = %d, sy = %d" printfln(sx, sy)
            "xx = %d, xy = %d" printfln(xx, xy)

            if (cur * sx * sy < 0) {                           /* negated curvature? */
                "negated curvature!" println()
                xx = -xx
                yy = -yy
                xy = -xy
                cur = -cur
            }

            dx = 4.0 * sy * cur * (x1 - x0) + xx - xy      /* differences 1st degree */
            dy = 4.0 * sx * cur * (y0 - y1) + yy - xy
            xx += xx
            yy += yy
            err = dx + dy + xy                /* error 1st step */    

            while (true) {
                put(x0, y0)                        /* plot curve */
                
                if (x0 == x2 && y0 == y2) {
                    return  /* last pixel -> curve finished */
                }
                y1 = (2 * err < dx) ? 1 : 0       /* save value for test of y step */
                if (2 * err > dy) {
                    x0 += sx
                    dx -= xy
                    dy += yy
                    err += dy

                    "x0 = %.2f, dx = %.2f, dy = %.2f, err = %.2f" printfln(
                        x0, dx, dy, err)
                } /* x step */
                if (    y1    ) {
                    y0 += sy
                    dy -= xy
                    dx += xx
                    err += dx

                    "y0 = %.2f, dy = %.2f, dx = %.2f, err = %.2f" printfln(
                        y0, dy, dx, err)
                } /* y step */

                "dx = %.2f, dy = %.2f" printfln(dx, dy)

                if (dx >= dy) break
            }
        }

        plotLine(x0, y0, x2, y2)                  /* plot remaining part to end */
    }  

}


