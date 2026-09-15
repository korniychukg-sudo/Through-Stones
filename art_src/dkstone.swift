import Foundation
import CoreGraphics

struct StoneChord {
    var shadow: Hue
    var body: Hue
    var light: Hue
    var speck: Hue
    var speckLight: Hue
    var density: Double
    var bedSpacing: Double
    var bedContrast: Double
    var roughness: Double
}

func chordOf(_ kind: StoneKind) -> StoneChord {
    switch kind {
    case .gritstone:
        return StoneChord(shadow: Hue(r: 0.30, g: 0.25, b: 0.20), body: Hue(r: 0.52, g: 0.44, b: 0.35), light: Hue(r: 0.70, g: 0.62, b: 0.50),
                          speck: Hue(r: 0.18, g: 0.14, b: 0.10), speckLight: Hue(r: 0.82, g: 0.74, b: 0.60), density: 0.045, bedSpacing: 17, bedContrast: 0.32, roughness: 1.0)
    case .limestone:
        return StoneChord(shadow: Hue(r: 0.46, g: 0.46, b: 0.42), body: Hue(r: 0.70, g: 0.69, b: 0.64), light: Hue(r: 0.86, g: 0.85, b: 0.80),
                          speck: Hue(r: 0.30, g: 0.30, b: 0.27), speckLight: Hue(r: 0.95, g: 0.95, b: 0.92), density: 0.02, bedSpacing: 24, bedContrast: 0.18, roughness: 0.7)
    case .oolite:
        return StoneChord(shadow: Hue(r: 0.55, g: 0.45, b: 0.28), body: Hue(r: 0.79, g: 0.68, b: 0.47), light: Hue(r: 0.92, g: 0.84, b: 0.64),
                          speck: Hue(r: 0.45, g: 0.36, b: 0.20), speckLight: Hue(r: 0.97, g: 0.92, b: 0.76), density: 0.06, bedSpacing: 8, bedContrast: 0.22, roughness: 0.8)
    case .sandstone:
        return StoneChord(shadow: Hue(r: 0.40, g: 0.30, b: 0.21), body: Hue(r: 0.65, g: 0.51, b: 0.37), light: Hue(r: 0.82, g: 0.70, b: 0.54),
                          speck: Hue(r: 0.35, g: 0.20, b: 0.10), speckLight: Hue(r: 0.90, g: 0.80, b: 0.64), density: 0.05, bedSpacing: 10, bedContrast: 0.34, roughness: 0.9)
    case .slate:
        return StoneChord(shadow: Hue(r: 0.20, g: 0.23, b: 0.28), body: Hue(r: 0.37, g: 0.41, b: 0.46), light: Hue(r: 0.55, g: 0.59, b: 0.64),
                          speck: Hue(r: 0.12, g: 0.14, b: 0.18), speckLight: Hue(r: 0.66, g: 0.70, b: 0.76), density: 0.012, bedSpacing: 5, bedContrast: 0.26, roughness: 0.4)
    case .granite:
        return StoneChord(shadow: Hue(r: 0.40, g: 0.36, b: 0.34), body: Hue(r: 0.62, g: 0.58, b: 0.55), light: Hue(r: 0.80, g: 0.76, b: 0.72),
                          speck: Hue(r: 0.10, g: 0.10, b: 0.10), speckLight: Hue(r: 0.90, g: 0.72, b: 0.66), density: 0.10, bedSpacing: 0, bedContrast: 0, roughness: 1.1)
    case .whinstone:
        return StoneChord(shadow: Hue(r: 0.20, g: 0.19, b: 0.17), body: Hue(r: 0.36, g: 0.34, b: 0.31), light: Hue(r: 0.52, g: 0.48, b: 0.44),
                          speck: Hue(r: 0.55, g: 0.35, b: 0.20), speckLight: Hue(r: 0.66, g: 0.62, b: 0.58), density: 0.035, bedSpacing: 0, bedContrast: 0, roughness: 1.2)
    case .greywacke:
        return StoneChord(shadow: Hue(r: 0.30, g: 0.29, b: 0.26), body: Hue(r: 0.48, g: 0.46, b: 0.42), light: Hue(r: 0.66, g: 0.63, b: 0.57),
                          speck: Hue(r: 0.20, g: 0.18, b: 0.15), speckLight: Hue(r: 0.78, g: 0.74, b: 0.68), density: 0.04, bedSpacing: 30, bedContrast: 0.12, roughness: 1.1)
    case .schist:
        return StoneChord(shadow: Hue(r: 0.32, g: 0.33, b: 0.36), body: Hue(r: 0.54, g: 0.55, b: 0.57), light: Hue(r: 0.74, g: 0.75, b: 0.78),
                          speck: Hue(r: 0.20, g: 0.21, b: 0.24), speckLight: Hue(r: 0.98, g: 0.98, b: 1.0), density: 0.07, bedSpacing: 6, bedContrast: 0.24, roughness: 0.6)
    case .fieldstone:
        return StoneChord(shadow: Hue(r: 0.36, g: 0.34, b: 0.31), body: Hue(r: 0.58, g: 0.55, b: 0.50), light: Hue(r: 0.76, g: 0.73, b: 0.67),
                          speck: Hue(r: 0.22, g: 0.20, b: 0.18), speckLight: Hue(r: 0.88, g: 0.84, b: 0.78), density: 0.05, bedSpacing: 0, bedContrast: 0, roughness: 0.8)
    case .flagstone:
        return StoneChord(shadow: Hue(r: 0.24, g: 0.26, b: 0.26), body: Hue(r: 0.42, g: 0.44, b: 0.44), light: Hue(r: 0.60, g: 0.62, b: 0.61),
                          speck: Hue(r: 0.15, g: 0.16, b: 0.16), speckLight: Hue(r: 0.70, g: 0.72, b: 0.70), density: 0.02, bedSpacing: 4, bedContrast: 0.28, roughness: 0.5)
    case .clunch:
        return StoneChord(shadow: Hue(r: 0.66, g: 0.65, b: 0.58), body: Hue(r: 0.86, g: 0.85, b: 0.78), light: Hue(r: 0.96, g: 0.95, b: 0.90),
                          speck: Hue(r: 0.55, g: 0.53, b: 0.46), speckLight: Hue(r: 1.0, g: 1.0, b: 0.98), density: 0.018, bedSpacing: 20, bedContrast: 0.10, roughness: 0.5)
    }
}

let stoneLight = -2.36

func paintStone(_ p: Leaf, poly: [CGPoint], kind: StoneKind, seed: UInt64, age: Double = 0, bed: Double = 0, wet: Double = 0, ink: Bool = true, hatch: Bool = true) {
    guard poly.count > 2 else { return }
    var rng = Chip(seed)
    let ch = chordOf(kind)
    let path = pathOf(poly)
    let box = path.boundingBox
    let size = Double(max(box.width, box.height))
    let scale = max(0.35, min(2.2, size / 160))
    let c = centreOf(poly)
    let cx = Double(c.x), cy = Double(c.y)
    let lx = cos(stoneLight), ly = sin(stoneLight)
    var body = ch.body
    if kind == .gritstone { body = body.dk(age * 0.35) }
    if kind == .limestone || kind == .clunch { body = body.lt(age * 0.18) }
    if kind == .sandstone { body = body.warm(age * 0.15).dk(age * 0.12) }
    if kind == .greywacke { body = body.warm(age * 0.25) }
    body = body.dk(wet * 0.3)
    p.shape(poly, body)
    p.radial(pt(cx + lx * size * 0.55, cy + ly * size * 0.55), size * 1.1, ch.light.dk(age * 0.15).dk(wet * 0.25), ch.shadow.dk(wet * 0.2), clip: path)
    p.inside(path) {
        let n = Int(Double(box.width * box.height) * ch.density * 0.9)
        for _ in 0..<min(9000, n) {
            let x = Double(box.minX) + rng.d() * Double(box.width)
            let y = Double(box.minY) + rng.d() * Double(box.height)
            let light = rng.chance(kind == .schist ? 0.6 : 0.42)
            let r = rng.r(0.6, 1.5) * scale * (kind == .granite ? 1.4 : 1.0) * (kind == .schist ? 0.6 : 1.0)
            p.dot(x, y, r, (light ? ch.speckLight : ch.speck).al(rng.r(0.25, 0.7)))
        }
        if ch.bedSpacing > 0 {
            let sp = ch.bedSpacing * scale
            let dx = cos(bed), dy = sin(bed)
            let nx = -dy, ny = dx
            let span = size * 1.4
            var u = -span / 2 + rng.r(0, sp)
            var k = 0
            while u < span / 2 {
                let ax = cx + nx * u - dx * span / 2, ay = cy + ny * u - dy * span / 2
                let bx = cx + nx * u + dx * span / 2, by = cy + ny * u + dy * span / 2
                var line: [CGPoint] = []
                let steps = 12
                for s in 0...steps {
                    let t = Double(s) / Double(steps)
                    let wob = sin(t * 9 + Double(k)) * sp * 0.12 + rng.signed() * sp * 0.05
                    line.append(pt(ax + (bx - ax) * t + nx * wob, ay + (by - ay) * t + ny * wob))
                }
                let strong = rng.chance(0.35)
                pen(p, line, weight: (strong ? 1.6 : 0.9) * scale, colour: ch.shadow.dk(0.3).al(ch.bedContrast * rng.r(0.6, 1.2)), wobble: 0.5, taper: false, seed: rng.next())
                pen(p, line.map { pt(Double($0.x) + nx * 1.6 * scale, Double($0.y) + ny * 1.6 * scale) }, weight: 0.8 * scale, colour: ch.light.lt(0.3).al(ch.bedContrast * 0.6), wobble: 0.4, taper: false, seed: rng.next())
                u += sp * rng.r(0.7, 1.3)
                k += 1
            }
        }
        for _ in 0..<Int(rng.r(2, 5) * ch.roughness) {
            let x = Double(box.minX) + rng.d() * Double(box.width)
            let y = Double(box.minY) + rng.d() * Double(box.height)
            let rr = rng.r(size * 0.05, size * 0.16)
            p.radial(pt(x, y), rr, (rng.chance(0.5) ? ch.shadow : ch.light).al(0.18), ch.body.al(0), clip: path)
        }
        if age > 0.04 {
            let lichenScore = age * kind.lichenRate
            let patches = Int(lichenScore * Double(box.width * box.height) / (3200 * scale * scale) * rng.r(0.7, 1.4)) + (lichenScore > 0.25 ? 1 : 0)
            for _ in 0..<min(40, patches) {
                let x = Double(box.minX) + rng.d() * Double(box.width)
                let y = Double(box.minY) + rng.d() * Double(box.height)
                let rr = rng.r(6, 16) * scale * (0.5 + lichenScore * 0.8)
                let tone: Hue = rng.chance(0.6) ? Pot.lichenPale.mix(Hue(r: 0.58, g: 0.62, b: 0.54), rng.d()) : (rng.chance(0.6) ? Pot.lichen.mix(ch.body, 0.3) : Hue(r: 0.80, g: 0.60, b: 0.30))
                let ring = lumpy(cx: x, cy: y, rx: rr, ry: rr * rng.r(0.7, 1.0), rough: 0.34, steps: 16, seed: rng.next())
                p.shape(ring, tone.al(rng.r(0.40, 0.62)))
                p.shape(scaledRing(ring, about: pt(x, y), 0.55), tone.lt(0.2).al(0.35))
                grit(p, pathOf(ring), density: 0.05, sizeMin: 0.4 * scale, sizeMax: 1.1 * scale, colour: tone.dk(0.5).al(0.5), seed: rng.next())
                penOutline(p, ring, weight: 0.5 * scale, colour: tone.dk(0.4).al(0.35), seed: rng.next())
            }
            let mossScore = age * (0.6 + wet)
            let mossPatches = Int(mossScore * Double(box.width) / (60 * scale) * rng.r(0.5, 1.2)) + (mossScore > 0.5 ? 1 : 0)
            for _ in 0..<min(20, mossPatches) {
                let x = Double(box.minX) + rng.d() * Double(box.width)
                let y = Double(box.maxY) - rng.d() * Double(box.height) * 0.3
                let rr = rng.r(5, 13) * scale * (0.6 + mossScore * 0.5)
                let ring = lumpy(cx: x, cy: y, rx: rr * 1.4, ry: rr, rough: 0.35, steps: 12, seed: rng.next())
                p.shape(ring, Pot.moss.mix(Pot.mossDeep, rng.d() * 0.6).al(rng.r(0.5, 0.85)))
                hairs(p, pathOf(ring), count: 8, length: rr * 0.6, weight: 0.5 * scale, spread: 0.6, colour: Pot.mossDeep.al(0.6), seed: rng.next())
            }
            if age > 0.5 {
                let dark = p.light
                p.radial(pt(cx, cy + size * 0.35), size * 0.8, Pot.mossDeep.al(0.10 * age), Pot.mossDeep.al(0), clip: path)
                p.light = dark
            }
        }
        if wet > 0.05 {
            for _ in 0..<Int(6 * wet) {
                let x = Double(box.minX) + rng.d() * Double(box.width)
                let y = Double(box.minY) + rng.d() * Double(box.height) * 0.5
                p.egg(x, y, rng.r(4, 10) * scale, rng.r(1.5, 3) * scale, Hue(r: 1, g: 1, b: 1, a: 0.18 * wet))
            }
        }
    }
    let dense = densify(poly, step: 3)
    p.inside(path) {
        for run in rimRunsOf(dense, light: stoneLight, enter: 0.30, leave: 0.04, window: 9, bridge: 10, minRun: 10, inset: 1.2 * scale, gate: 0.2) {
            rimStroke(p, run, weight: 3.2 * scale, colour: ch.light.lt(0.45).al(0.55), sharp: 0.9, wobble: 0.3, seed: rng.next())
        }
        for run in rimRunsOf(dense, light: stoneLight + .pi, enter: 0.30, leave: 0.04, window: 9, bridge: 10, minRun: 10, inset: 1.4 * scale, gate: 0.2) {
            rimStroke(p, run, weight: 4.5 * scale, colour: ch.shadow.dk(0.45).al(0.5), sharp: 0.8, wobble: 0.3, seed: rng.next())
        }
    }
    if hatch {
        let saved = p.light
        p.light = stoneLight
        roundShade(p, poly, inset: size * 0.22, depth: 1, spacing: max(3.0, 5.5 * scale), colour: Pot.ink.al(0.28), seed: rng.next())
        p.light = saved
    }
    if ink {
        let saved = p.light
        p.light = stoneLight
        penEdge(p, poly, weight: 1.5 * scale, colour: Pot.ink.al(0.85), seed: rng.next())
        p.light = saved
    }
}

func stonePolygon(kind: StoneKind, cls: StoneClass, seed: UInt64, width: Double, height: Double, at c: CGPoint, tilt: Double = 0) -> [CGPoint] {
    var rng = Spool(seed)
    let unit = StoneForge.unitPolygon(family: cls == .flag ? .thinBedded : (cls == .cope ? .blocky : kind.family), flatBase: cls == .footing || cls == .through, rng: &rng)
    let pts = Geometry.transform(unit, width: width, height: height, tilt: 0, x: 0, y: 0)
    return pts.map { q in
        let x = q.x, y = -q.y
        let rx = x * cos(tilt) - y * sin(tilt), ry = x * sin(tilt) + y * cos(tilt)
        return pt(Double(c.x) + rx, Double(c.y) + ry)
    }
}

func drawStonePlate(kind: StoneKind, cls: StoneClass, dir: String) {
    let name = "st_\(kind.rawValue)_\(cls.rawValue)"
    let p = Leaf(900, 600)
    let seed = hashOf(name)
    var rng = Chip(seed)
    layPaper(p, seed: seed, tone: Pot.paperCool, laid: false)
    p.flipDown()
    p.light = stoneLight
    let ch = chordOf(kind)
    var pieces: [(Double, Double, Double, Double, Double)] = []
    let entry = StoneLore.entry(kind)
    var sub = ""
    switch cls {
    case .footing:
        pieces = [(450, 330, 470, 190, 0)]
        sub = "A footing: flat side down, the largest in the heap, \(Int(rng.r(45, 62))) cm into the wall"
    case .builder:
        pieces = [(450, 330, 380, 170, 0)]
        sub = "A builder: length into the wall, \(Int(rng.r(30, 46))) cm long, \(Int(rng.r(16, 28))) cm on the face"
    case .through:
        pieces = [(450, 330, 620, 120, 0)]
        sub = "A through: long enough to reach both faces, \(Int(rng.r(75, 92))) cm, laid at half height"
    case .cope:
        pieces = [(450, 340, 150, 300, 0)]
        sub = "A cope: set upright on the top course, tight against the next"
    default:
        pieces = [(250, 380, 120, 70, 0.2), (420, 340, 90, 60, -0.3), (560, 390, 140, 50, 0.1), (690, 350, 110, 40, -0.15), (350, 450, 70, 40, 0.4), (520, 460, 160, 26, 0.05)]
        sub = "Hearting and pinnings: the small stone that fills the core and levels a rocking builder"
    }
    p.egg(450, 470, 330, 40, Pot.shadowInk.al(0.10))
    for (i, piece) in pieces.enumerated() {
        let poly = stonePolygon(kind: kind, cls: cls == .hearting && i % 2 == 1 ? .pinning : cls, seed: seed &+ UInt64(i * 31), width: piece.2, height: piece.3, at: pt(piece.0, piece.1), tilt: piece.4)
        let depth = min(70, max(18, piece.2 * 0.16))
        p.shape(offsetRing(poly, 14, 22), Pot.shadowInk.al(0.28))
        var side = Chip(seed &+ 7)
        extrudeSides(p, poly, dx: depth * 0.6, dy: -depth * 0.75, light: stoneLight, base: ch.body.dk(0.25), rng: &side, bevel: false)
        let top = offsetRing(poly, depth * 0.6, -depth * 0.75)
        p.inside(pathOf(top)) {
            grit(p, pathOf(top), density: ch.density * 0.6, sizeMin: 0.6, sizeMax: 1.4, colour: ch.speck, seed: seed &+ 99)
        }
        paintStone(p, poly: poly, kind: kind, seed: seed &+ UInt64(i * 13), age: 0.05, bed: cls == .cope ? .pi / 2 : piece.4, ink: true)
    }
    letter(p, "\(entry.name)", at: 450, 78, size: 34, colour: Pot.ink, face: "Copperplate-Bold", align: .centre, tracking: 1.5)
    let subLines = wrapText(sub, width: 760, size: 21, face: "Georgia-Italic")
    for (i, line) in subLines.prefix(2).enumerated() {
        letter(p, line, at: 450, 545 + Double(i) * 26, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    }
    p.writeJPG(dir, name)
}

func weatherGroups() -> [(String, StoneKind, String)] {
    [("grit", .gritstone, "Gritstone"), ("lime", .limestone, "Limestone"), ("oolite", .oolite, "Cotswold oolite"),
     ("slate", .slate, "Slate and schist"), ("hard", .granite, "Granite and whin"), ("field", .fieldstone, "Fieldstone")]
}

let weatherAges: [(String, Double, String)] = [("new", 0.0, "Newly built"), ("year", 0.08, "One winter"), ("ten", 0.28, "Ten years"), ("fifty", 0.62, "Fifty years"), ("century", 1.0, "A hundred and fifty years")]

func drawWeatherPlate(group: (String, StoneKind, String), age: (String, Double, String), dir: String) {
    let name = "wx_\(group.0)_\(age.0)"
    let p = Leaf(1200, 900)
    let seed = hashOf(name)
    var rng = Chip(seed ^ hashOf(group.0))
    layPaper(p, seed: seed, tone: Pot.paperCool, laid: false)
    p.flipDown()
    p.light = stoneLight
    let x0 = 120.0, x1 = 1080.0, y0 = 150.0, y1 = 720.0
    p.box(x0 - 20, y0 - 20, x1 - x0 + 40, y1 - y0 + 40, Pot.earthDeep.al(0.35))
    var y = y1
    var course = 0
    var sameSeed = Chip(hashOf(group.0) &+ 77)
    while y > y0 + 40 {
        let h = sameSeed.r(70, 118)
        var x = x0 + (course % 2 == 0 ? 0 : sameSeed.r(40, 120))
        while x < x1 - 30 {
            let w = min(x1 - x, sameSeed.r(120, 260))
            let poly = stonePolygon(kind: group.1, cls: .builder, seed: sameSeed.next(), width: w - 6, height: h - 5, at: pt(x + w / 2, y - h / 2))
            paintStone(p, poly: poly, kind: group.1, seed: rng.next(), age: age.1, wet: age.1 * 0.3, ink: true)
            x += w
        }
        y -= h
        course += 1
    }
    p.insideRect(CGRect(x: x0 - 20, y: y0 - 20, width: x1 - x0 + 40, height: y1 - y0 + 40)) {
        if age.1 > 0.2 {
            for _ in 0..<Int(age.1 * 40) {
                let gx = rng.r(x0, x1), gy = y1 - rng.r(0, 30)
                hairs(p, rectPath(gx - 20, gy - 40, 40, 50), count: 6, length: 22, weight: 1.1, spread: 0.5, colour: Pot.grassDeep.al(0.7), seed: rng.next())
            }
        }
    }
    plateCaption(p, title: "\(group.2), \(age.2.lowercased())", sub: weatherNote(group.1, age.1), y: 760, titleSize: 34)
    p.writeJPG(dir, name)
}

func weatherNote(_ kind: StoneKind, _ age: Double) -> String {
    let e = StoneLore.entry(kind)
    if age < 0.04 { return "Fresh from the heap: the colour of the quarry, no lichen yet, the joints still open" }
    if age < 0.2 { return "The first winter darkens the weather side and the rain finds the joints" }
    if age < 0.5 { return e.lichen }
    return e.weathers
}
