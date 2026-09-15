import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

struct Chip {
    var s: UInt64
    init(_ seed: UInt64) { s = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 { s ^= s << 13; s ^= s >> 7; s ^= s << 17; return s }
    mutating func d() -> Double { Double(next() % 1_000_000) / 1_000_000.0 }
    mutating func r(_ a: Double, _ b: Double) -> Double { a + d() * (b - a) }
    mutating func i(_ a: Int, _ b: Int) -> Int { a + Int(next() % UInt64(max(1, b - a + 1))) }
    mutating func chance(_ p: Double) -> Bool { d() < p }
    mutating func signed() -> Double { d() * 2 - 1 }
}

func bits(_ v: Int) -> UInt64 { UInt64(bitPattern: Int64(v)) }

func hashOf(_ name: String) -> UInt64 {
    var h: UInt64 = 14695981039346656037
    for b in name.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
    return h
}

struct Hue {
    var r: Double, g: Double, b: Double, a: Double = 1
    func al(_ v: Double) -> Hue { Hue(r: r, g: g, b: b, a: v) }
    func mix(_ o: Hue, _ t: Double) -> Hue {
        Hue(r: r + (o.r - r) * t, g: g + (o.g - g) * t, b: b + (o.b - b) * t, a: a + (o.a - a) * t)
    }
    func lt(_ t: Double) -> Hue { mix(Hue(r: 1, g: 1, b: 1, a: a), t) }
    func dk(_ t: Double) -> Hue { mix(Hue(r: 0, g: 0, b: 0, a: a), t) }
    func warm(_ t: Double) -> Hue { mix(Hue(r: 0.95, g: 0.72, b: 0.45, a: a), t) }
    func cool(_ t: Double) -> Hue { mix(Hue(r: 0.55, g: 0.66, b: 0.80, a: a), t) }
}

let deviceRGB = CGColorSpaceCreateDeviceRGB()

func cg(_ c: Hue) -> CGColor {
    CGColor(colorSpace: deviceRGB, components: [CGFloat(c.r), CGFloat(c.g), CGFloat(c.b), CGFloat(c.a)])!
}

enum Pot {
    static let paper      = Hue(r: 0.933, g: 0.910, b: 0.855)
    static let paperWarm  = Hue(r: 0.937, g: 0.906, b: 0.835)
    static let paperCool  = Hue(r: 0.910, g: 0.905, b: 0.870)
    static let paperDeep  = Hue(r: 0.867, g: 0.835, b: 0.770)
    static let ink        = Hue(r: 0.118, g: 0.106, b: 0.094)
    static let inkSoft    = Hue(r: 0.262, g: 0.240, b: 0.212)
    static let inkPale    = Hue(r: 0.450, g: 0.420, b: 0.380)
    static let sepia      = Hue(r: 0.360, g: 0.270, b: 0.185)
    static let rubric     = Hue(r: 0.640, g: 0.196, b: 0.160)
    static let stone      = Hue(r: 0.549, g: 0.541, b: 0.510)
    static let stoneDark  = Hue(r: 0.360, g: 0.352, b: 0.325)
    static let stoneLight = Hue(r: 0.720, g: 0.710, b: 0.675)
    static let grit       = Hue(r: 0.478, g: 0.369, b: 0.267)
    static let moss       = Hue(r: 0.369, g: 0.478, b: 0.275)
    static let mossDeep   = Hue(r: 0.230, g: 0.330, b: 0.170)
    static let lichen     = Hue(r: 0.725, g: 0.702, b: 0.408)
    static let lichenPale = Hue(r: 0.830, g: 0.820, b: 0.700)
    static let sky        = Hue(r: 0.655, g: 0.737, b: 0.788)
    static let skyDeep    = Hue(r: 0.470, g: 0.580, b: 0.680)
    static let dusk       = Hue(r: 0.788, g: 0.541, b: 0.353)
    static let night      = Hue(r: 0.110, g: 0.125, b: 0.190)
    static let grass      = Hue(r: 0.490, g: 0.560, b: 0.330)
    static let grassDeep  = Hue(r: 0.330, g: 0.420, b: 0.230)
    static let bracken    = Hue(r: 0.620, g: 0.470, b: 0.260)
    static let earth      = Hue(r: 0.400, g: 0.310, b: 0.220)
    static let earthDeep  = Hue(r: 0.250, g: 0.190, b: 0.130)
    static let wood       = Hue(r: 0.560, g: 0.430, b: 0.290)
    static let woodDark   = Hue(r: 0.330, g: 0.240, b: 0.150)
    static let steel      = Hue(r: 0.520, g: 0.530, b: 0.545)
    static let steelDark  = Hue(r: 0.290, g: 0.300, b: 0.320)
    static let steelLight = Hue(r: 0.760, g: 0.770, b: 0.790)
    static let fleece     = Hue(r: 0.880, g: 0.860, b: 0.800)
    static let shadowInk  = Hue(r: 0.070, g: 0.062, b: 0.055)
    static let slateTone  = Hue(r: 0.36, g: 0.40, b: 0.45)
}

var sheetScale: Double = 1.42

final class Leaf {
    let ctx: CGContext
    let w: Double
    let h: Double
    var light: Double = 2.30

    init(_ wi: Int, _ hi: Int) {
        w = Double(wi); h = Double(hi)
        let pw = Int((Double(wi) * sheetScale).rounded())
        let ph = Int((Double(hi) * sheetScale).rounded())
        ctx = CGContext(data: nil, width: pw, height: ph, bitsPerComponent: 8,
                        bytesPerRow: pw * 4, space: deviceRGB,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        ctx.scaleBy(x: CGFloat(sheetScale), y: CGFloat(sheetScale))
        ctx.setShouldAntialias(true)
        ctx.interpolationQuality = .high
    }

    func flipDown() {
        ctx.translateBy(x: 0, y: CGFloat(h))
        ctx.scaleBy(x: 1, y: -1)
    }

    func fillAll(_ c: Hue) {
        ctx.setFillColor(cg(c)); ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
    }

    func box(_ x: Double, _ y: Double, _ rw: Double, _ rh: Double, _ c: Hue) {
        ctx.setFillColor(cg(c)); ctx.fill(CGRect(x: x, y: y, width: rw, height: rh))
    }

    func dot(_ x: Double, _ y: Double, _ rad: Double, _ c: Hue) {
        ctx.setFillColor(cg(c))
        ctx.fillEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
    }

    func egg(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double, _ c: Hue) {
        ctx.setFillColor(cg(c))
        ctx.fillEllipse(in: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2))
    }

    func hoop(_ x: Double, _ y: Double, _ rad: Double, _ width: Double, _ c: Hue) {
        ctx.setStrokeColor(cg(c)); ctx.setLineWidth(CGFloat(width))
        ctx.strokeEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
    }

    func shape(_ pts: [CGPoint], _ c: Hue) {
        guard pts.count > 2 else { return }
        ctx.setFillColor(cg(c)); ctx.beginPath(); ctx.move(to: pts[0])
        for p in pts.dropFirst() { ctx.addLine(to: p) }
        ctx.closePath(); ctx.fillPath()
    }

    func rule(_ a: CGPoint, _ b: CGPoint, _ width: Double, _ c: Hue, dash: [CGFloat] = []) {
        ctx.saveGState()
        ctx.setStrokeColor(cg(c)); ctx.setLineWidth(CGFloat(width))
        ctx.setLineCap(.round)
        if !dash.isEmpty { ctx.setLineDash(phase: 0, lengths: dash) }
        ctx.beginPath(); ctx.move(to: a); ctx.addLine(to: b); ctx.strokePath()
        ctx.restoreGState()
    }

    func polyline(_ pts: [CGPoint], _ width: Double, _ c: Hue) {
        guard pts.count > 1 else { return }
        ctx.saveGState()
        ctx.setStrokeColor(cg(c)); ctx.setLineWidth(CGFloat(width))
        ctx.setLineCap(.round); ctx.setLineJoin(.round)
        ctx.beginPath(); ctx.move(to: pts[0])
        for p in pts.dropFirst() { ctx.addLine(to: p) }
        ctx.strokePath()
        ctx.restoreGState()
    }

    func inside(_ path: CGPath, _ body: () -> Void) {
        guard !path.isEmpty else { return }
        ctx.saveGState(); ctx.beginPath(); ctx.addPath(path); ctx.clip(); body(); ctx.restoreGState()
    }

    func insideBoth(_ a: CGPath, _ b: CGPath, _ body: () -> Void) {
        guard !a.isEmpty, !b.isEmpty else { return }
        ctx.saveGState()
        ctx.beginPath(); ctx.addPath(a); ctx.clip()
        ctx.beginPath(); ctx.addPath(b); ctx.clip()
        body()
        ctx.restoreGState()
    }

    func insideRect(_ r: CGRect, _ body: () -> Void) {
        ctx.saveGState(); ctx.clip(to: r); body(); ctx.restoreGState()
    }

    func gradientRect(_ r: CGRect, _ top: Hue, _ bottom: Hue) {
        guard let g = CGGradient(colorsSpace: deviceRGB, colors: [cg(top), cg(bottom)] as CFArray, locations: [0, 1]) else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.drawLinearGradient(g, start: CGPoint(x: r.midX, y: r.minY), end: CGPoint(x: r.midX, y: r.maxY), options: [])
        ctx.restoreGState()
    }

    func gradientLine(_ clip: CGPath, from: CGPoint, to: CGPoint, _ a: Hue, _ b: Hue) {
        guard let g = CGGradient(colorsSpace: deviceRGB, colors: [cg(a), cg(b)] as CFArray, locations: [0, 1]) else { return }
        inside(clip) {
            ctx.drawLinearGradient(g, start: from, end: to, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
    }

    func radial(_ c: CGPoint, _ radius: Double, _ inner: Hue, _ outer: Hue, clip: CGPath? = nil) {
        guard let g = CGGradient(colorsSpace: deviceRGB, colors: [cg(inner), cg(outer)] as CFArray, locations: [0, 1]) else { return }
        ctx.saveGState()
        if let clip = clip, !clip.isEmpty { ctx.beginPath(); ctx.addPath(clip); ctx.clip() }
        ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: CGFloat(radius), options: [])
        ctx.restoreGState()
    }

    func writeJPG(_ dir: String, _ name: String, quality: Double = 0.94) {
        guard let img = ctx.makeImage() else { return }
        let url = URL(fileURLWithPath: dir).appendingPathComponent("\(name).jpg")
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(dest, img, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
        CGImageDestinationFinalize(dest)
    }

    func writePNG(_ dir: String, _ name: String) {
        guard let img = ctx.makeImage() else { return }
        let url = URL(fileURLWithPath: dir).appendingPathComponent("\(name).png")
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(dest, img, nil)
        CGImageDestinationFinalize(dest)
    }

    func image() -> CGImage? { ctx.makeImage() }
}

func pt(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }

func pathOf(_ pts: [CGPoint], close: Bool = true) -> CGPath {
    let p = CGMutablePath()
    guard let first = pts.first else { return p }
    p.move(to: first)
    for q in pts.dropFirst() { p.addLine(to: q) }
    if close { p.closeSubpath() }
    return p
}

func rectPath(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> CGPath {
    CGPath(rect: CGRect(x: x, y: y, width: w, height: h), transform: nil)
}

func resample(_ pts: [CGPoint], count: Int) -> [CGPoint] {
    guard pts.count > 1, count > 1 else { return pts }
    var lengths: [Double] = [0]
    var total = 0.0
    for i in 1..<pts.count {
        let dx = Double(pts[i].x - pts[i - 1].x), dy = Double(pts[i].y - pts[i - 1].y)
        total += (dx * dx + dy * dy).squareRoot()
        lengths.append(total)
    }
    guard total > 0 else { return pts }
    var out: [CGPoint] = []
    var seg = 1
    for k in 0..<count {
        let target = total * Double(k) / Double(count - 1)
        while seg < lengths.count - 1 && lengths[seg] < target { seg += 1 }
        let l0 = lengths[seg - 1], l1 = lengths[seg]
        let t = l1 > l0 ? (target - l0) / (l1 - l0) : 0
        let a = pts[seg - 1], b = pts[seg]
        out.append(CGPoint(x: a.x + (b.x - a.x) * CGFloat(t), y: a.y + (b.y - a.y) * CGFloat(t)))
    }
    return out
}

func resampleKeep(_ pts: [CGPoint], count: Int) -> [CGPoint] {
    guard pts.count > 1, count > pts.count else { return pts }
    var lengths: [Double] = []
    var total = 0.0
    for i in 1..<pts.count {
        let dx = Double(pts[i].x - pts[i - 1].x), dy = Double(pts[i].y - pts[i - 1].y)
        let l = (dx * dx + dy * dy).squareRoot()
        lengths.append(l)
        total += l
    }
    guard total > 0 else { return pts }
    var out: [CGPoint] = [pts[0]]
    for i in 1..<pts.count {
        let n = max(1, Int((lengths[i - 1] / total * Double(count)).rounded()))
        let a = pts[i - 1], b = pts[i]
        for k in 1...n {
            let t = Double(k) / Double(n)
            out.append(CGPoint(x: a.x + (b.x - a.x) * CGFloat(t), y: a.y + (b.y - a.y) * CGFloat(t)))
        }
    }
    return out
}

func offsetRing(_ ring: [CGPoint], _ dx: Double, _ dy: Double) -> [CGPoint] {
    ring.map { pt(Double($0.x) + dx, Double($0.y) + dy) }
}

func scaledRing(_ ring: [CGPoint], about c: CGPoint, _ k: Double) -> [CGPoint] {
    ring.map { pt(Double(c.x) + (Double($0.x) - Double(c.x)) * k, Double(c.y) + (Double($0.y) - Double(c.y)) * k) }
}

func rotatedRing(_ ring: [CGPoint], about c: CGPoint, _ a: Double) -> [CGPoint] {
    let ca = cos(a), sa = sin(a)
    return ring.map { q -> CGPoint in
        let dx = Double(q.x) - Double(c.x), dy = Double(q.y) - Double(c.y)
        return pt(Double(c.x) + dx * ca - dy * sa, Double(c.y) + dx * sa + dy * ca)
    }
}

func centreOf(_ pts: [CGPoint]) -> CGPoint {
    var cx = 0.0, cy = 0.0
    for q in pts { cx += Double(q.x); cy += Double(q.y) }
    let n = Double(max(1, pts.count))
    return pt(cx / n, cy / n)
}

func densify(_ pts: [CGPoint], step: Double) -> [CGPoint] {
    var out: [CGPoint] = []
    for i in 0..<pts.count {
        let a = pts[i], b = pts[(i + 1) % pts.count]
        let dx = Double(b.x - a.x), dy = Double(b.y - a.y)
        let len = (dx * dx + dy * dy).squareRoot()
        let n = max(1, Int(len / step))
        for k in 0..<n {
            let t = Double(k) / Double(n)
            out.append(pt(Double(a.x) + dx * t, Double(a.y) + dy * t))
        }
    }
    return out
}

func layPaper(_ p: Leaf, seed: UInt64, tone: Hue = Pot.paper, laid: Bool = true) {
    var rng = Chip(seed)
    p.fillAll(tone)
    for _ in 0..<20 {
        let x = rng.d() * p.w, y = rng.d() * p.h
        let rr = rng.r(p.w * 0.05, p.w * 0.18)
        let warm = rng.chance(0.6)
        p.radial(pt(x, y), rr, warm ? tone.lt(0.045).al(0.22) : tone.dk(0.036).al(0.17), tone.al(0))
    }
    if laid {
        var y = 0.0
        while y < p.h {
            p.box(0, y, p.w, 1.0 / sheetScale, tone.dk(0.058).al(0.30))
            y += rng.r(4.0, 5.6)
        }
        var x = rng.r(0, 90)
        while x < p.w {
            p.box(x, 0, 1.4 / sheetScale, p.h, tone.lt(0.10).al(0.26))
            x += rng.r(70, 94)
        }
    }
    for _ in 0..<Int(p.w * p.h * sheetScale * sheetScale / 3600) {
        let fx = rng.d() * p.w, fy = rng.d() * p.h
        let a = rng.r(0, 6.283), len = rng.r(3, 14)
        p.ctx.setStrokeColor(cg(tone.dk(rng.r(0.05, 0.18)).al(rng.r(0.14, 0.42))))
        p.ctx.setLineWidth(rng.r(0.6, 1.3))
        p.ctx.beginPath()
        p.ctx.move(to: CGPoint(x: fx, y: fy))
        p.ctx.addLine(to: CGPoint(x: fx + cos(a) * len, y: fy + sin(a) * len))
        p.ctx.strokePath()
    }
    for _ in 0..<rng.i(1, 3) {
        let sx = rng.d() * p.w, sy = rng.d() * p.h
        let rr = rng.r(p.w * 0.04, p.w * 0.11)
        var band: [CGPoint] = []
        var a = 0.0
        while a < 6.283 {
            band.append(CGPoint(x: sx + cos(a) * rr * rng.r(0.80, 1.20), y: sy + sin(a) * rr * rng.r(0.80, 1.20)))
            a += 0.34
        }
        p.shape(band, Hue(r: 0.514, g: 0.431, b: 0.306, a: 0.035))
    }
    p.radial(pt(p.w / 2, p.h / 2), max(p.w, p.h) * 0.74, tone.dk(0.17).al(0), tone.dk(0.17).al(0.42))
}

func wash(_ p: Leaf, _ region: [CGPoint], _ colour: Hue, strength: Double = 0.42, bleed: Double = 6, seed: UInt64) {
    guard region.count > 2 else { return }
    var rng = Chip(seed)
    var edge: [CGPoint] = []
    for q in resample(region + [region[0]], count: max(24, region.count * 3)) {
        edge.append(CGPoint(x: q.x + CGFloat(rng.signed() * bleed), y: q.y + CGFloat(rng.signed() * bleed)))
    }
    let path = pathOf(edge)
    p.ctx.setFillColor(cg(colour.al(strength)))
    p.ctx.beginPath(); p.ctx.addPath(path); p.ctx.fillPath()
    p.ctx.setStrokeColor(cg(colour.dk(0.20).al(strength * 0.54)))
    p.ctx.setLineWidth(CGFloat(bleed * 1.6))
    p.ctx.setLineJoin(.round)
    p.ctx.beginPath(); p.ctx.addPath(path); p.ctx.strokePath()
    p.inside(path) {
        let boxRect = path.boundingBox
        let unit = Double(min(boxRect.width, boxRect.height))
        let count = Int(Double(boxRect.width * boxRect.height) / (unit * unit * 0.5)) + 18
        for _ in 0..<min(170, count) {
            let x = Double(boxRect.minX) + rng.d() * Double(boxRect.width)
            let y = Double(boxRect.minY) + rng.d() * Double(boxRect.height)
            let rx = rng.r(unit * 0.020, unit * 0.085)
            let ry = rx * rng.r(0.35, 0.85)
            p.egg(x, y, rx, ry, rng.chance(0.62) ? colour.dk(0.15).al(strength * 0.14) : colour.lt(0.26).al(strength * 0.10))
        }
    }
}

func washBand(_ p: Leaf, from y0: Double, to y1: Double, _ colour: Hue, strength: Double, seed: UInt64) {
    var rng = Chip(seed)
    let over = p.w * 0.09
    var top: [CGPoint] = []
    var x = -over
    while x <= p.w + over {
        top.append(CGPoint(x: x, y: y1 + CGFloat(rng.signed() * (abs(y1 - y0) * 0.10 + 4))))
        x += p.w / 22
    }
    var region: [CGPoint] = [CGPoint(x: CGFloat(-over), y: CGFloat(y0))]
    region.append(contentsOf: top)
    region.append(CGPoint(x: CGFloat(p.w + over), y: CGFloat(y0)))
    wash(p, region, colour, strength: strength, bleed: max(3, abs(y1 - y0) * 0.05), seed: seed &+ 5)
}

func pen(_ p: Leaf, _ pts: [CGPoint], weight: Double, colour: Hue = Pot.ink, wobble: Double = 1.0, taper: Bool = true, seed: UInt64 = 7) {
    guard pts.count > 1, weight > 0 else { return }
    var rng = Chip(seed)
    let n = max(10, min(96, Int(weight * 14)))
    let spine = pts.count > 2 ? resampleKeep(pts, count: n) : resample(pts, count: n)
    var left: [CGPoint] = []
    var right: [CGPoint] = []
    for i in 0..<spine.count {
        let t = Double(i) / Double(spine.count - 1)
        let a = spine[max(0, i - 1)], b = spine[min(spine.count - 1, i + 1)]
        var tx = Double(b.x - a.x), ty = Double(b.y - a.y)
        let len = (tx * tx + ty * ty).squareRoot()
        if len > 0 { tx /= len; ty /= len } else { tx = 1; ty = 0 }
        let nx = -ty, ny = tx
        let swell = taper ? pow(sin(.pi * t), 0.42) : 1.0
        let hw = max(0.32, weight * 0.5 * (0.55 + 0.45 * swell)) * rng.r(0.88, 1.12)
        let off = rng.signed() * wobble
        let cx = Double(spine[i].x) + nx * off
        let cy = Double(spine[i].y) + ny * off
        left.append(CGPoint(x: cx + nx * hw, y: cy + ny * hw))
        right.append(CGPoint(x: cx - nx * hw, y: cy - ny * hw))
    }
    p.shape(left + right.reversed(), colour)
}

func penBroken(_ p: Leaf, _ pts: [CGPoint], weight: Double, colour: Hue = Pot.ink, pieces: Int = 3, gap: Double = 0.10, wobble: Double = 0.9, seed: UInt64 = 11) {
    var rng = Chip(seed)
    let spine = resample(pts, count: 60)
    var t = 0.0
    var k = 0
    while t < 1.0 {
        let run = rng.r(0.7, 1.3) / Double(max(1, pieces))
        let end = min(1.0, t + run)
        let i0 = Int(t * 59), i1 = Int(end * 59)
        if i1 > i0 + 1 {
            pen(p, Array(spine[i0...i1]), weight: weight * rng.r(0.82, 1.12), colour: colour, wobble: wobble, taper: true, seed: seed &+ UInt64(k) &+ 1)
        }
        t = end + rng.r(gap * 0.4, gap * 1.4)
        k += 1
    }
}

func penEdge(_ p: Leaf, _ pts: [CGPoint], weight: Double, colour: Hue = Pot.ink, seed: UInt64 = 13) {
    guard pts.count > 2 else { return }
    let closed = pts + [pts[0]]
    for i in 0..<(closed.count - 1) {
        let a = closed[i], b = closed[i + 1]
        let ang = atan2(Double(b.y - a.y), Double(b.x - a.x))
        let facing = cos(ang + .pi / 2 - p.light)
        let wt = weight * (0.60 + 0.66 * max(0, -facing))
        pen(p, [a, b], weight: wt, colour: colour, wobble: weight * 0.28, taper: false, seed: seed &+ UInt64(i * 17 + 3))
    }
}

func penOutline(_ p: Leaf, _ pts: [CGPoint], weight: Double, colour: Hue = Pot.ink, seed: UInt64 = 13) {
    guard pts.count > 2 else { return }
    let closed = pts + [pts[0]]
    var rng = Chip(seed)
    var i = 0
    while i < closed.count - 1 {
        let run = min(closed.count - 1, i + rng.i(3, 7))
        pen(p, Array(closed[i...run]), weight: weight * rng.r(0.8, 1.15), colour: colour, wobble: weight * 0.25, taper: true, seed: seed &+ UInt64(i * 13 + 5))
        i = max(i + 1, run - 1)
    }
}

func rules(_ p: Leaf, _ path: CGPath, angle: Double, spacing: Double, weight: Double = 1.1, colour: Hue = Pot.inkSoft,
           coverage: Double = 0.88, bound: CGPath? = nil, seed: UInt64 = 17) {
    guard !path.isEmpty else { return }
    var rng = Chip(seed)
    let boxRect = path.boundingBox.insetBy(dx: -6, dy: -6)
    guard boxRect.width > 1, boxRect.height > 1 else { return }
    let dx = cos(angle), dy = sin(angle)
    let span = Double(boxRect.width + boxRect.height) * 1.2
    let body: () -> Void = {
        var t = -span / 2
        while t < span / 2 {
            if rng.d() <= coverage {
                let cx = Double(boxRect.midX) - dy * t
                let cy = Double(boxRect.midY) + dx * t
                let pieces = rng.i(2, 4)
                var u = -0.5 + rng.r(0, 0.10)
                for k in 0..<pieces {
                    let run = rng.r(0.08, 0.20)
                    let a = CGPoint(x: cx + dx * span * u, y: cy + dy * span * u)
                    let b = CGPoint(x: cx + dx * span * (u + run), y: cy + dy * span * (u + run))
                    pen(p, [a, b], weight: weight * rng.r(0.7, 1.25), colour: colour.al(colour.a * rng.r(0.55, 0.95)), wobble: 0.85, taper: true,
                        seed: seed &+ bits(Int(t) &* 31 &+ k &+ 101))
                    u += run + rng.r(0.03, 0.13)
                }
            }
            t += spacing * rng.r(0.86, 1.18)
        }
    }
    if let b = bound { p.insideBoth(path, b, body) } else { p.inside(path, body) }
}

func crossHatch(_ p: Leaf, _ path: CGPath, depth: Int, spacing: Double, colour: Hue = Pot.inkSoft, bound: CGPath? = nil, seed: UInt64 = 23) {
    let base = p.light + .pi / 2
    rules(p, path, angle: base, spacing: spacing, weight: 1.05, colour: colour, coverage: 0.92, bound: bound, seed: seed)
    if depth >= 2 {
        rules(p, path, angle: base + 1.0, spacing: spacing * 1.15, weight: 0.95, colour: colour, coverage: 0.78, bound: bound, seed: seed &+ 71)
    }
    if depth >= 3 {
        rules(p, path, angle: base - 0.9, spacing: spacing * 1.35, weight: 0.85, colour: colour, coverage: 0.62, bound: bound, seed: seed &+ 131)
    }
}

func roundShade(_ p: Leaf, _ pts: [CGPoint], inset: Double, depth: Int, spacing: Double, colour: Hue = Pot.inkSoft, seed: UInt64 = 53) {
    guard pts.count > 3 else { return }
    let c = centreOf(pts)
    let cx = Double(c.x), cy = Double(c.y)
    let lx = cos(p.light), ly = sin(p.light)
    var outer: [CGPoint] = []
    var inner: [CGPoint] = []
    for q in pts {
        var dx = Double(q.x) - cx, dy = Double(q.y) - cy
        let len = (dx * dx + dy * dy).squareRoot()
        guard len > 0 else { continue }
        dx /= len; dy /= len
        let facing = dx * lx + dy * ly
        guard facing < 0.12 else { continue }
        let pull = inset * min(1.0, -facing + 0.12) * 1.4
        outer.append(q)
        inner.append(CGPoint(x: q.x - CGFloat(dx * pull), y: q.y - CGFloat(dy * pull)))
    }
    guard outer.count > 2 else { return }
    crossHatch(p, pathOf(outer + inner.reversed()), depth: depth, spacing: spacing, colour: colour, bound: pathOf(pts), seed: seed)
}

func grit(_ p: Leaf, _ path: CGPath, density: Double, sizeMin: Double, sizeMax: Double, colour: Hue = Pot.inkSoft, seed: UInt64 = 29) {
    guard !path.isEmpty else { return }
    var rng = Chip(seed)
    let boxRect = path.boundingBox
    let count = Int(Double(boxRect.width * boxRect.height) * density)
    p.inside(path) {
        for _ in 0..<max(0, min(24000, count)) {
            let x = Double(boxRect.minX) + rng.d() * Double(boxRect.width)
            let y = Double(boxRect.minY) + rng.d() * Double(boxRect.height)
            p.dot(x, y, rng.r(sizeMin, sizeMax), colour.al(colour.a * rng.r(0.28, 0.85)))
        }
    }
}

func hairs(_ p: Leaf, _ path: CGPath, count: Int, length: Double, weight: Double, spread: Double, colour: Hue = Pot.ink, seed: UInt64 = 31) {
    guard !path.isEmpty else { return }
    var rng = Chip(seed)
    let boxRect = path.boundingBox
    p.inside(path) {
        for k in 0..<count {
            let x = Double(boxRect.minX) + rng.d() * Double(boxRect.width)
            let y = Double(boxRect.minY) + rng.d() * Double(boxRect.height)
            let a = rng.r(-spread, spread) - .pi / 2
            let len = length * rng.r(0.6, 1.4)
            let mid = CGPoint(x: x + cos(a + 0.4) * len * 0.5, y: y - sin(a) * len * 0.5)
            pen(p, [CGPoint(x: x, y: y), mid, CGPoint(x: x + cos(a) * len * 0.4, y: y - sin(a) * len)],
                weight: weight * rng.r(0.7, 1.3), colour: colour, wobble: 0.5, taper: true, seed: seed &+ UInt64(k))
        }
    }
}

func streaks(_ p: Leaf, _ clip: CGPath, count: Int, angle: Double, light: Hue, dark: Hue, length: ClosedRange<Double>,
             weight: ClosedRange<Double> = 0.6...1.6, seed: UInt64) {
    var rng = Chip(seed)
    let box = clip.boundingBox
    p.inside(clip) {
        for _ in 0..<count {
            let x = Double(box.minX) + rng.d() * Double(box.width)
            let y = Double(box.minY) + rng.d() * Double(box.height)
            let a = angle + rng.signed() * 0.04
            let len = rng.r(length.lowerBound, length.upperBound)
            let tone = rng.chance(0.5) ? light.al(light.a * rng.r(0.35, 1.0)) : dark.al(dark.a * rng.r(0.35, 1.0))
            p.ctx.setStrokeColor(cg(tone))
            p.ctx.setLineWidth(CGFloat(rng.r(weight.lowerBound, weight.upperBound)))
            p.ctx.setLineCap(.round)
            p.ctx.beginPath()
            p.ctx.move(to: pt(x - cos(a) * len * 0.5, y - sin(a) * len * 0.5))
            p.ctx.addLine(to: pt(x + cos(a) * len * 0.5, y + sin(a) * len * 0.5))
            p.ctx.strokePath()
        }
    }
}

func ringOf(cx: Double, cy: Double, rx: Double, ry: Double, steps: Int) -> [CGPoint] {
    var out: [CGPoint] = []
    for i in 0..<steps {
        let a = Double(i) / Double(steps) * 6.283185
        out.append(CGPoint(x: cx + cos(a) * rx, y: cy + sin(a) * ry))
    }
    return out
}

func lumpy(cx: Double, cy: Double, rx: Double, ry: Double, rough: Double, steps: Int = 28, seed: UInt64 = 41) -> [CGPoint] {
    var rng = Chip(seed)
    var out: [CGPoint] = []
    for i in 0..<steps {
        let a = Double(i) / Double(steps) * 6.283185
        let k = 1.0 + rng.signed() * rough
        out.append(CGPoint(x: cx + cos(a) * rx * k, y: cy + sin(a) * ry * k))
    }
    return out
}

func bandOf(_ spine: [CGPoint], _ widths: [Double], per: Int = 6) -> [CGPoint] {
    let fine = resample(spine, count: max(4, spine.count * per))
    var left: [CGPoint] = []
    var right: [CGPoint] = []
    for i in 0..<fine.count {
        let t = Double(i) / Double(fine.count - 1)
        let a = fine[max(0, i - 1)], b = fine[min(fine.count - 1, i + 1)]
        var tx = Double(b.x - a.x), ty = Double(b.y - a.y)
        let l = (tx * tx + ty * ty).squareRoot()
        if l > 0 { tx /= l; ty /= l } else { tx = 1; ty = 0 }
        let idx = t * Double(widths.count - 1)
        let i0 = Int(idx), i1 = min(widths.count - 1, i0 + 1)
        let f = idx - Double(i0)
        let hw = (widths[i0] + (widths[i1] - widths[i0]) * f) * 0.5
        left.append(pt(Double(fine[i].x) - ty * hw, Double(fine[i].y) + tx * hw))
        right.append(pt(Double(fine[i].x) + ty * hw, Double(fine[i].y) - tx * hw))
    }
    return left + right.reversed()
}

enum Justify { case left, centre, right }

func letter(_ p: Leaf, _ text: String, at x: Double, _ y: Double, size: Double, colour: Hue = Pot.ink, face: String = "Georgia",
            align: Justify = .centre, tracking: Double = 0, rotate: Double = 0) {
    guard !text.isEmpty else { return }
    let font = CTFontCreateWithName(face as CFString, CGFloat(size), nil)
    var attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): cg(colour)
    ]
    if tracking != 0 { attrs[NSAttributedString.Key(kCTKernAttributeName as String)] = CGFloat(tracking) }
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    var dx = 0.0
    switch align {
    case .left: dx = 0
    case .centre: dx = -Double(bounds.width) / 2
    case .right: dx = -Double(bounds.width)
    }
    p.ctx.saveGState()
    p.ctx.translateBy(x: CGFloat(x), y: CGFloat(y))
    if rotate != 0 { p.ctx.rotate(by: CGFloat(rotate)) }
    p.ctx.scaleBy(x: 1, y: -1)
    p.ctx.textPosition = CGPoint(x: CGFloat(dx), y: 0)
    CTLineDraw(line, p.ctx)
    p.ctx.restoreGState()
}

func letterWidth(_ text: String, size: Double, face: String = "Georgia") -> Double {
    let font = CTFontCreateWithName(face as CFString, CGFloat(size), nil)
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [NSAttributedString.Key(kCTFontAttributeName as String): font]))
    return Double(CTLineGetBoundsWithOptions(line, .useOpticalBounds).width)
}

func wrapText(_ text: String, width: Double, size: Double, face: String = "Georgia") -> [String] {
    var lines: [String] = []
    var current = ""
    for word in text.split(separator: " ") {
        let trial = current.isEmpty ? String(word) : current + " " + String(word)
        if letterWidth(trial, size: size, face: face) > width && !current.isEmpty {
            lines.append(current); current = String(word)
        } else {
            current = trial
        }
    }
    if !current.isEmpty { lines.append(current) }
    return lines
}

func borderRule(_ p: Leaf, inset: Double, seed: UInt64) {
    var rng = Chip(seed)
    func frame(_ i: Double, _ wgt: Double, _ shade: Hue) {
        let c: [CGPoint] = [pt(i, i), pt(p.w - i, i), pt(p.w - i, p.h - i), pt(i, p.h - i)]
        for k in 0..<4 {
            pen(p, [c[k], c[(k + 1) % 4]], weight: wgt, colour: shade, wobble: 0.7, taper: false, seed: seed &+ UInt64(k * 7 + 1))
        }
    }
    frame(inset, 2.4, Pot.ink)
    frame(inset + rng.r(8, 12), 1.1, Pot.inkSoft)
}

func plateGround(_ p: Leaf, seed: UInt64, tone: Hue = Pot.paperWarm, border: Bool = true) {
    layPaper(p, seed: seed, tone: tone)
    p.flipDown()
    p.light = 2.34
    if border { borderRule(p, inset: 34, seed: seed &+ 3) }
}

func plateCaption(_ p: Leaf, title: String, sub: String, y: Double, titleSize: Double = 40) {
    p.box(p.w * 0.10, y, p.w * 0.80, 1.5, Pot.ink.al(0.32))
    letter(p, title, at: p.w / 2, y + 50, size: titleSize, colour: Pot.ink, face: "Copperplate-Bold", align: .centre, tracking: 1.5)
    if !sub.isEmpty {
        for (i, line) in wrapText(sub, width: p.w * 0.78, size: 24, face: "Georgia-Italic").prefix(3).enumerated() {
            letter(p, line, at: p.w / 2, y + 92 + Double(i) * 32, size: 24, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
        }
    }
}

struct Run {
    var pts: [CGPoint]
    var power: [Double]
}

func signedTwiceArea(_ pts: [CGPoint]) -> Double {
    var twice = 0.0
    for i in 0..<pts.count {
        let a = pts[i], b = pts[(i + 1) % pts.count]
        twice += Double(a.x) * Double(b.y) - Double(b.x) * Double(a.y)
    }
    return twice
}

func smoothFall(_ v: Double, _ gate: Double) -> Double {
    let c = max(0.0, min(1.0, v))
    guard gate > 0, gate < 0.999 else { return c }
    let t = max(0.0, min(1.0, (c - gate) / (1.0 - gate)))
    return t * t * (3.0 - 2.0 * t)
}

func rimRunsOf(_ pts: [CGPoint], light: Double, enter: Double, leave: Double, window: Int = 11, bridge: Int = 14, minRun: Int = 16,
               inset: Double = 0, gate: Double = 0) -> [Run] {
    let n = pts.count
    guard n > 8 else { return [] }
    let turn: Double = signedTwiceArea(pts) > 0 ? -(.pi / 2) : (.pi / 2)
    let reach = max(1, min(n / 8, 4))
    var nx = [Double](repeating: 0, count: n)
    var ny = [Double](repeating: 0, count: n)
    var raw = [Double](repeating: 0, count: n)
    var carry = 0.0
    for i in 0..<n {
        let a = pts[(i + n - reach) % n], b = pts[(i + reach) % n]
        let dx = Double(b.x - a.x), dy = Double(b.y - a.y)
        if dx * dx + dy * dy > 1e-9 { carry = atan2(dy, dx) }
        let na = carry + turn
        nx[i] = cos(na)
        ny[i] = sin(na)
        raw[i] = cos(na - light)
    }
    var facing = [Double](repeating: 0, count: n)
    let half = max(1, min(window / 2, n / 3))
    for i in 0..<n {
        var acc = 0.0, mass = 0.0
        for k in -half...half {
            let w = 1.0 - Double(abs(k)) / Double(half + 1)
            acc += raw[(i + k + n) % n] * w
            mass += w
        }
        facing[i] = acc / mass
    }
    var seedIdx = 0
    var peak = facing[0]
    for i in 1..<n {
        if facing[i] < facing[seedIdx] { seedIdx = i }
        if facing[i] > peak { peak = facing[i] }
    }
    var lit = [Bool](repeating: false, count: n)
    var on = facing[seedIdx] > enter
    for k in 0..<n {
        let i = (seedIdx + k) % n
        if on {
            if facing[i] < leave { on = false }
        } else if facing[i] > enter {
            on = true
        }
        lit[i] = on
    }
    guard lit.contains(true) else { return [] }
    if lit.contains(false) {
        var fill: [Int] = []
        for i in 0..<n where !lit[i] && lit[(i + n - 1) % n] {
            var len = 0
            while len < n && !lit[(i + len) % n] { len += 1 }
            if len <= bridge { for k in 0..<len { fill.append((i + k) % n) } }
        }
        for i in fill { lit[i] = true }
    }
    var runs: [(Int, Int)] = []
    if lit.contains(false) {
        for i in 0..<n where lit[i] && !lit[(i + n - 1) % n] {
            var len = 0
            while len < n && lit[(i + len) % n] { len += 1 }
            runs.append((i, len))
        }
    } else {
        runs = [(0, n)]
    }
    let spread = max(0.14, peak - leave)
    var out: [Run] = []
    for (start, len) in runs where len >= minRun {
        var line: [CGPoint] = []
        var lift: [Double] = []
        for k in 0..<len {
            let i = (start + k) % n
            let lam = smoothFall((facing[i] - leave) / spread, gate)
            line.append(pt(Double(pts[i].x) - nx[i] * inset * lam, Double(pts[i].y) - ny[i] * inset * lam))
            lift.append(lam)
        }
        out.append(Run(pts: line, power: lift))
    }
    return out
}

func runResample(_ g: Run, count: Int) -> Run {
    guard g.pts.count > 1, count > 1 else { return g }
    var marks: [Double] = [0]
    var total = 0.0
    for i in 1..<g.pts.count {
        let dx = Double(g.pts[i].x - g.pts[i - 1].x), dy = Double(g.pts[i].y - g.pts[i - 1].y)
        total += (dx * dx + dy * dy).squareRoot()
        marks.append(total)
    }
    guard total > 0 else { return g }
    var line: [CGPoint] = []
    var lift: [Double] = []
    var seg = 1
    for k in 0..<count {
        let target = total * Double(k) / Double(count - 1)
        while seg < marks.count - 1 && marks[seg] < target { seg += 1 }
        let l0 = marks[seg - 1], l1 = marks[seg]
        let t = l1 > l0 ? (target - l0) / (l1 - l0) : 0
        let a = g.pts[seg - 1], b = g.pts[seg]
        line.append(CGPoint(x: a.x + (b.x - a.x) * CGFloat(t), y: a.y + (b.y - a.y) * CGFloat(t)))
        lift.append(g.power[seg - 1] + (g.power[seg] - g.power[seg - 1]) * t)
    }
    return Run(pts: line, power: lift)
}

func rimStroke(_ p: Leaf, _ g: Run, weight: Double, colour: Hue, sharp: Double = 1.0, wobble: Double = 0.0, seed: UInt64 = 9) {
    guard g.pts.count > 1, weight > 0 else { return }
    var total = 0.0
    for i in 1..<g.pts.count {
        let dx = Double(g.pts[i].x - g.pts[i - 1].x), dy = Double(g.pts[i].y - g.pts[i - 1].y)
        total += (dx * dx + dy * dy).squareRoot()
    }
    guard total > 3 else { return }
    let n = max(28, min(420, Int(total / 3.0)))
    let s = runResample(g, count: n)
    var rng = Chip(seed)
    let f1 = rng.r(1.4, 3.0), f2 = rng.r(4.0, 7.4)
    let ph1 = rng.r(0, 6.283185), ph2 = rng.r(0, 6.283185)
    var left: [CGPoint] = []
    var right: [CGPoint] = []
    for i in 0..<n {
        let t = Double(i) / Double(n - 1)
        let a = s.pts[max(0, i - 1)], b = s.pts[min(n - 1, i + 1)]
        var tx = Double(b.x - a.x), ty = Double(b.y - a.y)
        let len = (tx * tx + ty * ty).squareRoot()
        if len > 0 { tx /= len; ty /= len } else { tx = 1; ty = 0 }
        let px = -ty, py = tx
        let ends = pow(sin(.pi * t), 0.42)
        let lam = pow(max(0.0, min(1.0, s.power[i])), sharp)
        let ripple = 1.0 + 0.13 * sin(t * f1 * 6.283185 + ph1) + 0.06 * sin(t * f2 * 6.283185 + ph2)
        let hw = max(0.0, weight * 0.5 * ends * lam * ripple)
        let off = sin(t * f2 * 3.141593 + ph2) * wobble
        let cx = Double(s.pts[i].x) + px * off
        let cy = Double(s.pts[i].y) + py * off
        left.append(pt(cx + px * hw, cy + py * hw))
        right.append(pt(cx - px * hw, cy - py * hw))
    }
    p.shape(left + right.reversed(), colour)
}

func softGlowAt(_ p: Leaf, cx: Double, cy: Double, radius: Double, colour: Hue, strength: Double) {
    guard radius > 1, let g = CGGradient(colorsSpace: deviceRGB, colors: [cg(colour.al(strength)), cg(colour.al(strength * 0.34)), cg(colour.al(0))] as CFArray, locations: [0, 0.44, 1]) else { return }
    p.ctx.drawRadialGradient(g, startCenter: CGPoint(x: cx, y: cy), startRadius: 0, endCenter: CGPoint(x: cx, y: cy), endRadius: CGFloat(radius), options: [])
}

func filmGrain(_ p: Leaf, amount: Double, seed: UInt64) {
    guard let data = p.ctx.data else { return }
    let w = p.ctx.width, h = p.ctx.height, row = p.ctx.bytesPerRow
    let bytes = data.bindMemory(to: UInt8.self, capacity: row * h)
    var rng = Chip(seed)
    for y in 0..<h {
        let base = y * row
        for x in 0..<w {
            let o = base + x * 4
            let n = rng.signed() * amount
            let lum = rng.signed() * amount * 0.35
            for c in 0..<3 {
                let v = Double(bytes[o + c]) + n + (c == 0 ? lum : (c == 2 ? -lum : 0))
                bytes[o + c] = UInt8(max(0, min(255, v.rounded())))
            }
        }
    }
}

func extrudeSides(_ p: Leaf, _ top: [CGPoint], dx: Double, dy: Double, light: Double, base: Hue, rng: inout Chip, bevel: Bool = true) {
    let n = top.count
    guard n > 2 else { return }
    let turn: Double = signedTwiceArea(top) > 0 ? -(.pi / 2) : (.pi / 2)
    for i in 0..<n {
        let a = top[i], b = top[(i + 1) % n]
        let ex = Double(b.x - a.x), ey = Double(b.y - a.y)
        guard ex * ex + ey * ey > 0.5 else { continue }
        let na = atan2(ey, ex) + turn
        let nxv = cos(na), nyv = sin(na)
        guard nxv * dx + nyv * dy > 0.002 else { continue }
        let facing = cos(na - light)
        let level = 0.5 + 0.5 * facing
        var tone = base.dk(0.62 * (1 - level))
        if level > 0.5 { tone = tone.lt((level - 0.5) * 0.5) }
        let quad = [a, b, pt(Double(b.x) + dx, Double(b.y) + dy), pt(Double(a.x) + dx, Double(a.y) + dy)]
        p.shape(quad, tone)
        p.gradientLine(pathOf(quad), from: a, to: pt(Double(a.x) + dx, Double(a.y) + dy), Hue(r: 1, g: 1, b: 1, a: 0.10 * level), Hue(r: 0, g: 0, b: 0, a: 0.30))
        if bevel {
            pen(p, [a, b], weight: 2.0, colour: Hue(r: 1, g: 0.99, b: 0.96, a: 0.20 + 0.5 * level), wobble: 0.2, taper: true, seed: rng.next())
            pen(p, [pt(Double(a.x) + dx, Double(a.y) + dy), pt(Double(b.x) + dx, Double(b.y) + dy)], weight: 2.4, colour: Hue(r: 0, g: 0, b: 0, a: 0.5), wobble: 0.2, taper: false, seed: rng.next())
        }
    }
}
