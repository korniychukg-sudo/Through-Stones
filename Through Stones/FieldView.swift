import SwiftUI

struct FieldSlot {
    var u: Double
    var v: Double
    var scale: Double
}

enum FieldLayout {
    static let slots: [FieldSlot] = [
        FieldSlot(u: 0.08, v: 0.86, scale: 1.0), FieldSlot(u: 0.56, v: 0.90, scale: 1.0), FieldSlot(u: 0.30, v: 0.70, scale: 0.86),
        FieldSlot(u: 0.72, v: 0.72, scale: 0.86), FieldSlot(u: 0.06, v: 0.58, scale: 0.74), FieldSlot(u: 0.46, v: 0.56, scale: 0.72),
        FieldSlot(u: 0.80, v: 0.55, scale: 0.7), FieldSlot(u: 0.20, v: 0.44, scale: 0.6), FieldSlot(u: 0.58, v: 0.42, scale: 0.58),
        FieldSlot(u: 0.36, v: 0.32, scale: 0.5), FieldSlot(u: 0.74, v: 0.30, scale: 0.48)
    ]

    static func slot(for feature: WallFeature) -> FieldSlot {
        let i = WallFeature.allCases.firstIndex(of: feature) ?? 0
        return slots[i % slots.count]
    }
}

struct FieldScene: View {
    var walls: [FieldWall]
    var hour: Double
    var weather: FellWeather
    var onTap: (FieldWall) -> Void

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 15.0)) { timeline in
                Canvas { ctx, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    FieldPainter.draw(&ctx, size: size, t: t, walls: walls, hour: hour, weather: weather)
                }
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onEnded { value in
                let dx = value.location.x - value.startLocation.x, dy = value.location.y - value.startLocation.y
                guard dx * dx + dy * dy < 100 else { return }
                let hits = FieldPainter.frames(walls: walls, size: geo.size)
                for (id, rect) in hits.reversed() where rect.contains(value.location) {
                    if let wall = walls.first(where: { $0.id == id }) { Knock.light(); onTap(wall); return }
                }
            })
        }
    }
}

enum FieldPainter {
    static func horizon(_ size: CGSize) -> Double { Double(size.height) * 0.22 }

    static func map(for wall: FieldWall, size: CGSize) -> PaintMap {
        let w = Double(size.width), h = Double(size.height)
        let slot = FieldLayout.slot(for: wall.feature)
        let ppm = CGFloat(min(w, 700) * 0.075 * slot.scale)
        let ox = CGFloat(slot.u * w)
        let oy = CGFloat(horizon(size) + slot.v * (h - horizon(size)) - 4)
        return PaintMap(ox: ox, oy: oy, ppm: ppm)
    }

    static func frame(for wall: FieldWall, size: CGSize) -> CGRect {
        let map = map(for: wall, size: size)
        return CGRect(x: map.ox - 6, y: map.oy - map.len(wall.commission.height + 0.4), width: map.len(wall.commission.length) + 12, height: map.len(wall.commission.height + 0.5))
    }

    static func frames(walls: [FieldWall], size: CGSize) -> [(String, CGRect)] {
        ordered(walls).map { ($0.id, frame(for: $0, size: size)) }
    }

    static func ordered(_ walls: [FieldWall]) -> [FieldWall] {
        walls.sorted { FieldLayout.slot(for: $0.feature).v < FieldLayout.slot(for: $1.feature).v }
    }

    static func draw(_ ctx: inout GraphicsContext, size: CGSize, t: Double, walls: [FieldWall], hour: Double, weather: FellWeather) {
        let tone = FellClock.at(hour)
        drawSky(&ctx, size: size, t: t, tone: tone)
        let near = drawGround(&ctx, size: size, tone: tone, weather: weather)
        let gust = sin(t * 0.9) * 0.5 + 0.5 * sin(t * 2.1)
        let lean = weather.wind * (0.5 + 0.5 * gust) * 6
        drawTufts(&ctx, size: size, lean: lean, near: near)
        for wall in ordered(walls) {
            drawWall(&ctx, wall: wall, size: size, t: t, tone: tone)
        }
        drawWeather(&ctx, size: size, t: t, lean: lean, weather: weather)
        let w = Double(size.width), h = Double(size.height)
        ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .radialGradient(Gradient(colors: [Color.clear, Color.black.opacity(0.15 + 0.2 * (1 - tone.light))]), center: CGPoint(x: w * 0.5, y: h * 0.5), startRadius: min(w, h) * 0.3, endRadius: max(w, h) * 0.85))
    }

    static func drawSky(_ ctx: inout GraphicsContext, size: CGSize, t: Double, tone: FellLight) {
        let w = Double(size.width), h = Double(size.height)
        let horizon = horizon(size)
        ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: [tone.skyTop, tone.skyLow]), startPoint: .zero, endPoint: CGPoint(x: 0, y: horizon + 30)))
        if tone.stars > 0.05 {
            for (u, v, ph) in FellBits.stars.prefix(40) {
                let tw = 0.5 + 0.5 * sin(t * 1.5 + ph * 4)
                ctx.fill(Path(ellipseIn: CGRect(x: u * w - 1, y: v * horizon - 1, width: 2, height: 2)), with: .color(Color.white.opacity(tone.stars * (0.3 + 0.6 * tw))))
            }
        }
        if tone.moon > 0.05 {
            ctx.fill(Path(ellipseIn: CGRect(x: w * 0.8 - 8, y: h * 0.08 - 8, width: 16, height: 16)), with: .color(Color(red: 0.94, green: 0.95, blue: 0.9).opacity(tone.moon)))
            ctx.fill(Path(ellipseIn: CGRect(x: w * 0.8 - 12, y: h * 0.08 - 10, width: 15, height: 15)), with: .color(tone.skyTop.opacity(tone.moon * 0.9)))
        }
        for k in 0..<2 {
            var ridge = Path()
            ridge.move(to: CGPoint(x: -10, y: h))
            var x = -10.0
            while x <= w + 10 {
                let y = horizon - h * (0.10 - Double(k) * 0.05) + sin(x * 0.007 + Double(k) * 2) * h * 0.04
                ridge.addLine(to: CGPoint(x: x, y: y))
                x += 20
            }
            ridge.addLine(to: CGPoint(x: w + 10, y: h))
            ridge.closeSubpath()
            ctx.fill(ridge, with: .color(k == 0 ? Color.blend(tone.far, tone.skyLow, 0.3) : tone.far))
        }
    }

    static func drawGround(_ ctx: inout GraphicsContext, size: CGSize, tone: FellLight, weather: FellWeather) -> Color {
        let w = Double(size.width), h = Double(size.height)
        let horizon = horizon(size)
        var near = Path()
        near.move(to: CGPoint(x: -10, y: h + 10))
        var x = -10.0
        while x <= w + 10 {
            near.addLine(to: CGPoint(x: x, y: horizon + 4 + sin(x * 0.009 + 1) * h * 0.02))
            x += 20
        }
        near.addLine(to: CGPoint(x: w + 10, y: h + 10))
        near.closeSubpath()
        let winterNear = Color.blend(tone.near, Color(red: 0.55, green: 0.48, blue: 0.32), 0.45)
        let seasonNear: Color = weather.season == 3 ? winterNear : tone.near
        ctx.fill(near, with: .linearGradient(Gradient(colors: [Color.blend(seasonNear, tone.far, 0.35), seasonNear]), startPoint: CGPoint(x: 0, y: horizon), endPoint: CGPoint(x: 0, y: h)))
        if weather.snow > 0.3 { ctx.fill(near, with: .color(Color.white.opacity(0.4 * weather.snow))) }
        var track = Path()
        track.move(to: CGPoint(x: w * 0.02, y: h * 0.98))
        track.addCurve(to: CGPoint(x: w * 0.55, y: h * 0.28), control1: CGPoint(x: w * 0.9, y: h * 0.75), control2: CGPoint(x: w * 0.1, y: h * 0.5))
        ctx.stroke(track, with: .color(Color.blend(seasonNear, Fell.earth, 0.35).opacity(0.6)), style: StrokeStyle(lineWidth: 8, lineCap: .round))
        return seasonNear
    }

    static func drawTufts(_ ctx: inout GraphicsContext, size: CGSize, lean: Double, near: Color) {
        let w = Double(size.width), h = Double(size.height)
        let horizon = horizon(size)
        let ink = Color.blend(near, Color.black, 0.35).opacity(0.6)
        for (u, v, s) in FellBits.tufts {
            let bx = u * w, by = horizon + v * (h - horizon)
            let tall = 5 * s * (0.5 + v)
            var tuft = Path()
            tuft.move(to: CGPoint(x: bx, y: by))
            tuft.addQuadCurve(to: CGPoint(x: bx + lean * s * 0.5, y: by - tall), control: CGPoint(x: bx + lean * s * 0.15, y: by - tall * 0.6))
            ctx.stroke(tuft, with: .color(ink), lineWidth: 1)
        }
    }

    static func drawWall(_ ctx: inout GraphicsContext, wall: FieldWall, size: CGSize, t: Double, tone: FellLight) {
        let map = map(for: wall, size: size)
        let ppm = map.ppm
        if wall.standing && wall.passedAll {
            let sheepTone = Color.blend(Color(red: 0.88, green: 0.86, blue: 0.80), Color.black, 0.7 * (1 - tone.light))
            let sheepDark = Color.blend(Color(red: 0.07, green: 0.06, blue: 0.05), Color.white, 0.15 * tone.light)
            for k in 0..<2 {
                let along = map.len(wall.commission.length) * CGFloat(0.3 + Double(k) * 0.4)
                let sx = map.ox + along + CGFloat(sin(t * 0.07 + Double(k) * 2) * 8)
                let sy = map.oy - map.len(wall.commission.height) * 0.2
                let body = ppm * 0.3
                ctx.fill(Path(ellipseIn: CGRect(x: sx - body * 0.6, y: sy - body * 0.7, width: body * 1.2, height: body * 0.6)), with: .color(sheepTone))
                ctx.fill(Path(ellipseIn: CGRect(x: sx + body * 0.45, y: sy - body * 0.6, width: body * 0.3, height: body * 0.32)), with: .color(sheepDark))
            }
        }
        WallPaint.drawField(&ctx, stones: wall.stones, fallen: wall.fallen, map: map, age: wall.weathering, detail: 0, coreKind: wall.kind)
        if !wall.fallen.isEmpty {
            var rng = Spool(UInt64(wall.built) &+ 11)
            for (i, idx) in wall.fallen.prefix(10).enumerated() where idx < wall.stones.count {
                let s = wall.stones[idx]
                let b = Geometry.bounds(s.polygon)
                let cx = rng.range(b.minX - 0.2, b.maxX + 0.3), cy = rng.range(-0.02, 0.04)
                let wdt = b.maxX - b.minX, hgt = b.maxY - b.minY
                let poly = [map.at(cx - wdt / 2, cy), map.at(cx + wdt / 2, cy + 0.01), map.at(cx + wdt / 2, cy + hgt), map.at(cx - wdt / 2, cy + hgt)]
                StonePaint.draw(&ctx, poly: poly, kind: s.kind, seed: UInt64(i * 7 + 3), age: wall.weathering, detail: 0, ink: true)
            }
        }
        if wall.weathering > 0.02 {
            ctx.fill(Path(frame(for: wall, size: size)), with: .color(Fell.mossDeep.opacity(0.06 * wall.weathering)))
        }
    }

    static func drawWeather(_ ctx: inout GraphicsContext, size: CGSize, t: Double, lean: Double, weather: FellWeather) {
        let w = Double(size.width), h = Double(size.height)
        if weather.rain > 0 {
            for (u, v, s) in FellBits.flakes.prefix(30) {
                let fall = (v + t * 0.7 * s).truncatingRemainder(dividingBy: 1)
                var drop = Path()
                drop.move(to: CGPoint(x: u * w, y: fall * h))
                drop.addLine(to: CGPoint(x: u * w - lean * 0.3, y: fall * h + 8))
                ctx.stroke(drop, with: .color(Color.white.opacity(0.25 * weather.rain)), lineWidth: 1)
            }
        }
        if weather.snow > 0 {
            for (u, v, s) in FellBits.flakes.prefix(40) {
                let fall = (v + t * 0.12 * s).truncatingRemainder(dividingBy: 1)
                let sway = sin(t * 1.3 + u * 20) * 4
                ctx.fill(Path(ellipseIn: CGRect(x: u * w + sway - 1.2, y: fall * h - 1.2, width: 2.4, height: 2.4)), with: .color(Color.white.opacity(0.5 * weather.snow)))
            }
        }
    }
}

struct FieldView: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    @State private var open: FieldWall? = nil
    @State private var now = Date()
    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        let walls = store.ledger.walls
        return ScrollView {
            Column {
                SheetCard(padding: 0) {
                    VStack(spacing: 0) {
                        FieldScene(walls: walls, hour: FellClock.hourValue(now), weather: FellWeather.today(store.today)) { open = $0 }
                            .frame(height: Fell.isPad ? 440 : 300)
                            .clipped()
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fieldWords(walls)).font(Fell.title(13.5)).foregroundColor(Fell.ink).fixedSize(horizontal: false, vertical: true)
                                Text("Tap a wall for its record. Lichen and moss grow with the real days; the sheep graze behind the walls that stood every test.")
                                    .font(Fell.body(11.5)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(13)
                    }
                }
                .rising(0)
                if walls.isEmpty {
                    SheetCard {
                        VStack(alignment: .leading, spacing: 9) {
                            HeadRule(text: "An empty field")
                            PlateBox(name: "dc_sheep", height: Fell.isPad ? 220 : 150)
                            Text("Nothing has been built yet. Take the wall of the day from the fell, or set out a wall of your own on the bank; whatever you leave in the field stands here in its own style and stone.")
                                .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                            SealButton(title: "To the bank", tone: Fell.grit) { store.wantedTab = 1 }
                        }
                    }
                    .rising(1)
                } else {
                    SheetCard(padding: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            HeadRule(text: "Standing", trailing: "\(store.standingWalls) of \(walls.count)")
                            HStack(spacing: 9) {
                                CountTile(value: "\(walls.filter { $0.grade == 3 }.count)", label: "master's", tone: Fell.good)
                                CountTile(value: "\(walls.filter { $0.grade == 2 }.count)", label: "sound", tone: Fell.moss)
                                CountTile(value: "\(walls.filter { $0.grade == 1 }.count)", label: "standing", tone: Fell.query)
                                CountTile(value: "\(walls.filter { $0.grade == 0 }.count)", label: "heaps", tone: Fell.rubric)
                            }
                            Text("\(WallFeature.allCases.count - walls.count) feature slots still empty: \(emptySlots(walls)).")
                                .font(Fell.note(11.5)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .rising(1)
                    ForEach(Array(walls.sorted { $0.builtAt > $1.builtAt }.enumerated()), id: \.element.id) { i, wall in
                        Button(action: { Knock.light(); open = wall }) {
                            SheetCard(padding: 11) {
                                HStack(alignment: .top, spacing: 10) {
                                    FieldWallThumb(wall: wall, height: 82).frame(width: 130)
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(wall.name).font(Fell.title(13)).foregroundColor(Fell.ink).lineLimit(1)
                                            Spacer(minLength: 4)
                                            Text("\(wall.score)").font(Fell.title(14)).foregroundColor(scoreTone(wall.score))
                                        }
                                        Text("\(wall.style.shortName), \(StoneLore.name(wall.kind).lowercased()), \(Words.metres(wall.commission.length))").font(Fell.body(11.5)).foregroundColor(Fell.inkSoft)
                                        Text("Built \(Words.days(store.today - wall.built)). \(wall.standing ? "Standing." : "A section down.") \(weatherWords(wall))")
                                            .font(Fell.note(11)).foregroundColor(wall.standing ? Fell.inkFaint : Fell.rubric).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .rising(2 + i)
                    }
                }
                SheetCard(padding: 9) {
                    VStack(alignment: .leading, spacing: 6) {
                        PlateBox(name: benchPlate, height: Fell.isPad ? 220 : 150)
                        Text(benchWords).font(Fell.note(12)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, Fell.gutter)
            .padding(.bottom, 28)
        }
        .background(Fell.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Text("The Field").font(Fell.title(17)).foregroundColor(Fell.ink) }
        }
        .onReceive(clock) { _ in now = Date() }
        .fullScreenCover(item: $open) { wall in
            FieldDetail(wall: wall) { open = nil }.environmentObject(store).environmentObject(session)
        }
    }

    private func fieldWords(_ walls: [FieldWall]) -> String {
        if walls.isEmpty { return "The fell, with no walls on it yet" }
        let standing = walls.filter { $0.standing }.count
        if standing == walls.count { return walls.count == 1 ? "One wall standing on the fell" : "\(walls.count) walls standing on the fell" }
        return "\(standing) standing, \(walls.count - standing) with a section down"
    }

    private func emptySlots(_ walls: [FieldWall]) -> String {
        let built = Set(walls.map { $0.feature })
        let missing = WallFeature.allCases.filter { !built.contains($0) }.map { $0.shortName.lowercased() }
        return missing.isEmpty ? "none" : missing.prefix(5).joined(separator: ", ") + (missing.count > 5 ? " and more" : "")
    }

    private func weatherWords(_ wall: FieldWall) -> String {
        let days = wall.ageDays
        if days < 2 { return "Fresh from the heap." }
        if days < 30 { return "The joints darkening." }
        if days < 365 { return "The first lichen on the copes." }
        return "Grey with lichen, moss in the joints."
    }

    private var benchPlate: String {
        let keys = ["dc_gate", "dc_hawthorn", "dc_stile", "dc_barn", "dc_crag", "dc_rowan", "dc_curlew", "dc_bracken", "dc_tree", "dc_frame", "dc_sky", "dc_sheep"]
        return keys[store.today % keys.count]
    }

    private var benchWords: String {
        let lines = ["A field gate hung on a through stone.", "A hawthorn grown into the wall's lee.", "A step stile, the throughs projecting as steps.", "A field barn, the same stone as the walls.", "A crag: the wall stone's own bed showing.", "A rowan by the wall head.", "Curlews over the fell at dusk.", "Bracken in the bottoms.", "A thorn bent by the wind.", "The batter frame left against the wall.", "Sky over the tops.", "The flock behind the wall that held."]
        return lines[store.today % lines.count]
    }
}
