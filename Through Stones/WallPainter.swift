import SwiftUI

struct StoneLook {
    var body: Color
    var light: Color
    var shadow: Color
    var speck: Color
    var speckLight: Color
    var density: Double
    var bedSpacing: Double
}

enum StonePaint {
    static func look(_ kind: StoneKind) -> StoneLook {
        switch kind {
        case .gritstone: return StoneLook(body: Color(red: 0.52, green: 0.44, blue: 0.35), light: Color(red: 0.70, green: 0.62, blue: 0.50), shadow: Color(red: 0.30, green: 0.25, blue: 0.20), speck: Color(red: 0.18, green: 0.14, blue: 0.10), speckLight: Color(red: 0.82, green: 0.74, blue: 0.60), density: 0.045, bedSpacing: 17)
        case .limestone: return StoneLook(body: Color(red: 0.70, green: 0.69, blue: 0.64), light: Color(red: 0.86, green: 0.85, blue: 0.80), shadow: Color(red: 0.46, green: 0.46, blue: 0.42), speck: Color(red: 0.30, green: 0.30, blue: 0.27), speckLight: Color(red: 0.95, green: 0.95, blue: 0.92), density: 0.02, bedSpacing: 24)
        case .oolite: return StoneLook(body: Color(red: 0.79, green: 0.68, blue: 0.47), light: Color(red: 0.92, green: 0.84, blue: 0.64), shadow: Color(red: 0.55, green: 0.45, blue: 0.28), speck: Color(red: 0.45, green: 0.36, blue: 0.20), speckLight: Color(red: 0.97, green: 0.92, blue: 0.76), density: 0.06, bedSpacing: 8)
        case .sandstone: return StoneLook(body: Color(red: 0.65, green: 0.51, blue: 0.37), light: Color(red: 0.82, green: 0.70, blue: 0.54), shadow: Color(red: 0.40, green: 0.30, blue: 0.21), speck: Color(red: 0.35, green: 0.20, blue: 0.10), speckLight: Color(red: 0.90, green: 0.80, blue: 0.64), density: 0.05, bedSpacing: 10)
        case .slate: return StoneLook(body: Color(red: 0.37, green: 0.41, blue: 0.46), light: Color(red: 0.55, green: 0.59, blue: 0.64), shadow: Color(red: 0.20, green: 0.23, blue: 0.28), speck: Color(red: 0.12, green: 0.14, blue: 0.18), speckLight: Color(red: 0.66, green: 0.70, blue: 0.76), density: 0.012, bedSpacing: 5)
        case .granite: return StoneLook(body: Color(red: 0.62, green: 0.58, blue: 0.55), light: Color(red: 0.80, green: 0.76, blue: 0.72), shadow: Color(red: 0.40, green: 0.36, blue: 0.34), speck: Color(red: 0.10, green: 0.10, blue: 0.10), speckLight: Color(red: 0.90, green: 0.72, blue: 0.66), density: 0.10, bedSpacing: 0)
        case .whinstone: return StoneLook(body: Color(red: 0.36, green: 0.34, blue: 0.31), light: Color(red: 0.52, green: 0.48, blue: 0.44), shadow: Color(red: 0.20, green: 0.19, blue: 0.17), speck: Color(red: 0.55, green: 0.35, blue: 0.20), speckLight: Color(red: 0.66, green: 0.62, blue: 0.58), density: 0.035, bedSpacing: 0)
        case .greywacke: return StoneLook(body: Color(red: 0.48, green: 0.46, blue: 0.42), light: Color(red: 0.66, green: 0.63, blue: 0.57), shadow: Color(red: 0.30, green: 0.29, blue: 0.26), speck: Color(red: 0.20, green: 0.18, blue: 0.15), speckLight: Color(red: 0.78, green: 0.74, blue: 0.68), density: 0.04, bedSpacing: 30)
        case .schist: return StoneLook(body: Color(red: 0.54, green: 0.55, blue: 0.57), light: Color(red: 0.74, green: 0.75, blue: 0.78), shadow: Color(red: 0.32, green: 0.33, blue: 0.36), speck: Color(red: 0.20, green: 0.21, blue: 0.24), speckLight: Color(red: 0.98, green: 0.98, blue: 1.0), density: 0.07, bedSpacing: 6)
        case .fieldstone: return StoneLook(body: Color(red: 0.58, green: 0.55, blue: 0.50), light: Color(red: 0.76, green: 0.73, blue: 0.67), shadow: Color(red: 0.36, green: 0.34, blue: 0.31), speck: Color(red: 0.22, green: 0.20, blue: 0.18), speckLight: Color(red: 0.88, green: 0.84, blue: 0.78), density: 0.05, bedSpacing: 0)
        case .flagstone: return StoneLook(body: Color(red: 0.42, green: 0.44, blue: 0.44), light: Color(red: 0.60, green: 0.62, blue: 0.61), shadow: Color(red: 0.24, green: 0.26, blue: 0.26), speck: Color(red: 0.15, green: 0.16, blue: 0.16), speckLight: Color(red: 0.70, green: 0.72, blue: 0.70), density: 0.02, bedSpacing: 4)
        case .clunch: return StoneLook(body: Color(red: 0.86, green: 0.85, blue: 0.78), light: Color(red: 0.96, green: 0.95, blue: 0.90), shadow: Color(red: 0.66, green: 0.65, blue: 0.58), speck: Color(red: 0.55, green: 0.53, blue: 0.46), speckLight: Color(red: 1.0, green: 1.0, blue: 0.98), density: 0.018, bedSpacing: 20)
        }
    }

    static func path(_ poly: [CGPoint]) -> Path {
        var p = Path()
        guard let first = poly.first else { return p }
        p.move(to: first)
        for q in poly.dropFirst() { p.addLine(to: q) }
        p.closeSubpath()
        return p
    }

    static func bounds(_ poly: [CGPoint]) -> CGRect {
        var minX = CGFloat.infinity, maxX = -CGFloat.infinity, minY = CGFloat.infinity, maxY = -CGFloat.infinity
        for q in poly { minX = min(minX, q.x); maxX = max(maxX, q.x); minY = min(minY, q.y); maxY = max(maxY, q.y) }
        return CGRect(x: minX, y: minY, width: max(0.1, maxX - minX), height: max(0.1, maxY - minY))
    }

    static func draw(_ ctx: inout GraphicsContext, poly: [CGPoint], kind: StoneKind, seed: UInt64, age: Double = 0, bed: Double = 0, detail: Int = 2, ink: Bool = true, tint: Color? = nil, alpha: Double = 1) {
        guard poly.count > 2 else { return }
        let look = look(kind)
        let shape = path(poly)
        let box = bounds(poly)
        var rng = Spool(seed)
        var bodyColor = look.body
        if kind == .gritstone { bodyColor = Color.blend(bodyColor, Color.black, age * 0.3) }
        if kind == .limestone || kind == .clunch { bodyColor = Color.blend(bodyColor, Color.white, age * 0.15) }
        if kind == .greywacke || kind == .sandstone { bodyColor = Color.blend(bodyColor, Fell.grit, age * 0.25) }
        var sub = ctx
        sub.opacity = alpha
        sub.fill(shape, with: .color(bodyColor))
        sub.fill(shape, with: .linearGradient(Gradient(colors: [look.light.opacity(0.85), look.body.opacity(0), look.shadow.opacity(0.85)]),
                                              startPoint: CGPoint(x: box.minX, y: box.minY), endPoint: CGPoint(x: box.maxX, y: box.maxY)))
        if detail >= 1 {
            let area = Double(box.width * box.height)
            let count = min(detail >= 2 ? 140 : 40, Int(area * look.density * (detail >= 2 ? 0.35 : 0.12)))
            var clipped = sub
            clipped.clip(to: shape)
            for _ in 0..<count {
                let x = Double(box.minX) + rng.unit() * Double(box.width)
                let y = Double(box.minY) + rng.unit() * Double(box.height)
                let r = rng.range(0.5, 1.4) * max(0.6, Double(box.height) / 90)
                let lightDot = rng.chance(kind == .schist ? 0.6 : 0.4)
                clipped.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color((lightDot ? look.speckLight : look.speck).opacity(rng.range(0.25, 0.6))))
            }
            if look.bedSpacing > 0 && detail >= 2 {
                let sp = look.bedSpacing * max(0.5, Double(box.height) / 90)
                let dx = cos(bed), dy = sin(bed)
                let nx = -dy, ny = dx
                let cx = Double(box.midX), cy = Double(box.midY)
                let span = Double(max(box.width, box.height)) * 1.4
                var u = -span / 2 + rng.range(0, sp)
                while u < span / 2 {
                    var line = Path()
                    line.move(to: CGPoint(x: cx + nx * u - dx * span / 2, y: cy + ny * u - dy * span / 2))
                    line.addLine(to: CGPoint(x: cx + nx * u + dx * span / 2, y: cy + ny * u + dy * span / 2))
                    clipped.stroke(line, with: .color(look.shadow.opacity(0.28)), lineWidth: max(0.6, Double(box.height) / 120))
                    u += sp * rng.range(0.7, 1.3)
                }
            }
            if age > 0.05 {
                let lichenScore = age * kind.lichenRate
                let patches = min(12, Int(lichenScore * area / 2600))
                for _ in 0..<patches {
                    let x = Double(box.minX) + rng.unit() * Double(box.width)
                    let y = Double(box.minY) + rng.unit() * Double(box.height)
                    let r = rng.range(2.5, 6) * (0.5 + lichenScore) * max(0.5, Double(box.height) / 80)
                    let tone: Color = rng.chance(0.65) ? Color(red: 0.80, green: 0.80, blue: 0.68) : (rng.chance(0.6) ? Fell.lichen : Color(red: 0.82, green: 0.60, blue: 0.30))
                    clipped.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r * 0.8, width: r * 2, height: r * 1.6)), with: .color(tone.opacity(0.5)))
                }
                if age > 0.25 {
                    let moss = min(6, Int(age * Double(box.width) / 40))
                    for _ in 0..<moss {
                        let x = Double(box.minX) + rng.unit() * Double(box.width)
                        let y = Double(box.maxY) - rng.unit() * Double(box.height) * 0.3
                        let r = rng.range(2, 5) * (0.6 + age) * max(0.5, Double(box.height) / 80)
                        clipped.fill(Path(ellipseIn: CGRect(x: x - r * 1.3, y: y - r * 0.7, width: r * 2.6, height: r * 1.4)), with: .color(Fell.mossDeep.opacity(0.65)))
                    }
                }
            }
        }
        if let tint = tint {
            sub.fill(shape, with: .color(tint))
        }
        if ink {
            sub.stroke(shape, with: .color(look.light.opacity(0.35)), style: StrokeStyle(lineWidth: max(1, Double(box.height) / 60), lineJoin: .round))
            sub.stroke(shape, with: .color(Fell.ink.opacity(0.75)), style: StrokeStyle(lineWidth: max(0.6, Double(box.height) / 110), lineJoin: .round))
        }
    }
}

struct PaintMap {
    var ox: CGFloat
    var oy: CGFloat
    var ppm: CGFloat

    func at(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: ox + CGFloat(x) * ppm, y: oy - CGFloat(y) * ppm) }
    func at(_ q: Pt) -> CGPoint { at(q.x, q.y) }
    func len(_ m: Double) -> CGFloat { CGFloat(m) * ppm }
    func metres(_ px: CGFloat) -> Double { Double((px - ox) / ppm) }
    func height(_ py: CGFloat) -> Double { Double((oy - py) / ppm) }

    static func fit(length: Double, height: Double, slope: Double, in size: CGSize, margin: Double = 0.14, topRoom: Double = 0.55, bottomRoom: Double = 0.22) -> PaintMap {
        let widthM = length + margin * 2
        let heightM = height + topRoom + bottomRoom + slope * length
        let ppm = min(size.width / CGFloat(widthM), size.height / CGFloat(heightM))
        let ox = (size.width - CGFloat(length) * ppm) / 2
        let oy = size.height - CGFloat(bottomRoom) * ppm
        return PaintMap(ox: ox, oy: oy, ppm: ppm)
    }
}

enum WallPaint {
    static func hearting(_ ctx: inout GraphicsContext, rect: CGRect, kind: StoneKind, seed: UInt64, detail: Int) {
        let look = StonePaint.look(kind)
        ctx.fill(Path(rect), with: .color(Color.blend(look.shadow, Color.black, 0.35)))
        guard detail >= 1 else { return }
        var rng = Spool(seed)
        let n = min(detail >= 2 ? 500 : 120, Int(Double(rect.width * rect.height) / 90))
        var clipped = ctx
        clipped.clip(to: Path(rect))
        for _ in 0..<n {
            let x = Double(rect.minX) + rng.unit() * Double(rect.width)
            let y = Double(rect.minY) + rng.unit() * Double(rect.height)
            let r = rng.range(1.5, 4.5)
            clipped.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4)), with: .color(Color.blend(look.body, Color.black, rng.range(0.1, 0.5))))
        }
    }

    static func pin(_ ctx: inout GraphicsContext, at c: CGPoint, size: CGFloat, kind: StoneKind, front: Bool) {
        let look = StonePaint.look(kind)
        var tri = Path()
        tri.move(to: CGPoint(x: c.x - size, y: c.y + size * 0.4))
        tri.addLine(to: CGPoint(x: c.x + size, y: c.y + size * 0.5))
        tri.addLine(to: CGPoint(x: c.x + size * 0.3, y: c.y - size * 0.35))
        tri.closeSubpath()
        ctx.fill(tri, with: .color(front ? Fell.rubric.opacity(0.9) : look.shadow))
        ctx.stroke(tri, with: .color(Fell.ink.opacity(0.7)), lineWidth: 0.8)
    }

    static func frame(_ ctx: inout GraphicsContext, map: PaintMap, x: Double, height: Double, lean: Double, baseWidth: Double, topWidth: Double, tone: Color = Fell.woodDark) {
        let foot = map.at(x, -0.02)
        let head = map.at(x, height + 0.25)
        let spreadBase = map.len(baseWidth * 0.5) * 0.45
        let spreadTop = map.len(max(0.12, baseWidth * 0.5 - lean * (height + 0.2))) * 0.45
        for side in [-1.0, 1.0] {
            var leg = Path()
            leg.move(to: CGPoint(x: foot.x + CGFloat(side) * spreadBase, y: foot.y))
            leg.addLine(to: CGPoint(x: head.x + CGFloat(side) * spreadTop, y: head.y))
            ctx.stroke(leg, with: .color(tone), style: StrokeStyle(lineWidth: max(2, map.len(0.022)), lineCap: .round))
            ctx.stroke(leg, with: .color(Fell.wood.opacity(0.5)), style: StrokeStyle(lineWidth: max(1, map.len(0.008)), lineCap: .round))
        }
        for f in [0.25, 0.55, 0.85] {
            let y = foot.y + (head.y - foot.y) * CGFloat(f)
            let hx = spreadBase + (spreadTop - spreadBase) * CGFloat(f)
            var bar = Path()
            bar.move(to: CGPoint(x: foot.x - hx, y: y))
            bar.addLine(to: CGPoint(x: foot.x + hx, y: y))
            ctx.stroke(bar, with: .color(tone), style: StrokeStyle(lineWidth: max(1.5, map.len(0.016)), lineCap: .round))
        }
    }

    static func stringLine(_ ctx: inout GraphicsContext, map: PaintMap, from x0: Double, to x1: Double, y: Double, sag: Double = 0) {
        let a = map.at(x0, y), b = map.at(x1, y)
        var line = Path()
        line.move(to: a)
        line.addQuadCurve(to: b, control: CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 + map.len(sag)))
        ctx.stroke(line, with: .color(Fell.ink.opacity(0.35)), lineWidth: 2.4)
        ctx.stroke(line, with: .color(Fell.string), lineWidth: 1.3)
    }

    static func drawStones(_ ctx: inout GraphicsContext, stones: [Stone], map: PaintMap, age: Double, detail: Int, lost: Set<Int> = [], sag: [Int: Double] = [:], shove: [Int: Double] = [:], highlight: Set<Int> = [], faultIds: Set<Int> = [], coreKind: StoneKind, coreRect: Bool = true, trench: Double = 0.14) {
        let placed = stones.filter { $0.placed && !lost.contains($0.id) }
        guard !placed.isEmpty else { return }
        if coreRect {
            var minX = Double.infinity, maxX = -Double.infinity, top = 0.0
            for s in placed {
                let b = Geometry.bounds(s.polygon)
                minX = min(minX, b.minX); maxX = max(maxX, b.maxX); top = max(top, b.maxY)
            }
            let rect = CGRect(x: map.at(minX, 0).x, y: map.at(0, top).y, width: map.len(maxX - minX), height: map.len(top + trench))
            hearting(&ctx, rect: rect, kind: coreKind, seed: 77, detail: detail)
        }
        for s in placed.sorted(by: { $0.y < $1.y }) {
            let dy = sag[s.id] ?? 0
            let dx = shove[s.id] ?? 0
            let poly = s.polygon.map { map.at($0.x + dx, $0.y - dy) }
            let bed = s.cls == .cope ? -s.tilt + .pi / 2 : -s.tilt
            var tint: Color? = nil
            if highlight.contains(s.id) { tint = Fell.string.opacity(0.35) }
            if faultIds.contains(s.id) { tint = Fell.rubric.opacity(0.28) }
            StonePaint.draw(&ctx, poly: poly, kind: s.kind, seed: s.seed &+ 3, age: age, bed: bed, detail: detail, ink: true, tint: tint)
            if s.pinned, let px = s.pinX {
                let b = Geometry.bounds(s.polygon)
                let c = map.at(px, b.minY - dy)
                pin(&ctx, at: CGPoint(x: c.x, y: c.y + map.len(0.012)), size: max(3, map.len(0.028)), kind: s.kind, front: s.pinFront)
            }
            if s.rocking && !s.pinned {
                let b = Geometry.bounds(s.polygon)
                let c = map.at(s.x, b.maxY + 0.05)
                var arc = Path()
                arc.addArc(center: c, radius: map.len(0.09), startAngle: .degrees(210), endAngle: .degrees(330), clockwise: false)
                ctx.stroke(arc, with: .color(Fell.rubric.opacity(0.8)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            }
        }
    }

    static func drawField(_ ctx: inout GraphicsContext, stones: [FieldStone], fallen: [Int], map: PaintMap, age: Double, detail: Int, coreKind: StoneKind) {
        guard !stones.isEmpty else { return }
        var minX = Double.infinity, maxX = -Double.infinity, top = 0.0
        for (i, s) in stones.enumerated() where !fallen.contains(i) {
            let b = Geometry.bounds(s.polygon)
            minX = min(minX, b.minX); maxX = max(maxX, b.maxX); top = max(top, b.maxY)
        }
        if top > 0 {
            let rect = CGRect(x: map.at(minX, 0).x, y: map.at(0, top).y, width: map.len(maxX - minX), height: map.len(top + 0.12))
            hearting(&ctx, rect: rect, kind: coreKind, seed: 77, detail: detail)
        }
        for (i, s) in stones.enumerated() where !fallen.contains(i) {
            let poly = s.polygon.map { map.at($0.x, $0.y) }
            let bed = s.cls == .cope ? -s.t + .pi / 2 : -s.t
            StonePaint.draw(&ctx, poly: poly, kind: s.kind, seed: UInt64(i * 131 + 7), age: age, bed: bed, detail: detail, ink: true)
        }
    }

    static func drawJoints(_ ctx: inout GraphicsContext, joints: [JointMark], map: PaintMap) {
        for j in joints {
            var line = Path()
            line.move(to: map.at(j.x, j.y0))
            line.addLine(to: map.at(j.x, j.y1))
            ctx.stroke(line, with: .color(Fell.rubric.opacity(0.9)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        }
    }

    static func drawSection(_ ctx: inout GraphicsContext, wall: Wall, map: PaintMap, detail: Int, bulge: Double = 0) {
        let r = wall.rules
        let lean = wall.frameSet ? wall.batterSet : (r.batter.lowerBound + r.batter.upperBound) * 0.5
        func halfWidth(_ y: Double) -> Double {
            if r.form == .flags { return r.baseWidth * 0.5 }
            return max(r.topWidth * 0.5, r.baseWidth * 0.5 - lean * max(0, y)) + bulge * sin(.pi * min(1, max(0, y / max(0.1, wall.height))))
        }
        let depth = wall.trenchDepth
        let ground = Path(CGRect(x: map.at(-1.2, 0).x, y: map.at(0, 0).y, width: map.len(2.4), height: map.len(0.2)))
        ctx.fill(ground, with: .color(Fell.earth))
        var outline = Path()
        let steps = 10
        outline.move(to: map.at(-halfWidth(0), -depth))
        for k in 0...steps {
            let y = -depth + (wall.height + depth) * Double(k) / Double(steps)
            outline.addLine(to: map.at(-halfWidth(max(0, y)), y))
        }
        for k in stride(from: steps, through: 0, by: -1) {
            let y = -depth + (wall.height + depth) * Double(k) / Double(steps)
            outline.addLine(to: map.at(halfWidth(max(0, y)), y))
        }
        outline.closeSubpath()
        if r.core == .earth {
            ctx.fill(outline, with: .color(Fell.earth))
        } else if r.core != .none {
            ctx.fill(outline, with: .color(Color.blend(StonePaint.look(wall.kind).shadow, Color.black, 0.35)))
        } else {
            ctx.fill(outline, with: .color(Fell.pageDeep))
        }
        let structural = wall.placed.filter { $0.cls != .cope }.sorted { $0.y < $1.y }
        var drawn: [(Double, Double)] = []
        var rng = Spool(wall.seed)
        for s in structural {
            let b = Geometry.bounds(s.polygon)
            if drawn.contains(where: { abs($0.0 - b.minY) < 0.03 && abs($0.1 - b.maxY) < 0.03 }) { continue }
            drawn.append((b.minY, b.maxY))
            let yMid = (b.minY + b.maxY) * 0.5
            let hw = halfWidth(max(0, yMid))
            let reach = min(s.reach, hw * 2)
            let single = r.form == .doubleThenSingle && yMid > wall.doubleTop
            if r.form == .flags || single || (s.cls == .through && s.orientation == .lengthIn) {
                let poly = [map.at(-hw, b.minY), map.at(hw, b.minY), map.at(hw, b.maxY), map.at(-hw, b.maxY)]
                StonePaint.draw(&ctx, poly: poly, kind: s.kind, seed: s.seed &+ 11, detail: detail, ink: true, tint: s.cls == .through ? Fell.string.opacity(0.18) : nil)
                continue
            }
            let front = [map.at(-hw, b.minY), map.at(-hw + reach, b.minY + 0.006), map.at(-hw + reach, b.maxY - 0.006), map.at(-hw, b.maxY)]
            StonePaint.draw(&ctx, poly: front, kind: s.kind, seed: s.seed &+ 11, detail: detail, ink: true, tint: s.orientation == .traced || s.orientation == .faced ? Fell.rubric.opacity(0.25) : nil)
            let backReach = min(hw * 2 - reach - 0.04, rng.range(0.22, 0.42))
            if backReach > 0.08 {
                let back = [map.at(hw - backReach, b.minY + 0.006), map.at(hw, b.minY), map.at(hw, b.maxY), map.at(hw - backReach, b.maxY - 0.006)]
                StonePaint.draw(&ctx, poly: back, kind: s.kind, seed: s.seed &+ 13, detail: detail, ink: true, alpha: 0.6)
            }
        }
        if r.core != .none && r.core != .earth {
            var course = 0
            while course < wall.heartFill.count {
                let fill = wall.heartFill[course]
                let y0 = Double(course) * r.courseHeight, y1 = y0 + r.courseHeight * min(1, fill)
                if fill > 0.05 && y0 < wall.height {
                    let hw = halfWidth(y0) * 0.55
                    let rect = CGRect(x: map.at(-hw, 0).x, y: map.at(0, min(wall.height, y1)).y, width: map.len(hw * 2), height: map.len(min(wall.height, y1) - y0))
                    hearting(&ctx, rect: rect, kind: wall.kind, seed: UInt64(course * 17 + 5), detail: detail)
                }
                course += 1
            }
        }
        if let c = wall.copesPlaced.first, r.cope != .turf, r.cope != .none {
            let topY = wall.topMedian
            let b = Geometry.bounds(c.polygon)
            let hw = halfWidth(topY) + 0.04
            let poly = [map.at(-hw, topY), map.at(hw, topY), map.at(hw * 0.92, topY + (b.maxY - b.minY)), map.at(-hw * 0.92, topY + (b.maxY - b.minY))]
            StonePaint.draw(&ctx, poly: poly, kind: c.kind, seed: c.seed &+ 15, bed: r.cope == .flat ? 0 : .pi / 2, detail: detail, ink: true)
        } else if r.cope == .turf && wall.turfLaid > 0.05 {
            let topY = wall.topMedian
            let hw = halfWidth(topY)
            let turf = [map.at(-hw - 0.05, topY), map.at(hw + 0.05, topY), map.at(hw, topY + 0.14), map.at(-hw, topY + 0.14)]
            ctx.fill(StonePaint.path(turf), with: .color(Fell.grassDeep))
        }
        ctx.stroke(outline, with: .color(Fell.ink.opacity(0.6)), lineWidth: 1.2)
        if r.batter.upperBound > 0.03 {
            var dash = Path()
            dash.move(to: map.at(-halfWidth(0) - 0.03, 0))
            dash.addLine(to: map.at(-halfWidth(wall.height) - 0.03, wall.height))
            ctx.stroke(dash, with: .color(Fell.rubric.opacity(0.7)), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
        }
    }
}
