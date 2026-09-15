import SwiftUI

struct StagePanel: View {
    @ObservedObject var session: WallSession
    @Binding var showSection: Bool
    var onJudge: () -> Void
    var onTest: (TestKind) -> Void
    var testAnim: TestAnim?
    var onNotice: (String) -> Void
    @State private var turfStart: CGFloat? = nil

    var body: some View {
        Group {
            if let w = session.wall {
                switch session.stage {
                case .strip: stripPanel(w)
                case .footings: footingsPanel(w)
                case .courses: coursesPanel(w)
                case .throughs: throughsPanel(w)
                case .cope: copePanel(w)
                case .test: testPanel(w)
                }
            }
        }
    }

    private func stripPanel(_ w: Wall) -> some View {
        SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                HeadRule(text: "Strip", trailing: "\(Int((w.trenchShare * 100).rounded())) % of the trench cut")
                Text("Drag the shovel along the ground under the line to strip the turf and cut the trench to firm ground. On a slope the trench cuts itself in level steps.")
                    .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                MeterBar(label: "Trench", value: w.trenchShare, tone: Fell.earth)
                if w.trenchShare < 0.99 {
                    Button(action: { Knock.soft(); session.cut(from: -0.1, to: w.length + 0.1) }) {
                        Text("Cut it end to end").font(Fell.title(10.5)).foregroundColor(Fell.earth)
                            .padding(.horizontal, 9).padding(.vertical, 7)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.earth.opacity(0.55), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                if w.rules.batter.upperBound > 0.03 {
                    BatterControl(wall: w) { session.setBatter($0) }
                } else {
                    Text(w.rules.form == .flags ? "A flag fence stands plumb: no frame, no batter. Set the flags on end in the trench, each butted to the last." : "A feidin stands nearly plumb: the gaps take the wind.")
                        .font(Fell.note(12)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 8) {
                    if w.trenchShare > 0.85 && (w.frameSet || w.rules.batter.upperBound <= 0.03) {
                        SealButton(title: "Pull the line and start the footings", tone: Fell.grit) { session.stage = .footings }
                    } else {
                        SealButton(title: "Start the footings anyway", tone: Fell.inkSoft, filled: false) {
                            onNotice(w.trenchShare <= 0.85 ? "The trench is not cut along the whole line; footings on turf will rock and settle." : "No batter frame set: the judge will call it wrong batter.")
                            session.stage = .footings
                        }
                    }
                }
            }
        }
    }

    private func footingsPanel(_ w: Wall) -> some View {
        SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 9) {
                HeadRule(text: "Footings", trailing: "\(w.placed.filter { $0.cls == .footing || $0.cls == .flag }.count) set")
                Text(w.rules.form == .flags ? "Drag each flag into the trench on its end, tight against the last. It stands on its own if the trench is cut under it." : "The biggest stones from the heap, flat side down, dragged into the trench end to end. Turn a stone with the dial if its flat face is up; the section shows how far each reaches.")
                    .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                lineRow(w)
                if w.rules.form != .flags {
                    SealButton(title: "Footings in, raise the line for the first course", tone: Fell.grit, enabled: w.placed.count > 0) {
                        if w.lineHeight < 0.05 { session.raiseLine(to: min(w.height, w.topMedian + w.heapCourseHeight)) }
                        session.stage = .courses
                    }
                } else {
                    SealButton(title: "The flags are set: test the fence", tone: Fell.grit, enabled: w.placed.count > 0) { session.stage = .test }
                }
            }
        }
    }

    private func lineRow(_ w: Wall) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("The line").font(Fell.title(12)).foregroundColor(Fell.ink)
                Text(w.lineHeight > 0.02 ? "at \(Words.centimetres(w.lineHeight)), course \(w.lineIndex)" : "not yet raised").font(Fell.note(11.5)).foregroundColor(Fell.inkFaint)
            }
            Spacer()
            Button(action: { Knock.crisp(); session.raiseLine(to: min(w.height + 0.02, max(w.lineHeight + 0.03, w.topMedian + w.heapCourseHeight))) }) {
                Text("Raise a course").font(Fell.title(10.5)).foregroundColor(Fell.grit)
                    .padding(.horizontal, 9).padding(.vertical, 7)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.grit.opacity(0.55), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func coursesPanel(_ w: Wall) -> some View {
        let fill = w.currentHeartFill
        let coreWanted = w.rules.core != .none && (w.rules.form != .doubleThenSingle || w.lineHeight <= w.doubleTop + 0.02)
        return SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 9) {
                HeadRule(text: "Courses", trailing: "course \(max(1, w.lineIndex)) of about \(w.courseCount)")
                Text(courseWords(w)).font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                if coreWanted {
                    HStack(spacing: 12) {
                        HeartingButton(fill: fill, left: w.heartingLeft, earth: w.rules.core == .earth) {
                            if session.hearting() > 0 { Knock.soft() } else { onNotice("The bucket is empty: no hearting left in the heap.") }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            MeterBar(label: w.rules.core == .earth ? "Earth rammed in this course" : "Hearting in this course", value: fill, tone: fill < 0.6 ? Fell.rubric : Fell.moss)
                            Text(fill < 0.6 ? "Hollow: the faces have nothing to lean on." : "Packed.").font(Fell.note(11)).foregroundColor(fill < 0.6 ? Fell.rubric : Fell.good)
                        }
                    }
                }
                lineRow(w)
                if w.throughsWanted > 0 && w.lineHeight >= w.height * 0.38 && w.throughsPlaced.count < w.throughsWanted {
                    NoticeBar(text: "Half height: \(w.throughsWanted) throughs are wanted along this run, one every \(Words.metres(w.rules.throughSpacing)) or so.", tone: Fell.query, action: ("Throughs", { session.stage = .throughs }))
                }
                if w.style == .galloway && w.lineHeight >= w.doubleTop - 0.05 && !w.placed.contains(where: { $0.cls == .through }) {
                    NoticeBar(text: "The double base is up: lay the cover band, a whole course of throughs across the dyke, then the single stones.", tone: Fell.query, action: ("Cover band", { session.stage = .throughs }))
                }
                if w.topMedian >= w.height - w.heapCourseHeight * 0.6 {
                    SealButton(title: "Up to height: set the cope", tone: Fell.grit) { session.stage = .cope }
                }
            }
        }
    }

    private func courseWords(_ w: Wall) -> String {
        switch w.style {
        case .cornish: return "Grounders first, then Jack and Jill: the stones of each course leaning one way, the next course the other, with the earth rammed behind them as you go."
        case .aran: return "A low double base with hearting, then tall slabs rolled bed-out and stood upright on it, a hand's gap between each so the wind goes through."
        case .galloway: return "Double with hearting to half height, a cover band of throughs, then single stones spanning the width with daylight between them, and a locked top."
        case .caithness: return "Flags on end in the trench."
        default: return "Every stone with its length into the wall, crossing the joint below. Pin the ones that rock from behind. Pack the hearting before the line goes up."
        }
    }

    private func throughsPanel(_ w: Wall) -> some View {
        SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 9) {
                HeadRule(text: w.style == .galloway ? "Cover band" : "Throughs", trailing: "\(w.style == .galloway ? w.placed.filter { $0.cls == .through }.count : w.throughsPlaced.count) laid")
                Text(w.style == .galloway ? "A whole course of long stones laid across the full width on top of the double base; the single stones above sit on them." : (w.throughsWanted == 0 ? "This wall wants no throughs: it is single, or too low for the wind to matter." : "Long stones from the through pile, laid flat at about half height, one every \(Words.metres(w.rules.throughSpacing)), reaching both faces. Each is drawn projecting in the section. For a step stile they are the steps; for a gate post the top one is the hanging stone."))
                    .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                lineRow(w)
                SealButton(title: "Back to the courses", tone: Fell.grit) { session.stage = .courses }
            }
        }
    }

    private func copePanel(_ w: Wall) -> some View {
        SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 9) {
                HeadRule(text: "Cope", trailing: copeCount(w))
                Text(copeWords(w)).font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                if w.rules.cope == .turf {
                    TurfStrip(laid: w.turfLaid) { amount in session.layTurf(amount) }
                }
                if w.rules.cope == .locked {
                    Text("Tap the joint between two copes on the wall to drive a locking wedge. \(w.locks.count) locked.").font(Fell.note(12)).foregroundColor(Fell.inkFaint)
                }
                SealButton(title: "The cope is on: test the wall", tone: Fell.grit) { session.stage = .test }
            }
        }
    }

    private func copeCount(_ w: Wall) -> String {
        switch w.rules.cope {
        case .turf: return "\(Int((w.turfLaid * 100).rounded())) % turfed"
        case .none: return "no cope in this style"
        default: return "\(w.copesPlaced.count) set"
        }
    }

    private func copeWords(_ w: Wall) -> String {
        switch w.rules.cope {
        case .flat: return "Big flat stones laid across the top of both faces, each tight against the last, their weight holding the top course down."
        case .upright: return "Copes set on end, each tight against the next so a horse leaning on them moves the whole row or nothing."
        case .cockAndHen: return "Small stones set upright, a tall one and a short one alternately, tight together: the cock and hen."
        case .buckAndDoe: return "Tall and low copes alternating along the top."
        case .locked: return "Upright copes with a gap between, and a wedge driven into each gap so the top is one piece."
        case .turf: return "No stone cope: sweep the turf along the top and the grass roots bind it."
        case .none: return "Nothing goes on top: the tops of the single stones are the top of the wall."
        }
    }

    private func testPanel(_ w: Wall) -> some View {
        SheetCard(padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                HeadRule(text: "The tests", trailing: "press and hold")
                Text("Hold a test to run it and watch. A wall stands, loses a section, or comes down; the stones that fall are drawn falling. The hundred years is all three, with roots under the footings and a branch across the cope.")
                    .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    ForEach(TestKind.allCases, id: \.rawValue) { kind in
                        HoldButton(kind: kind, outcome: session.outcomes[kind], running: testAnim?.kind == kind) { onTest(kind) }
                    }
                }
                if let anim = testAnim {
                    NoticeBar(text: "\(anim.kind.name): \(anim.outcome.note)", tone: anim.outcome.passed ? Fell.good : Fell.rubric)
                }
                SealButton(title: "Judge the wall", tone: Fell.grit, enabled: w.placed.count > 0) { onJudge() }
                if session.outcomes.count < 3 {
                    Text("The critique counts every test you have run; the ones you skip count for nothing either way.").font(Fell.note(11.5)).foregroundColor(Fell.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct HoldButton: View {
    var kind: TestKind
    var outcome: TestOutcome?
    var running: Bool
    var onFire: () -> Void
    @State private var progress: Double = 0
    @State private var holding = false
    @State private var fired = false
    private let ticker = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        let tone: Color = outcome == nil ? Fell.inkSoft : (outcome!.passed ? Fell.good : Fell.rubric)
        return VStack(spacing: 4) {
            ZStack {
                Circle().stroke(tone.opacity(0.25), lineWidth: 4)
                Circle().trim(from: 0, to: CGFloat(progress)).stroke(tone, style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90))
                TestMark(kind: kind, size: 26, color: tone)
            }
            .frame(width: 58, height: 58)
            .scaleEffect(holding ? 0.94 : 1)
            .animation(.easeOut(duration: 0.15), value: holding)
            Text(kind == .century ? "100 years" : kind.name).font(Fell.title(9.5)).foregroundColor(tone).lineLimit(1).minimumScaleFactor(0.7)
            if let o = outcome {
                Text(o.passed ? "stood" : "failed").font(Fell.note(10)).foregroundColor(tone)
            } else {
                Text("hold").font(Fell.note(10)).foregroundColor(Fell.inkFaint)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !holding { holding = true; fired = false; progress = 0 } }
                .onEnded { _ in holding = false; if !fired { progress = 0 } }
        )
        .onReceive(ticker) { _ in
            guard holding, !fired else { return }
            progress = min(1, progress + 0.05 / 1.1)
            if progress >= 1 {
                fired = true
                onFire()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { progress = 0 }
            }
        }
    }
}

struct HeartingButton: View {
    var fill: Double
    var left: Int
    var earth: Bool
    var onTap: () -> Void
    @State private var pulse = false

    var body: some View {
        Button(action: {
            onTap()
            pulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { pulse = false }
        }) {
            VStack(spacing: 3) {
                Canvas { ctx, size in
                    var rng = Spool(41)
                    ctx.fill(Path(ellipseIn: CGRect(x: 4, y: size.height * 0.55, width: size.width - 8, height: size.height * 0.4)), with: .color(Fell.ink.opacity(0.12)))
                    for _ in 0..<14 {
                        let x = 8 + rng.unit() * (Double(size.width) - 16)
                        let y = Double(size.height) * 0.3 + rng.unit() * Double(size.height) * 0.45
                        let r = 3 + rng.unit() * 4
                        ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r * 0.7, width: r * 2, height: r * 1.4)), with: .color(earth ? Fell.earth : Fell.stoneDark))
                    }
                }
                .frame(width: 70, height: 46)
                Text(earth ? "Ram the earth" : "Shake in").font(Fell.title(10)).foregroundColor(Fell.card)
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 7).fill(Fell.grit))
            .scaleEffect(pulse ? 0.93 : 1)
            .animation(.easeOut(duration: 0.12), value: pulse)
        }
        .buttonStyle(.plain)
        .disabled(left <= 0)
        .opacity(left <= 0 ? 0.5 : 1)
    }
}

struct TurfStrip: View {
    var laid: Double
    var onSweep: (Double) -> Void
    @State private var lastX: CGFloat? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Sweep the turf along the top").font(Fell.title(12)).foregroundColor(Fell.ink)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(Fell.earth.opacity(0.5))
                    RoundedRectangle(cornerRadius: 6).fill(Fell.grassDeep).frame(width: max(6, geo.size.width * CGFloat(laid)))
                    Text(laid >= 0.95 ? "turfed" : "drag across").font(Fell.note(11)).foregroundColor(Fell.card).padding(.leading, 10)
                }
                .gesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { value in
                            if let last = lastX {
                                let dx = Double(abs(value.location.x - last) / geo.size.width)
                                if dx > 0.002 { onSweep(dx * 0.9) }
                            }
                            lastX = value.location.x
                        }
                        .onEnded { _ in lastX = nil; Knock.soft() }
                )
            }
            .frame(height: 34)
        }
    }
}

struct CritiqueSheet: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    var onKeep: () -> Void
    var onClose: () -> Void
    var onReference: () -> Void

    var body: some View {
        let report = session.judge()
        return ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: "The critique", subtitle: session.name) { onClose() }
                ScrollView {
                    Column {
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                ScoreWord(score: report.score)
                                HStack(spacing: 9) {
                                    CountTile(value: "\(session.wall?.placed.count ?? 0)", label: "stones")
                                    CountTile(value: Words.percent(report.efficiency), label: "picked up once")
                                    CountTile(value: "\(report.sheet.throughsPlaced)", label: "throughs")
                                    CountTile(value: report.complete ? "yes" : "no", label: "to height", tone: report.complete ? Fell.good : Fell.rubric)
                                }
                                if !report.tests.isEmpty {
                                    HStack(spacing: 8) {
                                        ForEach(report.tests, id: \.kind.rawValue) { t in
                                            StampTag(text: "\(t.kind == .century ? "100 years" : t.kind.name) \(t.passed ? "stood" : "fell")", tone: t.passed ? Fell.good : Fell.rubric)
                                        }
                                    }
                                }
                            }
                        }
                        if !report.critique.isEmpty {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HeadRule(text: "What let it down")
                                    ForEach(Array(report.critique.enumerated()), id: \.offset) { _, line in
                                        HStack(alignment: .top, spacing: 8) {
                                            Rectangle().fill(Fell.rubric).frame(width: 3, height: 14).padding(.top, 3)
                                            Text(line).font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }
                        if !report.praise.isEmpty {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HeadRule(text: "What stood")
                                    ForEach(Array(report.praise.enumerated()), id: \.offset) { _, line in
                                        HStack(alignment: .top, spacing: 8) {
                                            Rectangle().fill(Fell.good).frame(width: 3, height: 14).padding(.top, 3)
                                            Text(line).font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "Leave it in the field")
                                Text("The field keeps the best wall of each feature. A better attempt later replaces it; a fallen wall can be rebuilt from the field with the same stones.")
                                    .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                SealButton(title: "Leave it in the field", tone: Fell.grit) { onKeep() }
                                SealButton(title: "Keep working on it", tone: Fell.inkSoft, filled: false) { onClose() }
                                SealButton(title: "See the master's wall", tone: Fell.inkSoft, filled: false) { onReference() }
                            }
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

struct ReferenceSheet: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    var onClose: () -> Void
    @State private var reference: Wall? = nil
    @State private var report: WallReport? = nil

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: "The master's wall", subtitle: "The same heap laid by the engine's own waller") { onClose() }
                ScrollView {
                    Column {
                        if let ref = reference, let rep = report {
                            SheetCard(padding: 8) {
                                VStack(alignment: .leading, spacing: 6) {
                                    StaticWallView(wall: ref).frame(height: Fell.isPad ? 320 : 220)
                                    ScoreWord(score: rep.score)
                                    ForEach(Array(rep.praise.prefix(4).enumerated()), id: \.offset) { _, line in
                                        Text(line).font(Fell.body(12)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            SheetCard(padding: 8) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HeadRule(text: "Its section")
                                    SectionView(wall: ref).frame(height: 220)
                                }
                            }
                            NoticeBar(text: "Same stones, same rules: every joint crossed, the core packed, throughs at half height, the cope tight. Compare it with your own face on the bank.", tone: Fell.sky)
                        } else {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HeadRule(text: "Laying it")
                                    Text("The waller is picking through the heap and laying the same commission, stone by stone, with every rule kept.")
                                        .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Fell.grit))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            guard let w = session.wall else { return }
            let c = Commission(style: w.style, feature: w.feature, kind: w.kind, length: w.length, height: w.height, seed: w.seed, client: "", place: "", day: 0)
            store.reference(for: c) { ref in
                reference = ref
                let sheet = WallJudge.sheet(ref)
                let tests = TestKind.allCases.map { WallJudge.test($0, ref, sheet: sheet) }
                report = WallJudge.report(ref, tests: tests)
            }
        }
    }
}

struct StaticWallView: View {
    var wall: Wall
    var age: Double = 0

    var body: some View {
        Canvas { ctx, size in
            let tone = FellClock.at(FellClock.hourValue())
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: [tone.skyTop.opacity(0.8), Fell.grass]), startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
            let map = PaintMap.fit(length: wall.length, height: wall.height, slope: wall.feature.slopeRate, in: size, margin: 0.2, topRoom: 0.5, bottomRoom: 0.25)
            ctx.fill(Path(CGRect(x: 0, y: map.at(0, 0).y, width: size.width, height: size.height)), with: .color(Fell.grassDeep))
            WallPaint.drawStones(&ctx, stones: wall.stones, map: map, age: age, detail: 1, coreKind: wall.kind, trench: wall.trenchDepth)
        }
        .cornerRadius(5)
    }
}
