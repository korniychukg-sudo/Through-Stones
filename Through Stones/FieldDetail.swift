import SwiftUI

struct FieldElevation: View {
    var wall: FieldWall
    var hour: Double

    var body: some View {
        Canvas { ctx, size in
            let tone = FellClock.at(hour)
            let w = size.width, h = size.height
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: [tone.skyTop, tone.skyLow]), startPoint: .zero, endPoint: CGPoint(x: 0, y: h * 0.7)))
            let map = PaintMap.fit(length: wall.commission.length, height: wall.commission.height, slope: wall.feature.slopeRate, in: size, margin: 0.09, topRoom: 0.42, bottomRoom: 0.16)
            var ridge = Path()
            ridge.move(to: CGPoint(x: -4, y: h))
            var x = -4.0
            while x <= w + 4 {
                ridge.addLine(to: CGPoint(x: x, y: map.at(0, 0).y - h * 0.16 + sin(x * 0.012 + 0.6) * h * 0.05))
                x += 16
            }
            ridge.addLine(to: CGPoint(x: w + 4, y: h))
            ridge.closeSubpath()
            ctx.fill(ridge, with: .color(Color.blend(tone.far, tone.skyLow, 0.2)))
            let groundY = map.at(0, 0).y
            var ground = Path()
            ground.move(to: CGPoint(x: -4, y: h + 4))
            x = -4.0
            while x <= w + 4 {
                let slopeDrop = map.len(wall.feature.slopeRate * max(0, map.metres(x)))
                ground.addLine(to: CGPoint(x: x, y: groundY - slopeDrop + sin(x * 0.03) * 1.5))
                x += 12
            }
            ground.addLine(to: CGPoint(x: w + 4, y: h + 4))
            ground.closeSubpath()
            ctx.fill(ground, with: .linearGradient(Gradient(colors: [tone.near, Color.blend(tone.near, Fell.earth, 0.5)]), startPoint: CGPoint(x: 0, y: groundY - 20), endPoint: CGPoint(x: 0, y: h)))
            WallPaint.drawField(&ctx, stones: wall.stones, fallen: wall.fallen, map: map, age: wall.weathering, detail: 2, coreKind: wall.kind)
            if !wall.fallen.isEmpty {
                var rng = Spool(UInt64(wall.built) &+ 5)
                for (i, idx) in wall.fallen.prefix(14).enumerated() where idx < wall.stones.count {
                    let s = wall.stones[idx]
                    let b = Geometry.bounds(s.polygon)
                    let wdt = (b.maxX - b.minX) * 0.9, hgt = (b.maxY - b.minY) * 0.9
                    let cx = rng.range(b.minX - 0.25, b.maxX + 0.35), cy = rng.range(-0.02, 0.05)
                    let poly = [map.at(cx - wdt / 2, cy), map.at(cx + wdt / 2, cy + 0.012), map.at(cx + wdt / 2, cy + hgt), map.at(cx - wdt / 2, cy + hgt)]
                    StonePaint.draw(&ctx, poly: poly, kind: s.kind, seed: UInt64(i * 13 + 1), age: wall.weathering, detail: 1, ink: true)
                }
            }
            for (u, v, s) in FellBits.tufts.prefix(60) {
                let bx = u * w, by = groundY + v * (h - groundY) * 0.9
                var tuft = Path()
                tuft.move(to: CGPoint(x: bx, y: by))
                tuft.addQuadCurve(to: CGPoint(x: bx + 2, y: by - 6 * s), control: CGPoint(x: bx + 0.5, y: by - 3 * s))
                ctx.stroke(tuft, with: .color(Color.blend(tone.near, Color.black, 0.35).opacity(0.5)), lineWidth: 1)
            }
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .radialGradient(Gradient(colors: [Color.clear, Color.black.opacity(0.12)]), center: CGPoint(x: w * 0.5, y: h * 0.5), startRadius: min(w, h) * 0.4, endRadius: max(w, h) * 0.8))
        }
    }
}

struct FieldSectionView: View {
    var wall: FieldWall

    var body: some View {
        Canvas { ctx, size in
            let r = wall.style.rules
            let height = max(0.5, wall.lineHeight > 0.3 ? wall.lineHeight : wall.commission.height)
            let ppm = min(size.height * 0.8 / CGFloat(height), size.width * 0.7 / CGFloat(max(r.baseWidth, 0.6)))
            let cx = size.width * 0.5
            let baseY = size.height * 0.9
            let lean = wall.frameLean > 0 ? wall.frameLean : (r.batter.lowerBound + r.batter.upperBound) * 0.5
            let bw = CGFloat(r.baseWidth) * ppm
            let topW = max(CGFloat(r.topWidth) * ppm, bw - CGFloat(lean * height * 2) * ppm)
            let topY = baseY - CGFloat(height) * ppm
            ctx.fill(Path(CGRect(x: 0, y: baseY, width: size.width, height: size.height - baseY)), with: .color(Fell.earth.opacity(0.75)))
            ctx.fill(Path(CGRect(x: 0, y: 0, width: size.width, height: baseY)), with: .color(Fell.sky.opacity(0.35)))
            var outline = Path()
            outline.move(to: CGPoint(x: cx - bw / 2, y: baseY))
            outline.addLine(to: CGPoint(x: cx - topW / 2, y: topY))
            outline.addLine(to: CGPoint(x: cx + topW / 2, y: topY))
            outline.addLine(to: CGPoint(x: cx + bw / 2, y: baseY))
            outline.closeSubpath()
            ctx.fill(outline, with: .color(Fell.stoneLight))
            var rng = Spool(wall.commission.seed &+ 77)
            let courseH = CGFloat(r.courseHeight) * ppm
            var y = baseY
            var course = 0
            while y - courseH > topY - 1 {
                let t = Double((baseY - y) / (baseY - topY))
                let halfW = (bw / 2) + (topW / 2 - bw / 2) * CGFloat(t)
                let faceW = r.form == .single ? halfW * 2 : max(halfW * 0.72, courseH * 1.1)
                let stoneH = courseH * CGFloat(rng.range(0.82, 1.0))
                let throughHere = r.wantsThroughs && abs(t - 0.5) < 0.09 && course % 2 == 0
                if throughHere {
                    let poly = [CGPoint(x: cx - halfW - 4, y: y), CGPoint(x: cx + halfW + 4, y: y), CGPoint(x: cx + halfW + 4, y: y - stoneH * 0.8), CGPoint(x: cx - halfW - 4, y: y - stoneH * 0.8)]
                    StonePaint.draw(&ctx, poly: poly, kind: wall.kind, seed: rng.next(), age: wall.weathering, detail: 1, ink: true)
                } else if r.form == .single {
                    let poly = [CGPoint(x: cx - halfW, y: y), CGPoint(x: cx + halfW, y: y), CGPoint(x: cx + halfW * 0.9, y: y - stoneH), CGPoint(x: cx - halfW * 0.9, y: y - stoneH)]
                    StonePaint.draw(&ctx, poly: poly, kind: wall.kind, seed: rng.next(), age: wall.weathering, detail: 1, ink: true)
                } else {
                    let left = [CGPoint(x: cx - halfW, y: y), CGPoint(x: cx - halfW + faceW, y: y), CGPoint(x: cx - halfW + faceW * CGFloat(rng.range(0.85, 1.05)), y: y - stoneH), CGPoint(x: cx - halfW + 2, y: y - stoneH)]
                    let right = [CGPoint(x: cx + halfW - faceW, y: y), CGPoint(x: cx + halfW, y: y), CGPoint(x: cx + halfW - 2, y: y - stoneH), CGPoint(x: cx + halfW - faceW * CGFloat(rng.range(0.85, 1.05)), y: y - stoneH)]
                    StonePaint.draw(&ctx, poly: left, kind: wall.kind, seed: rng.next(), age: wall.weathering, detail: 1, ink: true)
                    StonePaint.draw(&ctx, poly: right, kind: wall.kind, seed: rng.next(), age: wall.weathering, detail: 1, ink: true)
                    let core = CGRect(x: cx - halfW + faceW - 1, y: y - stoneH, width: max(2, halfW * 2 - faceW * 2 + 2), height: stoneH)
                    if r.core == .earth {
                        ctx.fill(Path(core), with: .color(Fell.earth.opacity(0.85)))
                    } else if r.core == .hearting {
                        WallPaint.hearting(&ctx, rect: core, kind: wall.kind, seed: rng.next(), detail: 1)
                    }
                }
                y -= stoneH
                course += 1
            }
            ctx.stroke(outline, with: .color(Fell.ink.opacity(0.5)), lineWidth: 1)
            var plumb = Path()
            plumb.move(to: CGPoint(x: cx - bw / 2, y: baseY + 6))
            plumb.addLine(to: CGPoint(x: cx - bw / 2, y: topY - 8))
            ctx.stroke(plumb, with: .color(Fell.rubric.opacity(0.7)), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            let label = Text(batterWords(lean)).font(Fell.note(11)).foregroundColor(Fell.ink)
            ctx.draw(label, at: CGPoint(x: cx, y: topY - 14))
        }
    }
}

struct FieldDetail: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    var wall: FieldWall
    var onClose: () -> Void
    @State private var askReplace = false

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: wall.name, subtitle: "\(wall.style.name), \(StoneLore.name(wall.kind).lowercased())") { onClose() }
                ScrollView {
                    Column {
                        SheetCard(padding: 0) {
                            VStack(spacing: 0) {
                                FieldElevation(wall: wall, hour: FellClock.hourValue(Date()))
                                    .frame(height: Fell.isPad ? 360 : 240)
                                    .clipped()
                                HStack(alignment: .firstTextBaseline) {
                                    ScoreWord(score: wall.score)
                                    Spacer(minLength: 0)
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(wall.standing ? "Standing" : "A section down").font(Fell.title(12)).foregroundColor(wall.standing ? Fell.good : Fell.rubric)
                                        Text("Built \(Words.days(store.today - wall.built))").font(Fell.note(11.5)).foregroundColor(Fell.inkFaint)
                                    }
                                }
                                .padding(13)
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "The wall", trailing: wall.daily ? "wall of the day" : "your own")
                                HStack(spacing: 9) {
                                    CountTile(value: Words.metres(wall.commission.length), label: "long")
                                    CountTile(value: Words.metres(wall.commission.height), label: "high")
                                    CountTile(value: "\(wall.placedCount)", label: "stones")
                                    CountTile(value: "\(wall.throughs)", label: "throughs", tone: wall.throughs > 0 ? Fell.moss : Fell.rubric)
                                }
                                HStack(spacing: 9) {
                                    CountTile(value: Words.percent(wall.efficiency), label: "of the heap used", tone: wall.efficiency >= 0.999 ? Fell.good : Fell.ink)
                                    CountTile(value: "\(wall.faults.values.reduce(0, +))", label: "faults", tone: wall.faults.isEmpty ? Fell.good : Fell.rubric)
                                    CountTile(value: "\(wall.tests.values.filter { $0 }.count) of \(wall.tests.count)", label: "tests stood", tone: wall.passedAll ? Fell.good : Fell.query)
                                }
                                Text(wall.feature.name + ": " + StoneLore.feature(wall.feature).why).font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SheetCard(padding: 9) {
                            VStack(alignment: .leading, spacing: 6) {
                                FieldSectionView(wall: wall).frame(height: Fell.isPad ? 300 : 210)
                                Text("The section as built: \(wall.style.rules.form == .single ? "a single wall" : "two faces and a core"), \(Words.centimetres(wall.style.rules.baseWidth)) at the base.")
                                    .font(Fell.note(12)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "The tests")
                                ForEach(TestKind.allCases, id: \.self) { kind in
                                    HStack(spacing: 10) {
                                        TestMark(kind: kind, size: 22, color: testTone(kind))
                                        Text(kind.name).font(Fell.body(13)).foregroundColor(Fell.ink)
                                        Spacer(minLength: 4)
                                        Text(testWord(kind)).font(Fell.title(11)).foregroundColor(testTone(kind))
                                    }
                                }
                            }
                        }
                        if !wall.faults.isEmpty {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 9) {
                                    HeadRule(text: "Faults found")
                                    ForEach(FaultKind.allCases.filter { (wall.faults[$0.rawValue] ?? 0) > 0 }, id: \.self) { kind in
                                        HStack(alignment: .top, spacing: 8) {
                                            Rectangle().fill(Fell.rubric).frame(width: 3, height: 14).padding(.top, 3)
                                            Text(kind.name).font(Fell.body(13)).foregroundColor(Fell.ink)
                                            Spacer(minLength: 4)
                                            Text("\(wall.faults[kind.rawValue] ?? 0)").font(Fell.title(12)).foregroundColor(Fell.rubric)
                                        }
                                    }
                                }
                            }
                        }
                        if !wall.praise.isEmpty || !wall.critique.isEmpty {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 9) {
                                    HeadRule(text: "The judge's notes")
                                    ForEach(Array(wall.praise.enumerated()), id: \.offset) { _, line in
                                        Text(line).font(Fell.body(13)).foregroundColor(Fell.good).fixedSize(horizontal: false, vertical: true)
                                    }
                                    ForEach(Array(wall.critique.enumerated()), id: \.offset) { _, line in
                                        Text(line).font(Fell.body(13)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: wall.standing ? "Build it again" : "Rebuild it")
                                Text(wall.standing
                                     ? "The same commission goes back on the bank with a fresh heap. A better wall replaces this one in the field; a worse one leaves it standing."
                                     : "A section is down. Take the same commission back to the bank, and the new wall replaces this one whatever it scores.")
                                    .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                SealButton(title: wall.standing ? "Same wall, new heap" : "Rebuild on the bank", tone: wall.standing ? Fell.grit : Fell.rubric) {
                                    if session.active { askReplace = true } else { rebuild() }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
        .alert("A wall is already on the bank", isPresented: $askReplace) {
            Button("Leave it there", role: .cancel) {}
            Button("Abandon it and rebuild", role: .destructive) { rebuild() }
        } message: {
            Text("The wall on the bank will be lost. The heap is put back and the commission for this one takes its place.")
        }
    }

    private func rebuild() {
        Knock.firm()
        if !wall.standing { store.markRebuilt() }
        let c = WallBuilder.free(style: wall.style, feature: wall.feature, kind: wall.kind, length: wall.commission.length, height: wall.commission.height, seed: wall.commission.seed &+ UInt64(store.today))
        session.start(c, name: wall.name, daily: false)
        store.wantedTab = 1
        onClose()
    }

    private func testTone(_ kind: TestKind) -> Color {
        guard let passed = wall.tests[kind.rawValue] else { return Fell.inkFaint }
        return passed ? Fell.good : Fell.rubric
    }

    private func testWord(_ kind: TestKind) -> String {
        guard let passed = wall.tests[kind.rawValue] else { return "not run" }
        return passed ? "stood" : "fell"
    }
}
