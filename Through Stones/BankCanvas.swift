import SwiftUI

struct FallAnim: Equatable {
    var id: Int
    var fromY: Double
    var start: Double
}

struct ToppleAnim: Equatable {
    var poly: [Pt]
    var pivot: Pt
    var direction: Int
    var start: Double
    var kind: StoneKind
    var seed: UInt64
}

struct TestAnim: Equatable {
    var kind: TestKind
    var outcome: TestOutcome
    var start: Double
}

struct BankCanvas: View {
    @ObservedObject var session: WallSession
    var dragPoint: CGPoint?
    var fall: FallAnim?
    var topple: ToppleAnim?
    var test: TestAnim?
    var selected: Int?
    var lineDrag: Double?
    var cutting: (Double, Double)?
    var onMap: (PaintMap) -> Void

    var body: some View {
        let animating = dragPoint != nil || fall != nil || topple != nil || test != nil || (session.wall?.placed.contains { $0.rocking && !$0.pinned } ?? false)
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !animating)) { timeline in
            Canvas { ctx, size in
                guard let wall = session.wall else { return }
                let t = timeline.date.timeIntervalSinceReferenceDate
                let map = PaintMap.fit(length: wall.length, height: wall.height, slope: wall.feature.slopeRate, in: size, margin: 0.22, topRoom: 0.62, bottomRoom: 0.3)
                DispatchQueue.main.async { onMap(map) }
                drawBackdrop(&ctx, size: size, map: map, wall: wall, t: t)
                var lost: Set<Int> = []
                var sag: [Int: Double] = [:]
                var shove: [Int: Double] = [:]
                var progress = 0.0
                if let test = test {
                    progress = min(1, (t - test.start) / 1.6)
                    for id in test.outcome.lost { lost.insert(id) }
                    for (id, v) in test.outcome.sag { sag[id] = v * progress }
                    for (id, v) in test.outcome.shove { shove[id] = v * progress }
                }
                var fallLost = lost
                if let fall = fall, t - fall.start < 0.32 { fallLost.insert(fall.id) }
                var highlight: Set<Int> = []
                if let sel = selected { highlight.insert(sel) }
                let faultIds: Set<Int> = session.showJoints ? Set(session.sheet?.faults.flatMap { $0.ids } ?? []) : []
                WallPaint.drawStones(&ctx, stones: wall.stones, map: map, age: 0, detail: 1, lost: fallLost, sag: sag, shove: shove, highlight: highlight, faultIds: faultIds, coreKind: wall.kind, trench: wall.trenchDepth)
                if let test = test {
                    drawFalling(&ctx, wall: wall, map: map, ids: test.outcome.lost, progress: progress, t: t)
                }
                for s in wall.placed where s.rocking && !s.pinned && !lost.contains(s.id) {
                    let b = Geometry.bounds(s.polygon)
                    let c = map.at(s.x, b.maxY + 0.06)
                    let wob = sin(t * 9) * 3
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: c.x + wob, y: c.y), radius: max(6, map.len(0.08)), startAngle: .degrees(205), endAngle: .degrees(335), clockwise: false)
                    ctx.stroke(arc, with: .color(Fell.rubric.opacity(0.85)), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                }
                if session.showJoints, let sheet = session.sheet {
                    WallPaint.drawJoints(&ctx, joints: sheet.joints, map: map)
                }
                if let fall = fall, let s = wall.stone(fall.id), t - fall.start < 0.32 {
                    let k = min(1, (t - fall.start) / 0.28)
                    let eased = k * k
                    let y = fall.fromY + (s.y - fall.fromY) * eased
                    let poly = s.polygon(at: s.x, y, tilt: s.tilt).map { map.at($0) }
                    StonePaint.draw(&ctx, poly: poly, kind: s.kind, seed: s.seed &+ 3, bed: -s.tilt, detail: 1, ink: true)
                } else if let fall = fall, t - fall.start < 0.7, let s = wall.stone(fall.id) {
                    let k = (t - fall.start - 0.28) / 0.4
                    let b = Geometry.bounds(s.polygon)
                    for i in 0..<5 {
                        let px = map.at(b.minX + (b.maxX - b.minX) * Double(i) / 4, b.minY).x
                        let py = map.at(0, b.minY).y - CGFloat(k * 10)
                        ctx.fill(Path(ellipseIn: CGRect(x: px - 3, y: py - 3, width: 6, height: 6)), with: .color(Fell.pageDeep.opacity(0.6 * (1 - k))))
                    }
                }
                if let top = topple, t - top.start < 0.8 {
                    let k = min(1, (t - top.start) / 0.7)
                    let angle = Double(top.direction) * k * 1.4
                    let drop = k * k * 0.4
                    let poly = top.poly.map { q -> CGPoint in
                        let dx = q.x - top.pivot.x, dy = q.y - top.pivot.y
                        let rx = dx * cos(angle) + dy * sin(angle)
                        let ry = -dx * sin(angle) + dy * cos(angle)
                        return map.at(top.pivot.x + rx + Double(top.direction) * k * 0.15, top.pivot.y + ry - drop)
                    }
                    StonePaint.draw(&ctx, poly: poly, kind: top.kind, seed: top.seed &+ 3, detail: 1, ink: true, alpha: 1 - k * 0.6)
                }
                drawFrames(&ctx, map: map, wall: wall, t: t)
                if let (a, b) = cutting {
                    let y = map.at(0, -0.02).y
                    var line = Path()
                    line.move(to: CGPoint(x: map.at(min(a, b), 0).x, y: y))
                    line.addLine(to: CGPoint(x: map.at(max(a, b), 0).x, y: y))
                    ctx.stroke(line, with: .color(Fell.earth.opacity(0.9)), style: StrokeStyle(lineWidth: max(4, map.len(0.05)), lineCap: .round))
                }
                if let held = session.held, let s = wall.stone(held.id), let drag = dragPoint {
                    let x = map.metres(drag.x)
                    let (rest, landing) = wall.preview(held.id, at: x, tilt: held.tilt, orientation: held.orientation)
                    var probe = s
                    probe.orientation = held.orientation
                    let hoverY = max(map.height(drag.y), (landing?.y ?? 0) + 0.02)
                    let ghost = probe.polygon(at: x, hoverY, tilt: held.tilt).map { map.at($0) }
                    if let l = landing {
                        let landed = probe.polygon(at: x, l.y, tilt: l.tilt).map { map.at($0) }
                        var tone = Fell.good
                        switch rest {
                        case .settled: tone = Fell.good
                        case .rocking: tone = Fell.query
                        default: tone = Fell.rubric
                        }
                        ctx.fill(StonePaint.path(landed), with: .color(tone.opacity(0.28)))
                        ctx.stroke(StonePaint.path(landed), with: .color(tone.opacity(0.9)), style: StrokeStyle(lineWidth: 1.6, dash: [5, 4]))
                        var guide = Path()
                        guide.move(to: map.at(x, hoverY))
                        guide.addLine(to: map.at(x, l.y))
                        ctx.stroke(guide, with: .color(tone.opacity(0.5)), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                    }
                    StonePaint.draw(&ctx, poly: ghost, kind: s.kind, seed: s.seed &+ 3, bed: -held.tilt, detail: 1, ink: true, alpha: 0.92)
                }
                if let sel = selected, let s = wall.stone(sel), s.placed {
                    let b = Geometry.bounds(s.polygon)
                    let rect = CGRect(x: map.at(b.minX, 0).x - 3, y: map.at(0, b.maxY).y - 3, width: map.len(b.maxX - b.minX) + 6, height: map.len(b.maxY - b.minY) + 6)
                    ctx.stroke(Path(roundedRect: rect, cornerRadius: 3), with: .color(Fell.string), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }
                if let test = test, progress < 1 || t - test.start < 3.2 {
                    drawTestOverlay(&ctx, size: size, map: map, wall: wall, test: test, t: t)
                }
            }
        }
    }

    private func drawBackdrop(_ ctx: inout GraphicsContext, size: CGSize, map: PaintMap, wall: Wall, t: Double) {
        let tone = FellClock.at(FellClock.hourValue())
        ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: [tone.skyTop.opacity(0.85), Color.blend(tone.skyLow, Fell.page, 0.3)]), startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height * 0.6)))
        var hill = Path()
        hill.move(to: CGPoint(x: -10, y: size.height))
        var x: CGFloat = -10
        while x <= size.width + 10 {
            hill.addLine(to: CGPoint(x: x, y: size.height * 0.36 + sin(Double(x) * 0.008 + 0.7) * size.height * 0.05))
            x += 24
        }
        hill.addLine(to: CGPoint(x: size.width + 10, y: size.height))
        hill.closeSubpath()
        ctx.fill(hill, with: .color(Color.blend(tone.far, Fell.grass, 0.4)))
        var groundPath = Path()
        groundPath.move(to: CGPoint(x: -10, y: size.height + 10))
        x = -10
        while x <= size.width + 10 {
            let xm = map.metres(x)
            let g = wall.feature.slopeRate * (wall.length - xm) + (wall.feature == .slope ? 0 : 0)
            groundPath.addLine(to: CGPoint(x: x, y: map.at(0, g).y))
            x += 12
        }
        groundPath.addLine(to: CGPoint(x: size.width + 10, y: size.height + 10))
        groundPath.closeSubpath()
        ctx.fill(groundPath, with: .color(Color.blend(tone.near, Fell.grass, 0.5)))
        let trenchTop = map.at(0, 0).y
        let cutCount = wall.cut.count
        if cutCount > 0 {
            var i = 0
            while i < cutCount {
                if wall.cut[i] {
                    var j = i
                    while j < cutCount && wall.cut[j] { j += 1 }
                    let x0 = map.at(wall.sky.xAt(i), 0).x, x1 = map.at(wall.sky.xAt(j - 1), 0).x
                    let floor = wall.feature == .slope ? wall.trenchFloor(wall.sky.xAt(i)) : -wall.trenchDepth
                    let top = wall.feature == .slope ? floor + wall.trenchDepth : 0
                    ctx.fill(Path(CGRect(x: x0, y: map.at(0, top).y, width: max(1, x1 - x0), height: map.len(top - floor))), with: .color(Fell.earth))
                    i = j
                } else { i += 1 }
            }
        }
        for o in wall.openings {
            let r = CGRect(x: map.at(o.x0, 0).x, y: map.at(0, min(o.y1, wall.height)).y, width: map.len(o.width), height: map.len(min(o.y1, wall.height) - max(o.y0, -0.02)))
            ctx.fill(Path(r), with: .color(Color.blend(tone.skyLow, Fell.grass, 0.5).opacity(0.7)))
            ctx.stroke(Path(r), with: .color(Fell.ink.opacity(0.35)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        }
        _ = trenchTop
    }

    private func drawFrames(_ ctx: inout GraphicsContext, map: PaintMap, wall: Wall, t: Double) {
        let r = wall.rules
        guard r.batter.upperBound > 0.03 || wall.frameSet else { return }
        let lean = wall.frameSet ? wall.batterSet : 0.0
        for end in [0.0, wall.length] {
            WallPaint.frame(&ctx, map: map, x: end, height: wall.height, lean: lean, baseWidth: r.baseWidth, topWidth: r.topWidth, tone: wall.frameSet ? Fell.woodDark : Fell.woodDark.opacity(0.45))
        }
        let lineY = lineDrag ?? wall.lineHeight
        if lineY > 0.01 {
            WallPaint.stringLine(&ctx, map: map, from: -0.05, to: wall.length + 0.05, y: lineY, sag: wall.frameSet ? 0.004 : 0.03)
            let knob = map.at(wall.length + 0.09, lineY)
            ctx.fill(Path(ellipseIn: CGRect(x: knob.x - 9, y: knob.y - 9, width: 18, height: 18)), with: .color(Fell.card))
            ctx.stroke(Path(ellipseIn: CGRect(x: knob.x - 9, y: knob.y - 9, width: 18, height: 18)), with: .color(Fell.ink.opacity(0.7)), lineWidth: 1.5)
            var grip = Path()
            grip.move(to: CGPoint(x: knob.x - 4, y: knob.y - 3))
            grip.addLine(to: CGPoint(x: knob.x + 4, y: knob.y - 3))
            grip.move(to: CGPoint(x: knob.x - 4, y: knob.y + 3))
            grip.addLine(to: CGPoint(x: knob.x + 4, y: knob.y + 3))
            ctx.stroke(grip, with: .color(Fell.ink.opacity(0.6)), lineWidth: 1.2)
        }
        if wall.rules.cope == .turf && wall.turfLaid > 0.02 {
            let y = map.at(0, wall.topMedian).y
            let rect = CGRect(x: map.at(0, 0).x, y: y - map.len(0.1), width: map.len(wall.length * wall.turfLaid), height: map.len(0.12))
            ctx.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(Fell.grassDeep))
        }
        if wall.rules.cope == .locked {
            for lx in wall.locks {
                let c = map.at(lx, wall.topMedian + 0.12)
                WallPaint.pin(&ctx, at: c, size: max(3, map.len(0.03)), kind: wall.kind, front: false)
            }
        }
    }

    private func drawFalling(_ ctx: inout GraphicsContext, wall: Wall, map: PaintMap, ids: [Int], progress: Double, t: Double) {
        for (i, id) in ids.enumerated() {
            guard let s = wall.stone(id) else { continue }
            let delay = Double(i % 6) * 0.06
            let k = max(0, min(1, (progress * 1.6 - delay) / 1.0))
            let angle = (i % 2 == 0 ? 1.0 : -1.0) * k * 1.2
            let dropY = k * k * (s.y + wall.trenchDepth + 0.15)
            let dx = (i % 2 == 0 ? 0.25 : -0.2) * k
            let poly = s.polygon.map { q -> CGPoint in
                let cx = s.x, cy = s.y
                let ddx = q.x - cx, ddy = q.y - cy
                let rx = ddx * cos(angle) + ddy * sin(angle)
                let ry = -ddx * sin(angle) + ddy * cos(angle)
                return map.at(cx + rx + dx, max(-wall.trenchDepth - 0.02, cy + ry - dropY))
            }
            StonePaint.draw(&ctx, poly: poly, kind: s.kind, seed: s.seed &+ 3, detail: 1, ink: true)
        }
    }

    private func drawTestOverlay(_ ctx: inout GraphicsContext, size: CGSize, map: PaintMap, wall: Wall, test: TestAnim, t: Double) {
        let k = min(1, (t - test.start) / 1.6)
        let w = Double(size.width), h = Double(size.height)
        switch test.kind {
        case .frost:
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color.white.opacity(0.18 * (1 - abs(k - 0.5) * 2))))
            var rng = Spool(99)
            for _ in 0..<40 {
                let x = rng.unit() * w, y = rng.unit() * h
                let r = 2 + rng.unit() * 4
                var star = Path()
                for j in 0..<3 {
                    let a = Double(j) * .pi / 3
                    star.move(to: CGPoint(x: x - cos(a) * r, y: y - sin(a) * r))
                    star.addLine(to: CGPoint(x: x + cos(a) * r, y: y + sin(a) * r))
                }
                ctx.stroke(star, with: .color(Color.white.opacity(0.7 * (1 - k))), lineWidth: 1)
            }
        case .sheep:
            let sx = w * (1.05 - k * 0.55)
            let sy = map.at(0, 0).y
            let size = max(28, map.len(0.5))
            let body = Path(ellipseIn: CGRect(x: sx - size * 0.6, y: sy - size * 0.75, width: size * 1.2, height: size * 0.6))
            ctx.fill(body, with: .color(Color(red: 0.88, green: 0.86, blue: 0.80)))
            ctx.fill(Path(ellipseIn: CGRect(x: sx - size * 0.85, y: sy - size * 0.72, width: size * 0.34, height: size * 0.28)), with: .color(Color(red: 0.07, green: 0.06, blue: 0.05)))
            for lx in [-0.35, -0.15, 0.15, 0.35] {
                var leg = Path()
                leg.move(to: CGPoint(x: sx + lx * size, y: sy - size * 0.3))
                leg.addLine(to: CGPoint(x: sx + lx * size + sin(t * 8 + lx * 10) * 2, y: sy))
                ctx.stroke(leg, with: .color(Color(red: 0.07, green: 0.06, blue: 0.05)), lineWidth: max(1.5, size * 0.06))
            }
        case .wind:
            var rng = Spool(7)
            for _ in 0..<30 {
                let y = rng.unit() * h * 0.8
                let x = (rng.unit() * w + t * 300).truncatingRemainder(dividingBy: w + 60) - 30
                var streak = Path()
                streak.move(to: CGPoint(x: x, y: y))
                streak.addLine(to: CGPoint(x: x - 40 - rng.unit() * 30, y: y + 4))
                ctx.stroke(streak, with: .color(Color.white.opacity(0.35 * (1 - k * 0.5))), lineWidth: 1.2)
            }
        case .century:
            let years = Int(k * 100)
            let text = Text("\(years) years").font(Fell.title(20)).foregroundColor(Fell.card)
            ctx.draw(text, at: CGPoint(x: w * 0.5, y: h * 0.12))
            if k > 0.55 {
                let bk = min(1, (k - 0.55) / 0.3)
                let bx = map.at(wall.length * 0.55, wall.height + 0.8 - bk * 0.7)
                var branch = Path()
                branch.move(to: CGPoint(x: bx.x - map.len(0.4), y: bx.y + 6))
                branch.addQuadCurve(to: CGPoint(x: bx.x + map.len(0.45), y: bx.y - 4), control: CGPoint(x: bx.x, y: bx.y - 18))
                branch.move(to: CGPoint(x: bx.x + map.len(0.1), y: bx.y - 8))
                branch.addLine(to: CGPoint(x: bx.x + map.len(0.2), y: bx.y - 30))
                ctx.stroke(branch, with: .color(Fell.woodDark), style: StrokeStyle(lineWidth: max(3, map.len(0.03)), lineCap: .round))
            }
        }
    }
}
