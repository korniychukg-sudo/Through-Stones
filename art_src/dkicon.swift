import Foundation
import CoreGraphics

let iconDepth = (dx: -0.62, dy: -0.36)

func iconFace(_ p: Leaf, _ poly: [CGPoint], lit: Double, bed: Double, seed: UInt64, age: Double, hatch: Bool) {
    guard poly.count > 2 else { return }
    paintStone(p, poly: poly, kind: .gritstone, seed: seed, age: age, bed: bed, ink: false, hatch: hatch)
    let path = pathOf(poly)
    if lit < 1 {
        p.inside(path) { p.shape(poly, Hue(r: 0.02, g: 0.02, b: 0.03, a: (1 - lit) * 0.85)) }
    } else if lit > 1 {
        p.inside(path) { p.shape(poly, Hue(r: 1, g: 0.95, b: 0.82, a: (lit - 1) * 0.55)) }
    }
}

func iconRim(_ p: Leaf, _ poly: [CGPoint], weight: Double, rng: inout Chip) {
    let dense = densify(poly, step: 3)
    p.inside(pathOf(poly)) {
        for run in rimRunsOf(dense, light: stoneLight, enter: 0.32, leave: 0.06, window: 11, bridge: 14, minRun: 16, inset: weight * 0.35, gate: 0.3) {
            rimStroke(p, run, weight: weight * 2.2, colour: Hue(r: 1, g: 0.95, b: 0.82, a: 0.26), sharp: 0.7, wobble: 0.4, seed: rng.next())
            rimStroke(p, run, weight: weight, colour: Hue(r: 1, g: 0.97, b: 0.90, a: 0.82), sharp: 1.3, wobble: 0.2, seed: rng.next())
        }
        for run in rimRunsOf(dense, light: stoneLight + .pi, enter: 0.32, leave: 0.06, window: 11, bridge: 14, minRun: 16, inset: weight * 0.3, gate: 0.3) {
            rimStroke(p, run, weight: weight * 1.6, colour: Hue(r: 0.02, g: 0.02, b: 0.02, a: 0.55), sharp: 0.9, wobble: 0.3, seed: rng.next())
        }
    }
}

func iconExtrude(_ p: Leaf, _ front: [CGPoint], depth: Double, leftToo: Bool, seed: UInt64, age: Double) {
    let n = front.count
    guard n > 2 else { return }
    let turn: Double = signedTwiceArea(front) > 0 ? -(.pi / 2) : (.pi / 2)
    let dx = iconDepth.dx * depth, dy = iconDepth.dy * depth
    var wob = Chip(seed)
    for i in 0..<n {
        let a = front[i], b = front[(i + 1) % n]
        let ex = Double(b.x - a.x), ey = Double(b.y - a.y)
        guard ex * ex + ey * ey > 0.5 else { continue }
        let na = atan2(ey, ex) + turn
        let nx = cos(na), ny = sin(na)
        let upward = ny < -0.35
        let leftward = nx < -0.6
        guard (upward && nx * iconDepth.dx + ny * iconDepth.dy > 0.05) || (leftToo && leftward) else { continue }
        let quad = [a, b, pt(Double(b.x) + dx + wob.signed() * 2, Double(b.y) + dy + wob.signed() * 2), pt(Double(a.x) + dx + wob.signed() * 2, Double(a.y) + dy + wob.signed() * 2)]
        let lit = upward ? 1.34 : 1.06
        iconFace(p, quad, lit: lit, bed: upward ? atan2(iconDepth.dy, iconDepth.dx) : atan2(iconDepth.dy, iconDepth.dx), seed: wob.next(), age: age, hatch: false)
        penEdge(p, quad, weight: 1.2, colour: Pot.shadowInk.al(0.6), seed: wob.next())
    }
}

func iconStoneFace(seed: UInt64, cx: Double, cy: Double, w: Double, h: Double, tilt: Double, blocky: Bool) -> [CGPoint] {
    var rng = Chip(seed)
    let hw = w * 0.5, hh = h * 0.5
    var local: [(Double, Double)] = []
    let corners: [(Double, Double)] = [(-hw, -hh), (hw, -hh), (hw, hh), (-hw, hh)]
    for (k, c) in corners.enumerated() {
        let chamfer = rng.chance(blocky ? 0.55 : 0.85) ? rng.r(0.05, 0.16) : 0.02
        let cw = w * chamfer, ch = h * chamfer * rng.r(0.6, 1.4)
        let sx: Double = c.0 < 0 ? 1 : -1, sy: Double = c.1 < 0 ? 1 : -1
        if k == 0 || k == 2 {
            local.append((c.0, c.1 + sy * ch))
            local.append((c.0 + sx * cw, c.1))
        } else {
            local.append((c.0 + sx * cw, c.1))
            local.append((c.0, c.1 + sy * ch))
        }
    }
    return local.map { q in
        let x = q.0 + rng.signed() * 2.5, y = q.1 + rng.signed() * 2.5
        let rx = x * cos(tilt) - y * sin(tilt), ry = x * sin(tilt) + y * cos(tilt)
        return pt(cx + rx, cy + ry)
    }
}

func drawIcon(_ dir: String) {
    let previous = sheetScale
    sheetScale = 1.0
    let p = Leaf(1024, 1024)
    p.fillAll(Hue(r: 0.05, g: 0.06, b: 0.07))
    p.flipDown()
    p.light = stoneLight
    var rng = Chip(hashOf("through-stones-icon-corner-v2"))
    let all = rectPath(0, 0, 1024, 1024)
    p.gradientRect(CGRect(x: 0, y: 0, width: 1024, height: 1024), Hue(r: 0.46, g: 0.54, b: 0.62), Hue(r: 0.06, g: 0.08, b: 0.08))
    p.radial(pt(180, 60), 700, Hue(r: 0.95, g: 0.88, b: 0.70, a: 0.55), Hue(r: 0.95, g: 0.88, b: 0.70, a: 0), clip: all)
    for k in 0..<3 {
        let base = 300.0 + Double(k) * 90
        let ring = ridgeRing(p, base: base, amp: 30 - Double(k) * 6, freq: 0.004 + Double(k) * 0.002, seed: rng.next(), box: CGRect(x: 0, y: 0, width: 1024, height: 1024))
        let hue = Hue(r: 0.14, g: 0.19, b: 0.16).mix(Hue(r: 0.26, g: 0.32, b: 0.34), 0.6 - Double(k) * 0.25)
        p.shape(ring, hue)
        for _ in 0..<5 { wash(p, ring, hue.lt(0.12), strength: 0.10, bleed: 46, seed: rng.next()) }
    }
    for _ in 0..<5000 {
        let x = rng.d() * 1024, y = rng.r(420, 1024)
        let len = rng.r(3, 9)
        p.ctx.setStrokeColor(cg((rng.chance(0.5) ? Hue(r: 0.45, g: 0.56, b: 0.38) : Hue(r: 0.02, g: 0.04, b: 0.02)).al(rng.r(0.04, 0.12))))
        p.ctx.setLineWidth(CGFloat(rng.r(0.6, 1.4)))
        p.ctx.beginPath()
        p.ctx.move(to: pt(x, y))
        p.ctx.addLine(to: pt(x + rng.signed() * 3, y - len))
        p.ctx.strokePath()
    }
    p.gradientRect(CGRect(x: 0, y: 640, width: 1024, height: 384), Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.6))

    let cornerX = 290.0
    let baseY = 1080.0
    let faceDir = (dx: 1.0, dy: -0.07)
    let batterStep = 8.0
    func screen(_ u: Double, _ v: Double, _ d: Double, course: Int) -> CGPoint {
        let setback = Double(course) * batterStep
        let x = cornerX + u * faceDir.dx + d * iconDepth.dx + setback * 0.5
        let y = baseY - v + u * faceDir.dy + d * iconDepth.dy + setback * 0.3
        return pt(x, y)
    }
    let courseHeights = [225.0, 185.0, 170.0, 158.0]
    var v = 0.0
    var courses: [[(Double, Double, Double, Double, Bool)]] = []
    for (k, h) in courseHeights.enumerated() {
        var row: [(Double, Double, Double, Double, Bool)] = []
        var u = 0.0
        var idx = 0
        while u < 1150 {
            let corner = idx == 0
            let w = corner ? (k % 2 == 0 ? rng.r(200, 240) : rng.r(300, 350)) : rng.r(220, 340)
            let through = k == 2 && idx == 1
            row.append((u, u + w, v, v + h * rng.r(0.96, 1.0), through))
            u += w + rng.r(5, 9)
            idx += 1
        }
        courses.append(row)
        v += h + 5
    }
    let topV = v
    let shadowLift = 0.0
    _ = shadowLift
    for (k, row) in courses.enumerated() {
        for (i, s) in row.enumerated() {
            let corner = i == 0
            let cx = (screen(s.0, s.2, 0, course: k).x + screen(s.1, s.3, 0, course: k).x) * 0.5
            let cy = (screen(s.0, s.2, 0, course: k).y + screen(s.1, s.3, 0, course: k).y) * 0.5
            let w = Double(screen(s.1, s.2, 0, course: k).x - screen(s.0, s.2, 0, course: k).x)
            let h = s.3 - s.2
            let front = iconStoneFace(seed: rng.next(), cx: Double(cx), cy: Double(cy), w: w, h: h, tilt: -0.07, blocky: i % 3 != 2)
            let bedAngle = -0.07
            let topDepth = k == courses.count - 1 ? 380.0 : 24.0
            let sideDepth = corner ? (k % 2 == 0 ? 360.0 : 200.0) : 0
            if corner {
                iconExtrude(p, front, depth: sideDepth, leftToo: true, seed: rng.next(), age: 0.35)
            }
            iconExtrude(p, front, depth: topDepth, leftToo: false, seed: rng.next(), age: 0.45)
            let b = pathOf(front).boundingBox
            p.shape(offsetRing(front, 3, 6), Hue(r: 0, g: 0, b: 0, a: 0.6))
            let frontLit = 0.92 - Double(i) * 0.06 + rng.signed() * 0.07
            iconFace(p, front, lit: frontLit, bed: bedAngle, seed: rng.next(), age: rng.r(0.2, 0.5), hatch: false)
            p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.minY)), to: pt(Double(b.maxX), Double(b.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.22), Hue(r: 0, g: 0, b: 0, a: 0.34))
            p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.minY)), to: pt(Double(b.minX), Double(b.minY) + 34), Hue(r: 0, g: 0, b: 0, a: 0.5), Hue(r: 0, g: 0, b: 0, a: 0))
            p.gradientLine(pathOf(front), from: pt(Double(b.minX), Double(b.maxY)), to: pt(Double(b.minX), Double(b.maxY) - 26), Hue(r: 0, g: 0, b: 0, a: 0.3), Hue(r: 0, g: 0, b: 0, a: 0))
            iconRim(p, front, weight: 3.6, rng: &rng)
            penEdge(p, front, weight: 1.8, colour: Pot.shadowInk.al(0.8), seed: rng.next())
            if s.4 {
                let proj = 74.0
                let inset = front.map { pt(Double($0.x) + proj * 0.78, Double($0.y) + proj * 0.5) }.enumerated().map { (j, q) -> CGPoint in
                    let c = centreOf(front)
                    let dx = Double(q.x) - Double(c.x) - proj * 0.78, dy = Double(q.y) - Double(c.y) - proj * 0.5
                    _ = j
                    return pt(Double(c.x) + proj * 0.78 + dx * 0.9, Double(c.y) + proj * 0.5 + dy * 0.86)
                }
                p.shape(offsetRing(inset, 20, 36), Hue(r: 0, g: 0, b: 0, a: 0.6))
                p.gradientLine(pathOf(offsetRing(inset, 0, 70)), from: inset[0], to: pt(Double(inset[0].x), Double(inset[0].y) + 90), Hue(r: 0, g: 0, b: 0, a: 0.55), Hue(r: 0, g: 0, b: 0, a: 0))
                let n = front.count
                for j in 0..<n {
                    let a = front[j], bq = front[(j + 1) % n]
                    let ex = Double(bq.x - a.x), ey = Double(bq.y - a.y)
                    let turn: Double = signedTwiceArea(front) > 0 ? -(.pi / 2) : (.pi / 2)
                    let na = atan2(ey, ex) + turn
                    let nx = cos(na), ny = sin(na)
                    guard ny < -0.3 || nx < -0.5 || nx > 0.5 else { continue }
                    let quad = [a, bq, inset[(j + 1) % n], inset[j]]
                    let lit = ny < -0.3 ? 1.2 : (nx < 0 ? 0.85 : 0.5)
                    iconFace(p, quad, lit: lit, bed: 1.2, seed: rng.next(), age: 0.3, hatch: false)
                    penEdge(p, quad, weight: 1.2, colour: Pot.shadowInk.al(0.6), seed: rng.next())
                }
                iconFace(p, inset, lit: 1.02, bed: bedAngle, seed: rng.next(), age: 0.5, hatch: false)
                iconRim(p, inset, weight: 3.4, rng: &rng)
                penEdge(p, inset, weight: 1.8, colour: Pot.shadowInk.al(0.85), seed: rng.next())
            }
        }
        if k == 1, let s = row.first {
            let mossAt = screen(s.1 + 10, s.3 + 6, 0, course: k)
            let mossRing = lumpy(cx: Double(mossAt.x) + 70, cy: Double(mossAt.y), rx: 95, ry: 22, rough: 0.4, steps: 18, seed: rng.next())
            p.shape(mossRing, Pot.mossDeep.al(0.9))
            hairs(p, pathOf(offsetRing(mossRing, 0, -6)), count: 200, length: 13, weight: 1.0, spread: 0.9, colour: Pot.moss.lt(0.2).al(0.85), seed: rng.next())
            hairs(p, pathOf(mossRing), count: 90, length: 8, weight: 0.8, spread: 1.2, colour: Pot.mossDeep.dk(0.3).al(0.7), seed: rng.next())
        }
    }

    let copeC = screen(150, topV + 128, 40, course: 4)
    let copeFront = iconStoneFace(seed: rng.next(), cx: Double(copeC.x), cy: Double(copeC.y), w: 150, h: 262, tilt: 0.02, blocky: true)
    let copeShadow = [screen(30, topV, 0, course: 4), screen(320, topV, 0, course: 4), screen(280, topV, 280, course: 4), screen(0, topV, 340, course: 4)]
    p.shape(copeShadow, Hue(r: 0, g: 0, b: 0, a: 0.55))
    iconExtrude(p, copeFront, depth: 230, leftToo: true, seed: rng.next(), age: 0.4)
    iconFace(p, copeFront, lit: 1.0, bed: .pi / 2, seed: rng.next(), age: 0.35, hatch: false)
    let cb = pathOf(copeFront).boundingBox
    p.gradientLine(pathOf(copeFront), from: pt(Double(cb.minX), Double(cb.minY)), to: pt(Double(cb.maxX), Double(cb.maxY)), Hue(r: 1, g: 0.95, b: 0.8, a: 0.2), Hue(r: 0, g: 0, b: 0, a: 0.36))
    iconRim(p, copeFront, weight: 4.2, rng: &rng)
    penEdge(p, copeFront, weight: 1.8, colour: Pot.shadowInk.al(0.8), seed: rng.next())

    let hx = Double(cb.midX) + 30, hy = Double(cb.minY) - 22
    let handleEnd = pt(hx + 300, hy + 400)
    let shadowHandle = handleRing(from: pt(hx + 26, hy + 46), to: pt(Double(handleEnd.x) + 30, Double(handleEnd.y) + 44), width: 50)
    p.shape(shadowHandle, Hue(r: 0, g: 0, b: 0, a: 0.45))
    let handle = handleRing(from: pt(hx, hy + 8), to: handleEnd, width: 50, taper: 0.72)
    let ash = Hue(r: 0.80, g: 0.64, b: 0.42)
    p.shape(handle, ash)
    p.gradientLine(pathOf(handle), from: pt(hx - 40, hy - 30), to: pt(hx + 40, hy + 40), ash.lt(0.38), ash.dk(0.5))
    let axis = atan2(Double(handleEnd.y) - hy, Double(handleEnd.x) - hx)
    streaks(p, pathOf(handle), count: 1800, angle: axis, light: Hue(r: 1, g: 0.92, b: 0.72, a: 0.25), dark: Hue(r: 0.30, g: 0.18, b: 0.08, a: 0.38), length: 10...70, weight: 0.5...1.4, seed: rng.next())
    let denseH = densify(handle, step: 3)
    for run in rimRunsOf(denseH, light: stoneLight, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 14, inset: 3, gate: 0.25) {
        rimStroke(p, run, weight: 9, colour: Hue(r: 1, g: 0.96, b: 0.85, a: 0.4), sharp: 0.8, wobble: 0.3, seed: rng.next())
        rimStroke(p, run, weight: 3.4, colour: Hue(r: 1, g: 0.98, b: 0.92, a: 0.9), sharp: 1.4, wobble: 0.2, seed: rng.next())
    }
    for run in rimRunsOf(denseH, light: stoneLight + .pi, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 14, inset: 2.5, gate: 0.25) {
        rimStroke(p, run, weight: 7, colour: Hue(r: 0.1, g: 0.05, b: 0.02, a: 0.6), sharp: 0.9, wobble: 0.2, seed: rng.next())
    }
    penEdge(p, handle, weight: 1.6, colour: Hue(r: 0.15, g: 0.08, b: 0.03, a: 0.85), seed: rng.next())
    let head = [pt(hx - 70, hy - 34), pt(hx + 86, hy - 12), pt(hx + 78, hy + 50), pt(hx - 78, hy + 30)]
    let headTop = [pt(hx - 70, hy - 34), pt(hx + 86, hy - 12), pt(hx + 56, hy - 48), pt(hx - 100, hy - 70)]
    let headEnd = [pt(hx - 70, hy - 34), pt(hx - 100, hy - 70), pt(hx - 190, hy - 20), pt(hx - 160, hy + 22), pt(hx - 78, hy + 30)]
    p.shape(offsetRing(head, 14, 24), Hue(r: 0, g: 0, b: 0, a: 0.55))
    let steel = Hue(r: 0.50, g: 0.52, b: 0.56)
    let faces: [([CGPoint], Double)] = [(headEnd, 0.8), (headTop, 1.35), (head, 0.95)]
    for (ring, lit) in faces {
        p.shape(ring, steel.dk(0.3))
        p.gradientLine(pathOf(ring), from: ring[0], to: ring[2], steel.lt(0.2 * lit), steel.dk(0.6 / lit))
        streaks(p, pathOf(ring), count: 1000, angle: 0.3, light: Hue(r: 1, g: 1, b: 1, a: 0.22), dark: Hue(r: 0.02, g: 0.02, b: 0.04, a: 0.4), length: 6...36, weight: 0.5...1.2, seed: rng.next())
        let dense = densify(ring, step: 3)
        for run in rimRunsOf(dense, light: stoneLight, enter: 0.30, leave: 0.05, window: 9, bridge: 12, minRun: 12, inset: 2.4, gate: 0.25) {
            rimStroke(p, run, weight: 5.5, colour: Hue(r: 0.95, g: 0.97, b: 1, a: 0.9), sharp: 1.2, wobble: 0.2, seed: rng.next())
        }
        penEdge(p, ring, weight: 1.5, colour: Hue(r: 0.03, g: 0.03, b: 0.05, a: 0.9), seed: rng.next())
    }
    p.egg(hx - 50, hy - 30, 30, 7, Hue(r: 1, g: 1, b: 1, a: 0.5))

    p.gradientLine(all, from: pt(120, 80), to: pt(1024, 1024), Hue(r: 1, g: 0.95, b: 0.82, a: 0.14), Hue(r: 0.01, g: 0.02, b: 0.03, a: 0.5))
    p.gradientRect(CGRect(x: 620, y: 0, width: 404, height: 1024), Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0.02, g: 0.03, b: 0.04, a: 0.5))
    softGlowAt(p, cx: 1010, cy: 1010, radius: 620, colour: Hue(r: 1, g: 0.78, b: 0.50), strength: 0.13)
    softGlowAt(p, cx: 40, cy: 30, radius: 560, colour: Hue(r: 1.0, g: 0.96, b: 0.85), strength: 0.16)
    filmGrain(p, amount: 6, seed: rng.next())
    p.radial(pt(400, 470), 860, Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.55), clip: all)
    p.writePNG(dir, "AppIcon-1024")
    sheetScale = previous
}
