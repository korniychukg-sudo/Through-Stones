import Foundation
import CoreGraphics

struct WallMap {
    var ox: Double
    var oy: Double
    var ppm: Double

    func at(_ x: Double, _ y: Double) -> CGPoint { pt(ox + x * ppm, oy - y * ppm) }
    func at(_ q: Pt) -> CGPoint { at(q.x, q.y) }
    func len(_ m: Double) -> Double { m * ppm }
}

func mapFor(_ w: Wall, box: CGRect, margin: Double = 0.16) -> WallMap {
    let heightM = w.height + 0.72 + w.feature.slopeRate * w.length
    let widthM = w.length + margin * 2
    let ppm = min(Double(box.width) / widthM, Double(box.height) / heightM)
    let ox = Double(box.midX) - w.length * 0.5 * ppm
    let oy = Double(box.maxY) - 0.16 * ppm
    return WallMap(ox: ox, oy: oy, ppm: ppm)
}

func hillBackdrop(_ p: Leaf, box: CGRect, seed: UInt64, sky: Hue = Pot.sky, hill: Hue = Pot.grass) {
    var rng = Chip(seed)
    p.insideRect(box) {
        p.gradientRect(box, sky.lt(0.15), sky.lt(0.45))
        var ridge: [CGPoint] = [pt(Double(box.minX) - 20, Double(box.maxY) + 20)]
        var x = Double(box.minX) - 20
        let base = Double(box.minY) + Double(box.height) * rng.r(0.30, 0.45)
        while x <= Double(box.maxX) + 20 {
            let y = base + sin(x * 0.006 + rng.r(0, 0.4)) * Double(box.height) * 0.08 + rng.signed() * 4
            ridge.append(pt(x, y))
            x += 36
        }
        ridge.append(pt(Double(box.maxX) + 20, Double(box.maxY) + 20))
        p.shape(ridge, hill.dk(0.22).mix(sky, 0.35))
        wash(p, ridge, hill.dk(0.1), strength: 0.35, bleed: 4, seed: rng.next())
        var near: [CGPoint] = [pt(Double(box.minX) - 20, Double(box.maxY) + 20)]
        x = Double(box.minX) - 20
        let base2 = Double(box.minY) + Double(box.height) * rng.r(0.58, 0.68)
        while x <= Double(box.maxX) + 20 {
            near.append(pt(x, base2 + sin(x * 0.009 + 1.3) * Double(box.height) * 0.05 + rng.signed() * 3))
            x += 40
        }
        near.append(pt(Double(box.maxX) + 20, Double(box.maxY) + 20))
        p.shape(near, hill)
        wash(p, near, hill.lt(0.08), strength: 0.4, bleed: 5, seed: rng.next())
        hairs(p, pathOf(near), count: 260, length: 9, weight: 0.8, spread: 0.5, colour: Pot.grassDeep.al(0.55), seed: rng.next())
    }
}

func groundBand(_ p: Leaf, map: WallMap, wall: Wall, box: CGRect, seed: UInt64) {
    var rng = Chip(seed)
    var top: [CGPoint] = []
    var x = Double(box.minX) - 10
    while x <= Double(box.maxX) + 10 {
        let xm = (x - map.ox) / map.ppm
        let g = wall.feature.slopeRate * (wall.length - xm)
        top.append(pt(x, map.at(0, g).y + rng.signed() * 2))
        x += 24
    }
    let region = [pt(Double(box.minX) - 10, Double(box.maxY) + 10)] + top + [pt(Double(box.maxX) + 10, Double(box.maxY) + 10)]
    p.insideRect(box) {
        p.shape(region, Pot.grassDeep)
        wash(p, region, Pot.grass, strength: 0.5, bleed: 4, seed: rng.next())
        hairs(p, pathOf(region), count: 320, length: 12, weight: 0.9, spread: 0.55, colour: Pot.grassDeep.dk(0.2).al(0.6), seed: rng.next())
        for q in top.prefix(top.count) where rng.chance(0.5) {
            hairs(p, rectPath(Double(q.x) - 12, Double(q.y) - 22, 24, 26), count: 5, length: 16, weight: 1.0, spread: 0.45, colour: Pot.grassDeep.al(0.7), seed: rng.next())
        }
    }
}

func drawPin(_ p: Leaf, at c: CGPoint, size: Double, kind: StoneKind, seed: UInt64) {
    let ch = chordOf(kind)
    let tri = [pt(Double(c.x) - size, Double(c.y) + size * 0.4), pt(Double(c.x) + size, Double(c.y) + size * 0.5), pt(Double(c.x) + size * 0.3, Double(c.y) - size * 0.35)]
    p.shape(tri, ch.shadow)
    penOutline(p, tri, weight: 0.8, colour: Pot.ink.al(0.7), seed: seed)
}

func heartingTexture(_ p: Leaf, _ clip: CGPath, kind: StoneKind, seed: UInt64, scale: Double) {
    var rng = Chip(seed)
    let ch = chordOf(kind)
    let box = clip.boundingBox
    p.inside(clip) {
        p.box(Double(box.minX), Double(box.minY), Double(box.width), Double(box.height), ch.shadow.dk(0.12))
        let n = Int(Double(box.width * box.height) / (40 * scale * scale))
        for _ in 0..<min(6000, n) {
            let x = Double(box.minX) + rng.d() * Double(box.width)
            let y = Double(box.minY) + rng.d() * Double(box.height)
            let r = rng.r(2, 6) * scale
            let ring = lumpy(cx: x, cy: y, rx: r, ry: r * rng.r(0.5, 0.9), rough: 0.3, steps: 7, seed: rng.next())
            p.shape(ring, ch.body.dk(rng.r(0.1, 0.5)))
            p.shape(scaledRing(offsetRing(ring, -r * 0.2, -r * 0.2), about: pt(x, y), 0.5), ch.light.al(0.25))
        }
    }
}

func drawElevation(_ p: Leaf, wall: Wall, map: WallMap, age: Double, frame: Bool, line: Bool, joints: [JointMark] = [], lost: Set<Int> = [], sag: [Int: Double] = [:], seed: UInt64) {
    var rng = Chip(seed)
    let placed = wall.placed.filter { !lost.contains($0.id) }
    guard !placed.isEmpty else { return }
    var minX = Double.infinity, maxX = -Double.infinity, top = 0.0
    for s in placed {
        let b = Geometry.bounds(s.polygon)
        minX = min(minX, b.minX); maxX = max(maxX, b.maxX); top = max(top, b.maxY)
    }
    let coreRect = CGRect(x: map.at(minX, 0).x, y: map.at(0, top).y, width: map.len(maxX - minX), height: map.len(top + wall.trenchDepth))
    heartingTexture(p, CGPath(rect: coreRect, transform: nil), kind: wall.kind, seed: rng.next(), scale: map.ppm / 420)
    for o in wall.openings {
        let r = CGRect(x: map.at(o.x0, 0).x, y: map.at(0, min(o.y1, wall.height)).y, width: map.len(o.width), height: map.len(min(o.y1, wall.height) - max(o.y0, -0.01)))
        p.gradientRect(r, Pot.sky.mix(Pot.grass, 0.4), Pot.grass.dk(0.2))
    }
    for s in placed.sorted(by: { $0.y < $1.y }) {
        let dy = sag[s.id] ?? 0
        let poly = s.polygon.map { map.at($0.x, $0.y - dy) }
        let bed = s.cls == .cope && wall.rules.cope != .flat ? -s.tilt + .pi / 2 : -s.tilt
        paintStone(p, poly: poly, kind: s.kind, seed: s.seed &+ 3, age: age, bed: bed, wet: 0, ink: true, hatch: map.ppm > 200)
        if s.pinned, let px = s.pinX {
            let b = Geometry.bounds(s.polygon)
            let c = map.at(px, b.minY - dy)
            drawPin(p, at: pt(Double(c.x), Double(c.y) + map.len(0.012)), size: map.len(0.028), kind: s.kind, seed: rng.next())
        }
    }
    if wall.rules.cope == .locked {
        for lx in wall.locks {
            let c = map.at(lx, top - 0.06)
            drawPin(p, at: c, size: map.len(0.03), kind: wall.kind, seed: rng.next())
        }
    }
    if wall.rules.cope == .turf && wall.turfLaid > 0.05 {
        let y = map.at(0, wall.topMedian).y
        let turf = [pt(map.at(0, 0).x, y + map.len(0.02)), pt(map.at(wall.length * wall.turfLaid, 0).x, y + map.len(0.02)),
                    pt(map.at(wall.length * wall.turfLaid, 0).x, y - map.len(0.12)), pt(map.at(0, 0).x, y - map.len(0.12))]
        p.shape(turf, Pot.grassDeep)
        wash(p, turf, Pot.grass, strength: 0.5, bleed: 3, seed: rng.next())
        hairs(p, pathOf(offsetRing(turf, 0, -map.len(0.06))), count: 160, length: map.len(0.09), weight: 1.0, spread: 0.5, colour: Pot.grassDeep.al(0.8), seed: rng.next())
    }
    for j in joints {
        let a = map.at(j.x, j.y0), b = map.at(j.x, j.y1)
        pen(p, [a, b], weight: 3.2, colour: Pot.rubric.al(0.85), wobble: 0.6, taper: false, seed: rng.next())
    }
    if frame {
        for end in [0.0, wall.length] {
            let lean = wall.frameSet ? wall.batterSet : (wall.rules.batter.lowerBound + wall.rules.batter.upperBound) * 0.5
            let baseHalf = wall.rules.baseWidth * 0.5
            let topHalf = max(0.12, baseHalf - lean * (wall.height + 0.2))
            let foot = map.at(end, -0.02)
            let head = map.at(end, wall.height + 0.25)
            let spreadBase = map.len(baseHalf) * 0.45
            let spreadTop = map.len(topHalf) * 0.45
            let legL = [pt(Double(foot.x) - spreadBase, Double(foot.y)), pt(Double(head.x) - spreadTop, Double(head.y))]
            let legR = [pt(Double(foot.x) + spreadBase, Double(foot.y)), pt(Double(head.x) + spreadTop, Double(head.y))]
            for leg in [legL, legR] {
                pen(p, leg, weight: map.len(0.022), colour: Pot.woodDark, wobble: 0.3, taper: false, seed: rng.next())
                pen(p, leg, weight: map.len(0.010), colour: Pot.wood.lt(0.2), wobble: 0.3, taper: true, seed: rng.next())
            }
            for f in [0.25, 0.55, 0.85] {
                let y = Double(foot.y) + (Double(head.y) - Double(foot.y)) * f
                let hx = spreadBase + (spreadTop - spreadBase) * f
                pen(p, [pt(Double(foot.x) - hx, y), pt(Double(foot.x) + hx, y)], weight: map.len(0.016), colour: Pot.woodDark, wobble: 0.3, taper: false, seed: rng.next())
            }
        }
    }
    if line && wall.lineHeight > 0.02 {
        let y = map.at(0, wall.lineHeight).y
        p.rule(pt(map.at(-0.02, 0).x, y), pt(map.at(wall.length + 0.02, 0).x, y), 1.4, Hue(r: 0.95, g: 0.90, b: 0.72).al(0.95))
        p.rule(pt(map.at(-0.02, 0).x, y + 1.2), pt(map.at(wall.length + 0.02, 0).x, y + 1.2), 1.0, Pot.ink.al(0.35))
    }
}

func drawSection(_ p: Leaf, wall: Wall, at centre: CGPoint, ppm: Double, age: Double, labels: Bool, seed: UInt64) {
    var rng = Chip(seed)
    let r = wall.rules
    let lean = wall.frameSet ? wall.batterSet : (r.batter.lowerBound + r.batter.upperBound) * 0.5
    let height = wall.height
    let map = WallMap(ox: Double(centre.x), oy: Double(centre.y), ppm: ppm)
    func halfWidth(_ y: Double) -> Double {
        if r.form == .flags { return r.baseWidth * 0.5 }
        return max(r.topWidth * 0.5, r.baseWidth * 0.5 - lean * max(0, y))
    }
    let depth = wall.trenchDepth
    let ground = [pt(map.at(-1.4, 0).x, map.at(0, 0).y), pt(map.at(1.4, 0).x, map.at(0, 0).y), pt(map.at(1.4, 0).x, map.at(0, -0.26).y), pt(map.at(-1.4, 0).x, map.at(0, -0.26).y)]
    p.shape(ground, Pot.earth)
    wash(p, ground, Pot.earthDeep, strength: 0.4, bleed: 4, seed: rng.next())
    grit(p, pathOf(ground), density: 0.02, sizeMin: 0.6, sizeMax: 1.8, colour: Pot.earthDeep.al(0.6), seed: rng.next())
    let trench = [map.at(-halfWidth(0) - 0.08, 0.0), map.at(halfWidth(0) + 0.08, 0.0), map.at(halfWidth(0) + 0.08, -depth), map.at(-halfWidth(0) - 0.08, -depth)]
    p.shape(trench, Pot.earthDeep.dk(0.2))
    var outline: [CGPoint] = []
    let steps = 12
    for k in 0...steps {
        let y = -depth + (height + depth) * Double(k) / Double(steps)
        outline.append(map.at(-halfWidth(max(0, y)), y))
    }
    for k in stride(from: steps, through: 0, by: -1) {
        let y = -depth + (height + depth) * Double(k) / Double(steps)
        outline.append(map.at(halfWidth(max(0, y)), y))
    }
    let profile = pathOf(outline)
    if r.core == .earth {
        p.inside(profile) {
            p.gradientRect(profile.boundingBox, Pot.earth.lt(0.1), Pot.earthDeep)
            grit(p, profile, density: 0.03, sizeMin: 0.7, sizeMax: 2.0, colour: Pot.earthDeep.al(0.7), seed: rng.next())
        }
    } else if r.core != .none {
        heartingTexture(p, profile, kind: wall.kind, seed: rng.next(), scale: ppm / 420)
    }
    let structural = wall.placed.filter { $0.cls != .cope }.sorted { $0.y < $1.y }
    let sample = structural.filter { $0.x > wall.length * 0.30 && $0.x < wall.length * 0.70 }
    let chosen = sample.isEmpty ? structural : sample
    var drawn: [(Double, Double)] = []
    for s in chosen {
        let b = Geometry.bounds(s.polygon)
        if drawn.contains(where: { abs($0.0 - b.minY) < 0.03 && abs($0.1 - b.maxY) < 0.03 }) { continue }
        drawn.append((b.minY, b.maxY))
        let yMid = (b.minY + b.maxY) * 0.5
        let hw = halfWidth(max(0, yMid))
        let reach = min(s.reach, hw * 2)
        let isSingle = r.form == .doubleThenSingle && yMid > wall.doubleTop
        let flags = r.form == .flags
        if flags {
            let poly = [map.at(-hw, b.minY), map.at(hw, b.minY), map.at(hw, b.maxY), map.at(-hw, b.maxY)]
            paintStone(p, poly: poly, kind: s.kind, seed: s.seed &+ 11, age: age, bed: .pi / 2, ink: true, hatch: false)
            continue
        }
        if isSingle || (s.cls == .through && s.orientation == .lengthIn) {
            let poly = [map.at(-hw, b.minY), map.at(hw, b.minY), map.at(hw, b.maxY), map.at(-hw, b.maxY)]
            paintStone(p, poly: poly, kind: s.kind, seed: s.seed &+ 11, age: age, bed: 0, ink: true, hatch: false)
            if s.cls == .through && r.form != .doubleThenSingle {
                let over = min(0.06, max(0, s.reach - hw * 2) * 0.5)
                let proud = [map.at(-hw - over, b.minY + 0.005), map.at(-hw, b.minY + 0.005), map.at(-hw, b.maxY - 0.005), map.at(-hw - over, b.maxY - 0.005)]
                if over > 0.01 { paintStone(p, poly: proud, kind: s.kind, seed: s.seed &+ 12, age: age, ink: true, hatch: false) }
            }
            continue
        }
        let front = [map.at(-hw, b.minY), map.at(-hw + reach, b.minY + 0.006), map.at(-hw + reach, b.maxY - 0.006), map.at(-hw, b.maxY)]
        paintStone(p, poly: front, kind: s.kind, seed: s.seed &+ 11, age: age, bed: 0, ink: true, hatch: false)
        let backReach = min(hw * 2 - reach - 0.04, rng.r(0.22, 0.42))
        if backReach > 0.08 {
            let back = [map.at(hw - backReach, b.minY + 0.006), map.at(hw, b.minY), map.at(hw, b.maxY), map.at(hw - backReach, b.maxY - 0.006)]
            paintStone(p, poly: back, kind: s.kind, seed: s.seed &+ 13, age: age, bed: 0, ink: true, hatch: false)
        }
    }
    let topY = wall.topMedian
    let copes = wall.copesPlaced
    if let c = copes.first, r.cope != .turf, r.cope != .none {
        let b = Geometry.bounds(c.polygon)
        let hw = halfWidth(topY) + 0.04
        let ch = b.maxY - b.minY
        let poly = [map.at(-hw, topY), map.at(hw, topY), map.at(hw * 0.92, topY + ch), map.at(-hw * 0.92, topY + ch)]
        paintStone(p, poly: poly, kind: c.kind, seed: c.seed &+ 15, age: age, bed: r.cope == .flat ? 0 : .pi / 2, ink: true, hatch: false)
    } else if r.cope == .turf {
        let hw = halfWidth(topY)
        let turf = [map.at(-hw - 0.05, topY), map.at(hw + 0.05, topY), map.at(hw, topY + 0.14), map.at(-hw, topY + 0.14)]
        p.shape(turf, Pot.grassDeep)
        wash(p, turf, Pot.grass, strength: 0.5, bleed: 3, seed: rng.next())
        hairs(p, pathOf(offsetRing(turf, 0, -ppm * 0.06)), count: 60, length: ppm * 0.08, weight: 1.0, spread: 0.5, colour: Pot.grassDeep.al(0.8), seed: rng.next())
    }
    p.light = stoneLight
    penOutline(p, outline, weight: 1.6, colour: Pot.ink.al(0.6), seed: rng.next())
    if labels {
        let lx = map.at(halfWidth(0) + 0.32, 0).x
        func label(_ text: String, _ y: Double, _ fromX: Double) {
            let a = map.at(fromX, y), b = pt(lx - 8, map.at(0, y).y)
            p.rule(a, b, 1.0, Pot.ink.al(0.6))
            p.dot(Double(a.x), Double(a.y), 2.5, Pot.ink.al(0.8))
            letter(p, text, at: lx, map.at(0, y).y + 6, size: 19, colour: Pot.ink, face: "Georgia-Italic", align: .left)
        }
        if r.core == .hearting { label("hearting", height * 0.28, 0) }
        if r.core == .earth { label("rammed earth", height * 0.32, 0) }
        if r.wantsThroughs || r.form == .doubleThenSingle { label(r.form == .doubleThenSingle ? "cover band" : "through", r.form == .doubleThenSingle ? wall.doubleTop : height * 0.5, halfWidth(height * 0.5) * 0.6) }
        if r.cope != .none { label(r.cope == .turf ? "turf top" : "cope", topY + 0.12, halfWidth(topY) * 0.5) }
        label("footing", 0.06, halfWidth(0) * 0.5)
        if r.batter.upperBound > 0.03 {
            let a = map.at(-halfWidth(0) - 0.04, 0), b = map.at(-halfWidth(height) - 0.04, height)
            p.rule(a, b, 1.0, Pot.rubric.al(0.7), dash: [6, 5])
            letter(p, "batter \(batterWords(lean))", at: Double(map.at(-halfWidth(height) - 0.36, height).x), Double(b.y) + 6, size: 19, colour: Pot.rubric, face: "Georgia-Italic", align: .right)
        }
    }
}

func batterWords(_ lean: Double) -> String {
    guard lean > 0.005 else { return "plumb" }
    let ratio = Int((1.0 / lean).rounded())
    return "one in \(ratio)"
}

func plateWall(style: WallStyle, feature: WallFeature, length: Double = 2.2) -> Wall {
    let kind = style.nativeKinds[0]
    let c = WallBuilder.free(style: style, feature: feature, kind: kind, length: length, height: style.rules.typicalHeight, seed: hashOf("plate.\(style.rawValue).\(feature.rawValue)"))
    return WallBuilder.reference(c, attempts: 3)
}

func drawStylePlates(_ style: WallStyle, dir: String) {
    let entry = StoneLore.style(style)
    let wall = plateWall(style: style, feature: .straightRun)
    do {
        let p = Leaf(1200, 900)
        let seed = hashOf("sy_face_\(style.rawValue)")
        plateGround(p, seed: seed, tone: Pot.paperWarm)
        p.light = stoneLight
        let box = CGRect(x: 70, y: 70, width: 1060, height: 640)
        hillBackdrop(p, box: box, seed: seed &+ 1)
        let map = mapFor(wall, box: box.insetBy(dx: 20, dy: 10))
        drawElevation(p, wall: wall, map: map, age: 0.2, frame: false, line: false, seed: seed &+ 2)
        groundBand(p, map: map, wall: wall, box: box, seed: seed &+ 3)
        penOutline(p, [pt(70, 70), pt(1130, 70), pt(1130, 710), pt(70, 710)], weight: 1.6, colour: Pot.ink.al(0.7), seed: seed &+ 4)
        plateCaption(p, title: style.name, sub: entry.region, y: 740)
        p.writeJPG(dir, "sy_face_\(style.rawValue)")
    }
    do {
        let p = Leaf(1200, 900)
        let seed = hashOf("sy_sec_\(style.rawValue)")
        plateGround(p, seed: seed, tone: Pot.paperCool)
        p.light = stoneLight
        let ppm = min(320.0, 540.0 / (wall.height + 0.55))
        drawSection(p, wall: wall, at: pt(560, 650), ppm: ppm, age: 0.15, labels: true, seed: seed &+ 2)
        plateCaption(p, title: "\(style.shortName): the section", sub: entry.rules.prefix(3).joined(separator: "; "), y: 740, titleSize: 36)
        p.writeJPG(dir, "sy_sec_\(style.rawValue)")
    }
}

func featureStyle(_ f: WallFeature) -> WallStyle {
    switch f {
    case .straightRun: return .dales
    case .cheekEnd: return .dales
    case .corner: return .kentucky
    case .gatePost: return .kentucky
    case .squeezeStile: return .cotswold
    case .stepStile: return .dales
    case .lunky: return .dales
    case .curve: return .newEngland
    case .slope: return .dales
    case .retaining: return .cotswold
    case .beeBole: return .cotswold
    }
}

func drawFeaturePlate(_ feature: WallFeature, dir: String) {
    let entry = StoneLore.feature(feature)
    let style = featureStyle(feature)
    let wall = plateWall(style: style, feature: feature, length: feature == .curve ? 2.4 : 2.2)
    let p = Leaf(1200, 900)
    let seed = hashOf("fe_\(feature.rawValue)")
    plateGround(p, seed: seed, tone: Pot.paperWarm)
    p.light = stoneLight
    let box = CGRect(x: 70, y: 70, width: 1060, height: 640)
    hillBackdrop(p, box: box, seed: seed &+ 1)
    let map = mapFor(wall, box: box.insetBy(dx: 20, dy: 10))
    drawElevation(p, wall: wall, map: map, age: 0.12, frame: feature == .straightRun, line: false, seed: seed &+ 2)
    groundBand(p, map: map, wall: wall, box: box, seed: seed &+ 3)
    if feature == .gatePost {
        p.insideRect(box) {
            let gx = map.at(wall.length + 0.06, 0).x
            let barHeights: [Double] = [0.25, 0.55, 0.85]
            for i in 0..<3 {
                let y = barHeights[i]
                let a = pt(Double(gx), map.at(0, y).y)
                pen(p, [a, pt(Double(gx) + map.len(0.9), map.at(0, y - 0.02).y)], weight: map.len(0.05), colour: Pot.woodDark.al(0.9), wobble: 0.4, taper: false, seed: seed &+ UInt64(10 + i))
            }
            pen(p, [pt(Double(gx) + map.len(0.9), map.at(0, 0.1).y), pt(Double(gx) + map.len(0.9), map.at(0, 1.0).y)], weight: map.len(0.06), colour: Pot.woodDark, wobble: 0.4, taper: false, seed: seed &+ 20)
        }
    }
    penOutline(p, [pt(70, 70), pt(1130, 70), pt(1130, 710), pt(70, 710)], weight: 1.6, colour: Pot.ink.al(0.7), seed: seed &+ 4)
    plateCaption(p, title: feature.name, sub: entry.why, y: 740, titleSize: 36)
    p.writeJPG(dir, "fe_\(feature.rawValue)")
}
