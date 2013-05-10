
// third-party
use mxml

// sdk
import io/File
import text/StringTokenizer
import structs/[ArrayList]

SVGParser: class {

    width, height: SVGMetric

    paths := ArrayList<SVGPath> new()

    init: func (filePath: String) {
        file := File new(filePath)
        tree := XmlNode new()
        tree loadString(file read(), MXML_OPAQUE_CALLBACK)

        svg := tree findElement(tree, "svg")
        width = SVGMetric parse(svg getAttr("width"))
        height = SVGMetric parse(svg getAttr("height"))

        pathNode := tree findElement(svg, "path")
        path := SVGPath parse(pathNode getAttr("d"))
        paths add(path)

        tree delete()
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
                case (t startsWith?("M")) =>
                    // move
                    point := SVGPoint parse(t substring(1))
                    elem := SVGPathElement new(SVGPathElementType M)
                    elem points add(point)
                    path elements add(elem)
                case (t startsWith?("Q")) =>
                    // quadratic bezier absolute
                    point := SVGPoint parse(t substring(1))
                    elem := SVGPathElement new(SVGPathElementType Q)
                    elem points add(point)
                    path elements add(elem)
                case (t startsWith?("T")) =>
                    // quadratic bezier shorthand/smooth absolute
                    point := SVGPoint parse(t substring(1))
                    elem := SVGPathElement new(SVGPathElementType T)
                    elem points add(point)
                    path elements add(elem)
                case =>
                    // additional point
                    path elements last() points add(SVGPoint parse(t))
            }
        }

        path
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
    M /* move */
    Q /* quadratic bezier absolute */
    q /* quadratic bezier relative */
    T /* shorthand/smooth quadratic bezier absolute */
    t /* shorthand/smooth quadratic bezier relative */

    toString: func -> String {
        match this {
            case This M => "move"
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

    init: func (=value, =unit) {
    }

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

