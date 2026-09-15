import Foundation

enum FaultKind: String, Codable, CaseIterable {
    case runningJoint, faceBedded, hollowCore, noThroughs, belly, onEdge, looseCope, poorFooting, traced, badHead, pinFront, wrongBatter

    var name: String {
        switch self {
        case .runningJoint: return "Running joint"
        case .faceBedded: return "Face-bedded stone"
        case .hollowCore: return "Hollow core"
        case .noThroughs: return "No throughs"
        case .belly: return "Belly"
        case .onEdge: return "Stone on edge"
        case .looseCope: return "Loose cope"
        case .poorFooting: return "Poor footing"
        case .traced: return "Traced stone"
        case .badHead: return "Bad cheek end"
        case .pinFront: return "Pinning from the front"
        case .wrongBatter: return "Wrong batter"
        }
    }

    var weight: Double {
        switch self {
        case .runningJoint: return 6
        case .faceBedded: return 4
        case .hollowCore: return 8
        case .noThroughs: return 7
        case .belly: return 5
        case .onEdge: return 4
        case .looseCope: return 3
        case .poorFooting: return 5
        case .traced: return 3
        case .badHead: return 5
        case .pinFront: return 2
        case .wrongBatter: return 10
        }
    }

    var cap: Double {
        switch self {
        case .runningJoint: return 30
        case .faceBedded: return 20
        case .hollowCore: return 28
        case .noThroughs: return 16
        case .belly: return 12
        case .onEdge: return 18
        case .looseCope: return 15
        case .poorFooting: return 18
        case .traced: return 16
        case .badHead: return 16
        case .pinFront: return 8
        case .wrongBatter: return 10
        }
    }
}

struct Fault: Codable, Equatable {
    var kind: FaultKind
    var count: Int
    var detail: String
    var ids: [Int]

    var penalty: Double { min(kind.cap, Double(count) * kind.weight) }
}

struct JointMark: Codable, Equatable {
    var x: Double
    var y0: Double
    var y1: Double
    var upper: Int
    var lower: Int
}

struct Note: Codable, Equatable {
    var text: String
    var penalty: Double
}

enum TestKind: String, Codable, CaseIterable {
    case frost, sheep, wind, century

    var name: String {
        switch self {
        case .frost: return "Frost"
        case .sheep: return "Sheep"
        case .wind: return "Wind"
        case .century: return "The hundred years"
        }
    }
}

struct TestOutcome: Codable, Equatable {
    var kind: TestKind
    var passed: Bool
    var lost: [Int]
    var sag: [Int: Double]
    var shove: [Int: Double]
    var bulge: Double
    var note: String
}

struct FaultSheet: Codable {
    var faults: [Fault]
    var joints: [JointMark]
    var notes: [Note]
    var hollow: [Int]
    var proud: Int
    var rockingLoose: [Int]
    var throughsPlaced: Int
    var throughsWanted: Int
    var throughShortfall: Int
    var looseCopeIds: [Int]
    var poorFootingIds: [Int]
    var spallIds: [Int]
    var openness: Double

    func count(_ kind: FaultKind) -> Int { faults.first { $0.kind == kind }?.count ?? 0 }
    func has(_ kind: FaultKind) -> Bool { count(kind) > 0 }
    var penalty: Double { faults.reduce(0) { $0 + $1.penalty } + notes.reduce(0) { $0 + $1.penalty } }
}

struct WallReport: Codable {
    var sheet: FaultSheet
    var score: Int
    var word: String
    var efficiency: Double
    var stability: Double
    var complete: Bool
    var tests: [TestOutcome]
    var critique: [String]
    var praise: [String]

    var faults: [Fault] { sheet.faults }
    var joints: [JointMark] { sheet.joints }

    static func word(for score: Int) -> String {
        switch score {
        case ..<40: return "A heap"
        case 40..<65: return "A standing wall"
        case 65..<85: return "A sound wall"
        default: return "A master's wall"
        }
    }

    static func grade(for score: Int) -> Int {
        switch score {
        case ..<40: return 0
        case 40..<65: return 1
        case 65..<85: return 2
        default: return 3
        }
    }
}

enum WallJudge {
    static let jointTol = 0.035
    static let hollowLimit = 0.6
    static let stepBands: [Double] = [0.26, 0.54, 0.82]

    static func bedAngle(_ s: Stone) -> Double {
        let a = abs(s.tilt.truncatingRemainder(dividingBy: .pi))
        return min(a, .pi - a)
    }

    static func isStructural(_ s: Stone) -> Bool { s.cls == .builder || s.cls == .footing || s.cls == .through }

    static func headEdges(_ w: Wall) -> [(x: Double, right: Bool, y0: Double, y1: Double)] {
        var out: [(Double, Bool, Double, Double)] = []
        if w.feature.rightHead { out.append((w.length, true, -1, w.height + 1)) }
        for o in w.openings {
            out.append((o.x0, true, o.y0, o.y1))
            out.append((o.x1, false, o.y0, o.y1))
        }
        return out.map { (x: $0.0, right: $0.1, y0: $0.2, y1: $0.3) }
    }

    static func atHead(_ b: (minX: Double, maxX: Double, minY: Double, maxY: Double), _ w: Wall) -> Bool {
        for h in headEdges(w) {
            let edge = h.right ? b.maxX : b.minX
            if abs(edge - h.x) < 0.05 && b.maxY > h.y0 && b.minY < h.y1 { return true }
        }
        return false
    }

    static func sheet(_ w: Wall) -> FaultSheet {
        let r = w.rules
        let placed = w.placed
        var faults: [Fault] = []
        var notes: [Note] = []
        var joints: [JointMark] = []

        func add(_ kind: FaultKind, _ ids: [Int], _ detail: String) {
            guard !ids.isEmpty else { return }
            faults.append(Fault(kind: kind, count: ids.count, detail: detail, ids: ids))
        }

        var jointUppers: [Int] = []
        for s in placed where isStructural(s) && bedAngle(s) < 0.35 {
            let sb = Geometry.bounds(s.polygon)
            for uid in s.under {
                guard let u = w.stone(uid), u.cls != .cope, bedAngle(u) < 0.35 else { continue }
                let ub = Geometry.bounds(u.polygon)
                let leftEnd = sb.minX < 0.05
                let rightEnd = sb.maxX > w.length - 0.05
                func record(_ x: Double) {
                    if joints.contains(where: { abs($0.x - x) < 0.04 && abs($0.y0 - ub.minY) < 0.04 }) { return }
                    joints.append(JointMark(x: x, y0: ub.minY, y1: sb.maxY, upper: s.id, lower: u.id))
                    if !jointUppers.contains(s.id) { jointUppers.append(s.id) }
                }
                if abs(sb.minX - ub.minX) < jointTol && !leftEnd && !atHead((sb.minX, sb.minX, sb.minY, sb.maxY), w) {
                    record((sb.minX + ub.minX) * 0.5)
                }
                if abs(sb.maxX - ub.maxX) < jointTol && !rightEnd && !atHead((sb.maxX, sb.maxX, sb.minY, sb.maxY), w) {
                    record((sb.maxX + ub.maxX) * 0.5)
                }
            }
        }
        add(.runningJoint, Array(repeating: 0, count: joints.count).enumerated().map { jointUppers[min($0.offset, jointUppers.count - 1)] }, joints.count == 1 ? "one joint runs straight through two courses" : "\(joints.count) joints run straight through two or more courses")

        var tracedIds: [Int] = []
        var facedIds: [Int] = []
        var edgeIds: [Int] = []
        for s in placed where isStructural(s) {
            let b = Geometry.bounds(s.polygon)
            let aranUpright = w.style == .aran && s.y > w.doubleTop - 0.05
            let isLintel = w.lintels.contains(s.id)
            if s.orientation == .traced && !atHead(b, w) && !isLintel { tracedIds.append(s.id) }
            if s.orientation == .faced && !aranUpright { facedIds.append(s.id) }
            if s.onEdge && !aranUpright { edgeIds.append(s.id) }
        }
        add(.traced, tracedIds, "laid with the length along the face, not into the wall")
        add(.faceBedded, facedIds, "the bed turned out to make a face; it reaches nothing into the wall")
        add(.onEdge, edgeIds, "bedding planes stood upright; frost will split them")

        var hollow: [Int] = []
        if r.core != .none {
            let topCourse = w.topCourseIndex
            if topCourse >= 0 {
                for k in 0...topCourse {
                    guard let centre = w.courseMeanY(k) else { continue }
                    guard centre < w.doubleTop - 0.02 else { continue }
                    let fill = k < w.heartFill.count ? w.heartFill[k] : 0
                    if fill < hollowLimit { hollow.append(k) }
                }
            }
        }
        add(.hollowCore, hollow, r.core == .earth ? "courses with the earth core not rammed" : "courses left without hearting packed in")
        if hollow.count >= 1 && w.builtHeight > 0.7 {
            add(.belly, Array(repeating: 0, count: min(hollow.count, 3)), "an empty core lets the faces lean out")
        }

        var throughsWanted = w.throughsWanted
        var throughsPlaced = w.throughsPlaced.count
        var shortfall = 0
        if w.style == .galloway {
            let band = placed.filter { $0.cls == .through && $0.orientation == .lengthIn && abs($0.y - w.doubleTop) < 0.16 }
            throughsWanted = max(1, Int((w.length / 0.5).rounded(.up)))
            throughsPlaced = band.count
            shortfall = max(0, throughsWanted - throughsPlaced)
            if shortfall > 0 { add(.noThroughs, Array(repeating: 0, count: shortfall), "the cover band is short: \(throughsPlaced) of \(throughsWanted) covers across the dyke") }
        } else if throughsWanted > 0 {
            shortfall = max(0, throughsWanted - throughsPlaced)
            let xs = w.throughsPlaced.map { $0.x }.sorted()
            if !xs.isEmpty {
                let marks = [0.0] + xs + [w.length]
                var gaps: [Double] = []
                for i in 1..<marks.count {
                    var run = marks[i] - marks[i - 1]
                    for o in w.openings where o.kind == .stile && o.x0 >= marks[i - 1] - 0.05 && o.x1 <= marks[i] + 0.05 { run -= o.width }
                    gaps.append(run)
                }
                let wide = gaps.filter { $0 > r.throughSpacing + 0.45 }.count
                shortfall = max(shortfall, wide)
            }
            if shortfall > 0 {
                add(.noThroughs, Array(repeating: 0, count: shortfall),
                    throughsPlaced == 0 ? "no throughs at half height; the two faces are not tied" : "\(throughsPlaced) throughs where \(throughsWanted) were wanted, and a long run without one")
            }
        }

        var looseIds: [Int] = []
        var looseCount = 0
        var copeDetail = ""
        switch r.cope {
        case .none:
            break
        case .turf:
            if w.turfLaid < 0.9 {
                looseCount = Int(((1 - w.turfLaid) * w.length / 0.3).rounded(.up)) + 1
                copeDetail = "the turf is not laid along the top"
            }
        default:
            let copes = w.copesPlaced
            if copes.isEmpty {
                looseCount = Int((w.length / 0.3).rounded(.up))
                copeDetail = "no cope set on the wall"
            } else {
                var pairs = 0
                var lean = 0
                var alternation = 0
                let tops = w.courseTops(w.topCourseIndex)
                let topOfWall = tops.isEmpty ? 0 : tops[tops.count / 2]
                for i in 0..<copes.count {
                    let b = Geometry.bounds(copes[i].polygon)
                    if abs(copes[i].tilt) > 0.28 && !copes[i].pinned { lean += 1; looseIds.append(copes[i].id) }
                    if b.minY < topOfWall - (r.cope == .locked ? 0.24 : 0.16) { looseIds.append(copes[i].id); pairs += 1 }
                    if i + 1 < copes.count {
                        let nb = Geometry.bounds(copes[i + 1].polygon)
                        let gap = nb.minX - b.maxX
                        let mid = (b.maxX + nb.minX) * 0.5
                        let overOpening = w.openings.contains { $0.x0 >= b.maxX - 0.05 && $0.x1 <= nb.minX + 0.05 }
                        if overOpening {
                        } else if r.cope == .locked {
                            if !w.locks.contains(where: { abs($0 - mid) < 0.06 }) { pairs += 1; looseIds.append(copes[i + 1].id) }
                        } else if gap > 0.045 {
                            pairs += 1
                            looseIds.append(copes[i + 1].id)
                        }
                        if r.cope == .cockAndHen && gap < 0.12 && abs(copes[i].faceHeight - copes[i + 1].faceHeight) < 0.045 { alternation += 1 }
                    }
                }
                let first = Geometry.bounds(copes[0].polygon).minX
                let last = Geometry.bounds(copes[copes.count - 1].polygon).maxX
                let span = (last - first) / w.length
                var missing = 0
                if span < 0.88 { missing = Int(((0.88 - span) * w.length / 0.14).rounded(.up)) }
                if first > 0.10 { missing += 1 }
                if w.length - last > 0.10 { missing += 1 }
                looseCount = pairs + lean + alternation + missing
                var parts: [String] = []
                if pairs > 0 { parts.append(r.cope == .locked ? "\(pairs) copes not locked" : "\(pairs) gaps between copes") }
                if lean > 0 { parts.append("\(lean) leaning") }
                if alternation > 0 { parts.append("cock and hen not alternated \(alternation) times") }
                if missing > 0 { parts.append("the run of cope is short") }
                copeDetail = parts.joined(separator: ", ")
            }
        }
        if looseCount > 0 {
            faults.append(Fault(kind: .looseCope, count: looseCount, detail: copeDetail, ids: looseIds))
        }

        var poorIds: [Int] = []
        var poorDetail: [String] = []
        for s in placed where s.cls != .cope && s.cls != .pinning {
            let b = Geometry.bounds(s.polygon)
            let groundHere = w.feature == .slope ? w.trenchFloor(s.x) : -w.trenchDepth
            let onFloor = b.minY < groundHere + 0.06 || s.course == 0
            guard onFloor else { continue }
            var bad = false
            if s.cls == .builder && r.form != .flags && r.form != .single { bad = true; poorDetail.append("a small builder used as a footing") }
            if s.flipped && s.flatBottom { bad = true; poorDetail.append("a footing laid flat side up") }
            if w.trenchUnder(b.minX, b.maxX) < 0.7 { bad = true; poorDetail.append("set on turf that was never stripped") }
            if s.rocking && !s.pinned { bad = true; poorDetail.append("a footing left rocking") }
            if bad { poorIds.append(s.id) }
        }
        add(.poorFooting, poorIds, Array(Set(poorDetail)).sorted().joined(separator: "; "))

        var headBad: [Int] = []
        var headDetail: [String] = []
        for h in headEdges(w) {
            var column: [(Int, Stone)] = []
            for s in placed where isStructural(s) {
                let b = Geometry.bounds(s.polygon)
                let edge = h.right ? b.maxX : b.minX
                guard b.maxY > h.y0 + 0.02, b.minY < h.y1 - 0.02 else { continue }
                if abs(edge - h.x) < 0.06 { column.append((s.course, s)) }
            }
            column.sort { $0.0 < $1.0 }
            var last: Orientation? = nil
            var lastCourse = -1
            for (course, s) in column {
                if course == lastCourse { continue }
                let singlePart = r.form == .doubleThenSingle && s.y > w.doubleTop
                let b = Geometry.bounds(s.polygon)
                let edge = h.right ? b.maxX : b.minX
                if abs(edge - h.x) > 0.03 { headBad.append(s.id); headDetail.append("the head is not plumb") }
                lastCourse = course
                if s.cls == .through { continue }
                if s.orientation == .faced && !singlePart { headBad.append(s.id); headDetail.append("a face-bedded stone in the head") }
                else if let l = last, l == s.orientation, !singlePart { headBad.append(s.id); headDetail.append("headers and ties not alternated") }
                last = s.orientation
            }
            let topCourse = placed.filter { $0.cls != .cope }.map { $0.course }.max() ?? -1
            let coursesInHead = min(topCourse, Int((min(h.y1, w.height) / r.courseHeight).rounded()) - 1)
            if coursesInHead >= 1 && column.count < coursesInHead / 2 {
                headBad.append(-1)
                headDetail.append("the head is ragged; courses do not reach the end")
            }
        }
        add(.badHead, headBad, Array(Set(headDetail)).sorted().joined(separator: "; "))

        let pinFrontIds = placed.filter { $0.pinFront }.map { $0.id }
        add(.pinFront, pinFrontIds, "pinned from the face; the pins will be kicked out")

        if r.batter.upperBound > 0.03 {
            let low = max(r.batter.lowerBound, w.feature.minBatter)
            if !w.frameSet {
                faults.append(Fault(kind: .wrongBatter, count: 1, detail: "no batter frame was set; the faces have no lean", ids: []))
            } else if w.batterSet < low {
                faults.append(Fault(kind: .wrongBatter, count: 1, detail: "the frame stands too near plumb for this wall", ids: []))
            } else if w.batterSet > r.batter.upperBound {
                faults.append(Fault(kind: .wrongBatter, count: 1, detail: "the frame leans in too far; the top is too thin to cope", ids: []))
            }
        }

        var proud = 0
        for s in placed where s.cls != .cope && s.cls != .flag {
            if let line = w.lineTops[s.id], line > 0.02 {
                let top = Geometry.bounds(s.polygon).maxY
                if top - line > r.courseTol { proud += 1 }
            }
        }
        let structuralCount = max(1, placed.filter { isStructural($0) }.count)
        if Double(proud) / Double(structuralCount) > 0.25 {
            notes.append(Note(text: "The courses wander: \(proud) stones stand proud of the line.", penalty: min(8, Double(proud) * 1.0)))
        }

        let rockingLoose = placed.filter { $0.rocking && !$0.pinned }.map { $0.id }
        if !rockingLoose.isEmpty {
            notes.append(Note(text: rockingLoose.count == 1 ? "One stone was left rocking without a pin." : "\(rockingLoose.count) stones were left rocking without a pin.", penalty: min(12, Double(rockingLoose.count) * 4)))
        }

        for o in w.openings where o.needsLintel {
            let bridged = w.lintels.contains { lid in
                guard let s = w.stone(lid), s.placed else { return false }
                let b = Geometry.bounds(s.polygon)
                return b.minX <= o.x0 - 0.05 && b.maxX >= o.x1 + 0.05
            }
            if !bridged && w.builtHeight > o.y1 + 0.05 {
                notes.append(Note(text: "The \(o.kind == .lunky ? "lunky" : "bee bole") has no lintel across it.", penalty: 10))
            }
        }

        if w.feature == .stepStile {
            let zone = (w.length * 0.5 - 0.7)...(w.length * 0.5 + 0.7)
            let steps = placed.filter { $0.cls == .through && $0.orientation == .lengthIn && zone.contains($0.x) }.map { $0.y }
            let bandsHit = stepBands.filter { h in steps.contains { abs($0 - h) < 0.17 } }.count
            if bandsHit < 3 {
                notes.append(Note(text: "A step stile wants three throughs projecting as steps, each a stride above the last; \(bandsHit) of 3 are there.", penalty: Double(3 - bandsHit) * 4))
            }
        }

        if w.feature == .gatePost {
            let hanger = placed.contains { $0.cls == .through && $0.orientation == .lengthIn && $0.x > w.length - 0.55 && $0.y > w.height * 0.55 && $0.y < w.height * 0.95 }
            if !hanger { notes.append(Note(text: "The post has no hanging stone for the gate.", penalty: 8)) }
        }

        var openness = 0.0
        if r.form == .doubleThenSingle {
            let uppers = placed.filter { $0.cls != .cope && $0.y > w.doubleTop + 0.02 }
            if !uppers.isEmpty {
                let covered = uppers.reduce(0.0) { $0 + $1.faceWidth * $1.faceHeight }
                let upperTop = min(w.height, uppers.map { Geometry.bounds($0.polygon).maxY }.max() ?? w.height)
                let gapsWidth = w.openings.filter { $0.y1 > w.doubleTop }.reduce(0.0) { $0 + $1.width }
                openness = max(0, 1 - covered / (max(0.5, w.length - gapsWidth) * max(0.2, upperTop - w.doubleTop)))
                if openness < r.openness.lowerBound {
                    notes.append(Note(text: w.style == .aran ? "The feidin is too tight: the wind has nowhere to go but over." : "The single stones sit too close; a Galloway top is built to let daylight through.", penalty: 8))
                } else if openness > r.openness.upperBound {
                    notes.append(Note(text: "Too open: the gaps above the double are wider than the stones.", penalty: 8))
                }
            }
        } else if r.form == .double || r.form == .hedge {
            let fill = w.faceFill
            if fill < (r.herringbone ? 0.62 : 0.78) && w.builtHeight > 0.3 {
                notes.append(Note(text: "The face is open: a lot of daylight shows between the stones.", penalty: min(12, (0.78 - fill) * 45)))
            }
        }

        if r.herringbone {
            let uppers = placed.filter { isStructural($0) && $0.course >= 1 && !atHead(Geometry.bounds($0.polygon), w) && !(w.feature.rightHead && Geometry.bounds($0.polygon).maxX > w.length - 0.05) }
            if uppers.count >= 4 {
                var good = 0
                for s in uppers {
                    let a = bedAngle(s)
                    let sign: Double = s.tilt >= 0 ? 1 : -1
                    let want: Double = s.course % 2 == 1 ? 1 : -1
                    if a > 0.35 && a < 1.15 && sign == want { good += 1 }
                }
                if Double(good) / Double(uppers.count) < 0.6 {
                    notes.append(Note(text: "The courses are not herringboned: Jack and Jill should lean against each other course by course.", penalty: 9))
                }
            }
        }

        if w.feature == .curve {
            let wide = placed.filter { isStructural($0) && $0.faceWidth > w.feature.maxStoneWidth }
            if wide.count > 2 { notes.append(Note(text: "\(wide.count) stones are too long in the face to follow the curve.", penalty: min(8, Double(wide.count) * 2))) }
        }

        var spall: [Int] = []
        for s in placed where isStructural(s) && s.kind.weakness >= 0.35 && (s.orientation == .faced || (s.onEdge && !(w.style == .aran && s.y > w.doubleTop - 0.05))) {
            spall.append(s.id)
        }

        return FaultSheet(faults: faults, joints: joints, notes: notes, hollow: hollow, proud: proud, rockingLoose: rockingLoose,
                          throughsPlaced: throughsPlaced, throughsWanted: throughsWanted, throughShortfall: shortfall,
                          looseCopeIds: looseIds, poorFootingIds: poorIds, spallIds: spall, openness: openness)
    }

    static func test(_ kind: TestKind, _ w: Wall, sheet s: FaultSheet) -> TestOutcome {
        let r = w.rules
        let placed = w.placed
        switch kind {
        case .frost:
            var lost: [Int] = []
            var sag: [Int: Double] = [:]
            for j in s.joints {
                for st in placed {
                    let b = Geometry.bounds(st.polygon)
                    if b.minX >= j.x - 0.02 && b.minX < j.x + 0.55 && b.minY >= j.y0 - 0.03 && st.cls != .flag {
                        if !lost.contains(st.id) { lost.append(st.id) }
                    }
                }
            }
            for id in s.spallIds where !lost.contains(id) { lost.append(id) }
            for st in placed where st.cls != .flag {
                var below = 0
                for k in s.hollow where Double(k + 1) * r.courseHeight <= st.y + 0.02 { below += 1 }
                if below > 0 {
                    var rng = Spool(w.seed ^ UInt64(st.id &* 7919))
                    sag[st.id] = Double(below) * r.courseHeight * rng.range(0.02, 0.06)
                }
            }
            let longJoints = s.joints.filter { $0.y1 - $0.y0 > r.courseHeight * 2.6 }
            let cracks = s.joints.count >= 2 || !longJoints.isEmpty
            if !cracks { lost = lost.filter { id in !s.joints.contains { j in placed.first { $0.id == id }.map { Geometry.bounds($0.polygon).minX >= j.x - 0.02 } ?? false } } }
            let passed = !cracks && s.spallIds.count < 2
            let note: String
            if cracks { note = "Ice opened the running joint\(s.joints.count > 1 ? "s" : "") and a section came away." }
            else if !s.joints.isEmpty { note = "Ice worked at the one running joint but the stones either side held it." }
            else if s.spallIds.count >= 2 { note = "The stones set on edge shaled in the frost and dropped out of the face." }
            else if !s.hollow.isEmpty { note = "The hearting heaved and settled but nothing came away." }
            else { note = "The frost found nothing to open." }
            return TestOutcome(kind: .frost, passed: passed, lost: lost, sag: sag, shove: [:], bulge: 0, note: note)
        case .sheep:
            var lost: [Int] = []
            var shove: [Int: Double] = [:]
            if r.cope == .none {
                lost = s.rockingLoose
                let passed = lost.isEmpty
                return TestOutcome(kind: .sheep, passed: passed, lost: lost, sag: [:], shove: [:], bulge: 0,
                                   note: passed ? "The flock leaned on it and it did not move." : "The sheep found the rocking stones and knocked them down.")
            }
            for id in s.looseCopeIds where !lost.contains(id) { lost.append(id) }
            if r.cope == .turf && w.turfLaid < 0.9 {
                for c in placed where c.y > w.height - 0.25 { if !lost.contains(c.id) { lost.append(c.id) } }
            }
            if s.count(.looseCope) > 0 && lost.isEmpty {
                for c in w.copesPlaced.suffix(max(1, s.count(.looseCope))) { lost.append(c.id) }
            }
            let bulge = Double(s.hollow.count) * 0.035
            if bulge > 0 {
                for st in placed where st.cls != .cope && st.y > (s.hollow.min().map { Double($0) * r.courseHeight } ?? 0) {
                    shove[st.id] = bulge
                }
            }
            let passed = lost.isEmpty && s.hollow.isEmpty
            let note: String
            if !lost.isEmpty && !s.hollow.isEmpty { note = "The sheep pushed the loose cope off and the empty core let the face belly out." }
            else if !lost.isEmpty { note = "A ewe leaned on the cope and the loose stones went over." }
            else if !s.hollow.isEmpty { note = "The cope held but the face bellied where the core was hollow." }
            else { note = "Sheep rubbed along it all summer and nothing moved." }
            return TestOutcome(kind: .sheep, passed: passed, lost: lost, sag: [:], shove: shove, bulge: bulge, note: note)
        case .wind:
            var lost: [Int] = []
            var passed = true
            var note = "The wind went over and through and the wall stood."
            switch r.form {
            case .flags:
                let flags = placed.filter { $0.cls == .flag }.sorted { $0.x < $1.x }
                for (i, f) in flags.enumerated() {
                    let b = Geometry.bounds(f.polygon)
                    var bad = w.trenchUnder(b.minX, b.maxX) < 0.7
                    if i + 1 < flags.count {
                        let nb = Geometry.bounds(flags[i + 1].polygon)
                        if nb.minX - b.maxX > 0.05 { bad = true }
                    }
                    if bad { lost.append(f.id) }
                }
                passed = lost.isEmpty
                if !passed { note = "The flags that were not bedded in the trench, or stood alone, went over in the gale." }
            case .single:
                passed = true
            case .doubleThenSingle where w.style == .aran:
                passed = s.openness >= r.openness.lowerBound
                if !passed {
                    lost = placed.filter { $0.y > w.doubleTop }.sorted { $0.y > $1.y }.prefix(4).map { $0.id }
                    note = "Built too tight, the feidin took the whole gale on its face and the top went."
                }
            default:
                let tall = w.height > 1.2
                let vertical = s.faults.contains { $0.kind == .wrongBatter && $0.detail.contains("plumb") }
                if tall && (s.throughShortfall > 0 || vertical) {
                    passed = false
                    let xs = w.throughsPlaced.map { $0.x }.sorted()
                    var gapStart = 0.0, gapEnd = w.length
                    var best = -1.0
                    let marks = [0.0] + xs + [w.length]
                    for i in 1..<marks.count where marks[i] - marks[i - 1] > best {
                        best = marks[i] - marks[i - 1]
                        gapStart = marks[i - 1]
                        gapEnd = marks[i]
                    }
                    let mid = (gapStart + gapEnd) * 0.5
                    for st in placed where st.cls != .flag && st.y > w.height * 0.62 && abs(st.x - mid) < 0.45 {
                        lost.append(st.id)
                    }
                    note = vertical ? "With no lean in it the face caught the wind and shed its top." : "Over head height with nothing tying the faces together, the face bulged and shed its top."
                } else if s.hollow.count >= 2 && vertical {
                    passed = false
                    for st in placed where st.y > w.height * 0.62 { lost.append(st.id) }
                    note = "Plumb and hollow, the wall rocked in the wind and dropped its top course."
                }
            }
            return TestOutcome(kind: .wind, passed: passed, lost: lost, sag: [:], shove: [:], bulge: 0, note: note)
        case .century:
            let frost = test(.frost, w, sheet: s)
            let sheep = test(.sheep, w, sheet: s)
            let wind = test(.wind, w, sheet: s)
            var lost = frost.lost
            for id in sheep.lost + wind.lost where !lost.contains(id) { lost.append(id) }
            var sag = frost.sag
            for id in s.poorFootingIds {
                guard let f = w.stone(id) else { continue }
                let b = Geometry.bounds(f.polygon)
                for st in placed where st.x > b.minX && st.x < b.maxX && st.y > f.y {
                    sag[st.id] = (sag[st.id] ?? 0) + 0.03
                }
                if let weakest = placed.filter({ $0.x > b.minX && $0.x < b.maxX && $0.y > f.y }).min(by: { (w.margins[$0.id] ?? 1) < (w.margins[$1.id] ?? 1) }) {
                    if !lost.contains(weakest.id) { lost.append(weakest.id) }
                }
            }
            for id in s.rockingLoose where !lost.contains(id) { lost.append(id) }
            if let branchTarget = w.copesPlaced.min(by: { (w.margins[$0.id] ?? 1) < (w.margins[$1.id] ?? 1) }), s.count(.looseCope) > 0, !lost.contains(branchTarget.id) {
                lost.append(branchTarget.id)
            }
            let passed = frost.passed && sheep.passed && wind.passed && s.poorFootingIds.isEmpty && s.rockingLoose.isEmpty
            var note: String
            if passed { note = "A hundred winters, a hundred flocks, roots under the footings and a branch across the cope: it is still standing." }
            else if !s.poorFootingIds.isEmpty { note = "Roots heaved the poor footing and the wall above it slumped." }
            else if !frost.passed { note = frost.note }
            else if !wind.passed { note = wind.note }
            else if !sheep.passed { note = sheep.note }
            else { note = "The rocking stones worked loose over the years and came out." }
            return TestOutcome(kind: .century, passed: passed, lost: lost, sag: sag, shove: sheep.shove, bulge: sheep.bulge, note: note)
        }
    }

    static func report(_ w: Wall, tests: [TestOutcome]) -> WallReport {
        let s = sheet(w)
        let placed = w.placed
        let placedCount = placed.count
        let efficiency = placedCount == 0 ? 1.0 : min(1.0, Double(placedCount) / Double(max(1, w.picks)))
        var marginSum = 0.0
        var marginN = 0
        for st in placed { if let m = w.margins[st.id] { marginSum += m; marginN += 1 } }
        let stability = marginN == 0 ? 1.0 : marginSum / Double(marginN)
        let complete = w.builtHeight >= w.height * 0.85
        var score = 100.0
        score -= s.penalty
        score -= (1 - efficiency) * 25
        score -= (1 - stability) * 6
        let otherFailed = tests.contains { !$0.passed && $0.kind != .century }
        for t in tests where !t.passed { score -= t.kind == .century ? (otherFailed ? 0 : 6) : 8 }
        if placedCount == 0 { score = 0 }
        else if !complete {
            let frac = min(1, w.builtHeight / max(0.1, w.height))
            score = min(score, 20 + 35 * frac)
        }
        let final = Int(max(0, min(100, score)).rounded())
        var critique: [String] = []
        var praise: [String] = []
        for f in s.faults.sorted(by: { $0.penalty > $1.penalty }) {
            critique.append("\(f.kind.name)\(f.count > 1 ? " x\(f.count)" : ""): \(f.detail).")
        }
        for n in s.notes { critique.append(n.text) }
        if !complete && placedCount > 0 { critique.append("The wall is not up to height: \(Int((w.builtHeight * 100).rounded())) of \(Int((w.height * 100).rounded())) centimetres.") }
        if efficiency < 0.9 { critique.append("Stones picked up and put down again: \(Int(((1 - efficiency) * 100).rounded())) of every hundred lifts were wasted.") }
        for t in tests where !t.passed { critique.append("\(t.kind.name): \(t.note)") }
        if s.joints.isEmpty && placedCount > 6 { praise.append("Every joint is crossed; nothing runs.") }
        if s.count(.traced) == 0 && s.count(.faceBedded) == 0 && placedCount > 6 { praise.append("Every stone has its length into the wall.") }
        if s.hollow.isEmpty && w.rules.core != .none && w.builtHeight > 0.5 { praise.append("The core is packed tight to the top.") }
        if s.throughShortfall == 0 && s.throughsWanted > 0 { praise.append("The throughs tie the two faces at half height.") }
        if s.count(.looseCope) == 0 && w.rules.cope != .none && complete { praise.append("The cope is tight and stands to the sheep.") }
        if efficiency >= 0.97 && placedCount > 6 { praise.append("Each stone picked up once and laid once.") }
        if stability > 0.55 && placedCount > 6 { praise.append("The stones sit with their weight well inside their bearing.") }
        for t in tests where t.passed { praise.append("\(t.kind.name): \(t.note)") }
        return WallReport(sheet: s, score: final, word: WallReport.word(for: final), efficiency: efficiency, stability: stability,
                          complete: complete, tests: tests, critique: critique, praise: praise)
    }
}
