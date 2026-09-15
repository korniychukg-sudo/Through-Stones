import Foundation
import CoreGraphics

func inkWash(_ p: Leaf, _ ring: [CGPoint], _ tone: Hue, strength: Double = 0.55, hatchDepth: Int = 2, inset: Double = 18, weight: Double = 2.0, seed: UInt64) {
    var rng = Chip(seed)
    wash(p, ring, tone, strength: strength, bleed: 3, seed: rng.next())
    roundShade(p, ring, inset: inset, depth: hatchDepth, spacing: 5.5, colour: Pot.ink.al(0.5), seed: rng.next())
    p.light = stoneLight
    penEdge(p, ring, weight: weight, colour: Pot.ink, seed: rng.next())
}

func woodGrain(_ p: Leaf, _ ring: [CGPoint], axis: Double, seed: UInt64) {
    streaks(p, pathOf(ring), count: Int(Double(pathOf(ring).boundingBox.width + pathOf(ring).boundingBox.height) * 1.8), angle: axis,
            light: Hue(r: 0.95, g: 0.85, b: 0.6, a: 0.25), dark: Pot.woodDark.al(0.35), length: 8...40, weight: 0.5...1.3, seed: seed)
}

func steelShine(_ p: Leaf, _ ring: [CGPoint], axis: Double, seed: UInt64) {
    let path = pathOf(ring)
    let box = path.boundingBox
    p.gradientLine(path, from: pt(Double(box.minX), Double(box.minY)), to: pt(Double(box.maxX), Double(box.maxY)), Pot.steelLight, Pot.steelDark)
    streaks(p, path, count: Int(Double(box.width + box.height) * 2.2), angle: axis, light: Hue(r: 1, g: 1, b: 1, a: 0.3), dark: Pot.steelDark.al(0.4), length: 6...30, weight: 0.5...1.2, seed: seed)
}

func handleRing(from a: CGPoint, to b: CGPoint, width: Double, taper: Double = 0.85) -> [CGPoint] {
    bandOf([a, pt((Double(a.x) + Double(b.x)) * 0.5, (Double(a.y) + Double(b.y)) * 0.5), b], [width * taper, width, width * 0.9], per: 8)
}

func benchGround(_ p: Leaf, seed: UInt64, stone: Bool) {
    var rng = Chip(seed)
    if stone {
        let slab = lumpy(cx: 600, cy: 470, rx: 470, ry: 190, rough: 0.06, steps: 30, seed: rng.next())
        p.shape(offsetRing(slab, 10, 16), Pot.shadowInk.al(0.14))
        paintStone(p, poly: slab, kind: .gritstone, seed: rng.next(), age: 0.3, ink: true, hatch: true)
    } else {
        let turf = [pt(60, 380), pt(1140, 380), pt(1140, 700), pt(60, 700)]
        wash(p, turf, Pot.grass, strength: 0.4, bleed: 6, seed: rng.next())
        hairs(p, pathOf(turf), count: 900, length: 14, weight: 0.9, spread: 0.55, colour: Pot.grassDeep.al(0.6), seed: rng.next())
    }
}

func drawToolPlate(_ tool: ToolEntry, dir: String) {
    let p = Leaf(1200, 900)
    let seed = hashOf("tl_\(tool.key)")
    var rng = Chip(seed)
    plateGround(p, seed: seed, tone: Pot.paperWarm)
    p.light = stoneLight
    switch tool.key {
    case "hammer":
        benchGround(p, seed: rng.next(), stone: true)
        let handle = handleRing(from: pt(330, 610), to: pt(760, 330), width: 34)
        p.shape(offsetRing(handle, 8, 12), Pot.shadowInk.al(0.25))
        inkWash(p, handle, Pot.wood, strength: 0.6, seed: rng.next())
        woodGrain(p, handle, axis: atan2(-280, 430), seed: rng.next())
        let head = [pt(720, 250), pt(900, 330), pt(870, 400), pt(690, 320)]
        let peen = [pt(690, 320), pt(720, 250), pt(640, 210), pt(600, 280)]
        for ring in [head, peen] {
            p.shape(offsetRing(ring, 8, 12), Pot.shadowInk.al(0.3))
            p.shape(ring, Pot.steel)
            steelShine(p, ring, axis: 0.5, seed: rng.next())
            penEdge(p, ring, weight: 2.4, colour: Pot.ink, seed: rng.next())
        }
        pen(p, [pt(900, 330), pt(870, 400)], weight: 4, colour: Pot.steelLight.al(0.8), wobble: 0.3, taper: true, seed: rng.next())
    case "lump":
        benchGround(p, seed: rng.next(), stone: true)
        let handle = handleRing(from: pt(430, 640), to: pt(640, 380), width: 42)
        p.shape(offsetRing(handle, 8, 12), Pot.shadowInk.al(0.25))
        inkWash(p, handle, Pot.wood, strength: 0.6, seed: rng.next())
        woodGrain(p, handle, axis: atan2(-260, 210), seed: rng.next())
        let head = [pt(520, 300), pt(800, 300), pt(810, 420), pt(530, 420)]
        p.shape(offsetRing(head, 10, 14), Pot.shadowInk.al(0.3))
        p.shape(head, Pot.steelDark)
        steelShine(p, head, axis: 0.05, seed: rng.next())
        penEdge(p, head, weight: 2.6, colour: Pot.ink, seed: rng.next())
        for f in [0.0, 1.0] {
            let x = 520 + (800 - 520) * f + (f == 0 ? 0 : 10)
            pen(p, [pt(x, 300), pt(x, 420)], weight: 5, colour: Pot.steelLight.al(0.7), wobble: 0.3, taper: false, seed: rng.next())
        }
    case "chisel":
        benchGround(p, seed: rng.next(), stone: true)
        let bar = handleRing(from: pt(280, 560), to: pt(860, 300), width: 40, taper: 0.5)
        p.shape(offsetRing(bar, 8, 12), Pot.shadowInk.al(0.3))
        p.shape(bar, Pot.steel)
        steelShine(p, bar, axis: atan2(-260, 580), seed: rng.next())
        penEdge(p, bar, weight: 2.4, colour: Pot.ink, seed: rng.next())
        let mushroom = lumpy(cx: 866, cy: 296, rx: 30, ry: 26, rough: 0.2, steps: 14, seed: rng.next())
        p.shape(mushroom, Pot.steelDark)
        penOutline(p, mushroom, weight: 2.0, colour: Pot.ink, seed: rng.next())
        pen(p, [pt(250, 590), pt(300, 560)], weight: 3, colour: Pot.steelLight.al(0.9), wobble: 0.3, taper: true, seed: rng.next())
        pen(p, [pt(180, 610), pt(600, 640)], weight: 2.2, colour: Hue(r: 0.95, g: 0.95, b: 0.92, a: 0.9), wobble: 1.2, taper: true, seed: rng.next())
    case "line":
        benchGround(p, seed: rng.next(), stone: false)
        for x in [180.0, 1020.0] {
            let pin = handleRing(from: pt(x, 330), to: pt(x + 12, 560), width: 14, taper: 0.7)
            p.shape(pin, Pot.steelDark)
            steelShine(p, pin, axis: 1.5, seed: rng.next())
            penEdge(p, pin, weight: 1.6, colour: Pot.ink, seed: rng.next())
            p.dot(x, 330, 14, Pot.steelDark)
            p.hoop(x, 330, 13, 2, Pot.ink)
        }
        pen(p, [pt(186, 350), pt(1024, 352)], weight: 3.2, colour: Hue(r: 0.95, g: 0.90, b: 0.70), wobble: 0.5, taper: false, seed: rng.next())
        pen(p, [pt(186, 352), pt(1024, 354)], weight: 1.2, colour: Pot.ink.al(0.6), wobble: 0.3, taper: false, seed: rng.next())
        let peg = handleRing(from: pt(560, 470), to: pt(640, 540), width: 26)
        inkWash(p, peg, Pot.wood, strength: 0.6, seed: rng.next())
        woodGrain(p, peg, axis: 0.7, seed: rng.next())
        var coil: [CGPoint] = []
        for k in 0...60 { let a = Double(k) * 0.42; coil.append(pt(600 + cos(a) * (20 + Double(k) * 0.9), 505 + sin(a) * (8 + Double(k) * 0.4))) }
        pen(p, coil, weight: 2.4, colour: Hue(r: 0.92, g: 0.86, b: 0.66), wobble: 0.4, taper: false, seed: rng.next())
        pen(p, coil, weight: 0.9, colour: Pot.ink.al(0.5), wobble: 0.3, taper: false, seed: rng.next())
    case "frame":
        benchGround(p, seed: rng.next(), stone: false)
        let legL = handleRing(from: pt(360, 640), to: pt(520, 150), width: 30, taper: 0.9)
        let legR = handleRing(from: pt(840, 640), to: pt(680, 150), width: 30, taper: 0.9)
        let cross1 = handleRing(from: pt(410, 480), to: pt(790, 480), width: 26)
        let cross2 = handleRing(from: pt(490, 250), to: pt(710, 250), width: 24)
        for ring in [legL, legR, cross1, cross2] {
            p.shape(offsetRing(ring, 8, 12), Pot.shadowInk.al(0.2))
            inkWash(p, ring, Pot.wood, strength: 0.6, seed: rng.next())
            woodGrain(p, ring, axis: ring == cross1 || ring == cross2 ? 0 : -1.25, seed: rng.next())
        }
        pen(p, [pt(60, 300), pt(470, 300)], weight: 2.6, colour: Hue(r: 0.95, g: 0.90, b: 0.70), wobble: 0.4, taper: false, seed: rng.next())
        pen(p, [pt(730, 300), pt(1140, 300)], weight: 2.6, colour: Hue(r: 0.95, g: 0.90, b: 0.70), wobble: 0.4, taper: false, seed: rng.next())
        pen(p, [pt(60, 300), pt(470, 300)], weight: 1.0, colour: Pot.ink.al(0.5), wobble: 0.3, taper: false, seed: rng.next())
        pen(p, [pt(730, 300), pt(1140, 300)], weight: 1.0, colour: Pot.ink.al(0.5), wobble: 0.3, taper: false, seed: rng.next())
        pen(p, [pt(600, 150), pt(600, 640)], weight: 1.4, colour: Pot.rubric.al(0.6), wobble: 0.3, taper: false, seed: rng.next())
        p.dot(600, 660, 9, Pot.steelDark)
    case "bar":
        benchGround(p, seed: rng.next(), stone: false)
        let bar = handleRing(from: pt(180, 640), to: pt(1020, 220), width: 26, taper: 0.55)
        p.shape(offsetRing(bar, 10, 14), Pot.shadowInk.al(0.25))
        p.shape(bar, Pot.steelDark)
        steelShine(p, bar, axis: atan2(-420, 840), seed: rng.next())
        penEdge(p, bar, weight: 2.4, colour: Pot.ink, seed: rng.next())
        pen(p, [pt(150, 660), pt(200, 630)], weight: 4, colour: Pot.steelLight.al(0.9), wobble: 0.3, taper: true, seed: rng.next())
        let big = lumpy(cx: 300, cy: 560, rx: 150, ry: 80, rough: 0.12, steps: 22, seed: rng.next())
        paintStone(p, poly: big, kind: .limestone, seed: rng.next(), age: 0.2, ink: true)
    case "shovel":
        benchGround(p, seed: rng.next(), stone: false)
        let shaft = handleRing(from: pt(520, 470), to: pt(760, 120), width: 30, taper: 0.9)
        p.shape(offsetRing(shaft, 8, 12), Pot.shadowInk.al(0.2))
        inkWash(p, shaft, Pot.wood, strength: 0.6, seed: rng.next())
        woodGrain(p, shaft, axis: atan2(-350, 240), seed: rng.next())
        var d: [CGPoint] = []
        for k in 0...20 { let a = -1.9 + Double(k) / 20 * 3.6; d.append(pt(760 + cos(a) * 60, 110 + sin(a) * 50)) }
        pen(p, d, weight: 12, colour: Pot.woodDark, wobble: 0.3, taper: false, seed: rng.next())
        pen(p, d, weight: 4, colour: Pot.wood.lt(0.3), wobble: 0.3, taper: true, seed: rng.next())
        let blade = [pt(440, 470), pt(600, 470), pt(620, 640), pt(530, 690), pt(420, 640)]
        p.shape(offsetRing(blade, 10, 14), Pot.shadowInk.al(0.3))
        p.shape(blade, Pot.steel)
        steelShine(p, blade, axis: 1.35, seed: rng.next())
        penEdge(p, blade, weight: 2.6, colour: Pot.ink, seed: rng.next())
        let soil = [pt(380, 700), pt(700, 700), pt(700, 760), pt(380, 760)]
        wash(p, soil, Pot.earth, strength: 0.6, bleed: 8, seed: rng.next())
        grit(p, pathOf(soil), density: 0.02, sizeMin: 0.8, sizeMax: 2.0, colour: Pot.earthDeep, seed: rng.next())
    case "barrow":
        benchGround(p, seed: rng.next(), stone: false)
        let body = [pt(300, 360), pt(820, 360), pt(760, 560), pt(380, 560)]
        p.shape(offsetRing(body, 12, 16), Pot.shadowInk.al(0.25))
        inkWash(p, body, Pot.woodDark.lt(0.2), strength: 0.6, hatchDepth: 2, seed: rng.next())
        woodGrain(p, body, axis: 0.05, seed: rng.next())
        for x in stride(from: 330.0, through: 790.0, by: 92) {
            pen(p, [pt(x, 365), pt(x - 6, 555)], weight: 1.4, colour: Pot.ink.al(0.5), wobble: 0.3, taper: false, seed: rng.next())
        }
        let handle = handleRing(from: pt(800, 380), to: pt(1080, 330), width: 24)
        inkWash(p, handle, Pot.wood, strength: 0.6, seed: rng.next())
        let leg = handleRing(from: pt(730, 560), to: pt(770, 690), width: 22)
        inkWash(p, leg, Pot.wood, strength: 0.6, seed: rng.next())
        let wheel = ringOf(cx: 330, cy: 640, rx: 70, ry: 70, steps: 40)
        p.shape(offsetRing(wheel, 8, 10), Pot.shadowInk.al(0.25))
        inkWash(p, wheel, Pot.steelDark, strength: 0.7, hatchDepth: 1, seed: rng.next())
        p.hoop(330, 640, 42, 6, Pot.steel.lt(0.2))
        p.dot(330, 640, 10, Pot.ink)
        var hs = Chip(rng.next())
        for _ in 0..<26 {
            let x = hs.r(330, 780), y = hs.r(300, 360)
            let ring = lumpy(cx: x, cy: y, rx: hs.r(16, 34), ry: hs.r(10, 20), rough: 0.3, steps: 10, seed: hs.next())
            paintStone(p, poly: ring, kind: .gritstone, seed: hs.next(), ink: true, hatch: false)
        }
    case "gloves":
        benchGround(p, seed: rng.next(), stone: true)
        for (i, (cx, rot)) in [(440.0, -0.35), (720.0, 0.25)].enumerated() {
            var palm: [CGPoint] = [pt(cx - 70, 300), pt(cx + 70, 300), pt(cx + 90, 470), pt(cx + 40, 520), pt(cx - 50, 520), pt(cx - 90, 470)]
            palm = rotatedRing(palm, about: pt(cx, 420), rot)
            p.shape(offsetRing(palm, 10, 14), Pot.shadowInk.al(0.25))
            inkWash(p, palm, Pot.wood.lt(0.25), strength: 0.55, hatchDepth: 2, inset: 24, seed: rng.next())
            for f in 0..<4 {
                let fx = cx - 60 + Double(f) * 40
                var finger = handleRing(from: pt(fx, 305), to: pt(fx + Double(f - 2) * 6, 170 + abs(Double(f) - 1.5) * 20), width: 34, taper: 0.9)
                finger = rotatedRing(finger, about: pt(cx, 420), rot)
                inkWash(p, finger, Pot.wood.lt(0.3), strength: 0.5, hatchDepth: 1, inset: 12, weight: 1.6, seed: rng.next())
            }
            var thumb = handleRing(from: pt(cx + (i == 0 ? 60 : -60), 360), to: pt(cx + (i == 0 ? 130 : -130), 280), width: 36, taper: 0.9)
            thumb = rotatedRing(thumb, about: pt(cx, 420), rot)
            inkWash(p, thumb, Pot.wood.lt(0.3), strength: 0.5, hatchDepth: 1, inset: 12, weight: 1.6, seed: rng.next())
            var cuff = rotatedRing([pt(cx - 80, 500), pt(cx + 80, 500), pt(cx + 84, 560), pt(cx - 84, 560)], about: pt(cx, 420), rot)
            cuff = offsetRing(cuff, 0, 0)
            inkWash(p, cuff, Hue(r: 0.85, g: 0.80, b: 0.62), strength: 0.5, hatchDepth: 1, inset: 10, seed: rng.next())
        }
    case "bucket":
        benchGround(p, seed: rng.next(), stone: false)
        let body = [pt(430, 300), pt(770, 300), pt(730, 640), pt(470, 640)]
        p.shape(offsetRing(body, 12, 16), Pot.shadowInk.al(0.25))
        p.shape(body, Pot.steel)
        steelShine(p, body, axis: 1.5, seed: rng.next())
        penEdge(p, body, weight: 2.6, colour: Pot.ink, seed: rng.next())
        for y in [340.0, 590.0] {
            pen(p, [pt(430 + (y - 300) * 0.12, y), pt(770 - (y - 300) * 0.12, y)], weight: 6, colour: Pot.steelDark.al(0.8), wobble: 0.3, taper: false, seed: rng.next())
        }
        var arc: [CGPoint] = []
        for k in 0...30 { let a = .pi + Double(k) / 30 * .pi; arc.append(pt(600 + cos(a) * 180, 300 + sin(a) * 130)) }
        pen(p, arc, weight: 7, colour: Pot.steelDark, wobble: 0.3, taper: false, seed: rng.next())
        var hs = Chip(rng.next())
        for _ in 0..<22 {
            let x = hs.r(450, 750), y = hs.r(255, 300)
            let ring = lumpy(cx: x, cy: y, rx: hs.r(14, 28), ry: hs.r(9, 16), rough: 0.3, steps: 9, seed: hs.next())
            paintStone(p, poly: ring, kind: .limestone, seed: hs.next(), ink: true, hatch: false)
        }
        for _ in 0..<9 {
            let x = hs.r(760, 1000), y = hs.r(600, 680)
            let ring = lumpy(cx: x, cy: y, rx: hs.r(12, 24), ry: hs.r(8, 14), rough: 0.3, steps: 9, seed: hs.next())
            paintStone(p, poly: ring, kind: .limestone, seed: hs.next(), ink: true, hatch: false)
        }
    case "tape":
        benchGround(p, seed: rng.next(), stone: true)
        let caseRing = [pt(430, 300), pt(640, 300), pt(660, 320), pt(660, 500), pt(640, 520), pt(430, 520), pt(410, 500), pt(410, 320)]
        p.shape(offsetRing(caseRing, 12, 16), Pot.shadowInk.al(0.3))
        inkWash(p, caseRing, Pot.rubric.lt(0.1), strength: 0.7, hatchDepth: 2, inset: 30, seed: rng.next())
        p.hoop(535, 410, 60, 4, Pot.ink.al(0.5))
        let blade = [pt(660, 395), pt(1040, 380), pt(1040, 430), pt(660, 445)]
        p.shape(blade, Hue(r: 0.95, g: 0.90, b: 0.55))
        penEdge(p, blade, weight: 1.8, colour: Pot.ink, seed: rng.next())
        for k in 0..<20 {
            let x = 680 + Double(k) * 18
            let y = 380 + (x - 660) / 380 * (-15)
            pen(p, [pt(x, y + 2), pt(x, y + (k % 5 == 0 ? 22 : 12))], weight: 1.2, colour: Pot.ink.al(0.8), wobble: 0.1, taper: false, seed: rng.next())
        }
        let hook = [pt(1035, 372), pt(1060, 372), pt(1060, 440), pt(1035, 440)]
        p.shape(hook, Pot.steelDark)
        penEdge(p, hook, weight: 1.4, colour: Pot.ink, seed: rng.next())
    case "level":
        benchGround(p, seed: rng.next(), stone: true)
        let body = [pt(200, 330), pt(1000, 330), pt(1000, 420), pt(200, 420)]
        p.shape(offsetRing(body, 12, 16), Pot.shadowInk.al(0.3))
        inkWash(p, body, Pot.wood.dk(0.1), strength: 0.65, hatchDepth: 2, inset: 24, seed: rng.next())
        woodGrain(p, body, axis: 0.02, seed: rng.next())
        for x in [420.0, 780.0] {
            let vial = [pt(x - 60, 350), pt(x + 60, 350), pt(x + 60, 400), pt(x - 60, 400)]
            p.shape(vial, Pot.paperWarm)
            p.gradientLine(pathOf(vial), from: pt(x - 60, 350), to: pt(x + 60, 400), Hue(r: 0.85, g: 0.95, b: 0.75), Hue(r: 0.55, g: 0.75, b: 0.45))
            p.egg(x + 4, 372, 22, 14, Hue(r: 0.98, g: 0.99, b: 0.9, a: 0.9))
            pen(p, [pt(x - 18, 352), pt(x - 18, 398)], weight: 1.6, colour: Pot.ink, wobble: 0.2, taper: false, seed: rng.next())
            pen(p, [pt(x + 18, 352), pt(x + 18, 398)], weight: 1.6, colour: Pot.ink, wobble: 0.2, taper: false, seed: rng.next())
            penEdge(p, vial, weight: 1.6, colour: Pot.ink, seed: rng.next())
        }
        pen(p, [pt(200, 375), pt(1000, 375)], weight: 2.0, colour: Pot.steel.al(0.6), wobble: 0.2, taper: false, seed: rng.next())
    default:
        break
    }
    plateCaption(p, title: tool.name, sub: tool.use, y: 740, titleSize: 36)
    p.writeJPG(dir, tool.plate)
}
