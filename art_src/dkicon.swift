import Foundation
import CoreGraphics

let iconDepth = (dx: -0.34, dy: -0.22)
let iconNear = (dx: 0.30, dy: 0.34)

func iconOff(_ q: CGPoint, _ d: Double) -> CGPoint {
    pt(Double(q.x) + iconDepth.dx * d, Double(q.y) + iconDepth.dy * d)
}

func iconFace(_ p: Leaf, _ poly: [CGPoint], lit: Double, bed: Double, seed: UInt64, age: Double, hatch: Bool, kind: StoneKind = .gritstone, wet: Double = 0) {
    guard poly.count > 2 else { return }
    paintStone(p, poly: poly, kind: kind, seed: seed, age: age, bed: bed, wet: wet, ink: false, hatch: hatch)
    let path = pathOf(poly)
    if lit < 1 {
        p.inside(path) { p.shape(poly, Hue(r: 0.03, g: 0.04, b: 0.06, a: (1 - lit) * 0.9)) }
    } else if lit > 1 {
        p.inside(path) { p.shape(poly, Hue(r: 1, g: 0.95, b: 0.82, a: (lit - 1) * 0.55)) }
    }
}

func iconRim(_ p: Leaf, _ poly: [CGPoint], weight: Double, rng: inout Chip, strength: Double = 1.0) {
    let dense = densify(poly, step: 3)
    p.inside(pathOf(poly)) {
        for run in rimRunsOf(dense, light: stoneLight, enter: 0.32, leave: 0.06, window: 11, bridge: 14, minRun: 16, inset: weight * 0.35, gate: 0.3) {
            rimStroke(p, run, weight: weight * 2.2, colour: Hue(r: 1, g: 0.95, b: 0.82, a: 0.26 * strength), sharp: 0.7, wobble: 0.4, seed: rng.next())
            rimStroke(p, run, weight: weight, colour: Hue(r: 1, g: 0.97, b: 0.90, a: 0.82 * strength), sharp: 1.3, wobble: 0.2, seed: rng.next())
        }
        for run in rimRunsOf(dense, light: stoneLight + .pi, enter: 0.32, leave: 0.06, window: 11, bridge: 14, minRun: 16, inset: weight * 0.3, gate: 0.3) {
            rimStroke(p, run, weight: weight * 1.6, colour: Hue(r: 0.02, g: 0.02, b: 0.02, a: 0.55), sharp: 0.9, wobble: 0.3, seed: rng.next())
        }
    }
}

func iconLichen(_ p: Leaf, _ poly: [CGPoint], count: Int, sizes: ClosedRange<Double>, greyShare: Double, rng: inout Chip) {
    let path = pathOf(poly)
    let box = path.boundingBox
    guard box.width > 10, box.height > 10 else { return }
    p.inside(path) {
        for _ in 0..<count {
            let x = Double(box.minX) + rng.r(0.12, 0.88) * Double(box.width)
            let y = Double(box.minY) + rng.r(0.12, 0.88) * Double(box.height)
            let rr = rng.r(sizes.lowerBound, sizes.upperBound)
            let grey = rng.chance(greyShare)
            let tone = grey ? Hue(r: 0.56, g: 0.62, b: 0.53).mix(Hue(r: 0.66, g: 0.70, b: 0.62), rng.d()) : Hue(r: 0.725, g: 0.702, b: 0.408).mix(Hue(r: 0.80, g: 0.79, b: 0.56), rng.d())
            p.radial(pt(x, y), rr * 1.35, tone.al(0.7), tone.al(0), clip: path)
            let ring = lumpy(cx: x, cy: y, rx: rr, ry: rr * rng.r(0.7, 1.0), rough: 0.38, steps: 18, seed: rng.next())
            p.shape(ring, tone.al(0.58))
            p.radial(pt(x, y), rr * 0.7, tone.lt(0.3).al(0.5), tone.al(0), clip: pathOf(ring))
            grit(p, pathOf(ring), density: 0.06, sizeMin: 0.8, sizeMax: 2.2, colour: tone.dk(0.45).al(0.55), seed: rng.next())
            grit(p, pathOf(ring), density: 0.02, sizeMin: 0.8, sizeMax: 1.8, colour: tone.lt(0.5).al(0.7), seed: rng.next())
            let inner = lumpy(cx: x + rng.signed() * rr * 0.2, cy: y + rng.signed() * rr * 0.2, rx: rr * 0.45, ry: rr * 0.4, rough: 0.5, steps: 12, seed: rng.next())
            p.shape(inner, tone.dk(0.2).al(0.25))
        }
    }
}

func iconMoss(_ p: Leaf, at c: CGPoint, length: Double, thick: Double, rng: inout Chip) {
    let ring = lumpy(cx: Double(c.x), cy: Double(c.y), rx: length * 0.5, ry: thick, rough: 0.45, steps: 22, seed: rng.next())
    p.radial(c, length * 0.55, Pot.mossDeep.al(0.55), Pot.mossDeep.al(0), clip: nil)
    p.shape(ring, Hue(r: 0.37, g: 0.48, b: 0.27).al(0.92))
    p.shape(offsetRing(ring, 0, 3), Pot.mossDeep.al(0.5))
    hairs(p, pathOf(offsetRing(ring, 0, -4)), count: Int(length * 1.6), length: thick * 0.8, weight: 1.1, spread: 0.9, colour: Hue(r: 0.50, g: 0.62, b: 0.34).al(0.9), seed: rng.next())
    hairs(p, pathOf(ring), count: Int(length * 0.7), length: thick * 0.6, weight: 0.8, spread: 1.2, colour: Pot.mossDeep.dk(0.35).al(0.8), seed: rng.next())
    p.radial(pt(Double(c.x) - length * 0.2, Double(c.y) - thick * 0.4), length * 0.35, Hue(r: 0.62, g: 0.72, b: 0.40, a: 0.35), Hue(r: 0.62, g: 0.72, b: 0.40, a: 0), clip: pathOf(ring))
}

func iconTop(_ p: Leaf, _ front: [CGPoint], depth: Double, seed: UInt64, age: Double, rng: inout Chip, lit: Double = 1.36) {
    let n = front.count
    guard n > 2 else { return }
    let turn: Double = signedTwiceArea(front) > 0 ? -(.pi / 2) : (.pi / 2)
    var wob = Chip(seed)
    for i in 0..<n {
        let a = front[i], b = front[(i + 1) % n]
        let ex = Double(b.x - a.x), ey = Double(b.y - a.y)
        guard ex * ex + ey * ey > 0.5 else { continue }
        let na = atan2(ey, ex) + turn
        let nx = cos(na), ny = sin(na)
        guard ny < -0.35 && nx * iconDepth.dx + ny * iconDepth.dy > 0.05 else { continue }
        let quad = [a, b, iconOff(b, depth + wob.signed() * 2), iconOff(a, depth + wob.signed() * 2)]
        iconFace(p, quad, lit: lit, bed: atan2(iconDepth.dy, iconDepth.dx), seed: wob.next(), age: age, hatch: false)
        iconRim(p, quad, weight: 2.4, rng: &rng, strength: 0.8)
        penEdge(p, quad, weight: 1.2, colour: Pot.shadowInk.al(0.6), seed: wob.next())
    }
}

func iconShape(seed: UInt64, kind: StoneKind, cls: StoneClass, cx: Double, cy: Double, w: Double, h: Double, tilt: Double, rough: Double) -> [CGPoint] {
    let base = stonePolygon(kind: kind, cls: cls, seed: seed, width: w, height: h, at: pt(cx, cy), tilt: tilt)
    guard rough > 0.01, base.count > 3 else { return base }
    var rng = Chip(seed ^ 0x5A5A)
    let c = centreOf(base)
    var out: [CGPoint] = []
    let n = base.count
    for i in 0..<n {
        let a = base[i], b = base[(i + 1) % n]
        let ax = Double(a.x), ay = Double(a.y)
        let dx = ax - Double(c.x), dy = ay - Double(c.y)
        let len = max(1, (dx * dx + dy * dy).squareRoot())
        let k = rng.signed() * rough
        out.append(pt(ax + dx / len * k, ay + dy / len * k))
        let mx = (ax + Double(b.x)) * 0.5, my = (ay + Double(b.y)) * 0.5
        let mdx = mx - Double(c.x), mdy = my - Double(c.y)
        let mlen = max(1, (mdx * mdx + mdy * mdy).squareRoot())
        let mk = rng.signed() * rough * 0.6 - rough * 0.25
        out.append(pt(mx + mdx / mlen * mk, my + mdy / mlen * mk))
    }
    return out
}

struct IconStone {
    var u0: Double
    var u1: Double
    var v0: Double
    var v1: Double
    var kind: StoneKind
    var cls: StoneClass
    var through: Bool
    var tilt: Double
    var age: Double
    var tint: Hue
    var rough: Double
    var lichen: Int
}

func iconBatten(_ p: Leaf, from a: CGPoint, to b: CGPoint, width: Double, rng: inout Chip) {
    let band = bandOf([a, pt((Double(a.x) + Double(b.x)) * 0.5, (Double(a.y) + Double(b.y)) * 0.5), b], [width, width, width], per: 8)
    let ash = Hue(r: 0.82, g: 0.74, b: 0.56)
    p.shape(band, ash)
    let axis = atan2(Double(b.y) - Double(a.y), Double(b.x) - Double(a.x))
    let nx = -sin(axis), ny = cos(axis)
    let mid = pt((Double(a.x) + Double(b.x)) * 0.5, (Double(a.y) + Double(b.y)) * 0.5)
    p.gradientLine(pathOf(band), from: pt(Double(mid.x) - nx * width * 0.6, Double(mid.y) - ny * width * 0.6), to: pt(Double(mid.x) + nx * width * 0.6, Double(mid.y) + ny * width * 0.6), ash.lt(0.3), ash.dk(0.5))
    streaks(p, pathOf(band), count: 1400, angle: axis, light: Hue(r: 1, g: 0.95, b: 0.80, a: 0.22), dark: Hue(r: 0.34, g: 0.22, b: 0.10, a: 0.36), length: 14...90, weight: 0.5...1.4, seed: rng.next())
    let dense = densify(band, step: 3)
    for run in rimRunsOf(dense, light: stoneLight, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 14, inset: 2.6, gate: 0.25) {
        rimStroke(p, run, weight: 7, colour: Hue(r: 1, g: 0.97, b: 0.88, a: 0.4), sharp: 0.8, wobble: 0.3, seed: rng.next())
        rimStroke(p, run, weight: 2.8, colour: Hue(r: 1, g: 0.99, b: 0.94, a: 0.92), sharp: 1.4, wobble: 0.2, seed: rng.next())
    }
    for run in rimRunsOf(dense, light: stoneLight + .pi, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 14, inset: 2.2, gate: 0.25) {
        rimStroke(p, run, weight: 6, colour: Hue(r: 0.12, g: 0.07, b: 0.03, a: 0.6), sharp: 0.9, wobble: 0.2, seed: rng.next())
    }
    penEdge(p, band, weight: 1.6, colour: Hue(r: 0.15, g: 0.09, b: 0.04, a: 0.85), seed: rng.next())
}

func drawIcon(_ dir: String) {
    let previous = sheetScale
    sheetScale = 1.0
    let p = Leaf(1024, 1024)
    p.fillAll(Hue(r: 0.035, g: 0.045, b: 0.04))
    p.flipDown()
    p.light = stoneLight
    var rng = Chip(hashOf("through-stones-icon-frame-v1"))
    let all = rectPath(0, 0, 1024, 1024)

    p.gradientRect(CGRect(x: 0, y: 0, width: 1024, height: 1024), Hue(r: 0.10, g: 0.13, b: 0.16), Hue(r: 0.03, g: 0.04, b: 0.03))
    p.gradientRect(CGRect(x: 0, y: 90, width: 1024, height: 230), Hue(r: 0.46, g: 0.52, b: 0.52, a: 0), Hue(r: 0.46, g: 0.52, b: 0.52, a: 0.55))
    for k in 0..<3 {
        let base = 318.0 + Double(k) * 60
        let ring = ridgeRing(p, base: base, amp: 22 - Double(k) * 5, freq: 0.0045 + Double(k) * 0.002, seed: rng.next(), box: CGRect(x: 0, y: 0, width: 1024, height: 1024))
        let hue = Hue(r: 0.06, g: 0.09, b: 0.06).mix(Hue(r: 0.15, g: 0.18, b: 0.16), 0.7 - Double(k) * 0.3)
        p.shape(ring, hue)
        for _ in 0..<6 { wash(p, ring, hue.lt(0.10), strength: 0.08, bleed: 40, seed: rng.next()) }
    }
    p.gradientRect(CGRect(x: 0, y: 360, width: 1024, height: 664), Hue(r: 0.05, g: 0.06, b: 0.04, a: 0), Hue(r: 0.04, g: 0.04, b: 0.03, a: 0.92))
    p.radial(pt(120, 1010), 420, Hue(r: 0.19, g: 0.16, b: 0.10), Hue(r: 0.04, g: 0.05, b: 0.03, a: 0), clip: all)
    for _ in 0..<1800 {
        let x = rng.r(0, 260), y = rng.r(760, 1024)
        let len = rng.r(4, 14)
        p.ctx.setStrokeColor(cg((rng.chance(0.5) ? Hue(r: 0.36, g: 0.42, b: 0.24) : Hue(r: 0.05, g: 0.06, b: 0.03)).al(rng.r(0.05, 0.16))))
        p.ctx.setLineWidth(CGFloat(rng.r(0.7, 1.6)))
        p.ctx.beginPath()
        p.ctx.move(to: pt(x, y))
        p.ctx.addLine(to: pt(x + rng.signed() * 4, y - len))
        p.ctx.strokePath()
    }

    let wallX = 196.0
    let baseY = 1090.0
    let faceDir = (dx: 1.0, dy: -0.035)
    func screen(_ u: Double, _ v: Double, course: Int) -> CGPoint {
        let setback = Double(course) * 7.0
        return pt(wallX + u * faceDir.dx + setback * 0.4, baseY - v + u * faceDir.dy + setback * 0.25)
    }

    let warmTint = Hue(r: 0.64, g: 0.45, b: 0.26)
    let greyTint = Hue(r: 0.52, g: 0.51, b: 0.48)
    let plainTint = Hue(r: 0.58, g: 0.46, b: 0.33)
    let gapV = 9.0
    var courses: [[IconStone]] = []
    var v = 0.0
    courses.append([
        IconStone(u0: 0, u1: 336, v0: v, v1: v + 300, kind: .gritstone, cls: .builder, through: false, tilt: 0.01, age: 0.55, tint: plainTint, rough: 9, lichen: 1),
        IconStone(u0: 346, u1: 680, v0: v, v1: v + 290, kind: .sandstone, cls: .builder, through: false, tilt: -0.02, age: 0.6, tint: warmTint, rough: 9, lichen: 2),
        IconStone(u0: 690, u1: 1040, v0: v, v1: v + 296, kind: .gritstone, cls: .builder, through: false, tilt: 0.015, age: 0.5, tint: greyTint, rough: 9, lichen: 1)
    ])
    v += 300 + gapV
    courses.append([
        IconStone(u0: 0, u1: 238, v0: v, v1: v + 262, kind: .gritstone, cls: .builder, through: false, tilt: -0.01, age: 0.4, tint: greyTint, rough: 9, lichen: 1),
        IconStone(u0: 248, u1: 470, v0: v, v1: v + 240, kind: .gritstone, cls: .through, through: true, tilt: 0.0, age: 0.32, tint: warmTint, rough: 6, lichen: 1),
        IconStone(u0: 480, u1: 806, v0: v, v1: v + 258, kind: .sandstone, cls: .builder, through: false, tilt: 0.02, age: 0.42, tint: plainTint, rough: 9, lichen: 2),
        IconStone(u0: 816, u1: 1040, v0: v, v1: v + 252, kind: .gritstone, cls: .builder, through: false, tilt: -0.015, age: 0.38, tint: greyTint, rough: 9, lichen: 1)
    ])
    v += 262 + gapV
    let topV = v

    var frontsByCourse: [[[CGPoint]]] = []
    for (k, row) in courses.enumerated() {
        var fronts: [[CGPoint]] = []
        for s in row {
            let a = screen(s.u0, s.v0, course: k), b = screen(s.u1, s.v1, course: k)
            let cx = (Double(a.x) + Double(b.x)) * 0.5, cy = (Double(a.y) + Double(b.y)) * 0.5
            let w = Double(b.x) - Double(a.x), h = s.v1 - s.v0
            let shape = iconShape(seed: rng.next(), kind: s.kind, cls: s.cls, cx: cx, cy: cy, w: w, h: h, tilt: s.tilt + faceDir.dy, rough: s.rough)
            fronts.append(scaledRing(shape, about: pt(cx, cy), 1.07))
        }
        frontsByCourse.append(fronts)
    }

    let wallBack = [screen(-6, -40, course: 0), screen(1100, -40, course: 0), screen(1100, topV + 6, course: 0), screen(-6, topV + 6, course: 0)]
    p.shape(wallBack, Hue(r: 0.03, g: 0.03, b: 0.03))
    let groundShadow = [pt(0, 1024), pt(0, 930), pt(wallX - 30, 960), pt(wallX + 10, 1024)]
    for k in 0..<4 { p.shape(offsetRing(groundShadow, 0, Double(k) * 12), Hue(r: 0, g: 0, b: 0, a: 0.2)) }

    func paintFront(_ front: [CGPoint], _ s: IconStone, course k: Int, index i: Int) {
        p.shape(offsetRing(front, 4, 6), Hue(r: 0, g: 0, b: 0, a: 0.8))
        p.shape(offsetRing(front, 9, 13), Hue(r: 0, g: 0, b: 0, a: 0.4))
        p.shape(offsetRing(front, 14, 20), Hue(r: 0, g: 0, b: 0, a: 0.16))
        let frontLit = 0.98 - Double(i) * 0.05 - Double(1 - k) * 0.04 + rng.signed() * 0.03
        iconFace(p, front, lit: frontLit, bed: faceDir.dy + s.tilt, seed: rng.next(), age: s.age, hatch: false, kind: s.kind, wet: 0.12)
        p.inside(pathOf(front)) { p.shape(front, s.tint.al(0.27)) }
        let b = pathOf(front).boundingBox
        p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.minY)), to: pt(Double(b.maxX), Double(b.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.26), Hue(r: 0.04, g: 0.06, b: 0.12, a: 0.44))
        p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.minY)), to: pt(Double(b.minX), Double(b.minY) + 50), Hue(r: 0, g: 0, b: 0, a: 0.5), Hue(r: 0, g: 0, b: 0, a: 0))
        p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.maxY)), to: pt(Double(b.minX), Double(b.maxY) - 40), Hue(r: 0, g: 0, b: 0, a: 0.4), Hue(r: 0, g: 0, b: 0, a: 0))
        iconRim(p, front, weight: 4.4, rng: &rng)
        penEdge(p, front, weight: 2.0, colour: Pot.shadowInk.al(0.9), seed: rng.next())
        iconLichen(p, front, count: s.lichen, sizes: 34...70, greyShare: 0.45, rng: &rng)
    }

    for (k, row) in courses.enumerated() {
        let joint = [screen(-6, row[0].v0 - 3, course: k), screen(1100, row[0].v0 - 3, course: k), screen(1100, row[0].v0 - 24, course: k), screen(-6, row[0].v0 - 24, course: k)]
        p.shape(joint, Hue(r: 0.01, g: 0.01, b: 0.02, a: 0.85))
        for (i, s) in row.enumerated() where !s.through {
            let front = frontsByCourse[k][i]
            iconTop(p, front, depth: k == courses.count - 1 ? 30 : 22, seed: rng.next(), age: s.age, rng: &rng, lit: 1.3)
            paintFront(front, s, course: k, index: i)
        }
        for (i, s) in row.enumerated() where s.through {
            let front = frontsByCourse[k][i]
            let proj = 130.0
            let c = centreOf(front)
            let end = front.map { q -> CGPoint in
                let dx = Double(q.x) - Double(c.x), dy = Double(q.y) - Double(c.y)
                return pt(Double(c.x) + iconNear.dx * proj + dx * 1.04, Double(c.y) + iconNear.dy * proj + dy * 1.0)
            }
            for j in 0..<7 {
                p.shape(offsetRing(end, 12 + Double(j) * 12, 26 + Double(j) * 20), Hue(r: 0, g: 0, b: 0, a: 0.36 - Double(j) * 0.045))
            }
            let n = front.count
            let turn: Double = signedTwiceArea(front) > 0 ? -(.pi / 2) : (.pi / 2)
            for j in 0..<n {
                let a = front[j], bq = front[(j + 1) % n]
                let ex = Double(bq.x - a.x), ey = Double(bq.y - a.y)
                guard ex * ex + ey * ey > 0.5 else { continue }
                let na = atan2(ey, ex) + turn
                let nx = cos(na), ny = sin(na)
                guard ny < -0.3 || nx > 0.5 || ny > 0.3 else { continue }
                let quad = [a, bq, end[(j + 1) % n], end[j]]
                let lit = ny < -0.3 ? 1.5 : (ny > 0.3 ? 0.28 : 0.55)
                iconFace(p, quad, lit: lit, bed: 1.2, seed: rng.next(), age: 0.3, hatch: false, kind: .gritstone)
                if ny < -0.3 { iconRim(p, quad, weight: 3.6, rng: &rng) }
                penEdge(p, quad, weight: 1.4, colour: Pot.shadowInk.al(0.75), seed: rng.next())
            }
            p.shape(offsetRing(end, 4, 6), Hue(r: 0, g: 0, b: 0, a: 0.6))
            iconFace(p, end, lit: 1.04, bed: 0.05, seed: rng.next(), age: 0.4, hatch: false, kind: .gritstone, wet: 0.1)
            p.inside(pathOf(end)) { p.shape(end, s.tint.al(0.2)) }
            let eb = pathOf(end).boundingBox
            p.gradientLine(pathOf(end), from: pt(Double(eb.minX), Double(eb.minY)), to: pt(Double(eb.maxX), Double(eb.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.22), Hue(r: 0.04, g: 0.06, b: 0.12, a: 0.4))
            iconRim(p, end, weight: 4.4, rng: &rng)
            penEdge(p, end, weight: 2.0, colour: Pot.shadowInk.al(0.9), seed: rng.next())
            iconLichen(p, end, count: 1, sizes: 30...50, greyShare: 0.5, rng: &rng)
        }
        if k == 0 {
            let s = row[1]
            let at = screen((s.u0 + s.u1) * 0.5 + 20, s.v1 + 6, course: k)
            iconMoss(p, at: at, length: 280, thick: 24, rng: &rng)
        }
    }

    let copeSpecs: [(Double, Double, Double, Double)] = [(30, 236, 262, 0.06), (282, 486, 244, -0.05), (534, 742, 270, 0.04)]
    for (idx, cs) in copeSpecs.enumerated() {
        let a = screen(cs.0, topV, course: 2), b = screen(cs.1, topV + cs.2, course: 2)
        let cx = (Double(a.x) + Double(b.x)) * 0.5, cy = (Double(a.y) + Double(b.y)) * 0.5
        let w = Double(b.x) - Double(a.x)
        let front = scaledRing(iconShape(seed: rng.next(), kind: .sandstone, cls: .cope, cx: cx, cy: cy, w: w, h: cs.2, tilt: cs.3 + faceDir.dy, rough: 7), about: pt(cx, cy), 1.03)
        iconTop(p, front, depth: 40, seed: rng.next(), age: 0.4, rng: &rng, lit: 1.4)
        p.shape(offsetRing(front, 4, 6), Hue(r: 0, g: 0, b: 0, a: 0.75))
        p.shape(offsetRing(front, 10, 14), Hue(r: 0, g: 0, b: 0, a: 0.35))
        iconFace(p, front, lit: 1.0 - Double(idx) * 0.05, bed: .pi / 2 + cs.3, seed: rng.next(), age: 0.4, hatch: false, kind: .sandstone, wet: 0.1)
        p.inside(pathOf(front)) { p.shape(front, (idx % 2 == 0 ? plainTint : greyTint).al(0.22)) }
        let cb = pathOf(front).boundingBox
        p.gradientLine(pathOf(front), from: pt(Double(cb.minX), Double(cb.minY)), to: pt(Double(cb.maxX), Double(cb.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.22), Hue(r: 0.04, g: 0.06, b: 0.12, a: 0.42))
        iconRim(p, front, weight: 4.4, rng: &rng)
        penEdge(p, front, weight: 2.0, colour: Pot.shadowInk.al(0.9), seed: rng.next())
        iconLichen(p, front, count: 1, sizes: 36...60, greyShare: 0.5, rng: &rng)
    }

    let apex = pt(wallX - 4, 250)
    let legL = pt(48, 1100), legR = pt(352, 1100)
    let width = 34.0
    let frameShadow: [[CGPoint]] = [
        bandOf([pt(Double(legL.x) + 30, Double(legL.y)), pt(Double(apex.x) + 26, Double(apex.y) + 40)], [width * 1.2, width * 1.2], per: 6),
        bandOf([pt(Double(legR.x) + 30, Double(legR.y)), pt(Double(apex.x) + 30, Double(apex.y) + 40)], [width * 1.2, width * 1.2], per: 6)
    ]
    for ring in frameShadow {
        for j in 0..<3 { p.shape(offsetRing(ring, Double(j) * 6, Double(j) * 8), Hue(r: 0, g: 0, b: 0, a: 0.2)) }
    }
    let barY = 690.0
    func legX(_ leg: CGPoint, at y: Double) -> Double {
        let t = (Double(leg.y) - y) / (Double(leg.y) - Double(apex.y))
        return Double(leg.x) + (Double(apex.x) - Double(leg.x)) * t
    }
    let barA = pt(legX(legL, at: barY) - 8, barY + 4), barB = pt(legX(legR, at: barY) + 8, barY - 6)
    let barShadow = bandOf([pt(Double(barA.x) + 22, Double(barA.y) + 30), pt(Double(barB.x) + 22, Double(barB.y) + 30)], [width, width], per: 6)
    for j in 0..<3 { p.shape(offsetRing(barShadow, Double(j) * 5, Double(j) * 7), Hue(r: 0, g: 0, b: 0, a: 0.2)) }
    iconBatten(p, from: barA, to: barB, width: width * 0.86, rng: &rng)
    iconBatten(p, from: legL, to: pt(Double(apex.x) - 8, Double(apex.y) + 2), width: width, rng: &rng)
    iconBatten(p, from: legR, to: pt(Double(apex.x) + 10, Double(apex.y) - 4), width: width, rng: &rng)
    let peg = lumpy(cx: Double(apex.x) + 1, cy: Double(apex.y) + 36, rx: 9, ry: 9, rough: 0.15, steps: 14, seed: rng.next())
    p.shape(peg, Hue(r: 0.20, g: 0.16, b: 0.12))
    p.egg(Double(apex.x) - 2, Double(apex.y) + 33, 4, 3, Hue(r: 0.7, g: 0.66, b: 0.6, a: 0.7))

    let lineY0 = Double(screen(0, topV - 6, course: 2).y)
    let lineStart = pt(legX(legR, at: lineY0) + width * 0.5, lineY0)
    let lineEnd = pt(1024, lineY0 + 1024 * faceDir.dy * 0.5)
    let knot = lumpy(cx: Double(lineStart.x) - 8, cy: Double(lineStart.y), rx: 10, ry: 8, rough: 0.3, steps: 12, seed: rng.next())
    p.shape(knot, Hue(r: 0.94, g: 0.92, b: 0.86))
    penOutline(p, knot, weight: 0.9, colour: Hue(r: 0.4, g: 0.36, b: 0.3, a: 0.7), seed: rng.next())
    p.rule(pt(Double(lineStart.x), Double(lineStart.y) + 9), pt(Double(lineEnd.x), Double(lineEnd.y) + 11), 4.5, Hue(r: 0, g: 0, b: 0, a: 0.5))
    p.rule(lineStart, lineEnd, 7, Hue(r: 1, g: 0.98, b: 0.92, a: 0.28))
    p.rule(lineStart, lineEnd, 3.2, Hue(r: 0.98, g: 0.97, b: 0.93))
    p.rule(pt(Double(lineStart.x), Double(lineStart.y) - 0.8), pt(Double(lineEnd.x), Double(lineEnd.y) - 0.8), 1.1, Hue(r: 1, g: 1, b: 1, a: 0.9))

    p.gradientLine(all, from: pt(80, 60), to: pt(1024, 1024), Hue(r: 1, g: 0.95, b: 0.82, a: 0.12), Hue(r: 0.02, g: 0.03, b: 0.06, a: 0.40))
    p.gradientLine(all, from: pt(520, 0), to: pt(1024, 0), Hue(r: 0.03, g: 0.05, b: 0.10, a: 0), Hue(r: 0.03, g: 0.05, b: 0.10, a: 0.46))
    softGlowAt(p, cx: 1010, cy: 1000, radius: 640, colour: Hue(r: 1, g: 0.74, b: 0.42), strength: 0.16)
    softGlowAt(p, cx: 30, cy: 20, radius: 620, colour: Hue(r: 1.0, g: 0.96, b: 0.85), strength: 0.14)
    p.radial(pt(470, 540), 900, Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.6), clip: all)
    filmGrain(p, amount: 5, seed: rng.next())
    p.writePNG(dir, "AppIcon-1024")
    sheetScale = previous
}
