import Foundation
import SwiftUI

struct HeldStone: Equatable {
    var id: Int
    var orientation: Orientation
    var tilt: Double
}

enum DropEvent: Equatable {
    case settled(id: Int)
    case rocking(id: Int, side: Int)
    case toppled(id: Int, direction: Int)
    case refused(reason: String)
}

final class WallSession: ObservableObject {
    @Published var wall: Wall? = nil
    @Published var name: String = ""
    @Published var daily: Bool = false
    @Published var held: HeldStone? = nil
    @Published var lastEvent: DropEvent? = nil
    @Published var eventStamp: Int = 0
    @Published var report: WallReport? = nil
    @Published var outcomes: [TestKind: TestOutcome] = [:]
    @Published var showJoints: Bool = false
    @Published var showSection: Bool = true
    @Published var runningTest: TestKind? = nil
    var onChange: (() -> Void)? = nil

    var active: Bool { wall != nil }

    var stage: BuildStage {
        get { wall?.stage ?? .strip }
        set { wall?.stage = newValue; changed() }
    }

    func changed() { onChange?() }

    func start(_ c: Commission, name: String, daily: Bool) {
        wall = WallBuilder.newWall(c)
        self.name = name
        self.daily = daily
        held = nil
        lastEvent = nil
        report = nil
        outcomes = [:]
        runningTest = nil
        changed()
    }

    func restore(_ w: Wall, name: String, daily: Bool) {
        wall = w
        self.name = name
        self.daily = daily
        held = nil
        report = nil
        outcomes = [:]
        for t in w.tests { outcomes[t.kind] = t }
    }

    func abandon() {
        wall = nil
        held = nil
        report = nil
        outcomes = [:]
        changed()
    }

    func pick(_ id: Int) {
        guard let w = wall, let s = w.stone(id), !s.placed else { return }
        held = HeldStone(id: id, orientation: s.cls == .flag ? .lengthIn : .lengthIn, tilt: 0)
    }

    func turnHeld() {
        guard var h = held, let w = wall, let s = w.stone(h.id) else { return }
        guard s.cls != .flag else { return }
        switch h.orientation {
        case .lengthIn: h.orientation = .traced
        case .traced: h.orientation = .lengthIn
        case .faced: h.orientation = .lengthIn
        }
        held = h
    }

    func rollHeld() {
        guard var h = held, let w = wall, let s = w.stone(h.id) else { return }
        guard s.cls != .flag && s.cls != .cope else { return }
        h.orientation = h.orientation == .faced ? .lengthIn : .faced
        held = h
    }

    func tiltHeld(_ t: Double) {
        guard var h = held else { return }
        h.tilt = max(-Double.pi * 0.5, min(Double.pi * 0.5, t))
        held = h
    }

    func flipHeld() {
        guard var h = held else { return }
        h.tilt = h.tilt >= 0 ? h.tilt - .pi : h.tilt + .pi
        held = h
    }

    func preview(at x: Double) -> (Rest, Landing?)? {
        guard let h = held, let w = wall else { return nil }
        return w.preview(h.id, at: x, tilt: h.tilt, orientation: h.orientation)
    }

    func drop(at x: Double) {
        guard let h = held, wall != nil else { return }
        let (rest, _) = wall!.drop(h.id, at: x, tilt: h.tilt, orientation: h.orientation)
        held = nil
        switch rest {
        case .settled: lastEvent = .settled(id: h.id)
        case .rocking(let side): lastEvent = .rocking(id: h.id, side: side)
        case .topple(let d): lastEvent = .toppled(id: h.id, direction: d)
        case .refused(let reason): lastEvent = .refused(reason: reason)
        }
        eventStamp += 1
        if case .refused = rest { } else { advanceStageIfDue() }
        changed()
    }

    func advanceStageIfDue() {
        guard let w = wall else { return }
        if w.stage == .strip && w.trenchShare > 0.5 && w.placed.count > 0 { wall?.stage = .footings }
    }

    func pin(_ id: Int, front: Bool) -> Bool {
        guard wall != nil else { return false }
        let ok = wall!.pin(id, front: front)
        if ok { changed() }
        return ok
    }

    func chock(_ id: Int) -> Bool {
        guard wall != nil else { return false }
        let ok = wall!.chock(id)
        if ok { changed() }
        return ok
    }

    func lift(_ id: Int) -> Bool {
        guard wall != nil else { return false }
        let ok = wall!.lift(id)
        if ok { held = nil; changed() }
        return ok
    }

    func hearting() -> Int {
        guard wall != nil else { return 0 }
        let n = wall!.addHearting(1)
        if n > 0 { changed() }
        return n
    }

    func raiseLine(to y: Double) {
        guard wall != nil else { return }
        wall!.raiseLine(to: y)
        changed()
    }

    func lowerLine(to y: Double) {
        guard wall != nil else { return }
        wall!.lowerLine(to: y)
        changed()
    }

    func cut(from a: Double, to b: Double) {
        guard wall != nil else { return }
        wall!.cutTrench(from: a, to: b)
        changed()
    }

    func setBatter(_ lean: Double) {
        guard wall != nil else { return }
        wall!.setBatter(lean)
        changed()
    }

    func layTurf(_ amount: Double) {
        guard wall != nil else { return }
        wall!.layTurf(amount)
        changed()
    }

    func lock(at x: Double) -> Bool {
        guard wall != nil else { return false }
        let ok = wall!.lock(at: x)
        if ok { changed() }
        return ok
    }

    var sheet: FaultSheet? {
        guard let w = wall else { return nil }
        return WallJudge.sheet(w)
    }

    func runTest(_ kind: TestKind) -> TestOutcome? {
        guard let w = wall else { return nil }
        let s = WallJudge.sheet(w)
        let outcome = WallJudge.test(kind, w, sheet: s)
        outcomes[kind] = outcome
        wall!.tests.removeAll { $0.kind == kind }
        wall!.tests.append(outcome)
        changed()
        return outcome
    }

    func judge() -> WallReport {
        guard let w = wall else { return WallReport(sheet: FaultSheet(faults: [], joints: [], notes: [], hollow: [], proud: 0, rockingLoose: [], throughsPlaced: 0, throughsWanted: 0, throughShortfall: 0, looseCopeIds: [], poorFootingIds: [], spallIds: [], openness: 0), score: 0, word: "A heap", efficiency: 1, stability: 1, complete: false, tests: [], critique: [], praise: []) }
        let rep = WallJudge.report(w, tests: Array(outcomes.values).sorted { $0.kind.rawValue < $1.kind.rawValue })
        report = rep
        return rep
    }

    var heapByClass: [(StoneClass, [Stone])] {
        guard let w = wall else { return [] }
        var out: [(StoneClass, [Stone])] = []
        for cls in [StoneClass.footing, .builder, .through, .cope, .flag] {
            let list = w.heap.filter { $0.cls == cls }
            if !list.isEmpty { out.append((cls, list)) }
        }
        return out
    }

    var progressWords: String {
        guard let w = wall else { return "" }
        let placed = w.placed.count
        let h = Int((w.builtHeight * 100).rounded())
        return "\(placed) stones laid, \(h) of \(Int((w.height * 100).rounded())) cm"
    }
}
