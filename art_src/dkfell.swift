import Foundation
import CoreGraphics

struct FellTone {
    var skyTop: Hue
    var skyLow: Hue
    var far: Hue
    var mid: Hue
    var near: Hue
    var light: Double
    var mist: Double
    var stars: Double
    var sun: Double
    var moon: Double
    var warm: Double
}

let fellHours: [(String, String, FellTone)] = [
    ("h0", "Two in the morning",
     FellTone(skyTop: Hue(r: 0.06, g: 0.08, b: 0.15), skyLow: Hue(r: 0.14, g: 0.17, b: 0.26), far: Hue(r: 0.12, g: 0.14, b: 0.20), mid: Hue(r: 0.15, g: 0.18, b: 0.20), near: Hue(r: 0.17, g: 0.21, b: 0.18), light: 0.18, mist: 0.1, stars: 1.0, sun: -1, moon: 1, warm: 0)),
    ("h1", "Half past five, first light",
     FellTone(skyTop: Hue(r: 0.30, g: 0.34, b: 0.48), skyLow: Hue(r: 0.85, g: 0.66, b: 0.50), far: Hue(r: 0.40, g: 0.42, b: 0.52), mid: Hue(r: 0.36, g: 0.42, b: 0.36), near: Hue(r: 0.40, g: 0.48, b: 0.32), light: 0.45, mist: 0.75, stars: 0.15, sun: 0.02, moon: 0, warm: 0.5)),
    ("h2", "Half past eight",
     FellTone(skyTop: Hue(r: 0.50, g: 0.64, b: 0.80), skyLow: Hue(r: 0.80, g: 0.85, b: 0.86), far: Hue(r: 0.52, g: 0.60, b: 0.68), mid: Hue(r: 0.46, g: 0.56, b: 0.38), near: Hue(r: 0.50, g: 0.60, b: 0.34), light: 0.8, mist: 0.3, stars: 0, sun: 0.25, moon: 0, warm: 0.3)),
    ("h3", "Midday",
     FellTone(skyTop: Hue(r: 0.42, g: 0.60, b: 0.80), skyLow: Hue(r: 0.75, g: 0.82, b: 0.86), far: Hue(r: 0.55, g: 0.63, b: 0.70), mid: Hue(r: 0.50, g: 0.60, b: 0.38), near: Hue(r: 0.52, g: 0.62, b: 0.34), light: 1.0, mist: 0.0, stars: 0, sun: 0.8, moon: 0, warm: 0.1)),
    ("h4", "Four in the afternoon",
     FellTone(skyTop: Hue(r: 0.48, g: 0.60, b: 0.74), skyLow: Hue(r: 0.82, g: 0.80, b: 0.74), far: Hue(r: 0.55, g: 0.58, b: 0.62), mid: Hue(r: 0.50, g: 0.56, b: 0.36), near: Hue(r: 0.55, g: 0.58, b: 0.32), light: 0.9, mist: 0.05, stars: 0, sun: 0.6, moon: 0, warm: 0.35)),
    ("h5", "Half past seven, dusk",
     FellTone(skyTop: Hue(r: 0.30, g: 0.32, b: 0.48), skyLow: Hue(r: 0.85, g: 0.55, b: 0.36), far: Hue(r: 0.36, g: 0.32, b: 0.42), mid: Hue(r: 0.32, g: 0.36, b: 0.30), near: Hue(r: 0.34, g: 0.40, b: 0.26), light: 0.5, mist: 0.2, stars: 0.2, sun: 0.03, moon: 0, warm: 0.7)),
    ("h6", "Ten at night",
     FellTone(skyTop: Hue(r: 0.10, g: 0.12, b: 0.22), skyLow: Hue(r: 0.22, g: 0.22, b: 0.32), far: Hue(r: 0.16, g: 0.17, b: 0.24), mid: Hue(r: 0.18, g: 0.21, b: 0.22), near: Hue(r: 0.20, g: 0.24, b: 0.20), light: 0.25, mist: 0.15, stars: 0.8, sun: -1, moon: 0.7, warm: 0.05))
]

func ridgeRing(_ p: Leaf, base: Double, amp: Double, freq: Double, seed: UInt64, box: CGRect) -> [CGPoint] {
    var rng = Chip(seed)
    var ring: [CGPoint] = [pt(Double(box.minX) - 30, Double(box.maxY) + 30)]
    var x = Double(box.minX) - 30
    let ph = rng.r(0, 6)
    while x <= Double(box.maxX) + 30 {
        let y = base + sin(x * freq + ph) * amp + sin(x * freq * 2.7 + ph * 2) * amp * 0.35 + rng.signed() * 2
        ring.append(pt(x, y))
        x += 28
    }
    ring.append(pt(Double(box.maxX) + 30, Double(box.maxY) + 30))
    return ring
}

func sheepAt(_ p: Leaf, x: Double, y: Double, size: Double, tone: Hue, dark: Hue, facingLeft: Bool, grazing: Bool, seed: UInt64) {
    var rng = Chip(seed)
    let dir: Double = facingLeft ? -1 : 1
    let body = lumpy(cx: x, cy: y - size * 0.55, rx: size * 0.62, ry: size * 0.40, rough: 0.08, steps: 20, seed: rng.next())
    p.shape(offsetRing(body, size * 0.05, size * 0.5), dark.al(0.16))
    for lx in [-0.35, -0.18, 0.15, 0.32] {
        let a = pt(x + lx * size, y - size * 0.3), b = pt(x + lx * size + rng.signed() * size * 0.03, y + size * 0.02)
        pen(p, [a, b], weight: size * 0.075, colour: dark, wobble: 0.2, taper: false, seed: rng.next())
    }
    p.shape(body, tone)
    p.radial(pt(x - size * 0.2, y - size * 0.8), size * 0.9, tone.lt(0.2), tone.dk(0.3), clip: pathOf(body))
    let headY = grazing ? y - size * 0.15 : y - size * 0.7
    let headX = x + dir * (grazing ? size * 0.68 : size * 0.72)
    let head = lumpy(cx: headX, cy: headY, rx: size * 0.16, ry: size * 0.22, rough: 0.1, steps: 12, seed: rng.next())
    let neck = [pt(x + dir * size * 0.45, y - size * 0.55), pt(x + dir * size * 0.62, y - size * 0.75), pt(headX, headY - size * 0.05), pt(headX - dir * size * 0.02, headY + size * 0.12)]
    p.shape(neck, dark.lt(0.1))
    p.shape(head, dark)
    p.shape(rotatedRing(lumpy(cx: headX - dir * size * 0.05, cy: headY - size * 0.22, rx: size * 0.07, ry: size * 0.04, rough: 0.1, steps: 8, seed: rng.next()), about: pt(headX, headY), dir * 0.4), dark)
}

func fellWall(_ p: Leaf, from a: CGPoint, to b: CGPoint, nearHeight: Double, farHeight: Double, tone: FellTone, kind: StoneKind, age: Double, seed: UInt64) {
    var rng = Chip(seed)
    let n = 30
    var topLine: [CGPoint] = []
    var bottomLine: [CGPoint] = []
    for k in 0...n {
        let t = Double(k) / Double(n)
        let x = Double(a.x) + (Double(b.x) - Double(a.x)) * t
        let y = Double(a.y) + (Double(b.y) - Double(a.y)) * t
        let h = nearHeight + (farHeight - nearHeight) * pow(t, 0.8)
        bottomLine.append(pt(x, y))
        topLine.append(pt(x, y - h))
    }
    let band = bottomLine + topLine.reversed()
    p.shape(offsetRing(band, 6, 6), Pot.shadowInk.al(0.25 * tone.light))
    let ch = chordOf(kind)
    p.shape(band, ch.shadow.dk(0.3))
    let bandPath = pathOf(band)
    p.inside(bandPath) {
        var t = 0.0
        var course = 0
        while t < 1.0 {
            let x0 = Double(a.x) + (Double(b.x) - Double(a.x)) * t
            let y0 = Double(a.y) + (Double(b.y) - Double(a.y)) * t
            let h = nearHeight + (farHeight - nearHeight) * pow(t, 0.8)
            let stoneH = max(4, h * 0.19)
            let stoneW = max(6, stoneH * rng.r(1.4, 2.4))
            let dt = stoneW / hypot(Double(b.x - a.x), Double(b.y - a.y))
            var yy = y0 - stoneH * 0.5
            var row = 0
            while yy > y0 - h + stoneH * 0.3 {
                let shift = (row % 2 == 0) ? 0 : stoneW * 0.5
                let cx = x0 + shift * 0.3, cy = yy
                let poly = stonePolygon(kind: kind, cls: .builder, seed: rng.next(), width: stoneW * rng.r(0.85, 1.1), height: stoneH * rng.r(0.85, 1.05), at: pt(cx, cy), tilt: atan2(Double(b.y - a.y), Double(b.x - a.x)) * 0.5)
                if stoneW > 14 {
                    paintStone(p, poly: poly, kind: kind, seed: rng.next(), age: age, ink: stoneW > 24, hatch: false)
                } else {
                    p.shape(poly, ch.body.mix(ch.light, rng.d() * 0.4).dk(0.1))
                }
                yy -= stoneH * 0.95
                row += 1
            }
            t += dt
            course += 1
            if course > 400 { break }
        }
        var cope = 0.0
        while cope < 1.0 {
            let x = Double(a.x) + (Double(b.x) - Double(a.x)) * cope
            let y = Double(a.y) + (Double(b.y) - Double(a.y)) * cope
            let h = nearHeight + (farHeight - nearHeight) * pow(cope, 0.8)
            let cw = max(4, h * 0.11), chh = max(5, h * 0.2)
            let poly = stonePolygon(kind: kind, cls: .cope, seed: rng.next(), width: cw, height: chh, at: pt(x, y - h + chh * 0.35))
            if cw > 8 { paintStone(p, poly: poly, kind: kind, seed: rng.next(), age: age, bed: .pi / 2, ink: cw > 14, hatch: false) } else { p.shape(poly, ch.body.dk(0.2)) }
            cope += cw * 1.05 / hypot(Double(b.x - a.x), Double(b.y - a.y))
        }
    }
    p.gradientLine(bandPath, from: pt(Double(a.x), Double(a.y)), to: pt(Double(b.x), Double(b.y)), Pot.shadowInk.al(0), tone.skyLow.al(0.45))
    p.gradientLine(bandPath, from: pt(0, Double(a.y) - nearHeight), to: pt(0, Double(a.y)), Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.35 * (1 - tone.light) + 0.15))
}

func batterFrameAt(_ p: Leaf, x: Double, y: Double, height: Double, lean: Double, tone: FellTone, seed: UInt64) {
    var rng = Chip(seed)
    let dark = Pot.woodDark.dk(0.5 * (1 - tone.light))
    let legL = handleRing(from: pt(x - height * 0.30, y), to: pt(x - height * 0.10 + lean, y - height), width: height * 0.05)
    let legR = handleRing(from: pt(x + height * 0.30, y), to: pt(x + height * 0.10 + lean, y - height), width: height * 0.05)
    let cross = handleRing(from: pt(x - height * 0.23 + lean * 0.35, y - height * 0.36), to: pt(x + height * 0.23 + lean * 0.35, y - height * 0.36), width: height * 0.042)
    for ring in [legL, legR, cross] {
        p.shape(ring, dark)
        pen(p, [ring[0], ring[ring.count / 2]], weight: height * 0.008, colour: Pot.wood.lt(0.2).al(0.5 * tone.light), wobble: 0.3, taper: true, seed: rng.next())
    }
}

func skyAndFells(_ p: Leaf, tone: FellTone, seed: UInt64, box: CGRect, horizon: Double) {
    var rng = Chip(seed)
    p.gradientRect(box, tone.skyTop, tone.skyLow)
    if tone.sun >= 0 {
        let sx = Double(box.minX) + Double(box.width) * (0.2 + tone.sun * 0.5)
        let sy = horizon - Double(box.height) * (0.05 + tone.sun * 0.55)
        softGlowAt(p, cx: sx, cy: sy, radius: Double(box.width) * 0.5, colour: Hue(r: 1.0, g: 0.92, b: 0.70), strength: 0.35 + tone.warm * 0.3)
        if tone.sun < 0.2 { softGlowAt(p, cx: sx, cy: sy + 20, radius: Double(box.width) * 0.25, colour: Hue(r: 1.0, g: 0.75, b: 0.45), strength: 0.45) }
    }
    if tone.moon > 0 {
        let mx = Double(box.minX) + Double(box.width) * 0.78, my = Double(box.minY) + Double(box.height) * 0.18
        softGlowAt(p, cx: mx, cy: my, radius: 160, colour: Hue(r: 0.85, g: 0.88, b: 1.0), strength: 0.28 * tone.moon)
        p.dot(mx, my, 22, Hue(r: 0.94, g: 0.95, b: 0.90).al(tone.moon))
        p.dot(mx - 9, my - 5, 19, tone.skyTop.al(tone.moon * 0.9))
    }
    if tone.stars > 0.05 {
        for _ in 0..<160 {
            let x = rng.r(Double(box.minX), Double(box.maxX)), y = rng.r(Double(box.minY), horizon - 40)
            p.dot(x, y, rng.r(0.6, 1.6), Hue(r: 1, g: 1, b: 1, a: tone.stars * rng.r(0.3, 0.9)))
        }
    }
    for _ in 0..<4 {
        let cx = rng.r(Double(box.minX), Double(box.maxX)), cy = rng.r(Double(box.minY) + 40, horizon - 120)
        let cloud = lumpy(cx: cx, cy: cy, rx: rng.r(120, 260), ry: rng.r(18, 40), rough: 0.25, steps: 22, seed: rng.next())
        wash(p, cloud, tone.skyLow.lt(0.35).warm(tone.warm * 0.4), strength: 0.28 * (0.4 + tone.light * 0.6), bleed: 10, seed: rng.next())
    }
    let ridges: [(Double, Double, Double, Hue)] = [(horizon - 150, 34, 0.004, tone.far.mix(tone.skyLow, 0.35)), (horizon - 90, 26, 0.006, tone.far), (horizon - 30, 18, 0.008, tone.mid.mix(tone.far, 0.35))]
    for (base, amp, freq, hue) in ridges {
        let ring = ridgeRing(p, base: base, amp: amp, freq: freq, seed: rng.next(), box: box)
        p.shape(ring, hue)
        wash(p, ring, hue.lt(0.08), strength: 0.3, bleed: 4, seed: rng.next())
    }
    if tone.mist > 0.05 {
        p.gradientRect(CGRect(x: box.minX, y: horizon - 130, width: box.width, height: 150), tone.skyLow.lt(0.3).al(0), tone.skyLow.lt(0.3).al(0.75 * tone.mist))
    }
}

func drawFellPlate(_ index: Int, dir: String) {
    let (key, words, tone) = fellHours[index]
    let p = Leaf(1200, 820)
    let seed = hashOf("fell_\(key)")
    var rng = Chip(seed)
    p.fillAll(tone.skyLow)
    p.flipDown()
    p.light = stoneLight
    let box = CGRect(x: 0, y: 0, width: 1200, height: 820)
    let horizon = 400.0
    skyAndFells(p, tone: tone, seed: rng.next(), box: box, horizon: horizon)
    let near = ridgeRing(p, base: horizon + 10, amp: 14, freq: 0.006, seed: rng.next(), box: box)
    p.shape(near, tone.near)
    wash(p, near, tone.near.lt(0.1).warm(tone.warm * 0.2), strength: 0.35, bleed: 6, seed: rng.next())
    let grassTone = tone.near.dk(0.35)
    hairs(p, pathOf(near), count: 1800, length: 14, weight: 0.9, spread: 0.6, colour: grassTone.al(0.5), seed: rng.next())
    for _ in 0..<14 {
        let x = rng.r(60, 1140), y = rng.r(horizon + 30, 780)
        wash(p, lumpy(cx: x, cy: y, rx: rng.r(60, 140), ry: rng.r(14, 30), rough: 0.3, steps: 14, seed: rng.next()), Pot.bracken.mix(tone.near, 0.5), strength: 0.22, bleed: 6, seed: rng.next())
    }
    let sheepTone = Pot.fleece.dk(0.7 * (1 - tone.light)).warm(tone.warm * 0.3)
    let sheepDark = Pot.shadowInk.lt(0.15 * tone.light)
    for k in 0..<7 {
        let t = Double(k) / 7
        let x = 700 + t * 420 + rng.signed() * 40
        let y = horizon + 60 + t * 40 + rng.signed() * 20
        sheepAt(p, x: x, y: y, size: 28 + t * 30, tone: sheepTone, dark: sheepDark, facingLeft: rng.chance(0.5), grazing: rng.chance(0.65), seed: rng.next())
    }
    fellWall(p, from: pt(80, 760), to: pt(660, 430), nearHeight: 250, farHeight: 22, tone: tone, kind: .gritstone, age: 0.45, seed: rng.next())
    batterFrameAt(p, x: 260, y: 700, height: 300, lean: 40, tone: tone, seed: rng.next())
    pen(p, [pt(180, 560), pt(600, 470)], weight: 2.0, colour: Hue(r: 0.95, g: 0.90, b: 0.70).al(0.7 + 0.3 * tone.light), wobble: 0.4, taper: false, seed: rng.next())
    if index == 5 {
        for k in 0..<2 {
            let cx = 820 + Double(k) * 130, cy = 170 + Double(k) * 40
            let wing = [pt(cx - 42, cy - 6), pt(cx - 12, cy + 4), pt(cx, cy), pt(cx + 12, cy + 4), pt(cx + 46, cy - 10), pt(cx + 14, cy + 12), pt(cx, cy + 10), pt(cx - 14, cy + 12)]
            p.shape(wing, Pot.shadowInk.al(0.85))
            pen(p, [pt(cx + 8, cy + 4), pt(cx + 28, cy + 18)], weight: 1.8, colour: Pot.shadowInk.al(0.85), wobble: 0.2, taper: true, seed: rng.next())
        }
    }
    let heapSeed = rng.next()
    var hs = Chip(heapSeed)
    for _ in 0..<22 {
        let x = hs.r(700, 1120), y = hs.r(690, 790)
        let poly = stonePolygon(kind: .gritstone, cls: .builder, seed: hs.next(), width: hs.r(40, 110), height: hs.r(22, 48), at: pt(x, y), tilt: hs.r(-0.4, 0.4))
        paintStone(p, poly: poly, kind: .gritstone, seed: hs.next(), age: 0.1, ink: true, hatch: false)
    }
    p.gradientRect(CGRect(x: 0, y: 0, width: 1200, height: 820), Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.28 * (1 - tone.light)))
    p.radial(pt(600, 400), 900, Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.30))
    p.box(0, 730, 1200, 90, Pot.shadowInk.al(0.45))
    letter(p, words, at: 600, 770, size: 30, colour: Pot.paperWarm, face: "Copperplate-Bold", align: .centre, tracking: 1.5)
    letter(p, fellNote(index), at: 600, 800, size: 19, colour: Pot.paperWarm.al(0.85), face: "Georgia-Italic", align: .centre)
    p.writeJPG(dir, "fell_\(key)")
}

func fellNote(_ index: Int) -> String {
    switch index {
    case 0: return "The wall keeps the flock without a hand on it"
    case 1: return "Mist in the bottoms, the heap wet, the line still slack"
    case 2: return "The best hour on the bank, before the hands tire"
    case 3: return "Full light on the face and every joint showing"
    case 4: return "The sun has crossed the wall and the far face is in shadow"
    case 5: return "Curlews over the fell and the last course to the line"
    default: return "The frame left against the wall for the morning"
    }
}

func drawOnboardPlate(_ index: Int, dir: String) {
    let p = Leaf(1200, 900)
    let seed = hashOf("ob_\(index)")
    var rng = Chip(seed)
    plateGround(p, seed: seed, tone: Pot.paperWarm)
    p.light = stoneLight
    let box = CGRect(x: 70, y: 70, width: 1060, height: 640)
    switch index {
    case 0:
        hillBackdrop(p, box: box, seed: rng.next())
        let turf = [pt(70, 560), pt(1130, 560), pt(1130, 710), pt(70, 710)]
        p.shape(turf, Pot.grassDeep)
        wash(p, turf, Pot.grass, strength: 0.5, bleed: 4, seed: rng.next())
        hairs(p, pathOf(turf), count: 500, length: 12, weight: 0.9, spread: 0.55, colour: Pot.grassDeep.dk(0.2).al(0.6), seed: rng.next())
        let trench = [pt(200, 540), pt(1000, 540), pt(1000, 600), pt(200, 600)]
        p.shape(trench, Pot.earthDeep.dk(0.2))
        grit(p, pathOf(trench), density: 0.04, sizeMin: 0.8, sizeMax: 2.2, colour: Pot.stoneLight.al(0.6), seed: rng.next())
        var hs = Chip(rng.next())
        for k in 0..<70 {
            let t = Double(k) / 70
            let x = hs.r(150, 1050), y = 560 - abs(sin(t * 3.1)) * hs.r(0, 220) + hs.r(-20, 20)
            let poly = stonePolygon(kind: .gritstone, cls: hs.chance(0.2) ? .footing : .builder, seed: hs.next(), width: hs.r(60, 150), height: hs.r(30, 70), at: pt(x, y), tilt: hs.r(-0.5, 0.5))
            paintStone(p, poly: poly, kind: .gritstone, seed: hs.next(), age: 0.08, ink: true, hatch: false)
        }
        plateCaption(p, title: "The heap on the bank", sub: "Stone off the heap, into the wall, once", y: 740, titleSize: 36)
    case 1:
        let c = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 2.2, height: 1.35, seed: hashOf("ob.rising"))
        var wall = WallBuilder.reference(c, attempts: 2)
        let keep = wall.placed.filter { $0.y < 0.72 }.map { $0.id }
        for s in wall.stones where s.placed && !keep.contains(s.id) { _ = wall.lift(s.id) }
        wall.lineHeight = 0.86
        hillBackdrop(p, box: box, seed: rng.next())
        let map = mapFor(wall, box: box.insetBy(dx: 20, dy: 10))
        drawElevation(p, wall: wall, map: map, age: 0.05, frame: true, line: true, seed: rng.next())
        groundBand(p, map: map, wall: wall, box: box, seed: rng.next())
        plateCaption(p, title: "The wall rising to the line", sub: "Footings, courses, hearting, throughs, cope", y: 740, titleSize: 36)
    case 2:
        let c = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 1.8, height: 1.35, seed: hashOf("ob.section"))
        let wall = WallBuilder.reference(c, attempts: 2)
        drawSection(p, wall: wall, at: pt(560, 650), ppm: 300, age: 0.1, labels: true, seed: rng.next())
        plateCaption(p, title: "What the judge sees", sub: "The section tells the truth: the core, the throughs, the batter", y: 740, titleSize: 36)
    default:
        let tone = fellHours[3].2
        skyAndFells(p, tone: tone, seed: rng.next(), box: box, horizon: 420)
        let near = ridgeRing(p, base: 430, amp: 12, freq: 0.006, seed: rng.next(), box: box)
        p.shape(near, tone.near)
        hairs(p, pathOf(near), count: 1200, length: 12, weight: 0.9, spread: 0.6, colour: tone.near.dk(0.35).al(0.5), seed: rng.next())
        fellWall(p, from: pt(90, 690), to: pt(560, 470), nearHeight: 150, farHeight: 20, tone: tone, kind: .gritstone, age: 0.6, seed: rng.next())
        fellWall(p, from: pt(1120, 640), to: pt(700, 460), nearHeight: 130, farHeight: 18, tone: tone, kind: .limestone, age: 0.3, seed: rng.next())
        for k in 0..<5 {
            sheepAt(p, x: 500 + Double(k) * 110, y: 560 + Double(k % 2) * 30, size: 30, tone: Pot.fleece, dark: Pot.shadowInk, facingLeft: k % 2 == 0, grazing: true, seed: rng.next())
        }
        p.insideRect(box) { }
        plateCaption(p, title: "The field keeps what stood", sub: "Your walls weather on the fell, in real time, with the sheep behind them", y: 740, titleSize: 36)
    }
    p.writeJPG(dir, "ob_\(index)")
}

let decorKeys: [String] = ["sheep", "gate", "tree", "frame", "curlew", "hawthorn", "barn", "sky", "rowan", "bracken", "stile", "crag"]

func drawDecorPlate(_ key: String, dir: String) {
    let p = Leaf(900, 600)
    let seed = hashOf("dc_\(key)")
    var rng = Chip(seed)
    let tone = fellHours[3].2
    p.fillAll(tone.skyLow)
    p.flipDown()
    p.light = stoneLight
    let box = CGRect(x: 0, y: 0, width: 900, height: 600)
    let horizon = key == "sky" || key == "curlew" ? 520.0 : 330.0
    skyAndFells(p, tone: tone, seed: rng.next(), box: box, horizon: horizon)
    let near = ridgeRing(p, base: horizon + 8, amp: 10, freq: 0.007, seed: rng.next(), box: box)
    p.shape(near, tone.near)
    wash(p, near, tone.near.lt(0.1), strength: 0.35, bleed: 5, seed: rng.next())
    hairs(p, pathOf(near), count: 900, length: 12, weight: 0.9, spread: 0.6, colour: tone.near.dk(0.35).al(0.5), seed: rng.next())
    switch key {
    case "sheep":
        sheepAt(p, x: 450, y: 480, size: 150, tone: Pot.fleece, dark: Pot.shadowInk, facingLeft: true, grazing: true, seed: rng.next())
        sheepAt(p, x: 720, y: 400, size: 70, tone: Pot.fleece, dark: Pot.shadowInk, facingLeft: false, grazing: false, seed: rng.next())
    case "gate":
        for x in [200.0, 700.0] {
            let post = handleRing(from: pt(x, 540), to: pt(x, 200), width: 34)
            inkWash(p, post, Pot.woodDark.lt(0.15), strength: 0.7, hatchDepth: 1, inset: 10, seed: rng.next())
        }
        for (k, y) in [230.0, 300.0, 370.0, 440.0, 510.0].enumerated() {
            let bar = handleRing(from: pt(215, y), to: pt(685, y - 6), width: 22)
            inkWash(p, bar, Pot.wood.dk(0.1), strength: 0.65, hatchDepth: 1, inset: 8, weight: 1.6, seed: rng.next() &+ UInt64(k))
        }
        let diag = handleRing(from: pt(230, 500), to: pt(670, 240), width: 20)
        inkWash(p, diag, Pot.wood.dk(0.1), strength: 0.65, hatchDepth: 1, inset: 8, weight: 1.6, seed: rng.next())
        for x in [200.0, 700.0] {
            let hinge = [pt(x + 14, 250), pt(x + 60, 250), pt(x + 60, 262), pt(x + 14, 262)]
            p.shape(hinge, Pot.steelDark)
        }
    case "tree", "hawthorn", "rowan":
        let trunk = bandOf([pt(450, 540), pt(440, 420), pt(470, 300), pt(520, 200)], [46, 34, 22, 12], per: 8)
        p.shape(offsetRing(trunk, 8, 6), Pot.shadowInk.al(0.2))
        inkWash(p, trunk, Pot.woodDark.lt(0.1), strength: 0.7, hatchDepth: 2, inset: 12, seed: rng.next())
        for k in 0..<5 {
            let a = -1.1 + Double(k) * 0.5
            let branch = bandOf([pt(480, 320 - Double(k) * 30), pt(480 + cos(a) * 140, 300 - Double(k) * 30 + sin(a) * 120), pt(480 + cos(a) * 220, 280 - Double(k) * 30 + sin(a) * 200)], [14, 8, 3], per: 8)
            inkWash(p, branch, Pot.woodDark.lt(0.1), strength: 0.6, hatchDepth: 1, inset: 5, weight: 1.2, seed: rng.next())
        }
        let leafTone = key == "rowan" ? Pot.moss.lt(0.15) : Pot.moss
        for _ in 0..<26 {
            let x = rng.r(330, 720), y = rng.r(120, 330)
            let clump = lumpy(cx: x, cy: y, rx: rng.r(40, 80), ry: rng.r(26, 50), rough: 0.35, steps: 16, seed: rng.next())
            wash(p, clump, leafTone.mix(Pot.grassDeep, rng.d()), strength: 0.5, bleed: 5, seed: rng.next())
            hairs(p, pathOf(clump), count: 30, length: 8, weight: 0.7, spread: 1.2, colour: Pot.mossDeep.al(0.6), seed: rng.next())
        }
        if key != "tree" {
            let berry = key == "rowan" ? Hue(r: 0.85, g: 0.30, b: 0.15) : Hue(r: 0.60, g: 0.10, b: 0.10)
            for _ in 0..<120 { p.dot(rng.r(340, 700), rng.r(140, 320), rng.r(2, 4), berry.al(0.85)) }
        }
        if key == "tree" {
            let stump = handleRing(from: pt(640, 520), to: pt(760, 470), width: 30)
            paintStone(p, poly: stump, kind: .gritstone, seed: rng.next(), age: 0.6, ink: true, hatch: false)
        }
    case "frame":
        batterFrameAt(p, x: 450, y: 540, height: 360, lean: 30, tone: tone, seed: rng.next())
        pen(p, [pt(60, 380), pt(840, 372)], weight: 2.2, colour: Hue(r: 0.95, g: 0.90, b: 0.70), wobble: 0.4, taper: false, seed: rng.next())
        pen(p, [pt(60, 300), pt(840, 292)], weight: 2.2, colour: Hue(r: 0.95, g: 0.90, b: 0.70), wobble: 0.4, taper: false, seed: rng.next())
    case "curlew":
        for k in 0..<3 {
            let cx = 300 + Double(k) * 200, cy = 200 + Double(k) * 60
            let s = 1.6 - Double(k) * 0.3
            let wing = [pt(cx - 60 * s, cy - 8 * s), pt(cx - 16 * s, cy + 6 * s), pt(cx, cy), pt(cx + 16 * s, cy + 6 * s), pt(cx + 64 * s, cy - 14 * s), pt(cx + 18 * s, cy + 16 * s), pt(cx, cy + 14 * s), pt(cx - 18 * s, cy + 16 * s)]
            p.shape(wing, Pot.shadowInk.al(0.88))
            pen(p, [pt(cx + 10 * s, cy + 6 * s), pt(cx + 38 * s, cy + 26 * s)], weight: 2.4 * s, colour: Pot.shadowInk.al(0.85), wobble: 0.2, taper: true, seed: rng.next())
        }
    case "barn":
        let wallRing = [pt(240, 520), pt(660, 520), pt(660, 320), pt(240, 320)]
        heartingTexture(p, pathOf(wallRing), kind: .gritstone, seed: rng.next(), scale: 1.0)
        var hs = Chip(rng.next())
        var y = 512.0
        while y > 330 {
            var x = 244.0 + (Int(y) % 2 == 0 ? 0 : 30)
            while x < 650 {
                let w = min(650 - x, hs.r(40, 90))
                let poly = stonePolygon(kind: .gritstone, cls: .builder, seed: hs.next(), width: w - 3, height: 26, at: pt(x + w / 2, y - 13))
                paintStone(p, poly: poly, kind: .gritstone, seed: hs.next(), age: 0.5, ink: false, hatch: false)
                x += w
            }
            y -= 28
        }
        let roof = [pt(220, 330), pt(450, 190), pt(680, 330)]
        p.shape(roof, Pot.slateTone)
        for k in 0..<12 {
            let t = Double(k) / 12
            pen(p, [pt(220 + 230 * t, 330 - 140 * t), pt(680 - 230 * t, 330 - 140 * t)], weight: 1.2, colour: Pot.ink.al(0.4), wobble: 0.3, taper: false, seed: rng.next())
        }
        penOutline(p, roof, weight: 2.2, colour: Pot.ink.al(0.8), seed: rng.next())
        let door = [pt(410, 520), pt(490, 520), pt(490, 400), pt(410, 400)]
        inkWash(p, door, Pot.woodDark, strength: 0.8, hatchDepth: 2, inset: 12, seed: rng.next())
    case "sky":
        break
    case "bracken":
        for _ in 0..<40 {
            let x = rng.r(80, 820), y = rng.r(360, 560)
            let stem = [pt(x, y), pt(x + rng.signed() * 20, y - 80), pt(x + rng.signed() * 40, y - 150)]
            pen(p, stem, weight: 3, colour: Pot.bracken.dk(0.3), wobble: 0.4, taper: true, seed: rng.next())
            for k in 0..<8 {
                let t = Double(k) / 8
                let base = pt(Double(stem[0].x) + (Double(stem[2].x) - Double(stem[0].x)) * t, y - 150 * t)
                for side in [-1.0, 1.0] {
                    pen(p, [base, pt(Double(base.x) + side * (30 - 20 * t), Double(base.y) - 10)], weight: 2, colour: Pot.bracken.mix(Pot.grassDeep, rng.d() * 0.5), wobble: 0.3, taper: true, seed: rng.next())
                }
            }
        }
    case "stile":
        let stones = layCourses([
            [(0.38, 0.18), (0.40, 0.18), (0.36, 0.18), (0.40, 0.18)],
            [(0.30, 0.15), (0.34, 0.15), (0.50, 0.15), (0.36, 0.15)],
            [(0.36, 0.16), (0.30, 0.16), (0.42, 0.16), (0.44, 0.16)],
            [(0.30, 0.15), (0.40, 0.15), (0.34, 0.15), (0.46, 0.15)]
        ])
        let map = WallMap(ox: 130, oy: 540, ppm: 400)
        paintDiagram(p, stones: stones, map: map, kind: .gritstone, seed: rng.next())
        let stepX: [Double] = [0.42, 0.84, 1.26]
        for k in 0..<3 {
            let sx = stepX[k]
            let y = 0.19 + Double(k) * 0.16
            let step: [CGPoint] = [map.at(sx - 0.02, y), map.at(sx + 0.24, y), map.at(sx + 0.24, y + 0.08), map.at(sx - 0.02, y + 0.08)]
            let front = offsetRing(step, 16, 14)
            p.shape(offsetRing(front, 8, 22), Pot.shadowInk.al(0.4))
            let side: [CGPoint] = [step[1], front[1], front[2], step[2]]
            let top: [CGPoint] = [step[3], step[2], front[2], front[3]]
            paintStone(p, poly: side, kind: .gritstone, seed: rng.next(), ink: true, hatch: false)
            paintStone(p, poly: top, kind: .gritstone, seed: rng.next(), ink: true, hatch: false)
            paintStone(p, poly: front, kind: .gritstone, seed: rng.next(), ink: true, hatch: false)
        }
    case "crag":
        let crag = lumpy(cx: 450, cy: 330, rx: 360, ry: 140, rough: 0.14, steps: 26, seed: rng.next())
        paintStone(p, poly: crag, kind: .gritstone, seed: rng.next(), age: 0.9, ink: true, hatch: true)
        for _ in 0..<6 {
            let x = rng.r(200, 700), y = rng.r(240, 420)
            pen(p, [pt(x, y), pt(x + rng.r(60, 160), y + rng.signed() * 20)], weight: 2.4, colour: Pot.shadowInk.al(0.5), wobble: 1.0, taper: true, seed: rng.next())
        }
    default:
        break
    }
    p.radial(pt(450, 300), 640, Hue(r: 0, g: 0, b: 0, a: 0), Hue(r: 0, g: 0, b: 0, a: 0.22))
    p.writeJPG(dir, "dc_\(key)")
}
