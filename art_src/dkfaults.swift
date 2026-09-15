import Foundation
import CoreGraphics

struct DiaStone {
    var x: Double
    var y: Double
    var w: Double
    var h: Double
    var bed: Double = 0
    var marked: Bool = false
    var cls: StoneClass = .builder
    var tilt: Double = 0
}

func diaPolygon(_ s: DiaStone, map: WallMap, seed: UInt64) -> [CGPoint] {
    let c = map.at(s.x + s.w * 0.5, s.y + s.h * 0.5)
    return stonePolygon(kind: .gritstone, cls: s.cls, seed: seed, width: map.len(s.w) - 3, height: map.len(s.h) - 3, at: c, tilt: s.tilt)
}

func layCourses(_ courses: [[(Double, Double)]], gap: Double = 0.012, startX: Double = 0, offsets: [Double] = []) -> [DiaStone] {
    var out: [DiaStone] = []
    var y = 0.0
    for (k, course) in courses.enumerated() {
        var x = startX + (k < offsets.count ? offsets[k] : 0)
        var tallest = 0.0
        for (w, h) in course {
            out.append(DiaStone(x: x, y: y, w: w, h: h))
            x += w + gap
            tallest = max(tallest, h)
        }
        y += tallest + 0.008
    }
    return out
}

func paintDiagram(_ p: Leaf, stones: [DiaStone], map: WallMap, kind: StoneKind, seed: UInt64, core: Bool = true) {
    var rng = Chip(seed)
    if core, let minX = stones.map({ $0.x }).min(), let maxX = stones.map({ $0.x + $0.w }).max(), let top = stones.map({ $0.y + $0.h }).max() {
        let rect = CGRect(x: map.at(minX, 0).x, y: map.at(0, top).y, width: map.len(maxX - minX), height: map.len(top + 0.02))
        heartingTexture(p, CGPath(rect: rect, transform: nil), kind: kind, seed: rng.next(), scale: map.ppm / 420)
    }
    for s in stones {
        let poly = diaPolygon(s, map: map, seed: rng.next())
        paintStone(p, poly: poly, kind: kind, seed: rng.next(), age: 0.08, bed: s.bed - s.tilt, ink: true, hatch: true)
    }
}

func markRect(_ p: Leaf, map: WallMap, x: Double, y: Double, w: Double, h: Double, seed: UInt64) {
    let ring = [map.at(x - 0.03, y - 0.03), map.at(x + w + 0.03, y - 0.03), map.at(x + w + 0.03, y + h + 0.03), map.at(x - 0.03, y + h + 0.03)]
    penOutline(p, ring, weight: 3.0, colour: Pot.rubric.al(0.9), seed: seed)
}

func markLine(_ p: Leaf, _ a: CGPoint, _ b: CGPoint, seed: UInt64) {
    pen(p, [a, b], weight: 3.6, colour: Pot.rubric.al(0.9), wobble: 0.5, taper: false, seed: seed)
}

func drawFaultPlate(_ kind: FaultKind, dir: String) {
    let entry = StoneLore.fault(kind)
    let p = Leaf(1200, 900)
    let seed = hashOf("ft_\(kind.rawValue)")
    var rng = Chip(seed)
    plateGround(p, seed: seed, tone: Pot.paperWarm)
    p.light = stoneLight
    let box = CGRect(x: 90, y: 80, width: 1020, height: 600)
    let stone: StoneKind = .gritstone
    switch kind {
    case .runningJoint:
        let map = WallMap(ox: 250, oy: 660, ppm: 400)
        let courses: [[(Double, Double)]] = [
            [(0.42, 0.20), (0.36, 0.20), (0.38, 0.20), (0.34, 0.20)],
            [(0.30, 0.16), (0.48, 0.16), (0.38, 0.16), (0.34, 0.16)],
            [(0.30, 0.15), (0.48, 0.15), (0.30, 0.15), (0.42, 0.15)],
            [(0.30, 0.17), (0.48, 0.17), (0.34, 0.17), (0.38, 0.17)]
        ]
        let stones = layCourses(courses)
        paintDiagram(p, stones: stones, map: map, kind: stone, seed: rng.next())
        let jx = 0.30 + 0.012 + 0.48 + 0.006
        markLine(p, map.at(jx, 0.20), map.at(jx, 0.20 + 0.16 + 0.15 + 0.17 + 0.03), seed: rng.next())
        letter(p, "the same joint through three courses", at: map.at(jx, 0.75).x, map.at(0, 0.78).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .faceBedded:
        let map = WallMap(ox: 250, oy: 660, ppm: 400)
        var stones = layCourses([
            [(0.40, 0.19), (0.36, 0.19), (0.44, 0.19), (0.32, 0.19)],
            [(0.30, 0.15), (0.34, 0.15), (0.50, 0.15), (0.36, 0.15)],
            [(0.36, 0.16), (0.58, 0.16), (0.28, 0.16), (0.30, 0.16)]
        ])
        stones[9].bed = .pi / 2
        stones[9].marked = true
        paintDiagram(p, stones: stones, map: map, kind: .sandstone, seed: rng.next())
        markRect(p, map: map, x: stones[9].x, y: stones[9].y, w: stones[9].w, h: stones[9].h, seed: rng.next())
        letter(p, "the bed turned out to make the face", at: map.at(stones[9].x + 0.29, 0).x, map.at(0, stones[9].y + stones[9].h + 0.14).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .hollowCore, .noThroughs, .belly, .wrongBatter, .poorFooting:
        drawSectionFault(p, kind: kind, seed: rng.next())
    case .onEdge:
        let map = WallMap(ox: 250, oy: 660, ppm: 400)
        var stones = layCourses([
            [(0.40, 0.19), (0.36, 0.19), (0.44, 0.19), (0.32, 0.19)],
            [(0.30, 0.16), (0.34, 0.16), (0.14, 0.34), (0.36, 0.16), (0.30, 0.16)],
            [(0.36, 0.16), (0.30, 0.16), (0.28, 0.16), (0.30, 0.16)]
        ])
        stones[6].bed = .pi / 2
        stones[8].y += 0.0
        for i in [8, 9, 10, 11] where i < stones.count { stones[i].x += 0.0 }
        paintDiagram(p, stones: stones, map: map, kind: .sandstone, seed: rng.next())
        let s = stones[6]
        markRect(p, map: map, x: s.x, y: s.y, w: s.w, h: s.h, seed: rng.next())
        for k in 0..<3 {
            let cx = s.x + s.w * (0.3 + Double(k) * 0.2)
            pen(p, [map.at(cx, s.y + s.h - 0.02), map.at(cx + 0.01, s.y + s.h * 0.4)], weight: 2.2, colour: Pot.ink.al(0.8), wobble: 1.2, taper: true, seed: rng.next())
        }
        letter(p, "beds standing upright; frost splits them", at: map.at(s.x + 0.07, 0).x, map.at(0, s.y + s.h + 0.14).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .looseCope:
        let map = WallMap(ox: 250, oy: 660, ppm: 400)
        var stones = layCourses([
            [(0.40, 0.19), (0.36, 0.19), (0.44, 0.19), (0.32, 0.19)],
            [(0.30, 0.16), (0.34, 0.16), (0.50, 0.16), (0.36, 0.16)]
        ])
        let top = 0.19 + 0.008 + 0.16 + 0.008
        let copes: [(Double, Double, Double)] = [(0.02, 0.14, 0.0), (0.17, 0.12, 0.0), (0.40, 0.13, 0.0), (0.55, 0.15, -0.25), (0.82, 0.13, 0.0), (0.97, 0.12, 0.0), (1.20, 0.14, 0.0), (1.36, 0.13, 0.0)]
        for c in copes { stones.append(DiaStone(x: c.0, y: top, w: c.1, h: 0.28, bed: .pi / 2, cls: .cope, tilt: c.2)) }
        paintDiagram(p, stones: stones, map: map, kind: stone, seed: rng.next())
        markRect(p, map: map, x: 0.29, y: top, w: 0.11, h: 0.28, seed: rng.next())
        markRect(p, map: map, x: 1.10, y: top, w: 0.10, h: 0.28, seed: rng.next())
        markRect(p, map: map, x: 0.55, y: top, w: 0.16, h: 0.30, seed: rng.next())
        letter(p, "gaps, and one leaning: the first ewe has them over", at: map.at(0.75, 0).x, map.at(0, top + 0.42).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .traced:
        let map = WallMap(ox: 250, oy: 660, ppm: 400)
        var stones = layCourses([
            [(0.40, 0.19), (0.36, 0.19), (0.44, 0.19), (0.32, 0.19)],
            [(0.30, 0.15), (0.62, 0.11), (0.28, 0.15), (0.32, 0.15)],
            [(0.36, 0.16), (0.30, 0.16), (0.42, 0.16), (0.44, 0.16)]
        ])
        stones[5].marked = true
        paintDiagram(p, stones: stones, map: map, kind: stone, seed: rng.next())
        markRect(p, map: map, x: stones[5].x, y: stones[5].y, w: stones[5].w, h: stones[5].h, seed: rng.next())
        letter(p, "length along the face: it holds nothing", at: map.at(stones[5].x + 0.31, 0).x, map.at(0, 0.75).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
        let ix = 1040.0, iy = 300.0
        let plan = [pt(ix - 120, iy), pt(ix + 40, iy), pt(ix + 40, iy + 110), pt(ix - 120, iy + 110)]
        p.shape(plan, Pot.paperDeep)
        penOutline(p, plan, weight: 1.2, colour: Pot.ink.al(0.6), seed: rng.next())
        let traced = [pt(ix - 112, iy + 8), pt(ix + 32, iy + 8), pt(ix + 32, iy + 30), pt(ix - 112, iy + 30)]
        let good = [pt(ix - 40, iy + 40), pt(ix - 10, iy + 40), pt(ix - 10, iy + 104), pt(ix - 40, iy + 104)]
        paintStone(p, poly: traced, kind: stone, seed: rng.next(), ink: true, hatch: false)
        paintStone(p, poly: good, kind: stone, seed: rng.next(), ink: true, hatch: false)
        letter(p, "plan: face at the bottom", at: ix - 40, iy - 12, size: 16, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
        letter(p, "traced", at: ix + 46, iy + 24, size: 16, colour: Pot.rubric, face: "Georgia-Italic", align: .left)
        letter(p, "length in", at: ix + 46, iy + 78, size: 16, colour: Pot.inkSoft, face: "Georgia-Italic", align: .left)
    case .badHead:
        let map = WallMap(ox: 250, oy: 660, ppm: 400)
        let stones = layCourses([
            [(0.40, 0.19), (0.36, 0.19), (0.44, 0.19), (0.20, 0.19)],
            [(0.30, 0.15), (0.34, 0.15), (0.50, 0.15), (0.18, 0.15)],
            [(0.36, 0.16), (0.30, 0.16), (0.42, 0.16), (0.14, 0.16)],
            [(0.30, 0.15), (0.36, 0.15), (0.34, 0.15), (0.22, 0.15)]
        ])
        paintDiagram(p, stones: stones, map: map, kind: stone, seed: rng.next())
        let hx = 1.41
        for k in 0..<4 {
            let s = stones[k * 4 + 3]
            markRect(p, map: map, x: s.x, y: s.y, w: s.w, h: s.h, seed: rng.next())
        }
        pen(p, [map.at(hx + 0.10, -0.02), map.at(hx + 0.10, 0.72)], weight: 2.0, colour: Pot.ink.al(0.7), wobble: 0.3, taper: false, seed: rng.next())
        letter(p, "plumb line", at: map.at(hx + 0.13, 0).x, map.at(0, 0.70).y, size: 16, colour: Pot.inkSoft, face: "Georgia-Italic", align: .left)
        letter(p, "short stones all laid the same way; the end unzips", at: map.at(0.75, 0).x, map.at(0, 0.78).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .pinFront:
        let map = WallMap(ox: 250, oy: 660, ppm: 400)
        let stones = layCourses([
            [(0.40, 0.19), (0.36, 0.19), (0.44, 0.19), (0.32, 0.19)],
            [(0.30, 0.15), (0.34, 0.15), (0.50, 0.15), (0.36, 0.15)],
            [(0.36, 0.16), (0.30, 0.16), (0.42, 0.16), (0.44, 0.16)]
        ])
        paintDiagram(p, stones: stones, map: map, kind: stone, seed: rng.next())
        let s = stones[6]
        let pinAt = map.at(s.x + s.w * 0.75, s.y + 0.01)
        let wedge = [pt(Double(pinAt.x) - 16, Double(pinAt.y) + 3), pt(Double(pinAt.x) + 18, Double(pinAt.y) + 6), pt(Double(pinAt.x) + 12, Double(pinAt.y) - 12)]
        paintStone(p, poly: wedge, kind: stone, seed: rng.next(), ink: true, hatch: false)
        markRect(p, map: map, x: s.x + s.w * 0.55, y: s.y - 0.04, w: s.w * 0.4, h: 0.08, seed: rng.next())
        letter(p, "a pin showing in the face: kicked out within the year", at: map.at(0.75, 0).x, map.at(0, 0.75).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    }
    penOutline(p, [pt(Double(box.minX), Double(box.minY)), pt(Double(box.maxX), Double(box.minY)), pt(Double(box.maxX), Double(box.maxY)), pt(Double(box.minX), Double(box.maxY))], weight: 1.4, colour: Pot.ink.al(0.5), seed: seed &+ 4)
    plateCaption(p, title: kind.name, sub: entry.what, y: 720, titleSize: 36)
    p.writeJPG(dir, "ft_\(kind.rawValue)")
}

func drawSectionFault(_ p: Leaf, kind: FaultKind, seed: UInt64) {
    var rng = Chip(seed)
    let map = WallMap(ox: 600, oy: 640, ppm: 380)
    let H = 1.3
    let ground = [map.at(-1.2, 0), map.at(1.2, 0), map.at(1.2, -0.22), map.at(-1.2, -0.22)]
    p.shape(ground, Pot.earth)
    wash(p, ground, Pot.earthDeep, strength: 0.4, bleed: 4, seed: rng.next())
    let lean = kind == .wrongBatter ? 0.0 : 0.14
    func hw(_ y: Double) -> Double { max(0.2, 0.42 - lean * y) }
    let bulge = kind == .belly || kind == .noThroughs
    func faceX(_ y: Double, _ side: Double) -> Double {
        var x = hw(y) * side
        if bulge { x += side * 0.14 * sin(.pi * min(1, max(0, (y - 0.35) / 0.9))) }
        return x
    }
    var outline: [CGPoint] = []
    for k in 0...16 { let y = -0.14 + (H + 0.14) * Double(k) / 16; outline.append(map.at(faceX(max(0, y), -1), y)) }
    for k in stride(from: 16, through: 0, by: -1) { let y = -0.14 + (H + 0.14) * Double(k) / 16; outline.append(map.at(faceX(max(0, y), 1), y)) }
    let profile = pathOf(outline)
    if kind == .hollowCore {
        p.inside(profile) {
            p.box(Double(profile.boundingBox.minX), Double(profile.boundingBox.minY), Double(profile.boundingBox.width), Double(profile.boundingBox.height), Pot.earthDeep.dk(0.4))
            for _ in 0..<26 {
                let x = rng.r(-0.18, 0.18), y = rng.r(0.05, 0.5)
                let r = rng.r(0.02, 0.05)
                let ring = lumpy(cx: Double(map.at(x, y).x), cy: Double(map.at(x, y).y), rx: map.len(r), ry: map.len(r * 0.7), rough: 0.3, steps: 8, seed: rng.next())
                p.shape(ring, Pot.earth.dk(0.2))
            }
        }
    } else {
        heartingTexture(p, profile, kind: .gritstone, seed: rng.next(), scale: map.ppm / 420)
    }
    var y = 0.0
    var course = 0
    var stones: [(Double, Double, Double, Double)] = []
    while y < H - 0.02 {
        let h = rng.r(0.13, 0.19)
        let reach = kind == .poorFooting && course == 0 ? 0.22 : rng.r(0.28, 0.40)
        for side in [-1.0, 1.0] {
            let fx = faceX(y + h / 2, side)
            let inner = fx - side * reach
            let poly = [map.at(min(fx, inner), y), map.at(max(fx, inner), y), map.at(max(fx, inner), y + h), map.at(min(fx, inner), y + h)]
            var q = poly
            if kind == .poorFooting && course == 0 && side == -1 {
                q = rotatedRing(poly, about: map.at(fx - 0.11, y + h / 2), 0.22)
            }
            paintStone(p, poly: q, kind: .gritstone, seed: rng.next(), age: 0.1, ink: true, hatch: false)
            stones.append((fx, y, reach, h))
        }
        if kind != .noThroughs && kind != .belly && course == 3 {
            let poly = [map.at(-hw(y) - 0.03, y), map.at(hw(y) + 0.03, y), map.at(hw(y) + 0.03, y + h), map.at(-hw(y) - 0.03, y + h)]
            paintStone(p, poly: poly, kind: .gritstone, seed: rng.next(), age: 0.1, ink: true, hatch: false)
        }
        y += h + 0.01
        course += 1
    }
    let top = y
    let cope = [map.at(-hw(top) - 0.04, top), map.at(hw(top) + 0.04, top), map.at(hw(top) * 0.9, top + 0.11), map.at(-hw(top) * 0.9, top + 0.11)]
    paintStone(p, poly: cope, kind: .gritstone, seed: rng.next(), age: 0.1, ink: true, hatch: false)
    penOutline(p, outline, weight: 1.6, colour: Pot.ink.al(0.6), seed: rng.next())
    switch kind {
    case .hollowCore:
        markRect(p, map: map, x: -0.2, y: 0.05, w: 0.4, h: 0.5, seed: rng.next())
        letter(p, "nothing behind the faces", at: 600, map.at(0, 0.62).y - 8, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .noThroughs:
        for side in [-1.0, 1.0] {
            let a = map.at(side * (hw(0.8) + 0.25), 0.8), b = map.at(side * (hw(0.8) + 0.06), 0.8)
            markLine(p, a, b, seed: rng.next())
        }
        letter(p, "nothing ties the faces: they bulge under the wind", at: 600, map.at(0, H + 0.3).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .belly:
        let a = map.at(-hw(0) - 0.02, 0), b = map.at(-hw(H) - 0.02, H)
        p.rule(a, b, 1.6, Pot.rubric.al(0.9), dash: [8, 6])
        markLine(p, map.at(-hw(0.8) - 0.28, 0.8), map.at(-hw(0.8) - 0.16, 0.8), seed: rng.next())
        letter(p, "the face past the batter line", at: 600, map.at(0, H + 0.3).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .wrongBatter:
        let a = map.at(-0.42, 0), b = map.at(-0.42 + 0.14 * H, H)
        p.rule(a, b, 1.6, Pot.rubric.al(0.9), dash: [8, 6])
        letter(p, "where the face should lean", at: Double(b.x) - 10, Double(b.y) - 10, size: 17, colour: Pot.rubric, face: "Georgia-Italic", align: .right)
        letter(p, "plumb faces: the wind and the stock push them over", at: 600, map.at(0, H + 0.3).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case .poorFooting:
        let turf = [map.at(-0.62, 0.0), map.at(-0.2, 0.0), map.at(-0.2, 0.04), map.at(-0.62, 0.04)]
        p.shape(turf, Pot.grassDeep)
        hairs(p, pathOf(offsetRing(turf, 0, -10)), count: 40, length: 12, weight: 1.0, spread: 0.5, colour: Pot.grassDeep.al(0.8), seed: rng.next())
        markRect(p, map: map, x: -0.56, y: -0.02, w: 0.36, h: 0.2, seed: rng.next())
        letter(p, "a small stone on unstripped turf, and it rocks", at: 600, map.at(0, H + 0.3).y, size: 21, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    default:
        break
    }
}
