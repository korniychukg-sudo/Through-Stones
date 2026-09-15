import Foundation
import CoreGraphics

let iconDepth = (dx: -0.62, dy: -0.36)
let iconNear = (dx: 0.62, dy: 0.36)

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
            let x = Double(box.minX) + rng.r(0.1, 0.9) * Double(box.width)
            let y = Double(box.minY) + rng.r(0.1, 0.9) * Double(box.height)
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

func iconReturn(_ p: Leaf, _ front: [CGPoint], depth: Double, joints: [Double], seed: UInt64, age: Double, rng: inout Chip) {
    let n = front.count
    guard n > 2 else { return }
    let turn: Double = signedTwiceArea(front) > 0 ? -(.pi / 2) : (.pi / 2)
    var wob = Chip(seed)
    var stops: [Double] = [0]
    for j in joints where j > 8 && j < depth - 8 { stops.append(j) }
    stops.append(depth)
    for s in 0..<(stops.count - 1) {
        let d0 = stops[s] + (s == 0 ? 0 : 5), d1 = stops[s + 1] - (s == stops.count - 2 ? 0 : 5)
        let faceSeed = wob.next()
        for i in 0..<n {
            let a = front[i], b = front[(i + 1) % n]
            let ex = Double(b.x - a.x), ey = Double(b.y - a.y)
            guard ex * ex + ey * ey > 0.5 else { continue }
            let na = atan2(ey, ex) + turn
            let nx = cos(na)
            guard nx < -0.6 else { continue }
            let quad = [iconOff(a, d0), iconOff(b, d0), iconOff(b, d1), iconOff(a, d1)]
            let lit = 1.14 - Double(s) * 0.15
            iconFace(p, quad, lit: lit, bed: atan2(iconDepth.dy, iconDepth.dx), seed: faceSeed &+ UInt64(i), age: age, hatch: false)
            let qb = pathOf(quad).boundingBox
            p.gradientLine(pathOf(quad), from: pt(Double(qb.maxX), Double(qb.maxY)), to: pt(Double(qb.minX), Double(qb.minY)), Hue(r: 0, g: 0, b: 0, a: 0.06), Hue(r: 0.05, g: 0.06, b: 0.10, a: 0.40 + Double(s) * 0.1))
            iconRim(p, quad, weight: 3.0, rng: &rng, strength: max(0.2, 0.8 - Double(s) * 0.2))
            penEdge(p, quad, weight: 1.6, colour: Pot.shadowInk.al(0.75), seed: wob.next())
        }
        if s < stops.count - 2 {
            for i in 0..<n {
                let a = front[i], b = front[(i + 1) % n]
                let ex = Double(b.x - a.x), ey = Double(b.y - a.y)
                guard ex * ex + ey * ey > 0.5 else { continue }
                let na = atan2(ey, ex) + turn
                guard cos(na) < -0.6 else { continue }
                let gap = [iconOff(a, d1), iconOff(b, d1), iconOff(b, d1 + 10), iconOff(a, d1 + 10)]
                p.shape(gap, Hue(r: 0.02, g: 0.02, b: 0.03, a: 0.9))
            }
        }
    }
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
        let quad = [a, b, iconOff(b, depth + wob.signed() * 3), iconOff(a, depth + wob.signed() * 3)]
        iconFace(p, quad, lit: lit, bed: atan2(iconDepth.dy, iconDepth.dx), seed: wob.next(), age: age, hatch: false)
        iconRim(p, quad, weight: 2.6, rng: &rng, strength: 0.8)
        penEdge(p, quad, weight: 1.3, colour: Pot.shadowInk.al(0.6), seed: wob.next())
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
    var corner: Bool
    var through: Bool
    var tilt: Double
    var age: Double
    var returnDepth: Double
    var joints: [Double]
    var tint: Hue
    var rough: Double
}

func drawIcon(_ dir: String) {
    let previous = sheetScale
    sheetScale = 1.0
    let p = Leaf(1024, 1024)
    p.fillAll(Hue(r: 0.035, g: 0.045, b: 0.04))
    p.flipDown()
    p.light = stoneLight
    var rng = Chip(hashOf("through-stones-icon-corner-v3"))
    let all = rectPath(0, 0, 1024, 1024)

    p.gradientRect(CGRect(x: 0, y: 0, width: 1024, height: 1024), Hue(r: 0.10, g: 0.13, b: 0.16), Hue(r: 0.03, g: 0.04, b: 0.03))
    p.gradientRect(CGRect(x: 0, y: 120, width: 1024, height: 230), Hue(r: 0.44, g: 0.50, b: 0.50, a: 0), Hue(r: 0.44, g: 0.50, b: 0.50, a: 0.5))
    for k in 0..<3 {
        let base = 345.0 + Double(k) * 70
        let ring = ridgeRing(p, base: base, amp: 24 - Double(k) * 5, freq: 0.0045 + Double(k) * 0.002, seed: rng.next(), box: CGRect(x: 0, y: 0, width: 1024, height: 1024))
        let hue = Hue(r: 0.06, g: 0.09, b: 0.06).mix(Hue(r: 0.15, g: 0.18, b: 0.16), 0.7 - Double(k) * 0.3)
        p.shape(ring, hue)
        for _ in 0..<6 { wash(p, ring, hue.lt(0.10), strength: 0.08, bleed: 40, seed: rng.next()) }
    }
    p.gradientRect(CGRect(x: 0, y: 380, width: 1024, height: 644), Hue(r: 0.05, g: 0.06, b: 0.04, a: 0), Hue(r: 0.04, g: 0.04, b: 0.03, a: 0.9))
    p.radial(pt(140, 1010), 540, Hue(r: 0.19, g: 0.16, b: 0.10), Hue(r: 0.04, g: 0.05, b: 0.03, a: 0), clip: all)
    for _ in 0..<2600 {
        let x = rng.r(0, 420), y = rng.r(720, 1024)
        let len = rng.r(4, 14)
        p.ctx.setStrokeColor(cg((rng.chance(0.5) ? Hue(r: 0.36, g: 0.42, b: 0.24) : Hue(r: 0.05, g: 0.06, b: 0.03)).al(rng.r(0.05, 0.16))))
        p.ctx.setLineWidth(CGFloat(rng.r(0.7, 1.6)))
        p.ctx.beginPath()
        p.ctx.move(to: pt(x, y))
        p.ctx.addLine(to: pt(x + rng.signed() * 4, y - len))
        p.ctx.strokePath()
    }

    let cornerX = 345.0
    let baseY = 1085.0
    let faceDir = (dx: 1.0, dy: -0.05)
    let batterStep = 8.0
    func screen(_ u: Double, _ v: Double, _ d: Double, course: Int) -> CGPoint {
        let setback = Double(course) * batterStep
        let x = cornerX + u * faceDir.dx + d * iconDepth.dx + setback * 0.5
        let y = baseY - v + u * faceDir.dy + d * iconDepth.dy + setback * 0.3
        return pt(x, y)
    }

    let warmTint = Hue(r: 0.64, g: 0.45, b: 0.26)
    let greyTint = Hue(r: 0.52, g: 0.51, b: 0.48)
    let plainTint = Hue(r: 0.58, g: 0.46, b: 0.33)
    var courses: [[IconStone]] = []
    var v = 0.0
    let gapV = 13.0
    courses.append([
        IconStone(u0: 0, u1: 600, v0: v, v1: v + 150, kind: .sandstone, cls: .footing, corner: true, through: false, tilt: 0.012, age: 0.62, returnDepth: 560, joints: [95, 200, 330, 450], tint: warmTint, rough: 11),
        IconStone(u0: 616, u1: 1010, v0: v, v1: v + 142, kind: .gritstone, cls: .footing, corner: false, through: false, tilt: -0.02, age: 0.55, returnDepth: 0, joints: [], tint: greyTint, rough: 9)
    ])
    v += 150 + gapV
    courses.append([
        IconStone(u0: 0, u1: 262, v0: v, v1: v + 226, kind: .gritstone, cls: .builder, corner: true, through: false, tilt: 0.0, age: 0.42, returnDepth: 560, joints: [150, 290, 420], tint: plainTint, rough: 13),
        IconStone(u0: 278, u1: 474, v0: v, v1: v + 180, kind: .gritstone, cls: .through, corner: false, through: true, tilt: 0.0, age: 0.35, returnDepth: 0, joints: [], tint: warmTint, rough: 7),
        IconStone(u0: 284, u1: 468, v0: v + 192, v1: v + 226, kind: .sandstone, cls: .builder, corner: false, through: false, tilt: 0.015, age: 0.3, returnDepth: 0, joints: [], tint: greyTint, rough: 4),
        IconStone(u0: 490, u1: 1010, v0: v, v1: v + 216, kind: .greywacke, cls: .builder, corner: false, through: false, tilt: -0.015, age: 0.45, returnDepth: 0, joints: [], tint: greyTint, rough: 12)
    ])
    v += 226 + gapV
    courses.append([
        IconStone(u0: 0, u1: 470, v0: v, v1: v + 136, kind: .sandstone, cls: .builder, corner: true, through: false, tilt: 0.01, age: 0.36, returnDepth: 560, joints: [70, 190, 310, 440], tint: warmTint, rough: 10),
        IconStone(u0: 486, u1: 1010, v0: v, v1: v + 144, kind: .gritstone, cls: .builder, corner: false, through: false, tilt: -0.02, age: 0.3, returnDepth: 0, joints: [], tint: plainTint, rough: 12)
    ])
    v += 136 + gapV
    let topV = v

    var frontsByCourse: [[[CGPoint]]] = []
    for (k, row) in courses.enumerated() {
        var fronts: [[CGPoint]] = []
        for s in row {
            let a = screen(s.u0, s.v0, 0, course: k), b = screen(s.u1, s.v1, 0, course: k)
            let cx = (Double(a.x) + Double(b.x)) * 0.5, cy = (Double(a.y) + Double(b.y)) * 0.5
            let w = Double(b.x) - Double(a.x), h = s.v1 - s.v0
            fronts.append(iconShape(seed: rng.next(), kind: s.kind, cls: s.cls, cx: cx, cy: cy, w: w, h: h, tilt: s.tilt + faceDir.dy, rough: s.rough))
        }
        frontsByCourse.append(fronts)
    }

    let groundShadow = [pt(0, 1024), pt(0, 900), pt(cornerX - 250, 935), pt(cornerX + 20, 1024)]
    for k in 0..<4 {
        p.shape(offsetRing(groundShadow, 0, Double(k) * 14), Hue(r: 0, g: 0, b: 0, a: 0.22))
    }

    func paintFront(_ front: [CGPoint], _ s: IconStone, course k: Int, index i: Int) {
        p.shape(offsetRing(front, 5, 8), Hue(r: 0, g: 0, b: 0, a: 0.8))
        p.shape(offsetRing(front, 11, 17), Hue(r: 0, g: 0, b: 0, a: 0.42))
        p.shape(offsetRing(front, 18, 28), Hue(r: 0, g: 0, b: 0, a: 0.2))
        let frontLit = 0.9 - Double(i) * 0.05 - Double(2 - k) * 0.03 + rng.signed() * 0.04
        iconFace(p, front, lit: frontLit, bed: faceDir.dy + s.tilt, seed: rng.next(), age: s.age, hatch: false, kind: s.kind, wet: 0.12)
        p.inside(pathOf(front)) { p.shape(front, s.tint.al(0.27)) }
        let b = pathOf(front).boundingBox
        p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.minY)), to: pt(Double(b.maxX), Double(b.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.24), Hue(r: 0.04, g: 0.06, b: 0.12, a: 0.46))
        p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.minY)), to: pt(Double(b.minX), Double(b.minY) + 46), Hue(r: 0, g: 0, b: 0, a: 0.55), Hue(r: 0, g: 0, b: 0, a: 0))
        p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.maxY)), to: pt(Double(b.minX), Double(b.maxY) - 34), Hue(r: 0, g: 0, b: 0, a: 0.4), Hue(r: 0, g: 0, b: 0, a: 0))
        iconRim(p, front, weight: 4.2, rng: &rng)
        penEdge(p, front, weight: 2.0, colour: Pot.shadowInk.al(0.9), seed: rng.next())
        let lichenCount = k >= 1 ? Int(rng.r(2, 4)) : Int(rng.r(1, 3))
        iconLichen(p, front, count: lichenCount, sizes: 26...70, greyShare: 0.4, rng: &rng)
    }

    for (k, row) in courses.enumerated() {
        let jointShadowAll = [screen(0, row[0].v0 - 4, 0, course: k), screen(1100, row[0].v0 - 4, 0, course: k), screen(1100, row[0].v0 - 30, 0, course: k), screen(0, row[0].v0 - 30, 0, course: k)]
        p.shape(jointShadowAll, Hue(r: 0.01, g: 0.01, b: 0.02, a: 0.85))
        for (i, s) in row.enumerated() where !s.through {
            let front = frontsByCourse[k][i]
            if s.corner {
                iconReturn(p, front, depth: s.returnDepth, joints: s.joints, seed: rng.next(), age: s.age + 0.1, rng: &rng)
            }
            let topDepth = k == courses.count - 1 ? 300.0 : 30.0
            iconTop(p, front, depth: topDepth, seed: rng.next(), age: s.age, rng: &rng, lit: k == courses.count - 1 ? 1.36 : 1.22)
            paintFront(front, s, course: k, index: i)
        }
        for (i, s) in row.enumerated() where s.through {
            let front = frontsByCourse[k][i]
            let proj = 130.0
            let c = centreOf(front)
            let end = front.map { q -> CGPoint in
                let dx = Double(q.x) - Double(c.x), dy = Double(q.y) - Double(c.y)
                return pt(Double(c.x) + iconNear.dx * proj + dx * 0.94, Double(c.y) + iconNear.dy * proj + dy * 0.9)
            }
            for j in 0..<7 {
                p.shape(offsetRing(end, 10 + Double(j) * 12, 22 + Double(j) * 18), Hue(r: 0, g: 0, b: 0, a: 0.36 - Double(j) * 0.045))
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
                let lit = ny < -0.3 ? 1.5 : (ny > 0.3 ? 0.3 : 0.55)
                iconFace(p, quad, lit: lit, bed: 1.2, seed: rng.next(), age: 0.3, hatch: false, kind: .gritstone)
                if ny < -0.3 {
                    iconRim(p, quad, weight: 3.6, rng: &rng)
                    iconLichen(p, quad, count: 1, sizes: 14...26, greyShare: 0.3, rng: &rng)
                }
                penEdge(p, quad, weight: 1.4, colour: Pot.shadowInk.al(0.75), seed: rng.next())
            }
            p.shape(offsetRing(end, 4, 6), Hue(r: 0, g: 0, b: 0, a: 0.6))
            iconFace(p, end, lit: 1.04, bed: 0.05, seed: rng.next(), age: 0.45, hatch: false, kind: .gritstone, wet: 0.1)
            p.inside(pathOf(end)) { p.shape(end, s.tint.al(0.18)) }
            let eb = pathOf(end).boundingBox
            p.gradientLine(pathOf(end), from: pt(Double(eb.minX), Double(eb.minY)), to: pt(Double(eb.maxX), Double(eb.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.2), Hue(r: 0.04, g: 0.06, b: 0.12, a: 0.4))
            iconRim(p, end, weight: 4.2, rng: &rng)
            penEdge(p, end, weight: 2.0, colour: Pot.shadowInk.al(0.9), seed: rng.next())
            iconLichen(p, end, count: 2, sizes: 16...36, greyShare: 0.5, rng: &rng)
        }
        if k == 0 {
            let s = row[0]
            let at = screen(s.u1 * 0.40, s.v1 + 5, 0, course: k)
            iconMoss(p, at: at, length: 260, thick: 24, rng: &rng)
        }
        if k == 1 {
            let s = row[0]
            let at = screen(s.u1 * 0.55, s.v1 + 5, 0, course: k)
            iconMoss(p, at: at, length: 210, thick: 22, rng: &rng)
        }
        if k == 2 {
            let s = row[1]
            let jointY = screen(s.u0, s.v0 - 5, 0, course: k)
            for m in 0..<3 {
                let px = Double(jointY.x) + 34 + Double(m) * 58
                let py = Double(jointY.y) + rng.r(-2, 2)
                let pin = iconShape(seed: rng.next(), kind: .gritstone, cls: .pinning, cx: px, cy: py, w: rng.r(38, 50), h: rng.r(17, 24), tilt: rng.r(-0.35, 0.35), rough: 2)
                p.shape(offsetRing(pin, 3, 5), Hue(r: 0, g: 0, b: 0, a: 0.6))
                iconFace(p, pin, lit: 0.9, bed: 0.3, seed: rng.next(), age: 0.2, hatch: false, kind: .gritstone)
                iconRim(p, pin, weight: 2.4, rng: &rng)
                penEdge(p, pin, weight: 1.3, colour: Pot.shadowInk.al(0.85), seed: rng.next())
            }
        }
    }

    let copeSpecs: [(Double, Double, Double, Double, Bool)] = [(24, 146, 236, 0.05, true), (166, 284, 208, -0.04, false), (304, 428, 226, 0.03, false), (448, 566, 200, -0.05, false)]
    var copeFronts: [[CGPoint]] = []
    for (idx, cs) in copeSpecs.enumerated() {
        let a = screen(cs.0, topV, 28, course: 3), b = screen(cs.1, topV + cs.2, 28, course: 3)
        let cx = (Double(a.x) + Double(b.x)) * 0.5, cy = (Double(a.y) + Double(b.y)) * 0.5
        let w = Double(b.x) - Double(a.x)
        let front = iconShape(seed: rng.next(), kind: .gritstone, cls: .cope, cx: cx, cy: cy, w: w, h: cs.2, tilt: cs.3 + faceDir.dy, rough: 6)
        copeFronts.append(front)
        let shade = [screen(cs.0 - 6, topV, 0, course: 3), screen(cs.1 + 46, topV, 0, course: 3), screen(cs.1 + 46, topV, 250, course: 3), screen(cs.0 - 6, topV, 250, course: 3)]
        p.shape(shade, Hue(r: 0, g: 0, b: 0, a: 0.5))
        if cs.4 { iconReturn(p, front, depth: 420, joints: [120, 250], seed: rng.next(), age: 0.45, rng: &rng) }
        iconTop(p, front, depth: 84, seed: rng.next(), age: 0.4, rng: &rng, lit: 1.38)
        p.shape(offsetRing(front, 5, 8), Hue(r: 0, g: 0, b: 0, a: 0.75))
        p.shape(offsetRing(front, 12, 18), Hue(r: 0, g: 0, b: 0, a: 0.35))
        iconFace(p, front, lit: 0.98 - Double(idx) * 0.05, bed: .pi / 2 + cs.3, seed: rng.next(), age: 0.4, hatch: false, kind: .gritstone, wet: 0.1)
        p.inside(pathOf(front)) { p.shape(front, (idx % 2 == 0 ? plainTint : greyTint).al(0.2)) }
        let cb = pathOf(front).boundingBox
        p.gradientLine(pathOf(front), from: pt(Double(cb.minX), Double(cb.minY)), to: pt(Double(cb.maxX), Double(cb.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.22), Hue(r: 0.04, g: 0.06, b: 0.12, a: 0.42))
        iconRim(p, front, weight: 4.2, rng: &rng)
        penEdge(p, front, weight: 2.0, colour: Pot.shadowInk.al(0.9), seed: rng.next())
        iconLichen(p, front, count: 2, sizes: 18...44, greyShare: 0.5, rng: &rng)
    }

    let headBox = pathOf(copeFronts[0]).boundingBox
    let hx = Double(headBox.midX) + 70, hy = Double(headBox.minY) - 34
    let axis = 0.12
    let ax = cos(axis), ay = sin(axis)
    let halfH = 46.0, dp = 36.0
    func headPt(_ along: Double, _ up: Double, _ near: Double) -> CGPoint {
        pt(hx + ax * along - ay * up + iconNear.dx * near, hy + ay * along + ax * up + iconNear.dy * near)
    }
    let handleStart = headPt(146, 8, 4)
    let handleEnd = pt(1075, 665)
    let shadowHandle = handleRing(from: pt(Double(handleStart.x) + 36, Double(handleStart.y) + 62), to: pt(Double(handleEnd.x) + 30, Double(handleEnd.y) + 70), width: 62)
    for j in 0..<3 { p.shape(offsetRing(shadowHandle, Double(j) * 8, Double(j) * 10), Hue(r: 0, g: 0, b: 0, a: 0.22)) }
    let handle = handleRing(from: handleStart, to: handleEnd, width: 66, taper: 0.64)
    let ash = Hue(r: 0.78, g: 0.62, b: 0.40)
    p.shape(handle, ash)
    p.gradientLine(pathOf(handle), from: pt(Double(handleStart.x) - 30, Double(handleStart.y) - 40), to: pt(Double(handleStart.x) + 50, Double(handleStart.y) + 40), ash.lt(0.35), ash.dk(0.55))
    let hAxis = atan2(Double(handleEnd.y) - Double(handleStart.y), Double(handleEnd.x) - Double(handleStart.x))
    streaks(p, pathOf(handle), count: 2200, angle: hAxis, light: Hue(r: 1, g: 0.92, b: 0.72, a: 0.24), dark: Hue(r: 0.30, g: 0.18, b: 0.08, a: 0.40), length: 12...80, weight: 0.5...1.5, seed: rng.next())
    let denseH = densify(handle, step: 3)
    for run in rimRunsOf(denseH, light: stoneLight, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 14, inset: 3, gate: 0.25) {
        rimStroke(p, run, weight: 10, colour: Hue(r: 1, g: 0.96, b: 0.85, a: 0.4), sharp: 0.8, wobble: 0.3, seed: rng.next())
        rimStroke(p, run, weight: 3.6, colour: Hue(r: 1, g: 0.98, b: 0.92, a: 0.92), sharp: 1.4, wobble: 0.2, seed: rng.next())
    }
    for run in rimRunsOf(denseH, light: stoneLight + .pi, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 14, inset: 2.5, gate: 0.25) {
        rimStroke(p, run, weight: 8, colour: Hue(r: 0.1, g: 0.05, b: 0.02, a: 0.62), sharp: 0.9, wobble: 0.2, seed: rng.next())
    }
    penEdge(p, handle, weight: 1.7, colour: Hue(r: 0.15, g: 0.08, b: 0.03, a: 0.85), seed: rng.next())

    let blockL = -62.0, blockR = 150.0, peenL = -186.0
    let frontFace = [headPt(blockL, -halfH, dp), headPt(blockR, -halfH, dp), headPt(blockR, halfH, dp), headPt(blockL, halfH, dp)]
    let topFace = [headPt(blockL, -halfH, -dp), headPt(blockR, -halfH, -dp), headPt(blockR, -halfH, dp), headPt(blockL, -halfH, dp)]
    let peenFront = [headPt(blockL, -halfH, dp), headPt(blockL, halfH, dp), headPt(peenL, 10, dp * 0.55), headPt(peenL, -10, dp * 0.55)]
    let peenTop = [headPt(blockL, -halfH, -dp), headPt(blockL, -halfH, dp), headPt(peenL, -10, dp * 0.55), headPt(peenL, -10, -dp * 0.55)]
    let peenEdge = [headPt(peenL, -10, -dp * 0.55), headPt(peenL, -10, dp * 0.55), headPt(peenL, 10, dp * 0.55), headPt(peenL, 10, -dp * 0.55)]
    let headShadow = [headPt(peenL - 10, halfH + 6, dp + 10), headPt(blockR + 20, halfH + 10, dp + 12), headPt(blockR + 40, halfH + 40, dp + 40), headPt(peenL, halfH + 46, dp + 46)]
    for j in 0..<4 { p.shape(offsetRing(headShadow, Double(j) * 6, Double(j) * 8), Hue(r: 0, g: 0, b: 0, a: 0.24)) }
    let steel = Hue(r: 0.46, g: 0.48, b: 0.52)
    let steelFaces: [([CGPoint], Double, Double)] = [(peenEdge, 1.25, -0.4), (peenTop, 1.5, 0.1), (peenFront, 0.95, 0.12), (topFace, 1.55, 0.12), (frontFace, 0.98, 0.12)]
    for (ring, lit, angle) in steelFaces {
        let base = lit >= 1 ? steel.lt((lit - 1) * 0.7) : steel.dk((1 - lit) * 1.2)
        p.shape(ring, base)
        let rb = pathOf(ring).boundingBox
        p.gradientLine(pathOf(ring), from: pt(Double(rb.minX), Double(rb.minY)), to: pt(Double(rb.maxX), Double(rb.maxY)), base.lt(0.30), base.dk(0.55))
        streaks(p, pathOf(ring), count: 1600, angle: angle, light: Hue(r: 1, g: 1, b: 1, a: 0.26), dark: Hue(r: 0.02, g: 0.02, b: 0.04, a: 0.42), length: 8...60, weight: 0.5...1.3, seed: rng.next())
        let dense = densify(ring, step: 3)
        for run in rimRunsOf(dense, light: stoneLight, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 12, inset: 2.6, gate: 0.25) {
            rimStroke(p, run, weight: 9, colour: Hue(r: 0.95, g: 0.97, b: 1, a: 0.35), sharp: 0.8, wobble: 0.2, seed: rng.next())
            rimStroke(p, run, weight: 4.2, colour: Hue(r: 0.98, g: 0.99, b: 1, a: 0.95), sharp: 1.3, wobble: 0.2, seed: rng.next())
        }
        for run in rimRunsOf(dense, light: stoneLight + .pi, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 12, inset: 2.4, gate: 0.25) {
            rimStroke(p, run, weight: 6, colour: Hue(r: 0.02, g: 0.02, b: 0.04, a: 0.7), sharp: 0.9, wobble: 0.2, seed: rng.next())
        }
        penEdge(p, ring, weight: 1.6, colour: Hue(r: 0.03, g: 0.03, b: 0.05, a: 0.92), seed: rng.next())
    }
    let eye = headPt(blockR - 24, 0, dp)
    p.egg(Double(eye.x), Double(eye.y), 12, 18, Hue(r: 0.08, g: 0.07, b: 0.06, a: 0.85))
    let glint = headPt(blockL + 40, -halfH + 6, dp)
    p.egg(Double(glint.x), Double(glint.y), 34, 6, Hue(r: 1, g: 1, b: 1, a: 0.55))
    let glint2 = headPt(blockL + 30, -halfH, 0)
    p.egg(Double(glint2.x), Double(glint2.y), 46, 4, Hue(r: 1, g: 1, b: 1, a: 0.6))

    p.gradientLine(all, from: pt(80, 60), to: pt(1024, 1024), Hue(r: 1, g: 0.95, b: 0.82, a: 0.12), Hue(r: 0.02, g: 0.03, b: 0.06, a: 0.42))
    p.gradientLine(all, from: pt(480, 0), to: pt(1024, 0), Hue(r: 0.03, g: 0.05, b: 0.10, a: 0), Hue(r: 0.03, g: 0.05, b: 0.10, a: 0.5))
    softGlowAt(p, cx: 1010, cy: 1000, radius: 640, colour: Hue(r: 1, g: 0.74, b: 0.42), strength: 0.16)
    softGlowAt(p, cx: 30, cy: 20, radius: 620, colour: Hue(r: 1.0, g: 0.96, b: 0.85), strength: 0.15)
    p.radial(pt(420, 500), 900, Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.62), clip: all)
    filmGrain(p, amount: 5, seed: rng.next())
    p.writePNG(dir, "AppIcon-1024")
    sheetScale = previous
}
