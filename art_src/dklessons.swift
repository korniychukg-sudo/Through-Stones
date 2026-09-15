import Foundation
import CoreGraphics

func arrowLabel(_ p: Leaf, from a: CGPoint, to b: CGPoint, text: String, seed: UInt64, colour: Hue = Pot.ink, size: Double = 20, align: Justify = .left) {
    pen(p, [a, b], weight: 1.8, colour: colour.al(0.85), wobble: 0.3, taper: false, seed: seed)
    let ang = atan2(Double(b.y - a.y), Double(b.x - a.x))
    let tip = b
    let l = pt(Double(tip.x) - cos(ang - 0.4) * 12, Double(tip.y) - sin(ang - 0.4) * 12)
    let r = pt(Double(tip.x) - cos(ang + 0.4) * 12, Double(tip.y) - sin(ang + 0.4) * 12)
    p.shape([tip, l, r], colour.al(0.9))
    let tx = align == .left ? Double(a.x) + 8 : (align == .right ? Double(a.x) - 8 : Double(a.x))
    letter(p, text, at: tx, Double(a.y) + 7, size: size, colour: colour, face: "Georgia-Italic", align: align)
}

func drawLessonPlate(_ lesson: Lesson, dir: String) {
    let p = Leaf(1200, 900)
    let seed = hashOf("ls_\(lesson.index)")
    var rng = Chip(seed)
    plateGround(p, seed: seed, tone: Pot.paperWarm)
    p.light = stoneLight
    let map = WallMap(ox: 240, oy: 650, ppm: 400)
    switch lesson.index {
    case 0:
        let block = stonePolygon(kind: .gritstone, cls: .builder, seed: rng.next(), width: 420, height: 190, at: pt(520, 420))
        p.shape(offsetRing(block, 16, 22), Pot.shadowInk.al(0.28))
        var side = Chip(rng.next())
        extrudeSides(p, block, dx: 90, dy: -70, light: stoneLight, base: chordOf(.gritstone).body.dk(0.25), rng: &side, bevel: false)
        paintStone(p, poly: block, kind: .gritstone, seed: rng.next(), age: 0.05, ink: true)
        arrowLabel(p, from: pt(180, 240), to: pt(340, 330), text: "the bed: lines in the grain, laid flat", seed: rng.next(), align: .left)
        arrowLabel(p, from: pt(180, 560), to: pt(330, 470), text: "the face: rough, square to the bed", seed: rng.next(), align: .left)
        arrowLabel(p, from: pt(900, 250), to: pt(740, 300), text: "the length: into the wall", seed: rng.next(), align: .left)
        let wrongLabels: [String] = ["on edge", "traced", "face-bedded"]
        let wrongBeds: [Double] = [Double.pi / 2, 0.0, Double.pi / 2]
        let wrongW: [Double] = [70, 120, 70]
        let wrongH: [Double] = [110, 40, 90]
        for k in 0..<3 {
            let cx = 760.0 + Double(k) * 140
            let poly = stonePolygon(kind: .gritstone, cls: .builder, seed: rng.next(), width: wrongW[k], height: wrongH[k], at: pt(cx, 600))
            paintStone(p, poly: poly, kind: .gritstone, seed: rng.next(), bed: wrongBeds[k], ink: true)
            letter(p, wrongLabels[k], at: cx, 690, size: 17, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
        }
    case 1:
        let ground = [pt(80, 500), pt(1120, 500), pt(1120, 700), pt(80, 700)]
        wash(p, ground, Pot.earth, strength: 0.5, bleed: 5, seed: rng.next())
        grit(p, pathOf(ground), density: 0.012, sizeMin: 0.8, sizeMax: 2.2, colour: Pot.earthDeep.al(0.7), seed: rng.next())
        let turfL = [pt(80, 470), pt(330, 470), pt(330, 505), pt(80, 505)]
        let turfR = [pt(870, 470), pt(1120, 470), pt(1120, 505), pt(870, 505)]
        for t in [turfL, turfR] {
            p.shape(t, Pot.grassDeep)
            hairs(p, pathOf(offsetRing(t, 0, -14)), count: 60, length: 14, weight: 1.0, spread: 0.5, colour: Pot.grassDeep.al(0.8), seed: rng.next())
        }
        let trench = [pt(330, 505), pt(870, 505), pt(870, 580), pt(330, 580)]
        p.shape(trench, Pot.earthDeep.dk(0.2))
        grit(p, pathOf(trench), density: 0.05, sizeMin: 1.0, sizeMax: 2.6, colour: Pot.stoneLight.al(0.7), seed: rng.next())
        let footX: [Double] = [345, 560, 725]
        let footW: [Double] = [200, 150, 130]
        for k in 0..<3 {
            let x = footX[k], w = footW[k]
            let poly = stonePolygon(kind: .gritstone, cls: .footing, seed: rng.next(), width: w, height: 95, at: pt(x + w / 2, 530))
            paintStone(p, poly: poly, kind: .gritstone, seed: rng.next(), ink: true)
        }
        let core = [pt(555, 495), pt(730, 495), pt(730, 575), pt(555, 575)]
        arrowLabel(p, from: pt(200, 300), to: pt(400, 440), text: "turf stripped, trench cut to firm ground", seed: rng.next())
        arrowLabel(p, from: pt(700, 260), to: pt(640, 470), text: "the largest stones, flat side down", seed: rng.next())
        _ = core
        pen(p, [pt(330, 583), pt(870, 583)], weight: 2.2, colour: Pot.rubric.al(0.8), wobble: 0.5, taper: false, seed: rng.next())
        letter(p, "level floor, firm subsoil", at: 600, 615, size: 18, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case 2:
        let stones = layCourses([
            [(0.40, 0.18), (0.36, 0.18), (0.44, 0.18), (0.34, 0.18)],
            [(0.22, 0.15), (0.40, 0.15), (0.38, 0.15), (0.30, 0.15), (0.20, 0.15)],
            [(0.36, 0.16), (0.32, 0.16), (0.44, 0.16), (0.40, 0.16)],
            [(0.20, 0.15), (0.42, 0.15), (0.34, 0.15), (0.36, 0.15), (0.20, 0.15)]
        ])
        paintDiagram(p, stones: stones, map: map, kind: .limestone, seed: rng.next())
        var y = 0.0
        let courseH: [Double] = [0.18, 0.15, 0.16, 0.15]
        for k in 0..<4 {
            let h = courseH[k]
            if k < 3 {
                let row = stones.filter { abs($0.y - y) < 0.001 }
                for s in row.dropLast() {
                    let jx = s.x + s.w + 0.006
                    let lowY = y + 0.01, highY = y + h + 0.03
                    let above = stones.first { $0.y > lowY && $0.y < highY && $0.x < jx - 0.03 && $0.x + $0.w > jx + 0.03 }
                    if above != nil {
                        let a = map.at(jx, y + h * 0.3), b = map.at(jx, y + h + 0.07)
                        pen(p, [a, b], weight: 2.4, colour: Pot.moss.dk(0.2).al(0.9), wobble: 0.3, taper: true, seed: rng.next())
                    }
                }
            }
            y += h + 0.008
        }
        letter(p, "every joint crossed by the stone above: one over two, two over one", at: 600, 720, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    case 3:
        let plan = [pt(140, 250), pt(1060, 250), pt(1060, 560), pt(140, 560)]
        wash(p, plan, Pot.paperDeep, strength: 0.6, bleed: 4, seed: rng.next())
        penOutline(p, plan, weight: 1.6, colour: Pot.ink.al(0.6), seed: rng.next())
        letter(p, "plan of one course, seen from above; the face is along the bottom", at: 600, 235, size: 18, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
        var x = 150.0
        var k = 0
        while x < 1040 {
            let traced = k == 3
            let w = traced ? 220.0 : 90 + Double(k % 3) * 22
            let h = traced ? 90.0 : 170 + Double(k % 2) * 60
            let poly = stonePolygon(kind: .gritstone, cls: .builder, seed: rng.next(), width: w, height: h, at: pt(x + w / 2, 560 - h / 2 - 6))
            paintStone(p, poly: poly, kind: .gritstone, seed: rng.next(), ink: true, hatch: false)
            if traced { markRect(p, map: WallMap(ox: 0, oy: 0, ppm: 1), x: x - 4, y: -560 + 6, w: w + 8, h: h + 4, seed: rng.next()) }
            x += w + 14
            k += 1
        }
        heartingTexture(p, rectPath(150, 260, 890, 100), kind: .gritstone, seed: rng.next(), scale: 0.9)
        letter(p, "the hearting locks behind the tails", at: 600, 330, size: 18, colour: Pot.paperWarm, face: "Georgia-Italic", align: .centre)
        letter(p, "traced: it holds nothing", at: 600, 610, size: 18, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case 4:
        let c = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 1.6, height: 1.3, seed: hashOf("lesson.batter"))
        let wall = WallBuilder.reference(c, attempts: 2)
        drawSection(p, wall: wall, at: pt(560, 640), ppm: 330, age: 0.1, labels: false, seed: rng.next())
        let legL = handleRing(from: pt(360, 660), to: pt(490, 170), width: 20)
        let legR = handleRing(from: pt(760, 660), to: pt(630, 170), width: 20)
        let cross = handleRing(from: pt(415, 440), to: pt(705, 440), width: 18)
        for ring in [legL, legR, cross] {
            inkWash(p, ring, Pot.wood, strength: 0.55, hatchDepth: 1, inset: 8, weight: 1.6, seed: rng.next())
        }
        for y in [560.0, 470.0, 380.0, 290.0] {
            let t = (660 - y) / 490
            let xl = 360 + (490 - 360) * t, xr = 760 - (760 - 630) * t
            pen(p, [pt(xl - 10, y), pt(xr + 10, y)], weight: 1.4, colour: Hue(r: 0.9, g: 0.85, b: 0.6), wobble: 0.3, taper: false, seed: rng.next())
        }
        arrowLabel(p, from: pt(900, 300), to: pt(660, 300), text: "the frame is the wall's profile", seed: rng.next())
        arrowLabel(p, from: pt(900, 470), to: pt(720, 470), text: "the lines, raised a course at a time", seed: rng.next())
        letter(p, "batter one in six: the faces lean on the core", at: 600, 720, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    case 5:
        let c = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 1.6, height: 1.2, seed: hashOf("lesson.hearting"))
        let wall = WallBuilder.reference(c, attempts: 2)
        drawSection(p, wall: wall, at: pt(420, 640), ppm: 360, age: 0.1, labels: false, seed: rng.next())
        arrowLabel(p, from: pt(720, 380), to: pt(440, 400), text: "packed course by course, tapped in", seed: rng.next())
        let close = rectPath(800, 180, 300, 300)
        heartingTexture(p, close, kind: .gritstone, seed: rng.next(), scale: 2.2)
        penOutline(p, [pt(800, 180), pt(1100, 180), pt(1100, 480), pt(800, 480)], weight: 1.6, colour: Pot.ink.al(0.6), seed: rng.next())
        letter(p, "nothing smaller than an egg", at: 950, 510, size: 18, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
        letter(p, "no soil, no sand, no turf", at: 950, 540, size: 18, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
    case 6:
        let c = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 2.2, height: 1.3, seed: hashOf("lesson.throughs"))
        let wall = WallBuilder.reference(c, attempts: 3)
        let box = CGRect(x: 80, y: 80, width: 720, height: 600)
        let m = mapFor(wall, box: box)
        drawElevation(p, wall: wall, map: m, age: 0.1, frame: false, line: false, seed: rng.next())
        for t in wall.throughsPlaced {
            let b = Geometry.bounds(t.polygon)
            markRect(p, map: m, x: b.minX, y: b.minY, w: b.maxX - b.minX, h: b.maxY - b.minY, seed: rng.next())
        }
        drawSection(p, wall: wall, at: pt(980, 640), ppm: 300, age: 0.1, labels: false, seed: rng.next())
        letter(p, "at half height, every metre, reaching both faces", at: 600, 720, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    case 7:
        let big = stonePolygon(kind: .fieldstone, cls: .builder, seed: rng.next(), width: 360, height: 170, at: pt(400, 380))
        let under1 = stonePolygon(kind: .fieldstone, cls: .builder, seed: rng.next(), width: 220, height: 140, at: pt(300, 540))
        let under2 = stonePolygon(kind: .fieldstone, cls: .builder, seed: rng.next(), width: 220, height: 140, at: pt(560, 560))
        paintStone(p, poly: under1, kind: .fieldstone, seed: rng.next(), ink: true)
        paintStone(p, poly: under2, kind: .fieldstone, seed: rng.next(), ink: true)
        paintStone(p, poly: rotatedRing(big, about: pt(400, 380), 0.12), kind: .fieldstone, seed: rng.next(), ink: true)
        for k in 0..<3 {
            var arc: [CGPoint] = []
            let rad = 230.0 + Double(k) * 16
            for j in 0...10 {
                let a = -0.5 + Double(j) / 10 * 1.0 - Double.pi / 2
                let ax = 400 + cos(a) * rad
                let ay = 380 + sin(a) * rad
                arc.append(pt(ax, ay))
            }
            pen(p, arc, weight: 1.4, colour: Pot.rubric.al(0.7), wobble: 0.4, taper: true, seed: rng.next())
        }
        letter(p, "rocking on one point", at: 400, 130, size: 20, colour: Pot.rubric, face: "Georgia-Italic", align: .centre)
        let ox = 820.0
        let bigB = stonePolygon(kind: .fieldstone, cls: .builder, seed: rng.next(), width: 260, height: 130, at: pt(ox, 400))
        let underB = stonePolygon(kind: .fieldstone, cls: .builder, seed: rng.next(), width: 300, height: 130, at: pt(ox + 20, 540))
        paintStone(p, poly: underB, kind: .fieldstone, seed: rng.next(), ink: true)
        paintStone(p, poly: bigB, kind: .fieldstone, seed: rng.next(), ink: true)
        let wedge = [pt(ox + 60, 470), pt(ox + 130, 468), pt(ox + 125, 440)]
        paintStone(p, poly: wedge, kind: .fieldstone, seed: rng.next(), ink: true, hatch: false)
        arrowLabel(p, from: pt(1020, 300), to: pt(ox + 120, 445), text: "pinned from the back", seed: rng.next(), align: .right)
        letter(p, "the pin makes the stone level, not a prop under one corner", at: 600, 720, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    case 8:
        let copeLabels: [String] = ["flat cope, Dales", "cock and hen, Cotswold", "upright and tight, Kentucky", "locked top, Galloway", "turf top, Cornwall"]
        let copeKinds: [CopeKind] = [.flat, .cockAndHen, .upright, .locked, .turf]
        for k in 0..<5 {
            let label = copeLabels[k]
            let cope = copeKinds[k]
            let cx = 150.0 + Double(k) * 225
            let base: [CGPoint] = [pt(cx - 90, 470), pt(cx + 90, 470), pt(cx + 82, 600), pt(cx - 82, 600)]
            paintStone(p, poly: base, kind: .gritstone, seed: rng.next(), ink: true, hatch: false)
            let base2: [CGPoint] = [pt(cx - 84, 604), pt(cx + 84, 604), pt(cx + 76, 690), pt(cx - 76, 690)]
            paintStone(p, poly: base2, kind: .gritstone, seed: rng.next(), ink: true, hatch: false)
            switch cope {
            case .flat:
                let flat = [pt(cx - 100, 420), pt(cx + 100, 420), pt(cx + 96, 468), pt(cx - 96, 468)]
                paintStone(p, poly: flat, kind: .gritstone, seed: rng.next(), ink: true, hatch: false)
            case .cockAndHen:
                for j in 0..<5 {
                    let topY: Double = j % 2 == 0 ? 370 : 410
                    let x = cx - 72 + Double(j) * 36
                    let u = [pt(x - 16, 468), pt(x + 16, 468), pt(x + 14, topY), pt(x - 14, topY)]
                    paintStone(p, poly: u, kind: .oolite, seed: rng.next(), bed: .pi / 2, ink: true, hatch: false)
                }
            case .upright:
                for j in 0..<5 {
                    let x = cx - 72 + Double(j) * 36
                    let u = [pt(x - 17, 468), pt(x + 17, 468), pt(x + 15, 375), pt(x - 15, 375)]
                    paintStone(p, poly: u, kind: .limestone, seed: rng.next(), bed: .pi / 2, ink: true, hatch: false)
                }
            case .locked:
                for j in 0..<4 {
                    let x = cx - 66 + Double(j) * 44
                    let u = [pt(x - 15, 468), pt(x + 15, 468), pt(x + 13, 372), pt(x - 13, 372)]
                    paintStone(p, poly: u, kind: .greywacke, seed: rng.next(), bed: .pi / 2, ink: true, hatch: false)
                    if j < 3 {
                        let w = [pt(x + 18, 430), pt(x + 26, 400), pt(x + 24, 460)]
                        paintStone(p, poly: w, kind: .greywacke, seed: rng.next(), ink: true, hatch: false)
                    }
                }
            default:
                let turf = [pt(cx - 96, 468), pt(cx + 96, 468), pt(cx + 88, 420), pt(cx - 88, 420)]
                p.shape(turf, Pot.grassDeep)
                wash(p, turf, Pot.grass, strength: 0.5, bleed: 3, seed: rng.next())
                hairs(p, pathOf(offsetRing(turf, 0, -30)), count: 60, length: 26, weight: 1.1, spread: 0.5, colour: Pot.grassDeep.al(0.8), seed: rng.next())
            }
            for (i, line) in wrapText(label, width: 200, size: 16, face: "Georgia-Italic").enumerated() {
                letter(p, line, at: cx, 300 + Double(i) * 20, size: 16, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
            }
        }
        letter(p, "the lid that holds the wall down", at: 600, 200, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    case 9:
        let stones = layCourses([
            [(0.34, 0.18), (0.30, 0.18), (0.38, 0.18), (0.40, 0.18)],
            [(0.30, 0.15), (0.36, 0.15), (0.28, 0.15), (0.48, 0.15)],
            [(0.36, 0.16), (0.32, 0.16), (0.40, 0.16), (0.34, 0.16)],
            [(0.30, 0.15), (0.40, 0.15), (0.24, 0.15), (0.48, 0.15)]
        ])
        paintDiagram(p, stones: stones, map: map, kind: .gritstone, seed: rng.next())
        let labels = ["H", "T", "H", "T"]
        for k in 0..<4 {
            let s = stones[k * 4 + 3]
            letter(p, labels[k], at: map.at(s.x + s.w / 2, 0).x, map.at(0, s.y + s.h / 2).y + 9, size: 26, colour: Pot.paperWarm, face: "Copperplate-Bold", align: .centre)
        }
        pen(p, [map.at(1.50, -0.02), map.at(1.50, 0.75)], weight: 2.0, colour: Pot.rubric.al(0.8), wobble: 0.3, taper: false, seed: rng.next())
        letter(p, "plumb", at: map.at(1.53, 0).x, map.at(0, 0.72).y, size: 16, colour: Pot.rubric, face: "Georgia-Italic", align: .left)
        letter(p, "H a header into the wall, T a tie along the face, alternating all the way up", at: 600, 720, size: 20, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    case 10:
        let c = WallBuilder.free(style: .dales, feature: .slope, kind: .gritstone, length: 2.2, height: 1.2, seed: hashOf("lesson.slope"))
        let wall = WallBuilder.reference(c, attempts: 3)
        let box = CGRect(x: 80, y: 80, width: 1040, height: 600)
        hillBackdrop(p, box: box, seed: rng.next())
        let m = mapFor(wall, box: box.insetBy(dx: 20, dy: 10))
        drawElevation(p, wall: wall, map: m, age: 0.1, frame: false, line: false, seed: rng.next())
        groundBand(p, map: m, wall: wall, box: box, seed: rng.next())
        for k in 0..<3 {
            let y = 0.25 + Double(k) * 0.33
            p.rule(m.at(-0.1, y), m.at(wall.length + 0.1, y), 1.4, Pot.rubric.al(0.75), dash: [8, 6])
        }
        letter(p, "courses level, footings stepped into the bank", at: 600, 720, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    default:
        let c = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 2.2, height: 1.3, seed: hashOf("lesson.rebuild"))
        let wall = WallBuilder.reference(c, attempts: 3)
        let box = CGRect(x: 80, y: 80, width: 1040, height: 600)
        hillBackdrop(p, box: box, seed: rng.next())
        let m = mapFor(wall, box: box.insetBy(dx: 20, dy: 10))
        let lost = Set(wall.placed.filter { $0.x > wall.length * 0.55 && $0.y > 0.35 }.map { $0.id })
        drawElevation(p, wall: wall, map: m, age: 0.8, frame: false, line: false, lost: lost, seed: rng.next())
        groundBand(p, map: m, wall: wall, box: box, seed: rng.next())
        var hs = Chip(rng.next())
        for id in lost.prefix(18) {
            guard let s = wall.stone(id) else { continue }
            let x = hs.r(wall.length * 0.55, wall.length + 0.5), y = hs.r(-0.03, 0.05)
            let poly = stonePolygon(kind: s.kind, cls: .builder, seed: hs.next(), width: m.len(s.faceWidth), height: m.len(s.faceHeight), at: m.at(x, y), tilt: hs.r(-0.6, 0.6))
            paintStone(p, poly: poly, kind: s.kind, seed: hs.next(), age: 0.8, ink: true, hatch: false)
        }
        letter(p, "the stones are all there in the grass; sort them again and build to the line", at: 600, 720, size: 21, colour: Pot.inkSoft, face: "Georgia-Italic", align: .centre)
    }
    plateCaption(p, title: "Lesson \(lesson.index + 1): \(lesson.title)", sub: lesson.sub, y: 745, titleSize: 34)
    p.writeJPG(dir, lesson.plate)
}
