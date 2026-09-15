import SwiftUI

struct CanvasFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

struct BankView: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    @State private var map: PaintMap? = nil
    @State private var canvasFrame: CGRect = .zero
    @State private var dragPoint: CGPoint? = nil
    @State private var fall: FallAnim? = nil
    @State private var topple: ToppleAnim? = nil
    @State private var testAnim: TestAnim? = nil
    @State private var selected: Int? = nil
    @State private var lineDrag: Double? = nil
    @State private var cutting: (Double, Double)? = nil
    @State private var dragStart: CGPoint? = nil
    @State private var dragMode: Int = 0
    @State private var notice: String? = nil
    @State private var noticeStamp = 0
    @State private var openCritique = false
    @State private var openReference = false
    @State private var openFree = false
    @State private var celebration: (String, [String])? = nil
    @State private var showSection = false

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            if session.active {
                workBody
            } else {
                emptyBody
            }
            if let c = celebration {
                Celebration(title: c.0, lines: c.1, button: "Walk the field") {
                    celebration = nil
                    store.wantedTab = 3
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Text("The Bank").font(Fell.title(17)).foregroundColor(Fell.ink) }
        }
        .sheet(isPresented: $openCritique) {
            CritiqueSheet(onKeep: { keepWall() }, onClose: { openCritique = false }, onReference: { openCritique = false; openReference = true })
                .environmentObject(store).environmentObject(session)
        }
        .sheet(isPresented: $openReference) {
            ReferenceSheet { openReference = false }.environmentObject(store).environmentObject(session)
        }
        .sheet(isPresented: $openFree) {
            FreeWallSheet { openFree = false }.environmentObject(store).environmentObject(session)
        }
        .onReceive(session.$eventStamp) { _ in handleEvent() }
    }

    private var emptyBody: some View {
        ScrollView {
            Column {
                SheetCard(padding: 0) {
                    PlateBox(name: "ob_0", height: Fell.isPad ? 300 : 200, corner: 7)
                }
                SheetCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HeadRule(text: "Nothing on the bank")
                        Text("Take today's commission from the fell, or set out a wall of your own choosing: any style, any feature, any stone, any length.")
                            .font(Fell.body(13.5)).foregroundColor(Fell.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                        SealButton(title: "Take the wall of the day", tone: Fell.grit) {
                            let c = store.commission
                            store.lockDaily()
                            session.start(c, name: "\(c.feature.shortName) at \(c.place)", daily: true)
                        }
                        SealButton(title: "Set out a wall of my own", tone: Fell.inkSoft, filled: false) { openFree = true }
                    }
                }
                SheetCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HeadRule(text: "How the bank works")
                        ForEach(BuildStage.allCases, id: \.rawValue) { stage in
                            HStack(alignment: .top, spacing: 10) {
                                StageMark(stage: stage, size: 22, color: Fell.inkSoft)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stage.name).font(Fell.title(12.5)).foregroundColor(Fell.ink)
                                    Text(stageHelp(stage)).font(Fell.body(12)).foregroundColor(Fell.inkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Fell.gutter)
            .padding(.bottom, 28)
        }
    }

    private func stageHelp(_ stage: BuildStage) -> String {
        switch stage {
        case .strip: return "Drag the shovel along the ground to cut the trench, set the batter frames and pull the line taut."
        case .footings: return "The biggest stones, flat side down, dragged from the heap into the trench."
        case .courses: return "Stones off the heap: turn them length in, drop them, pin the ones that rock, tap the hearting in, raise the line."
        case .throughs: return "At half height, long stones that reach both faces."
        case .cope: return "The top course in the style's own way: flat, upright, cock and hen, locked, or turf."
        case .test: return "Press and hold for frost, sheep and wind; then the critique, and the field."
        }
    }

    private var workBody: some View {
        VStack(spacing: 0) {
            StageRail(stage: session.stage) { s in
                Knock.light()
                selected = nil
                session.stage = s
            }
            .padding(.horizontal, Fell.gutter)
            .padding(.top, 6)
            canvasArea
                .frame(height: Fell.isPad ? 360 : 250)
                .padding(.horizontal, Fell.gutter)
                .padding(.top, 8)
            statusLine
                .padding(.horizontal, Fell.gutter)
                .padding(.top, 6)
            ScrollView {
                Column {
                    if let notice = notice {
                        NoticeBar(text: notice, tone: Fell.query)
                    }
                    if let sel = selected, let w = session.wall, let s = w.stone(sel), s.placed {
                        StoneCallout(stone: s, wall: w, onLift: { _ = session.lift(sel); selected = nil },
                                     onPin: { front in if session.pin(sel, front: front) { Knock.crisp() }; selected = nil },
                                     onChock: { if session.chock(sel) { Knock.crisp() }; selected = nil },
                                     onClose: { selected = nil })
                    }
                    if let held = session.held, let w = session.wall, let s = w.stone(held.id) {
                        HeldStonePanel(stone: s, held: held, session: session)
                    }
                    StagePanel(session: session, showSection: $showSection, onJudge: { openCritique = true }, onTest: { runTest($0) }, testAnim: testAnim, onNotice: { notice = $0; noticeStamp += 1 })
                    if showSection, let w = session.wall {
                        SheetCard(padding: 8) {
                            VStack(alignment: .leading, spacing: 6) {
                                HeadRule(text: "The section", trailing: "the mate's face is built to match")
                                SectionView(wall: w, bulge: testAnim?.outcome.bulge ?? 0).frame(height: Fell.isPad ? 300 : 210)
                            }
                        }
                    }
                    if session.stage != .test, let w = session.wall {
                        HeapStrip(session: session, wall: w, canvasFrame: canvasFrame, onDrag: { point in
                            let local = CGPoint(x: point.x - canvasFrame.minX, y: point.y - canvasFrame.minY)
                            if canvasFrame.contains(point) { dragPoint = local } else { dragPoint = nil }
                        }, onEnd: { point in
                            let local = CGPoint(x: point.x - canvasFrame.minX, y: point.y - canvasFrame.minY)
                            if canvasFrame.contains(point) { dropHeld(at: local) } else { dragPoint = nil }
                        })
                    }
                    HStack(spacing: 10) {
                        Button(action: { Knock.light(); session.showJoints.toggle() }) {
                            Text(session.showJoints ? "Hide the frame check" : "Frame check").font(Fell.title(11)).foregroundColor(Fell.rubric)
                                .padding(.horizontal, 10).padding(.vertical, 7)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.rubric.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        Button(action: { Knock.light(); withAnimation { showSection.toggle() } }) {
                            Text(showSection ? "Hide the section" : "Show the section").font(Fell.title(11)).foregroundColor(Fell.sky)
                                .padding(.horizontal, 10).padding(.vertical, 7)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.sky.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button(action: { Knock.light(); openReference = true }) {
                            Text("Master's wall").font(Fell.title(11)).foregroundColor(Fell.inkSoft)
                                .padding(.horizontal, 10).padding(.vertical, 7)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.inkSoft.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    AbandonRow(session: session, store: store)
                }
                .padding(.horizontal, Fell.gutter)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
        .coordinateSpace(name: "bank")
        .onPreferenceChange(CanvasFrameKey.self) { canvasFrame = $0 }
    }

    private var canvasArea: some View {
        ZStack {
            BankCanvas(session: session, dragPoint: dragPoint, fall: fall, topple: topple, test: testAnim, selected: selected, lineDrag: lineDrag, cutting: cutting) { m in
                if map == nil || map!.ppm != m.ppm || map!.ox != m.ox { map = m }
            }
            .background(GeometryReader { geo in Color.clear.preference(key: CanvasFrameKey.self, value: geo.frame(in: .named("bank"))) })
            .gesture(canvasGesture)
        }
        .clipped()
        .cornerRadius(7)
        .overlay(RoundedRectangle(cornerRadius: 7).stroke(Fell.ink.opacity(0.15), lineWidth: 0.9))
    }

    private var canvasGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard let w = session.wall, let m = map else { return }
                if dragStart == nil {
                    dragStart = value.startLocation
                    dragMode = modeFor(start: value.startLocation, wall: w, map: m)
                }
                switch dragMode {
                case 1:
                    dragPoint = value.location
                case 2:
                    let a = m.metres(value.startLocation.x), b = m.metres(value.location.x)
                    cutting = (a, b)
                case 3:
                    lineDrag = max(0, min(w.height + 0.02, m.height(value.location.y)))
                default:
                    break
                }
            }
            .onEnded { value in
                guard let w = session.wall, let m = map else { dragStart = nil; return }
                let moved = hypot(value.location.x - value.startLocation.x, value.location.y - value.startLocation.y)
                switch dragMode {
                case 1:
                    dropHeld(at: value.location)
                case 2:
                    if let (a, b) = cutting, abs(b - a) > 0.03 {
                        session.cut(from: a, to: b)
                        Knock.soft()
                    }
                    cutting = nil
                case 3:
                    if let y = lineDrag {
                        if y > w.lineHeight + 0.015 { session.raiseLine(to: y); Knock.crisp() }
                        else if y < w.lineHeight - 0.015 { session.lowerLine(to: y); Knock.light() }
                    }
                    lineDrag = nil
                default:
                    if moved < 8 { tapAt(value.location, wall: w, map: m) }
                }
                dragStart = nil
                dragMode = 0
            }
    }

    private func modeFor(start: CGPoint, wall: Wall, map: PaintMap) -> Int {
        if session.held != nil { return 1 }
        let knob = map.at(wall.length + 0.09, wall.lineHeight)
        if wall.lineHeight > 0.01 && hypot(start.x - knob.x, start.y - knob.y) < 26 { return 3 }
        if session.stage == .strip {
            let groundY = map.at(0, wall.feature.slopeRate * (wall.length - map.metres(start.x))).y
            if abs(start.y - groundY) < 40 { return 2 }
        }
        return 0
    }

    private func tapAt(_ point: CGPoint, wall: Wall, map: PaintMap) {
        let x = map.metres(point.x), y = map.height(point.y)
        if session.stage == .cope && wall.rules.cope == .locked {
            if session.lock(at: x) { Knock.crisp(); return }
        }
        for s in wall.placed.reversed() where Geometry.contains(s.polygon, Pt(x, y)) {
            Knock.light()
            selected = selected == s.id ? nil : s.id
            return
        }
        selected = nil
    }

    private func dropHeld(at point: CGPoint) {
        guard let m = map, let held = session.held, let w = session.wall, let s = w.stone(held.id) else { dragPoint = nil; return }
        let x = m.metres(point.x)
        let fromY = max(m.height(point.y), 0.2)
        var probe = s
        probe.orientation = held.orientation
        let (preview, landing) = w.preview(held.id, at: x, tilt: held.tilt, orientation: held.orientation)
        if case .topple(let d) = preview, let l = landing {
            let poly = probe.polygon(at: x, l.y, tilt: l.tilt)
            let pivot = Pt(d < 0 ? l.supportA : l.supportB, l.bottom)
            topple = ToppleAnim(poly: poly, pivot: pivot, direction: d, start: Date().timeIntervalSinceReferenceDate, kind: s.kind, seed: s.seed)
        }
        fall = FallAnim(id: held.id, fromY: fromY, start: Date().timeIntervalSinceReferenceDate)
        session.drop(at: x)
        dragPoint = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if let f = fall, f.id == held.id { fall = nil }
            topple = nil
        }
    }

    private func handleEvent() {
        guard let event = session.lastEvent else { return }
        switch event {
        case .settled:
            Knock.firm()
            notice = nil
        case .rocking:
            Knock.hard()
            notice = "It rocks. Tap it and pin it from behind, or lift it and choose a flatter bed."
        case .toppled:
            Knock.hard()
            notice = "Its weight was outside its bearing and it went over. Back on the heap."
        case .refused(let reason):
            Knock.light()
            notice = reason
        }
        noticeStamp += 1
        let stamp = noticeStamp
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { if noticeStamp == stamp { notice = nil } }
    }

    private func runTest(_ kind: TestKind) {
        guard let outcome = session.runTest(kind) else { return }
        Knock.hard()
        testAnim = TestAnim(kind: kind, outcome: outcome, start: Date().timeIntervalSinceReferenceDate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            if let t = testAnim, t.kind == kind { testAnim = nil }
        }
    }

    private func keepWall() {
        guard let w = session.wall else { return }
        let report = session.judge()
        let (entry, improved) = store.keep(w, report: report, name: session.name, daily: session.daily)
        if session.daily { store.recordDay(score: report.score) }
        openCritique = false
        var lines: [String] = ["\(report.score), \(report.word.lowercased())."]
        lines.append(improved ? "It takes the \(entry.feature.shortName.lowercased()) slot in the field." : "A better \(entry.feature.shortName.lowercased()) already stands in the field; this one goes back to the heap.")
        if !entry.standing { lines.append("A section is down; from the field it can be rebuilt with the same stones.") }
        celebration = ("Left in the field", lines)
        session.abandon()
    }

    private var statusLine: some View {
        HStack(spacing: 8) {
            Text(session.name).font(Fell.title(11.5)).foregroundColor(Fell.ink).lineLimit(1)
            Spacer(minLength: 4)
            Text(session.progressWords).font(Fell.body(11)).foregroundColor(Fell.inkFaint).lineLimit(1)
        }
    }
}

struct StageRail: View {
    var stage: BuildStage
    var onPick: (BuildStage) -> Void

    var body: some View {
        HStack(spacing: 2) {
            ForEach(BuildStage.allCases, id: \.rawValue) { s in
                let active = s == stage
                let done = s.rawValue < stage.rawValue
                Button(action: { onPick(s) }) {
                    VStack(spacing: 3) {
                        StageMark(stage: s, size: 20, color: active ? Fell.card : (done ? Fell.moss : Fell.inkFaint))
                        Text(s.name).font(Fell.title(8.5)).foregroundColor(active ? Fell.card : (done ? Fell.moss : Fell.inkFaint))
                            .lineLimit(1).minimumScaleFactor(0.6)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 5).fill(active ? Fell.grit : Fell.ink.opacity(0.05)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct AbandonRow: View {
    @ObservedObject var session: WallSession
    var store: DykeStore
    @State private var confirm = false

    var body: some View {
        Group {
            if confirm {
                NoticeBar(text: "Put every stone back on the heap and clear the bank?", tone: Fell.rubric, action: ("Clear it", { session.abandon(); confirm = false }))
            } else {
                Button(action: { Knock.light(); confirm = true }) {
                    Text("Clear the bank").font(Fell.body(12)).foregroundColor(Fell.inkFaint).underline()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
