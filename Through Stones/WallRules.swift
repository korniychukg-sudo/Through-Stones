import Foundation

enum CoreKind: String, Codable { case hearting, earth, none }
enum CopeKind: String, Codable { case flat, upright, cockAndHen, buckAndDoe, locked, turf, none }
enum WallForm: String, Codable { case double, doubleThenSingle, hedge, single, flags }

struct StyleRules: Codable {
    var baseWidth: Double
    var topWidth: Double
    var batter: ClosedRange<Double>
    var courseTol: Double
    var wantsThroughs: Bool
    var throughSpacing: Double
    var core: CoreKind
    var cope: CopeKind
    var form: WallForm
    var doubleShare: Double
    var openness: ClosedRange<Double>
    var herringbone: Bool
    var typicalHeight: Double
    var courseHeight: Double
}

enum WallStyle: String, Codable, CaseIterable {
    case dales, cotswold, galloway, cornish, aran, caithness, newEngland, kentucky

    var name: String {
        switch self {
        case .dales: return "Yorkshire Dales double"
        case .cotswold: return "Cotswold limestone"
        case .galloway: return "Galloway dyke"
        case .cornish: return "Cornish hedge"
        case .aran: return "Aran feidin"
        case .caithness: return "Caithness flag fence"
        case .newEngland: return "New England laid wall"
        case .kentucky: return "Kentucky rock fence"
        }
    }

    var shortName: String {
        switch self {
        case .dales: return "Dales"
        case .cotswold: return "Cotswold"
        case .galloway: return "Galloway"
        case .cornish: return "Cornish"
        case .aran: return "Aran"
        case .caithness: return "Caithness"
        case .newEngland: return "New England"
        case .kentucky: return "Kentucky"
        }
    }

    var rules: StyleRules {
        switch self {
        case .dales:
            return StyleRules(baseWidth: 0.80, topWidth: 0.40, batter: 0.10...0.20, courseTol: 0.045, wantsThroughs: true,
                              throughSpacing: 0.95, core: .hearting, cope: .flat, form: .double, doubleShare: 1.0,
                              openness: 0...0.06, herringbone: false, typicalHeight: 1.35, courseHeight: 0.16)
        case .cotswold:
            return StyleRules(baseWidth: 0.70, topWidth: 0.36, batter: 0.09...0.19, courseTol: 0.028, wantsThroughs: true,
                              throughSpacing: 1.0, core: .hearting, cope: .cockAndHen, form: .double, doubleShare: 1.0,
                              openness: 0...0.05, herringbone: false, typicalHeight: 1.15, courseHeight: 0.10)
        case .galloway:
            return StyleRules(baseWidth: 0.75, topWidth: 0.34, batter: 0.09...0.22, courseTol: 0.05, wantsThroughs: false,
                              throughSpacing: 1.2, core: .hearting, cope: .locked, form: .doubleThenSingle, doubleShare: 0.5,
                              openness: 0.04...0.46, herringbone: false, typicalHeight: 1.45, courseHeight: 0.17)
        case .cornish:
            return StyleRules(baseWidth: 1.40, topWidth: 0.70, batter: 0.22...0.40, courseTol: 0.06, wantsThroughs: false,
                              throughSpacing: 1.5, core: .earth, cope: .turf, form: .hedge, doubleShare: 1.0,
                              openness: 0...0.08, herringbone: true, typicalHeight: 1.30, courseHeight: 0.15)
        case .aran:
            return StyleRules(baseWidth: 0.55, topWidth: 0.30, batter: 0.03...0.14, courseTol: 0.08, wantsThroughs: false,
                              throughSpacing: 1.5, core: .hearting, cope: .none, form: .doubleThenSingle, doubleShare: 0.45,
                              openness: 0.15...0.55, herringbone: false, typicalHeight: 1.08, courseHeight: 0.15)
        case .caithness:
            return StyleRules(baseWidth: 0.08, topWidth: 0.06, batter: 0.0...0.03, courseTol: 0.10, wantsThroughs: false,
                              throughSpacing: 2.0, core: .none, cope: .none, form: .flags, doubleShare: 0.0,
                              openness: 0...0.04, herringbone: false, typicalHeight: 1.00, courseHeight: 1.0)
        case .newEngland:
            return StyleRules(baseWidth: 0.85, topWidth: 0.50, batter: 0.07...0.18, courseTol: 0.08, wantsThroughs: true,
                              throughSpacing: 1.0, core: .hearting, cope: .flat, form: .double, doubleShare: 1.0,
                              openness: 0...0.10, herringbone: false, typicalHeight: 1.10, courseHeight: 0.17)
        case .kentucky:
            return StyleRules(baseWidth: 0.72, topWidth: 0.40, batter: 0.08...0.17, courseTol: 0.035, wantsThroughs: true,
                              throughSpacing: 1.1, core: .hearting, cope: .upright, form: .double, doubleShare: 1.0,
                              openness: 0...0.05, herringbone: false, typicalHeight: 1.30, courseHeight: 0.13)
        }
    }

    var nativeKinds: [StoneKind] {
        switch self {
        case .dales: return [.gritstone, .limestone, .sandstone]
        case .cotswold: return [.oolite, .limestone]
        case .galloway: return [.greywacke, .whinstone, .granite]
        case .cornish: return [.granite, .slate, .greywacke]
        case .aran: return [.limestone, .fieldstone]
        case .caithness: return [.flagstone]
        case .newEngland: return [.fieldstone, .granite, .schist]
        case .kentucky: return [.limestone, .clunch, .sandstone]
        }
    }
}

enum WallFeature: String, Codable, CaseIterable {
    case straightRun, cheekEnd, corner, gatePost, squeezeStile, stepStile, lunky, curve, slope, retaining, beeBole

    var name: String {
        switch self {
        case .straightRun: return "A straight run"
        case .cheekEnd: return "A cheek end"
        case .corner: return "A corner"
        case .gatePost: return "A gate post with a hanging stone"
        case .squeezeStile: return "A squeeze stile"
        case .stepStile: return "A step stile"
        case .lunky: return "A lunky"
        case .curve: return "A curve"
        case .slope: return "A wall on a slope"
        case .retaining: return "A retaining wall"
        case .beeBole: return "A bee bole"
        }
    }

    var shortName: String {
        switch self {
        case .straightRun: return "Straight run"
        case .cheekEnd: return "Cheek end"
        case .corner: return "Corner"
        case .gatePost: return "Gate post"
        case .squeezeStile: return "Squeeze stile"
        case .stepStile: return "Step stile"
        case .lunky: return "Lunky"
        case .curve: return "Curve"
        case .slope: return "On a slope"
        case .retaining: return "Retaining wall"
        case .beeBole: return "Bee bole"
        }
    }

    var rightHead: Bool {
        switch self {
        case .cheekEnd, .corner, .gatePost: return true
        default: return false
        }
    }

    var slopeRate: Double { self == .slope ? 0.16 : 0 }
    var minBatter: Double { self == .retaining ? 0.15 : 0 }
    var maxStoneWidth: Double { self == .curve ? 0.36 : 10 }
}

enum OpeningKind: String, Codable { case lunky, beeBole, stile }

struct Opening: Codable, Equatable {
    var kind: OpeningKind
    var x0: Double
    var x1: Double
    var y0: Double
    var y1: Double
    var width: Double { x1 - x0 }
    var needsLintel: Bool { kind != .stile }
}

enum BuildStage: Int, Codable, CaseIterable {
    case strip, footings, courses, throughs, cope, test

    var name: String {
        switch self {
        case .strip: return "Strip"
        case .footings: return "Footings"
        case .courses: return "Courses"
        case .throughs: return "Throughs"
        case .cope: return "Cope"
        case .test: return "Test"
        }
    }
}

struct Commission: Codable, Hashable {
    var style: WallStyle
    var feature: WallFeature
    var kind: StoneKind
    var length: Double
    var height: Double
    var seed: UInt64
    var client: String
    var place: String
    var day: Int

    var key: String { "\(style.rawValue).\(feature.rawValue).\(kind.rawValue).\(day)" }
}

struct Wall: Codable {
    var style: WallStyle
    var feature: WallFeature
    var kind: StoneKind
    var length: Double
    var height: Double
    var seed: UInt64
    var stones: [Stone]
    var sky: Skyline
    var ground: [Double]
    var cut: [Bool]
    var batterSet: Double = 0
    var frameSet: Bool = false
    var lineHeight: Double = 0
    var lineIndex: Int = 0
    var heartFill: [Double] = []
    var heartingLeft: Int = 0
    var heartingTotal: Int = 0
    var pinningsLeft: Int = 0
    var picks: Int = 0
    var returns: Int = 0
    var stage: BuildStage = .strip
    var turfLaid: Double = 0
    var locks: [Double] = []
    var openings: [Opening] = []
    var lintels: [Int] = []
    var tests: [TestOutcome] = []
    var placedOrder: [Int] = []
    var lineTops: [Int: Double] = [:]
    var margins: [Int: Double] = [:]
    var courseGuess: Double? = nil

    var rules: StyleRules { style.rules }
    var trenchDepth: Double { rules.form == .flags ? 0.30 : 0.14 }

    var placed: [Stone] { stones.filter { $0.placed } }
    var heap: [Stone] { stones.filter { !$0.placed } }

    func stone(_ id: Int) -> Stone? { stones.first { $0.id == id } }

    func index(of id: Int) -> Int? { stones.firstIndex { $0.id == id } }

    var builtHeight: Double {
        var top = 0.0
        for s in stones where s.placed && s.cls != .cope {
            top = max(top, Geometry.bounds(s.polygon).maxY)
        }
        return max(0, top)
    }

    var coreWidth: Double { rules.baseWidth }

    func widthAt(_ y: Double) -> Double {
        let r = rules
        let lean = frameSet ? batterSet : (r.batter.lowerBound + r.batter.upperBound) * 0.5
        return max(r.topWidth * 0.8, r.baseWidth - 2 * lean * max(0, y))
    }

    func groundAt(_ x: Double) -> Double {
        let i = sky.index(x)
        return ground[i]
    }

    func rawGround(_ x: Double) -> Double {
        var rng = Spool(seed ^ 0x51A7 &+ UInt64(bitPattern: Int64((x * 100).rounded())))
        let lump = rng.signed() * 0.012
        return feature.slopeRate * (length - x) + lump
    }

    func trenchFloor(_ x: Double) -> Double {
        if feature == .slope {
            let stepLen = 0.55
            let k = floor(x / stepLen)
            let stepStartX = k * stepLen
            return feature.slopeRate * (length - stepStartX) - trenchDepth
        }
        return -trenchDepth
    }

    var trenchShare: Double {
        guard !cut.isEmpty else { return 0 }
        return Double(cut.filter { $0 }.count) / Double(cut.count)
    }

    func trenchUnder(_ a: Double, _ b: Double) -> Double {
        let i0 = sky.index(a), i1 = sky.index(b)
        guard i1 >= i0 else { return 0 }
        var n = 0
        for i in i0...i1 where cut[i] { n += 1 }
        return Double(n) / Double(i1 - i0 + 1)
    }

    mutating func cutTrench(from a: Double, to b: Double) {
        let i0 = sky.index(min(a, b)), i1 = sky.index(max(a, b))
        guard i1 >= i0 else { return }
        for i in i0...i1 where !cut[i] {
            cut[i] = true
            let x = sky.xAt(i)
            let floor = trenchFloor(x)
            ground[i] = floor
            if sky.h[i] > floor && !anyStoneOver(x) { sky.h[i] = floor }
        }
    }

    private func anyStoneOver(_ x: Double) -> Bool {
        for s in stones where s.placed {
            let b = Geometry.bounds(s.polygon)
            if x >= b.minX && x <= b.maxX { return true }
        }
        return false
    }

    mutating func setBatter(_ lean: Double) {
        batterSet = max(0, min(0.5, lean))
        frameSet = true
    }

    func isLintelled(_ o: Opening) -> Bool {
        lintels.contains { lid in stone(lid).map { Geometry.bounds($0.polygon).minX < o.x1 && Geometry.bounds($0.polygon).maxX > o.x0 } ?? false }
    }

    func openingClash(_ poly: [Pt]) -> String? {
        let b = Geometry.bounds(poly)
        for o in openings {
            let overlapsX = b.maxX > o.x0 + 0.012 && b.minX < o.x1 - 0.012
            let spansX = b.minX <= o.x0 - 0.09 && b.maxX >= o.x1 + 0.09
            let word = o.kind == .lunky ? "lunky" : (o.kind == .beeBole ? "bole" : "stile gap")
            if o.kind == .stile && overlapsX && b.maxY > o.y0 + 0.012 { return "Keep the stile gap clear from the footings to the cope." }
            if o.needsLintel && overlapsX && !spansX && !isLintelled(o) && b.maxY > o.y0 + 0.012 && b.minY < o.y1 + 0.30 {
                return b.minY < o.y1 - 0.012 ? "Keep the \(word) clear; only a lintel may span it." : "Set the lintel across the \(word) before building over it."
            }
            let overlapsY = b.maxY > o.y0 + 0.012 && b.minY < o.y1 - (spansX ? 0.10 : 0.012)
            guard overlapsX && overlapsY else { continue }
            if !spansX { return "Keep the \(word) clear; only a lintel may span it." }
            return "Bring both jambs up to the head of the \(word) before the lintel goes on."
        }
        return nil
    }

    func lintelSpan(_ poly: [Pt]) -> Opening? {
        let b = Geometry.bounds(poly)
        for o in openings where o.needsLintel {
            if b.minX <= o.x0 - 0.05 && b.maxX >= o.x1 + 0.05 && b.minY >= o.y1 - 0.10 && b.minY <= o.y1 + 0.10 { return o }
        }
        return nil
    }

    mutating func drop(_ id: Int, at x: Double, tilt: Double, orientation: Orientation) -> (Rest, Landing?) {
        guard let i = index(of: id), !stones[i].placed else { return (.refused(reason: "That stone is already in the wall."), nil) }
        var s = stones[i]
        s.orientation = orientation
        let half = s.faceWidth * 0.5
        var px = x
        let minEdge = -0.03, maxEdge = length + 0.03
        if px - half < minEdge { px = minEdge + half }
        if px + half > maxEdge { px = maxEdge - half }
        if s.faceWidth > length + 0.06 { return (.refused(reason: "That stone is longer than the wall."), nil) }
        guard let (firstRest, landing) = Physics.settle(s, x: px, tilt: tilt, on: sky) else {
            return (.refused(reason: "Nothing under it to land on."), nil)
        }
        if let clash = openingClash(s.polygon(at: px, landing.y, tilt: landing.tilt)) {
            return (.refused(reason: clash), nil)
        }
        picks += 1
        let rest = leaned(firstRest, s, px, landing)
        switch rest {
        case .topple:
            returns += 1
            return (rest, landing)
        case .refused:
            return (rest, landing)
        case .settled, .rocking:
            s.x = px
            s.y = landing.y
            s.tilt = landing.tilt
            s.placed = true
            s.course = lineIndex
            s.rocking = { if case .rocking = rest { return true } else { return false } }()
            s.pinned = false
            s.pinX = nil
            s.pinFront = false
            let poly = s.polygon
            s.under = supporters(of: poly, contacts: landing.contacts)
            stones[i] = s
            sky.raise(poly)
            placedOrder.append(id)
            lineTops[id] = lineHeight
            margins[id] = landing.margin
            if lintelSpan(poly) != nil && !lintels.contains(id) { lintels.append(id) }
            return (rest, landing)
        }
    }

    func leaned(_ rest: Rest, _ s: Stone, _ px: Double, _ landing: Landing) -> Rest {
        guard rules.herringbone, abs(landing.tilt) > 0.3 else { return rest }
        var side = 0
        switch rest {
        case .rocking(let sd): side = sd
        case .topple(let d): side = d
        default: return rest
        }
        let poly = s.polygon(at: px, landing.y, tilt: landing.tilt)
        let b = Geometry.bounds(poly)
        for other in stones where other.placed && other.course == lineIndex && other.cls != .cope {
            let ob = Geometry.bounds(other.polygon)
            let touchesLeft = side < 0 && ob.maxX >= b.minX - 0.035 && ob.maxX <= b.minX + 0.08
            let touchesRight = side > 0 && ob.minX <= b.maxX + 0.035 && ob.minX >= b.maxX - 0.08
            if (touchesLeft || touchesRight) && ob.maxY > b.minY + 0.05 { return .settled }
        }
        return rest
    }

    func preview(_ id: Int, at x: Double, tilt: Double, orientation: Orientation) -> (Rest, Landing?) {
        guard let s0 = stone(id), !s0.placed else { return (.refused(reason: "already placed"), nil) }
        var s = s0
        s.orientation = orientation
        let half = s.faceWidth * 0.5
        var px = x
        if px - half < -0.03 { px = -0.03 + half }
        if px + half > length + 0.03 { px = length + 0.03 - half }
        if s.faceWidth > length + 0.06 { return (.refused(reason: "That stone is longer than the wall."), nil) }
        guard let (firstRest, landing) = Physics.settle(s, x: px, tilt: tilt, on: sky) else {
            return (.refused(reason: "Nothing under it to land on."), nil)
        }
        if let clash = openingClash(s.polygon(at: px, landing.y, tilt: landing.tilt)) { return (.refused(reason: clash), landing) }
        return (leaned(firstRest, s, px, landing), landing)
    }

    private func supporters(of poly: [Pt], contacts: [Double]) -> [Int] {
        var out: [Int] = []
        let b = Geometry.bounds(poly)
        for s in stones where s.placed {
            let sp = s.polygon
            let sb = Geometry.bounds(sp)
            guard sb.maxX > b.minX, sb.minX < b.maxX, sb.maxY <= b.minY + 0.05, sb.maxY >= b.minY - 0.08 else { continue }
            for cx in contacts where cx >= sb.minX - 0.002 && cx <= sb.maxX + 0.002 {
                if let span = Geometry.verticalSpan(sp, at: cx), let mine = Geometry.verticalSpan(poly, at: cx),
                   abs(span.top - mine.bottom) < Physics.contactTol * 2.2 {
                    if !out.contains(s.id) { out.append(s.id) }
                    break
                }
            }
        }
        return out
    }

    mutating func pin(_ id: Int, front: Bool) -> Bool {
        guard let i = index(of: id), stones[i].placed, stones[i].rocking, !stones[i].pinned, pinningsLeft > 0 else { return false }
        var s = stones[i]
        let landing = Physics.land(s, x: s.x, tilt: s.tilt, on: skyWithout(id))
        let side: Int = {
            guard let l = landing else { return 1 }
            let pivot = (l.supportA + l.supportB) * 0.5
            return l.com.x < pivot ? -1 : 1
        }()
        let slot = landing.flatMap { Physics.pinSlot(s, landing: $0, on: skyWithout(id), side: side) }
        s.pinned = true
        s.rocking = false
        s.pinFront = front
        s.pinX = slot?.x ?? (side < 0 ? Geometry.bounds(s.polygon).minX + 0.05 : Geometry.bounds(s.polygon).maxX - 0.05)
        stones[i] = s
        pinningsLeft -= 1
        return true
    }

    mutating func chock(_ id: Int) -> Bool {
        guard let i = index(of: id), stones[i].placed, !stones[i].pinned, pinningsLeft > 0 else { return false }
        var s = stones[i]
        guard abs(s.tilt) > 0.12 || s.rocking else { return false }
        let b = Geometry.bounds(s.polygon)
        s.pinned = true
        s.rocking = false
        s.pinFront = false
        s.pinX = s.tilt < 0 ? b.maxX - (b.maxX - b.minX) * 0.18 : b.minX + (b.maxX - b.minX) * 0.18
        stones[i] = s
        pinningsLeft -= 1
        return true
    }

    var heapCourseHeight: Double {
        if let g = courseGuess { return g }
        return WallBuilder.courseGuess(stones, rules: rules)
    }

    func skyWithout(_ id: Int) -> Skyline {
        var s = Skyline(from: sky.x0, to: sky.x1, dx: sky.dx) { _ in 0 }
        for i in 0..<s.count { s.h[i] = ground[i] }
        for st in stones where st.placed && st.id != id { s.raise(st.polygon) }
        return s
    }

    func canLift(_ id: Int) -> Bool {
        guard let s = stone(id), s.placed else { return false }
        for other in stones where other.placed && other.under.contains(id) { return false }
        return true
    }

    mutating func lift(_ id: Int) -> Bool {
        guard canLift(id), let i = index(of: id) else { return false }
        var s = stones[i]
        s.placed = false
        s.rocking = false
        if s.pinned { pinningsLeft += 1 }
        s.pinned = false
        s.pinX = nil
        s.pinFront = false
        s.under = []
        s.tilt = 0
        stones[i] = s
        placedOrder.removeAll { $0 == id }
        lintels.removeAll { $0 == id }
        lineTops[id] = nil
        margins[id] = nil
        picks += 1
        returns += 1
        sky = skyWithout(id)
        return true
    }

    mutating func addHearting(_ units: Int = 1) -> Int {
        guard rules.core != .none else { return 0 }
        while heartFill.count <= lineIndex { heartFill.append(0) }
        let n = min(units, heartingLeft)
        guard n > 0 else { return 0 }
        heartingLeft -= n
        let per = 1.0 / Double(max(4, heartingPerCourse))
        heartFill[lineIndex] = min(1.25, heartFill[lineIndex] + per * Double(n))
        return n
    }

    var coreCourses: Int {
        let courses = max(1, Int((height / (courseGuess ?? rules.courseHeight)).rounded())) + 1
        return rules.form == .doubleThenSingle ? max(1, Int((Double(courses) * rules.doubleShare).rounded(.up))) : courses
    }

    var heartingPerCourse: Int { max(4, Int(Double(heartingTotal) / Double(coreCourses + 2))) }

    var currentHeartFill: Double { lineIndex < heartFill.count ? heartFill[lineIndex] : 0 }

    mutating func raiseLine(to y: Double) {
        let target = max(lineHeight, min(height + 0.02, y))
        guard target > lineHeight + 0.015 else { return }
        while heartFill.count <= lineIndex { heartFill.append(0) }
        lineIndex += 1
        lineHeight = target
        while heartFill.count <= lineIndex { heartFill.append(0) }
    }

    mutating func lowerLine(to y: Double) {
        let target = max(0, min(lineHeight, y))
        guard target < lineHeight - 0.015, lineIndex > 0 else { return }
        lineIndex -= 1
        lineHeight = target
    }

    mutating func layTurf(_ amount: Double) {
        guard rules.cope == .turf else { return }
        turfLaid = min(1, turfLaid + amount)
    }

    mutating func lock(at x: Double) -> Bool {
        guard rules.cope == .locked else { return false }
        let copes = placed.filter { $0.cls == .cope }.sorted { $0.x < $1.x }
        for i in 0..<max(0, copes.count - 1) {
            let a = Geometry.bounds(copes[i].polygon).maxX, b = Geometry.bounds(copes[i + 1].polygon).minX
            let mid = (a + b) * 0.5
            if abs(x - mid) < 0.10 && !locks.contains(where: { abs($0 - mid) < 0.05 }) {
                locks.append(mid)
                return true
            }
        }
        return false
    }

    var courseCount: Int { max(1, Int((height / rules.courseHeight).rounded())) }
    var doubleTop: Double { rules.form == .doubleThenSingle ? height * rules.doubleShare : height }
    var halfHeight: Double { height * 0.5 }
    var throughsWanted: Int {
        guard rules.wantsThroughs && height >= 0.85 else { return 0 }
        let cut = openings.filter { $0.kind == .stile }.reduce(0.0) { $0 + $1.width }
        return max(1, Int((max(0.5, length - cut) / rules.throughSpacing - 0.02).rounded(.up)))
    }

    var throughsPlaced: [Stone] {
        placed.filter { $0.cls == .through && $0.orientation == .lengthIn && $0.y > height * 0.30 && $0.y < height * 0.70 }
    }

    var copesPlaced: [Stone] { placed.filter { $0.cls == .cope }.sorted { $0.x < $1.x } }

    var faceFill: Double {
        let h = min(builtHeight, height)
        guard h > 0.05 else { return 0 }
        var area = 0.0
        for s in placed where s.cls != .cope { area += s.faceWidth * s.faceHeight }
        return min(1.2, area / (length * h))
    }

    var topCourseIndex: Int { placed.filter { $0.cls != .cope }.map { $0.course }.max() ?? -1 }

    var topMedian: Double {
        let tops = courseTops(topCourseIndex)
        guard !tops.isEmpty else { return 0 }
        return tops[tops.count / 2]
    }

    func courseTops(_ k: Int) -> [Double] {
        placed.filter { $0.course == k && $0.cls != .cope }.map { Geometry.bounds($0.polygon).maxY }.sorted()
    }

    func courseMeanY(_ k: Int) -> Double? {
        let ys = placed.filter { $0.course == k && $0.cls != .cope }.map { $0.y }
        guard !ys.isEmpty else { return nil }
        return ys.reduce(0, +) / Double(ys.count)
    }
}
