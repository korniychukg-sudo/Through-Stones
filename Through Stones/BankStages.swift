import SwiftUI

struct StoneTile: View {
    var stone: Stone
    var orientation: Orientation = .lengthIn
    var tilt: Double = 0
    var size: CGFloat
    var highlighted: Bool = false

    var body: some View {
        Canvas { ctx, area in
            var probe = stone
            probe.orientation = orientation
            let w = probe.faceWidth, h = probe.faceHeight
            let scale = min(Double(area.width) * 0.86 / max(w, 0.1), Double(area.height) * 0.86 / max(h, 0.06), Double(area.height) * 0.86 / 0.36)
            let map = PaintMap(ox: area.width / 2, oy: area.height / 2, ppm: CGFloat(scale))
            let poly = probe.polygon(at: 0, 0, tilt: tilt).map { map.at($0) }
            StonePaint.draw(&ctx, poly: poly, kind: stone.kind, seed: stone.seed &+ 3, bed: -tilt, detail: 1, ink: true, tint: highlighted ? Fell.string.opacity(0.35) : nil)
        }
        .frame(width: size, height: size * 0.72)
    }
}

struct HeapStrip: View {
    @ObservedObject var session: WallSession
    var wall: Wall
    var canvasFrame: CGRect
    var onDrag: (CGPoint) -> Void
    var onEnd: (CGPoint) -> Void

    var body: some View {
        SheetCard(padding: 10) {
            VStack(alignment: .leading, spacing: 8) {
                HeadRule(text: "The heap", trailing: heapWords)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(session.heapByClass, id: \.0) { pair in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(pair.0.name.uppercased()) \(pair.1.count)").font(Fell.body(8.5)).tracking(1).foregroundColor(Fell.inkFaint)
                                HStack(spacing: 6) {
                                    ForEach(pair.1.prefix(14)) { stone in
                                        StoneTile(stone: stone, size: 78, highlighted: session.held?.id == stone.id)
                                            .background(RoundedRectangle(cornerRadius: 5).fill(Fell.ink.opacity(session.held?.id == stone.id ? 0.12 : 0.04)))
                                            .onTapGesture { Knock.light(); session.pick(stone.id) }
                                            .gesture(
                                                DragGesture(minimumDistance: 6, coordinateSpace: .named("bank"))
                                                    .onChanged { value in
                                                        if session.held?.id != stone.id { session.pick(stone.id) }
                                                        onDrag(value.location)
                                                    }
                                                    .onEnded { value in onEnd(value.location) }
                                            )
                                    }
                                    if pair.1.count > 14 {
                                        Text("+\(pair.1.count - 14)").font(Fell.body(11)).foregroundColor(Fell.inkFaint)
                                    }
                                }
                            }
                        }
                        if session.heapByClass.isEmpty {
                            Text("The heap is empty.").font(Fell.note(12.5)).foregroundColor(Fell.inkFaint)
                        }
                    }
                    .padding(.vertical, 2)
                }
                HStack(spacing: 14) {
                    if wall.rules.core != .none {
                        Text("Hearting \(wall.heartingLeft)").font(Fell.body(11)).foregroundColor(Fell.inkSoft)
                    }
                    Text("Pinnings \(wall.pinningsLeft)").font(Fell.body(11)).foregroundColor(Fell.inkSoft)
                    Spacer()
                    Text("tap to take up, drag onto the wall").font(Fell.note(10.5)).foregroundColor(Fell.inkFaint)
                }
            }
        }
    }

    private var heapWords: String {
        let n = wall.heap.filter { $0.cls != .hearting && $0.cls != .pinning }.count
        return "\(n) stones left"
    }
}

struct HeldStonePanel: View {
    var stone: Stone
    var held: HeldStone
    @ObservedObject var session: WallSession
    @State private var dialStart: Double? = nil

    var body: some View {
        var probe = stone
        probe.orientation = held.orientation
        let bedWords: String = {
            switch held.orientation {
            case .lengthIn: return "Length into the wall: \(Words.centimetres(probe.reach)) in, \(Words.centimetres(probe.faceWidth)) on the face."
            case .traced: return "Traced: \(Words.centimetres(probe.faceWidth)) along the face, only \(Words.centimetres(probe.reach)) into the wall."
            case .faced: return "Bed turned out: a \(Words.centimetres(probe.faceWidth)) face and \(Words.centimetres(probe.reach)) of reach. It will shale."
            }
        }()
        return SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    HeadRule(text: "In hand", trailing: stone.cls.name)
                    Button(action: { Knock.light(); session.held = nil }) {
                        CrossGlyph(size: 13, color: Fell.inkSoft).padding(7).background(Circle().fill(Fell.ink.opacity(0.07)))
                    }
                    .buttonStyle(.plain)
                }
                HStack(alignment: .center, spacing: 12) {
                    StoneTile(stone: stone, orientation: held.orientation, tilt: held.tilt, size: 120)
                        .background(RoundedRectangle(cornerRadius: 6).fill(Fell.ink.opacity(0.05)))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(StoneLore.name(stone.kind)).font(Fell.title(13)).foregroundColor(Fell.ink)
                        Text("\(Words.centimetres(stone.long)) by \(Words.centimetres(stone.short)) by \(Words.centimetres(stone.thick)) thick, about \(Int(stone.mass.rounded())) kg.")
                            .font(Fell.body(12)).foregroundColor(Fell.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(bedWords).font(Fell.note(12)).foregroundColor(held.orientation == .lengthIn ? Fell.good : Fell.rubric)
                            .fixedSize(horizontal: false, vertical: true)
                        if stone.onEdge || abs(held.tilt) > .pi / 3 {
                            Text("On edge: the beds stand upright.").font(Fell.note(12)).foregroundColor(Fell.rubric)
                        }
                    }
                }
                HStack(spacing: 8) {
                    if stone.cls != .flag {
                        smallButton("Turn end on") { session.turnHeld() }
                        if stone.cls != .cope { smallButton("Roll it") { session.rollHeld() } }
                    }
                    smallButton("Flip") { session.flipHeld() }
                    Spacer()
                }
                HStack(spacing: 10) {
                    Text("Tilt").font(Fell.body(11)).foregroundColor(Fell.inkFaint)
                    TiltDial(tilt: held.tilt) { session.tiltHeld($0) }
                    Text("\(Int((held.tilt * 180 / .pi).rounded()))\u{00B0}").font(Fell.title(12)).foregroundColor(Fell.ink).frame(width: 44, alignment: .trailing)
                    Button(action: { Knock.light(); session.tiltHeld(0) }) {
                        Text("Level").font(Fell.title(10.5)).foregroundColor(Fell.inkSoft)
                            .padding(.horizontal, 8).padding(.vertical, 6)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.inkSoft.opacity(0.5), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                Text("Drag on the wall to set it down. Green lands, amber rocks, red goes over.").font(Fell.note(11)).foregroundColor(Fell.inkFaint)
            }
        }
    }

    private func smallButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: { Knock.light(); action() }) {
            Text(title).font(Fell.title(11)).foregroundColor(Fell.grit)
                .padding(.horizontal, 10).padding(.vertical, 7)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.grit.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct TiltDial: View {
    var tilt: Double
    var onChange: (Double) -> Void
    @State private var startTilt: Double? = nil

    var body: some View {
        Canvas { ctx, size in
            let cx = Double(size.width) / 2
            let cy = Double(size.height) * 0.95
            let r = Double(min(size.width * 0.48, size.height * 0.9))
            func point(_ angle: Double, _ radius: Double) -> CGPoint {
                CGPoint(x: cx + cos(angle) * radius, y: cy + sin(angle) * radius)
            }
            var arc = Path()
            arc.addArc(center: CGPoint(x: cx, y: cy), radius: CGFloat(r), startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            ctx.stroke(arc, with: .color(Fell.ink.opacity(0.15)), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            for k in -3...3 {
                let a = Double(k) * 15.0 * Double.pi / 180.0 - Double.pi / 2
                var tick = Path()
                tick.move(to: point(a, r - 8))
                tick.addLine(to: point(a, r + 2))
                ctx.stroke(tick, with: .color(Fell.inkFaint), lineWidth: k == 0 ? 2 : 1)
            }
            let clamped = max(-1.2, min(1.2, tilt))
            let a = clamped - Double.pi / 2
            var needle = Path()
            needle.move(to: CGPoint(x: cx, y: cy))
            needle.addLine(to: point(a, r))
            ctx.stroke(needle, with: .color(Fell.grit), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            ctx.fill(Path(ellipseIn: CGRect(x: cx - 6, y: cy - 6, width: 12, height: 12)), with: .color(Fell.grit))
        }
        .frame(height: 44)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 2)
                .onChanged { value in
                    if startTilt == nil { startTilt = tilt }
                    let delta = Double(value.translation.width) / 90
                    onChange(max(-.pi / 2, min(.pi / 2, (startTilt ?? tilt) + delta)))
                }
                .onEnded { _ in startTilt = nil; Knock.light() }
        )
    }
}

struct StoneCallout: View {
    var stone: Stone
    var wall: Wall
    var onLift: () -> Void
    var onPin: (Bool) -> Void
    var onChock: () -> Void
    var onClose: () -> Void

    var body: some View {
        SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HeadRule(text: "\(stone.cls.name) in the wall", trailing: stone.orientation.name.lowercased())
                    Button(action: { Knock.light(); onClose() }) {
                        CrossGlyph(size: 13, color: Fell.inkSoft).padding(7).background(Circle().fill(Fell.ink.opacity(0.07)))
                    }
                    .buttonStyle(.plain)
                }
                Text(calloutWords).font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    if stone.rocking && !stone.pinned {
                        button("Pin from behind", Fell.good) { onPin(false) }
                        button("Pin from the face", Fell.rubric) { onPin(true) }
                    } else if !stone.pinned && abs(stone.tilt) > 0.12 && wall.pinningsLeft > 0 {
                        button("Chock it level", Fell.good) { onChock() }
                    }
                    if wall.canLift(stone.id) {
                        button("Lift it", Fell.inkSoft) { onLift() }
                    }
                    Spacer()
                }
            }
        }
    }

    private var calloutWords: String {
        var parts: [String] = []
        parts.append("\(Words.centimetres(stone.reach)) into the wall, \(Words.centimetres(stone.faceWidth)) on the face, course \(stone.course + 1).")
        if stone.rocking && !stone.pinned { parts.append("It rocks on a point. A pin from behind holds it and stays hidden; a pin from the face works loose.") }
        else if stone.pinned { parts.append(stone.pinFront ? "Pinned from the face: the judge will see it." : "Pinned from behind.") }
        else if abs(stone.tilt) > 0.12 { parts.append("It settled \(Int((abs(stone.tilt) * 180 / .pi).rounded())) degrees off level.") }
        if wall.pinningsLeft == 0 { parts.append("No pinnings left in the bucket.") }
        if !wall.canLift(stone.id) { parts.append("Stones sit on it; it cannot be lifted.") }
        return parts.joined(separator: " ")
    }

    private func button(_ title: String, _ tone: Color, action: @escaping () -> Void) -> some View {
        Button(action: { Knock.light(); action() }) {
            Text(title).font(Fell.title(10.5)).foregroundColor(tone)
                .padding(.horizontal, 9).padding(.vertical, 7)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(tone.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct SectionView: View {
    var wall: Wall
    var bulge: Double = 0

    var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Fell.pageDeep.opacity(0.5)))
            let ppm = min(size.height / CGFloat(wall.height + 0.6), size.width / CGFloat(wall.rules.baseWidth + 1.2))
            let map = PaintMap(ox: size.width / 2, oy: size.height - ppm * 0.3, ppm: ppm)
            WallPaint.drawSection(&ctx, wall: wall, map: map, detail: 1, bulge: bulge)
            if wall.lineHeight > 0.02 {
                let y = map.at(0, wall.lineHeight).y
                var line = Path()
                line.move(to: CGPoint(x: 6, y: y))
                line.addLine(to: CGPoint(x: size.width - 6, y: y))
                ctx.stroke(line, with: .color(Fell.string), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            }
        }
        .cornerRadius(5)
    }
}

struct BatterControl: View {
    var wall: Wall
    var onSet: (Double) -> Void
    @State private var startLean: Double? = nil

    var body: some View {
        let r = wall.rules
        let lean = wall.frameSet ? wall.batterSet : 0
        let low = max(r.batter.lowerBound, wall.feature.minBatter)
        let ok = wall.frameSet && lean >= low && lean <= r.batter.upperBound
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("The frame").font(Fell.title(12)).foregroundColor(Fell.ink)
                Spacer()
                Text(wall.frameSet ? "batter \(batterWords(lean))" : "not set").font(Fell.note(12)).foregroundColor(ok ? Fell.good : (wall.frameSet ? Fell.rubric : Fell.inkFaint))
            }
            Canvas { ctx, size in
                let cx = size.width / 2, base = size.height - 6, top: CGFloat = 8
                let halfBase = size.height * 0.42
                let halfTop = max(10, halfBase - CGFloat(lean) * size.height * 1.9)
                for side: CGFloat in [-1, 1] {
                    var leg = Path()
                    leg.move(to: CGPoint(x: cx + side * halfBase, y: base))
                    leg.addLine(to: CGPoint(x: cx + side * halfTop, y: top))
                    ctx.stroke(leg, with: .color(wall.frameSet ? Fell.woodDark : Fell.inkFaint), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                }
                var bar = Path()
                bar.move(to: CGPoint(x: cx - (halfBase + halfTop) * 0.5, y: (base + top) * 0.5))
                bar.addLine(to: CGPoint(x: cx + (halfBase + halfTop) * 0.5, y: (base + top) * 0.5))
                ctx.stroke(bar, with: .color(wall.frameSet ? Fell.woodDark : Fell.inkFaint), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                let target = CGFloat((low + r.batter.upperBound) * 0.5)
                var guide = Path()
                guide.move(to: CGPoint(x: cx - halfBase, y: base))
                guide.addLine(to: CGPoint(x: cx - (halfBase - target * size.height * 1.9), y: top))
                ctx.stroke(guide, with: .color(Fell.rubric.opacity(0.5)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                var handle = Path(ellipseIn: CGRect(x: cx + halfTop - 9, y: top - 9 + 4, width: 18, height: 18))
                ctx.fill(handle, with: .color(Fell.card))
                ctx.stroke(handle, with: .color(Fell.ink.opacity(0.7)), lineWidth: 1.5)
                handle = Path()
            }
            .frame(height: 90)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        if startLean == nil { startLean = lean }
                        let delta = -Double(value.translation.width) / 260
                        onSet(max(0, min(0.45, (startLean ?? lean) + delta)))
                    }
                    .onEnded { _ in startLean = nil; Knock.crisp() }
            )
            Text("Drag the top of the frame inward. This wall wants one in \(Int((1 / max(0.02, low)).rounded())) to one in \(Int((1 / max(0.02, r.batter.upperBound)).rounded())).")
                .font(Fell.note(11)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
        }
    }
}

func batterWords(_ lean: Double) -> String {
    guard lean > 0.005 else { return "plumb" }
    return "one in \(Int((1.0 / lean).rounded()))"
}

struct FreeWallSheet: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    var onClose: () -> Void
    @State private var style = 0
    @State private var feature = 0
    @State private var kind = 0
    @State private var length = 1.8
    @State private var height = 1.2

    var body: some View {
        let s = WallStyle.allCases[style]
        let features = WallFeature.allCases.filter { f in
            if s == .caithness { return [.straightRun, .cheekEnd, .curve].contains(f) }
            if s == .aran { return [.straightRun, .cheekEnd, .slope, .curve].contains(f) }
            if s == .cornish { return ![.lunky, .beeBole, .stepStile].contains(f) }
            return true
        }
        let f = features[min(feature, features.count - 1)]
        let k = StoneKind.allCases[kind]
        return ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: "A wall of your own", subtitle: "Any style, any feature, any stone") { onClose() }
                ScrollView {
                    Column {
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "Style")
                                pickerRows(WallStyle.allCases.map { $0.shortName }, selected: $style, perRow: 4)
                                PlateBox(name: StoneLore.style(s).facePlate, height: 110)
                                Text(StoneLore.style(s).rules.joined(separator: "; ") + ".").font(Fell.body(12)).foregroundColor(Fell.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "Feature")
                                pickerRows(features.map { $0.shortName }, selected: $feature, perRow: 3)
                                Text(StoneLore.feature(f).how).font(Fell.body(12)).foregroundColor(Fell.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "Stone")
                                pickerRows(StoneKind.allCases.map { StoneLore.name($0).components(separatedBy: " ").last ?? "" }, selected: $kind, perRow: 4)
                                Text(StoneLore.entry(k).note).font(Fell.body(12)).foregroundColor(Fell.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "Size")
                                HStack {
                                    Text("Run \(Words.metres(length))").font(Fell.body(12.5)).foregroundColor(Fell.ink).frame(width: 110, alignment: .leading)
                                    Slider(value: $length, in: 1.2...2.6, step: 0.05).accentColor(Fell.grit)
                                }
                                HStack {
                                    Text("Height \(Words.centimetres(height))").font(Fell.body(12.5)).foregroundColor(Fell.ink).frame(width: 110, alignment: .leading)
                                    Slider(value: $height, in: 0.8...1.6, step: 0.05).accentColor(Fell.grit)
                                }
                                Text("A longer, taller wall is more stones and a harder heap; a free wall counts for the field but not for the day.")
                                    .font(Fell.note(11.5)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SealButton(title: "Set it out on the bank", tone: Fell.grit) {
                            let seed = seedOf("free.\(s.rawValue).\(f.rawValue).\(k.rawValue).\(Int(Date().timeIntervalSince1970))")
                            let c = WallBuilder.free(style: s, feature: f, kind: k, length: length, height: s == .caithness ? min(height, 1.1) : height, seed: seed)
                            session.start(c, name: "\(f.shortName), \(s.shortName)", daily: false)
                            onClose()
                            store.wantedTab = 1
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func pickerRows(_ titles: [String], selected: Binding<Int>, perRow: Int) -> some View {
        let rows = stride(from: 0, to: titles.count, by: perRow).map { Array(titles[$0..<min($0 + perRow, titles.count)]) }
        return VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { r, row in
                HStack(spacing: 4) {
                    ForEach(Array(row.enumerated()), id: \.offset) { c, title in
                        let index = r * perRow + c
                        Button(action: { Knock.light(); selected.wrappedValue = index }) {
                            Text(title).font(Fell.title(10)).lineLimit(1).minimumScaleFactor(0.6)
                                .foregroundColor(selected.wrappedValue == index ? Fell.card : Fell.inkSoft)
                                .frame(maxWidth: .infinity).padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 5).fill(selected.wrappedValue == index ? Fell.ink : Fell.ink.opacity(0.06)))
                        }
                        .buttonStyle(.plain)
                    }
                    if row.count < perRow {
                        ForEach(0..<(perRow - row.count), id: \.self) { _ in Color.clear.frame(maxWidth: .infinity).frame(height: 1) }
                    }
                }
            }
        }
    }
}
