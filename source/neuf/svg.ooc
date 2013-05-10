
use mxml
import io/File

SVGParser: class {

    width, height: SVGMetric

    init: func (path: String) {
        file := File new(path)
        tree := XmlNode new()
        tree loadString(file read(), MXML_OPAQUE_CALLBACK)

        svg := tree findElement(tree, "svg")
        width = SVGMetric parse(svg getAttr("width"))
        height = SVGMetric parse(svg getAttr("height"))

        tree delete()
    }

}

SVGMetric: class {

    unit: SVGUnit
    value: Int

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
        value := rest toInt()

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

