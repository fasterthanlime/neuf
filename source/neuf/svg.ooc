
// third-party
use mxml

// sdk
import io/File
import text/StringTokenizer
import structs/[ArrayList]

SVGParser: class {

    width, height: SVGMetric
    viewBox: SVGViewBox

    paths := ArrayList<SVGPath> new()

    init: func (filePath: String) {
        file := File new(filePath)
        tree := XmlNode new()
        tree loadString(file read(), MXML_OPAQUE_CALLBACK)

        svg := tree findElement(tree, "svg")

        viewBox = SVGViewBox parse(svg getAttr("viewBox"))

        if (svg getAttr("width")) {
            // has width/height specified in SVG
            width = SVGMetric parse(svg getAttr("width"))
            height = SVGMetric parse(svg getAttr("height"))
        } else {
            // take dimensions from viewBox
            width = SVGMetric new(viewBox width, SVGUnit PX)
            height = SVGMetric new(viewBox height, SVGUnit PX)
        }

        pathNode := tree findElement(svg, "path")
        path := SVGPath parse(pathNode getAttr("d"))
        paths add(path)

        tree delete()
    }

    getWidth: func -> Float {
        width toPixels()
    }

    getHeight: func -> Float {
        height toPixels()
    }

}

SVGViewBox: class {

    xMin, yMin, width, height: Float

    init: func (=xMin, =yMin, =width, =height)

    parse: static func (s: String) -> This {
        tokens := s split(' ')
        xMin   := tokens get(0) toFloat()
        yMin   := tokens get(1) toFloat()
        width  := tokens get(2) toFloat()
        height := tokens get(3) toFloat()

        This new(xMin, yMin, width, height)
    }

    toString: func -> String {
        "min = (%.2f, %.2f), size = (%.2f, %.2f)" format(
            xMin, yMin, width, height)
    }

}

SVGPath: class {

    elements := ArrayList<SVGPathElement> new()

    init: func

    parse: static func (s: String) -> This {
        path := This new()

        tokens := s split(' ')

        while (!tokens empty?()) {
            t := tokens removeAt(0)

            match {
                // Move
                case (t startsWith?("M")) =>
                    parsePathElement(path, SVGPathElementType M, t)
                case (t startsWith?("m")) =>
                    parsePathElement(path, SVGPathElementType m, t)

                // Cubic bezier
                case (t startsWith?("C")) =>
                    parsePathElement(path, SVGPathElementType C, t)
                case (t startsWith?("c")) =>
                    parsePathElement(path, SVGPathElementType c, t)
                case (t startsWith?("S")) =>
                    parsePathElement(path, SVGPathElementType S, t)
                case (t startsWith?("s")) =>
                    parsePathElement(path, SVGPathElementType s, t)

                // Quadratic bezier
                case (t startsWith?("Q")) =>
                    parsePathElement(path, SVGPathElementType Q, t)
                case (t startsWith?("q")) =>
                    parsePathElement(path, SVGPathElementType q, t)
                case (t startsWith?("T")) =>
                    parsePathElement(path, SVGPathElementType T, t)
                case (t startsWith?("t")) =>
                    parsePathElement(path, SVGPathElementType t, t)
                case =>
                    // additional point
                    path elements last() points add(SVGPoint parse(t))
            }
        }

        path
    }

    parsePathElement: static func (path: SVGPath, type: SVGPathElementType,
        token: String) -> SVGPathElement {

        elem := SVGPathElement new(type)
        rest := token substring(1) trim()
        if (!rest empty?()) {
            point := SVGPoint parse(rest)
            elem points add(point)
        }
        path elements add(elem)
    }

}

SVGPathElement: class {

    type: SVGPathElementType
    points := ArrayList<SVGPoint> new()

    init: func (=type)

}

SVGPoint: class {

    x, y: Float

    init: func (=x, =y)

    parse: static func (s: String) -> This {
        tokens := s split(',') 

        This new(
            tokens get(0) toFloat(),
            tokens get(1) toFloat() 
        )
    }

}

SVGPathElementType: enum {
    m /* move relative */
    M /* move absolute */
    C /* cubic bezier absolute */
    c /* cubic bezier relative */
    S /* shorthand/smooth cubic bezier absolute */
    s /* shorthand/smooth cubic bezier relative */
    Q /* quadratic bezier absolute */
    q /* quadratic bezier relative */
    T /* shorthand/smooth quadratic bezier absolute */
    t /* shorthand/smooth quadratic bezier relative */

    toString: func -> String {
        match this {
            case This m => "move relative"
            case This M => "move absolute"
            case This C => "cubic bezier absolute"
            case This c => "cubic bezier relative"
            case This S => "shorthand/smooth cubic bezier absolute"
            case This s => "shorthand/smooth cubic bezier relative"
            case This Q => "quadratic bezier absolute"
            case This q => "quadratic bezier relative"
            case This T => "shorthand/smooth quadratic bezier absolute"
            case This t => "shorthand/smooth quadratic bezier relative"
            case => "<unknown>"
        }
    }
}

SVGMetric: class {

    unit: SVGUnit
    value: Float

    init: func (=value, =unit)

    parse: static func (s: String) -> This {
        unit := SVGUnit PX
        rest := s

        match {
            case s endsWith?("cm") =>
                rest = s substring(0, -2) 
                unit = SVGUnit CM
            case s endsWith?("mm") =>
                rest = s substring(0, -2) 
                unit = SVGUnit MM
            case s endsWith?("pc") =>
                rest = s substring(0, -2) 
                unit = SVGUnit PC
            case s endsWith?("pt") =>
                rest = s substring(0, -2) 
                unit = SVGUnit PT
            case s endsWith?("in") =>
                rest = s substring(0, -2) 
                unit = SVGUnit IN
            case s endsWith?("px") =>
                rest = s substring(0, -2) 
        }
        value := rest toFloat()

        This new(value, unit)
    }

    toPixels: func -> Int {
        ratio := match unit {
            case SVGUnit MM =>
                MM_RATIO
            case SVGUnit CM =>
                CM_RATIO
            case SVGUnit PC =>
                PC_RATIO
            case SVGUnit PT =>
                PT_RATIO
            case SVGUnit IN =>
                return value * DPI
                1.0
            case =>
                // pixels, no conversion needed
                return value
                1.0
        }

        (value as Float) / ratio * (DPI as Float)
    }

    /*
     * Unit definitions below
     */
    DPI := static 90
    CM_RATIO := static 2.54
    MM_RATIO := static 25.4
    PC_RATIO := static 6.0
    PT_RATIO := static 72.0
    IN_RATIO := static 1.0
}

SVGUnit: enum {
    PX /* pixels */
    CM /* centimeters */
    MM /* millimeters */
    PC /* picas */
    PT /* points */
    IN /* inches */
}

