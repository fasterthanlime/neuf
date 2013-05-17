
// third-party
use mxml

// sdk
import io/[File, StringReader, Reader]
import text/StringTokenizer
import structs/[ArrayList]

/**
 * Any SVG node such as, but not limited to: a group,
 * a path.
 */
SVGNode: abstract class {


}

/**
 * An SVG group, containing other svg element such as
 * paths and groups
 */
SVGGroup: class extends SVGNode {

    nodes := ArrayList<SVGNode> new()

    add: func (e: SVGNode) {
        nodes add(e)
    }

    each: func (f: Func (SVGNode)) {
        nodes each(|e| f(e))
    }

}

SVGParser: class extends SVGGroup {

    width, height: SVGMetric
    viewBox: SVGViewBox

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

        parseGroup(this, svg)

        tree delete()
    }

    parseGroup: func (parent: SVGGroup, node: XmlNode) {
        entity := node findElement(node, null)

        while (entity) {
            name := entity getElement()
            "Found entity %s" printfln(entity getElement())

            match name {
                case "g" =>
                    // a group, needs further parsing
                    group := SVGGroup new()
                    parent add(group)
                    parseGroup(group, entity)
                case "path" =>
                    // a path, needs parsing
                    path := SVGPath parse(entity)
                    parent add(path)
            }

            entity = entity findElement(node, null)
        }
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

SVGPath: class extends SVGNode {

    elements := ArrayList<SVGPathElement> new()

    init: func

    parse: static func (node: XmlNode) -> This {
        s := node getAttr("d")
        reader := StringReader new(s)
        path := This new()

        while (reader hasNext?()) {
            t := reader read()
            if (t whitespace?()) {
                continue // skiiiiiiip. skip skip skip skip
            }

            match t {
                // Move
                case 'M' =>
                    parsePathElement(path, SVGPathElementType M, reader)
                case 'm' =>
                    parsePathElement(path, SVGPathElementType m, reader)

                // Line
                case 'L' =>
                    parsePathElement(path, SVGPathElementType L, reader)
                case 'l' =>
                    parsePathElement(path, SVGPathElementType l, reader)

                // Cubic bezier
                case 'C' =>
                    parsePathElement(path, SVGPathElementType C, reader)
                case 'c' =>
                    parsePathElement(path, SVGPathElementType c, reader)
                case 'S' =>
                    parsePathElement(path, SVGPathElementType S, reader)
                case 's' =>
                    parsePathElement(path, SVGPathElementType s, reader)

                // Quadratic bezier
                case 'Q' =>
                    parsePathElement(path, SVGPathElementType Q, reader)
                case 'q' =>
                    parsePathElement(path, SVGPathElementType q, reader)
                case 'T' =>
                    parsePathElement(path, SVGPathElementType T, reader)
                case 't' =>
                    parsePathElement(path, SVGPathElementType t, reader)

                // Close path
                case 'Z' =>
                    parsePathElement(path, SVGPathElementType Z, reader)
                case 'z' =>
                    parsePathElement(path, SVGPathElementType z, reader)

                case =>
                    "Unknown symbol in SVG path: %c" printfln(t)
            }
        }

        path
    }

    parsePathElement: static func (path: SVGPath, type: SVGPathElementType,
        reader: Reader) -> SVGPathElement {

        elem := SVGPathElement new(type)
        while (true) {
            point := SVGPoint parse(reader)

            if (point) {
                elem points add(point)
            } else {
                // done parsing points!
                break
            }
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

    NUMBER_CHARS := static "0123456789."

    parse: static func (reader: Reader) -> This {
        if (!reader hasNext?()) return null

        // skip spaces
        reader skipWhile(|c| c == ' ')

        // some point pairs are separated by commas.. whatever
        reader skipWhile(|c| c == ',')

        mark := reader mark()

        xs := reader readWhile(|c| c == '-')
        xs = xs + reader readWhile(|c| NUMBER_CHARS contains?(c))
        if (xs empty?()) {
            // no point here, we've wandered too far!
            reader reset(mark)
            return null
        }

        mark = reader mark()
        comma := reader read()
        if (comma == ',') {
            // all good
        } else if (comma == '-') {
            // separated by dashes because negative numbers..
            // uncool imho, but still valid
            reader reset(mark)
        } else {
            "Unexpected symbol '%c', was expecting ','" printfln(comma)
        }

        ys := reader readWhile(|c| c == '-')
        ys = ys + reader readWhile(|c| NUMBER_CHARS contains?(c))

        This new(xs toFloat(), ys toFloat())
    }

}

SVGPathElementType: enum {
    // move
    M
    m

    // line
    L
    l

    // cubic bezier
    C
    c
    S
    s

    // quadratic bezier
    Q
    q
    T
    t

    // close path
    Z
    z

    toString: func -> String {
        match this {
            case This M => "move absolute"
            case This m => "move relative"

            case This L => "line absolute"
            case This l => "line relative"

            case This C => "cubic bezier absolute"
            case This c => "cubic bezier relative"
            case This S => "shorthand/smooth cubic bezier absolute"
            case This s => "shorthand/smooth cubic bezier relative"

            case This Q => "quadratic bezier absolute"
            case This q => "quadratic bezier relative"
            case This T => "shorthand/smooth quadratic bezier absolute"
            case This t => "shorthand/smooth quadratic bezier relative"

            case This Z => "close path"
            case This z => "close path"

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

