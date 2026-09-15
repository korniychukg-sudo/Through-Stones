import Foundation

var failures: [String: Int] = [:]
var checks = 0
var sections: [(String, Int, Int)] = []
var sectionStart = 0
var sectionFails = 0

func check(_ ok: Bool, _ message: String) {
    checks += 1
    if !ok {
        failures[message, default: 0] += 1
        sectionFails += 1
    }
}

var shortfalls: [String: Int] = [:]
func target(_ ok: Bool, _ message: String) {
    checks += 1
    if !ok { shortfalls[message, default: 0] += 1 }
}

func begin(_ name: String) {
    sectionStart = checks
    sectionFails = 0
    print("== \(name)")
}

func end(_ name: String) {
    sections.append((name, checks - sectionStart, sectionFails))
    print("   \(checks - sectionStart) checks, \(sectionFails) failed")
}

let artDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ""
func plateExists(_ name: String) -> Bool {
    guard !artDir.isEmpty else { return true }
    return FileManager.default.fileExists(atPath: artDir + "/" + name + ".jpg")
}

func score(_ w: Wall) -> WallReport {
    let sheet = WallJudge.sheet(w)
    let tests = TestKind.allCases.map { WallJudge.test($0, w, sheet: sheet) }
    return WallJudge.report(w, tests: tests)
}

begin("stones")
for kind in StoneKind.allCases {
    var rng = Spool(seedOf("validate.stones.\(kind.rawValue)"))
    var aspects: [Double] = []
    for cls in StoneClass.allCases where cls != .flag {
        for i in 0..<120 {
            let s = StoneForge.make(id: i, kind: kind, cls: cls, wallWidth: 0.7, rng: &rng)
            check(Geometry.isConvex(s.unit), "stone unit polygon not convex (\(kind.rawValue) \(cls.rawValue))")
            check(Geometry.area(s.unit) > 0.5, "stone unit polygon area too small (\(kind.rawValue) \(cls.rawValue))")
            check(s.unit.count >= 4 && s.unit.count <= 12, "stone vertex count out of range (\(cls.rawValue))")
            check(s.long >= s.short * 0.99, "stone long shorter than short (\(cls.rawValue))")
            check(s.thick > 0.01 && s.short > 0.03, "stone dimensions degenerate (\(cls.rawValue))")
            let poly = s.polygon(at: 0.5, 0.3, tilt: 0.2)
            check(Geometry.isConvex(poly), "placed polygon not convex after transform (\(kind.rawValue) \(cls.rawValue))")
            let b = Geometry.bounds(poly)
            check(b.maxX - b.minX > 0.02 && b.maxY - b.minY > 0.01, "placed polygon degenerate bounds")
            if cls == .builder { aspects.append(s.short / s.thick) }
            if cls == .footing || cls == .through { check(s.flatBottom, "footings and throughs must be flat-bottomed") }
        }
    }
    let mean = aspects.reduce(0, +) / Double(max(1, aspects.count))
    switch kind.family {
    case .thinBedded: check(mean >= 2.2, "thin-bedded builder mean aspect below 2.2 (\(kind.rawValue): \(String(format: "%.2f", mean)))")
    case .blocky: check(mean <= 1.6, "blocky builder mean aspect above 1.6 (\(kind.rawValue): \(String(format: "%.2f", mean)))")
    case .rounded: check(mean <= 1.7, "rounded builder mean aspect above 1.7 (\(kind.rawValue))")
    case .irregular: check(mean >= 1.4 && mean <= 2.3, "irregular builder mean aspect outside 1.4-2.3 (\(kind.rawValue))")
    }
    print("   \(kind.rawValue.padding(toLength: 11, withPad: " ", startingAt: 0)) \(kind.family.rawValue.padding(toLength: 11, withPad: " ", startingAt: 0)) builder aspect mean \(String(format: "%.2f", mean))")
}
end("stones")

begin("commissions")
var dailyCommissions: [Commission] = []
for day in 0..<400 {
    let rank = day % 5
    let a = WallBuilder.commission(day: day, rank: rank)
    let b = WallBuilder.commission(day: day, rank: rank)
    check(a == b, "daily commission not reproducible")
    check(a.length >= 1.0 && a.length <= 3.0, "commission length outside 1.0-3.0 m")
    check(a.height >= 0.6 && a.height <= 1.75, "commission height outside 0.6-1.75 m")
    check(!a.client.isEmpty && !a.place.isEmpty, "commission client or place empty")
    check(WallBuilder.line(for: a).count > 40, "commission line too short")
    if a.feature == .beeBole { check(a.height >= 1.25, "bee bole commission under 1.25 m") }
    if a.feature == .lunky { check(a.height >= 0.95, "lunky commission under 0.95 m") }
    if a.style == .cornish { check(![.lunky, .beeBole, .stepStile].contains(a.feature), "cornish hedge given an opening feature") }
    let ha = WallBuilder.heap(for: a), hb = WallBuilder.heap(for: a)
    check(ha.stones == hb.stones && ha.hearting == hb.hearting, "heap not reproducible")
    check(Set(ha.stones.map { $0.id }).count == ha.stones.count, "heap stone ids not unique")
    let wa = WallBuilder.newWall(a), wb = WallBuilder.newWall(a)
    check(wa.sky.h == wb.sky.h, "ground profile not reproducible")
    check(wa.openings == wb.openings, "openings not reproducible")
    if day < 70 { dailyCommissions.append(a) }
    if a.style.rules.form != .flags {
        let footings = ha.stones.filter { $0.cls == .footing }
        let builders = ha.stones.filter { $0.cls == .builder }
        let copes = ha.stones.filter { $0.cls == .cope }
        let footingRun = footings.reduce(0.0) { $0 + $1.short }
        check(footingRun >= a.length * 1.1, "heap footings do not cover the length")
        let faceArea = builders.reduce(0.0) { $0 + $1.short * $1.thick }
        let needed = a.length * max(0.3, a.height - 0.45)
        check(faceArea >= needed, "heap builder face area under the wall's need")
        if a.style.rules.cope != .none && a.style.rules.cope != .turf {
            let copeRun = copes.reduce(0.0) { $0 + $1.short }
            check(copeRun >= a.length * 1.05, "heap copes do not cover the length")
        }
        if wa.throughsWanted > 0 { check(ha.stones.filter { $0.cls == .through }.count >= wa.throughsWanted, "heap short of throughs") }
    }
}
var seenFeatures = Set<String>(), seenStyles = Set<String>()
for day in 0..<400 { let c = WallBuilder.commission(day: day, rank: 4); seenFeatures.insert(c.feature.rawValue); seenStyles.insert(c.style.rawValue) }
check(seenStyles.count == WallStyle.allCases.count, "not every style appears in 400 days at the top rank")
check(seenFeatures.count == WallFeature.allCases.count, "not every feature appears in 400 days at the top rank")
end("commissions")

begin("physics")
var rng = Spool(seedOf("validate.physics"))
var stand = 0, standWrong = 0, fall = 0, fallWrong = 0, rockCount = 0, rockBand = 0
let step = Skyline(from: -1.0, to: 2.0) { x in x >= 0 && x <= 1.0 ? 0.2 : 0.0 }
for i in 0..<1000 {
    let kind = rng.pick(StoneKind.allCases.filter { $0 != .flagstone })
    var s = StoneForge.make(id: i, kind: kind, cls: .through, wallWidth: 0.5, rng: &rng)
    s.orientation = .lengthIn
    let x = rng.range(0.55, 1.25)
    guard let first = Physics.land(s, x: x, tilt: 0, on: step) else { check(false, "land returned nil on a flat step"); continue }
    guard first.minX < 1.0 - 0.03 else { continue }
    guard let (rest, final) = Physics.settle(s, x: x, tilt: 0, on: step) else { check(false, "settle returned nil on a flat step"); continue }
    let inside = first.com.x < 1.0 - 0.006
    let outside = first.com.x > 1.0 + 0.012
    var fell = false
    switch rest {
    case .settled:
        fell = final.y < 0.1
    case .rocking:
        rockCount += 1
        fell = final.y < 0.1
    case .topple:
        fell = true
        check(!(first.comInside && first.supportWidth >= Physics.minSupport), "topple reported although the first landing was supported")
    case .refused:
        check(false, "settle refused a plain drop")
    }
    let farOut = first.com.x > 1.0 + s.faceWidth * 0.24
    if fell { fall += 1 } else { stand += 1 }
    if inside && fell { standWrong += 1 }
    if farOut && !fell { fallWrong += 1 }
    if outside && !farOut && !fell { rockBand += 1 }
    check(!(inside && fell), "stone with its weight over the step fell")
    check(!(farOut && !fell), "stone with its weight well beyond the edge stood")
    if outside && !farOut && !fell { if case .rocking = rest {} else { check(false, "stone in the rocking band settled instead of rocking") } }
}
print("   step edge: \(stand) stood, \(fall) fell, \(rockCount) rocked (\(rockBand) in the rocking band up to 24 percent of the width beyond the edge), \(standWrong + fallWrong) against the rule")
check(standWrong == 0 && fallWrong == 0, "centre-of-mass rule broken at the step edge")

var probe = WallBuilder.newWall(WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 3.0, height: 1.5, seed: 77))
probe.cutTrench(from: -0.1, to: probe.length + 0.1)
probe.setBatter(0.1)
probe.stage = .footings
WallBuilder.layFootings(&probe)
check(probe.placed.filter { $0.cls == .footing }.count >= 4, "footings were not laid on the probe wall")
probe.stage = .courses
var previewSettled = 0, previewTopple = 0, previewRock = 0, previewRefused = 0
var pinned = 0, pinFailed = 0
var rng2 = Spool(seedOf("validate.drops"))
for _ in 0..<1000 {
    let ids = probe.heap.filter { $0.cls == .builder }.map { $0.id }
    guard !ids.isEmpty else { break }
    let id = ids[rng2.int(0, ids.count - 1)]
    let x = rng2.range(0.05, probe.length - 0.05)
    let tilt = rng2.range(-0.15, 0.15)
    let (rest, landing) = probe.preview(id, at: x, tilt: tilt, orientation: .lengthIn)
    switch rest {
    case .settled:
        previewSettled += 1
        check(landing != nil && landing!.comInside && landing!.supportWidth >= Physics.minSupport - 0.001, "preview settled without a supported landing")
    case .topple:
        previewTopple += 1
        check(landing != nil && !(landing!.comInside && landing!.supportWidth >= Physics.minSupport), "preview toppled from a supported landing")
    case .rocking:
        previewRock += 1
    case .refused:
        previewRefused += 1
    }
    if probe.topMedian > probe.height - 0.2 { continue }
    let before = probe.sky.h
    let (dropRest, _) = probe.drop(id, at: x, tilt: tilt, orientation: .lengthIn)
    switch dropRest {
    case .settled, .rocking:
        let s = probe.stone(id)!
        check(s.placed, "dropped stone not marked placed")
        let b = Geometry.bounds(s.polygon)
        check(b.minX >= -0.06 && b.maxX <= probe.length + 0.06, "placed stone outside the wall's length")
        for k in 0..<before.count { if probe.sky.h[k] < before[k] - 1e-9 { check(false, "skyline lowered by a drop"); break } }
        if case .rocking = dropRest {
            check(s.rocking, "rocking drop not flagged on the stone")
            let left = probe.pinningsLeft
            if probe.pin(id, front: false) {
                pinned += 1
                let p = probe.stone(id)!
                check(!p.rocking && p.pinned && !p.pinFront, "pin from behind did not stop the rocking")
                check(probe.pinningsLeft == left - 1, "pinning not taken from the bucket")
            } else {
                pinFailed += 1
                check(probe.pinningsLeft == 0, "pin refused while pinnings remain")
            }
        }
    case .topple:
        check(!probe.stone(id)!.placed, "toppled stone marked placed")
        check(probe.sky.h == before, "skyline changed by a topple")
    case .refused:
        check(probe.sky.h == before, "skyline changed by a refusal")
    }
    if probe.topMedian > probe.lineHeight + 0.05 { probe.raiseLine(to: probe.topMedian + 0.12) }
}
print("   previews: \(previewSettled) settled, \(previewRock) rocking, \(previewTopple) toppled, \(previewRefused) refused; \(pinned) pinned, \(pinFailed) pins refused")
check(previewSettled > 300, "too few settled previews")
check(previewTopple > 20, "too few toppled previews")
check(previewRock > 5, "no rocking landings found")
target(pinned >= 3, "fewer than three rocking stones were pinned in the drop run")
let probeSheet = WallJudge.sheet(probe)
check(probeSheet.rockingLoose.isEmpty, "pinned stones still counted as rocking loose")

var rocker = WallBuilder.newWall(WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 2.0, height: 1.2, seed: 5))
rocker.cutTrench(from: -0.1, to: rocker.length + 0.1)
for k in 0..<rocker.sky.count {
    let x = rocker.sky.xAt(k)
    rocker.sky.h[k] = abs(x - 1.0) < 0.004 ? 0.30 : 0.0
}
var rockedOnce = false
var pinnedOnce = false
for id in rocker.heap.filter({ $0.cls == .through }).map({ $0.id }).prefix(12) {
    let (rest, _) = rocker.drop(id, at: 1.0, tilt: 0, orientation: .lengthIn)
    if case .rocking = rest {
        rockedOnce = true
        let s = rocker.stone(id)!
        check(s.placed && s.rocking && !s.pinned, "stone balanced on a point not flagged rocking")
        check(WallJudge.sheet(rocker).rockingLoose.contains(id), "rocking stone not listed as loose by the judge")
        let left = rocker.pinningsLeft
        check(rocker.pin(id, front: false), "pin refused on a rocking stone")
        let p = rocker.stone(id)!
        check(!p.rocking && p.pinned && !p.pinFront && rocker.pinningsLeft == left - 1, "pin from behind did not settle the rocking stone")
        check(!WallJudge.sheet(rocker).rockingLoose.contains(id), "pinned stone still listed as loose")
        check(!rocker.pin(id, front: false), "a pinned stone accepted a second pin")
        pinnedOnce = true
        break
    } else {
        _ = rocker.lift(id)
    }
}
check(rockedOnce, "a flat stone balanced on a point never rocked")
check(pinnedOnce, "the balanced stone was never pinned")
end("physics")

begin("reference")
var scores: [Int] = []
var low: [String] = []
let clock = Date()
for c in dailyCommissions {
    let w = WallBuilder.reference(c, attempts: 6)
    let r = score(w)
    scores.append(r.score)
    check(r.complete, "reference wall not complete (\(c.style.rawValue) \(c.feature.rawValue))")
    check(r.efficiency >= 0.999, "reference efficiency below 100 percent")
    check(!r.faults.contains { $0.kind == .wrongBatter }, "reference wall outside the batter (\(c.style.rawValue) \(c.feature.rawValue))")
    check(!r.faults.contains { $0.kind == .traced }, "reference wall has a traced stone")
    check(!r.faults.contains { $0.kind == .pinFront }, "reference wall pinned from the face")
    target(r.score >= 75, "reference wall under 75 (\(c.style.rawValue) \(c.feature.rawValue) \(c.kind.rawValue) day \(c.day): \(r.score))")
    if r.score < 90 { low.append("\(c.style.rawValue)/\(c.feature.rawValue)/\(c.kind.rawValue) day \(c.day): \(r.score)") }
    if c.style.rules.wantsThroughs && w.height >= 0.85 {
        target(r.sheet.throughShortfall == 0, "reference wall short of throughs (\(c.style.rawValue) \(c.feature.rawValue))")
    }
    for t in r.tests where t.kind != .century { target(t.passed, "reference wall failed \(t.kind.rawValue) (\(c.style.rawValue) \(c.feature.rawValue) day \(c.day))") }
}
let above90 = scores.filter { $0 >= 90 }.count
let above75 = scores.filter { $0 >= 75 }.count
print("   \(scores.count) daily references in \(Int(Date().timeIntervalSince(clock))) s: \(above90) at 90 or better, \(above75) at 75 or better, min \(scores.min() ?? 0), mean \(scores.reduce(0, +) / max(1, scores.count))")
for line in low { print("   under 90: \(line)") }
check(above90 * 10 >= scores.count * 7, "fewer than 70 percent of daily references reach 90")
end("reference")

begin("rules")
let dalesTall = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 2.0, height: 1.4, seed: 4242)
let tall = WallBuilder.reference(dalesTall, attempts: 4)
let tallReport = score(tall)
check(tallReport.tests.first { $0.kind == .wind }?.passed == true, "sound 1.4 m reference fails the wind test")
var noThroughs = tall
for i in 0..<noThroughs.stones.count where noThroughs.stones[i].placed && noThroughs.stones[i].cls == .through { noThroughs.stones[i].cls = .builder }
let noThroughsReport = score(noThroughs)
check(noThroughsReport.tests.first { $0.kind == .wind }?.passed == false, "1.4 m wall with no throughs passes the wind test")
check(noThroughsReport.faults.contains { $0.kind == .noThroughs }, "no throughs fault not raised")
check(noThroughsReport.score < tallReport.score, "removing the throughs did not lower the score")

var hollow = tall
hollow.heartFill = hollow.heartFill.map { _ in 0.0 }
let hollowReport = score(hollow)
check(hollowReport.tests.first { $0.kind == .sheep }?.passed == false, "hollow-cored wall passes the sheep test")
check(hollowReport.faults.contains { $0.kind == .hollowCore }, "hollow core fault not raised")
check(hollowReport.tests.first { $0.kind == .century }?.passed == false, "hollow-cored wall stands the hundred years")

var stack = WallBuilder.newWall(WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 1.8, height: 1.2, seed: 9090))
stack.cutTrench(from: -0.1, to: stack.length + 0.1)
stack.setBatter(0.1)
stack.stage = .footings
WallBuilder.layFootings(&stack)
stack.stage = .courses
var stackHeap = stack.heap.filter { $0.cls == .builder && $0.short >= 0.22 && $0.short <= 0.26 }.map { $0.id }
var columns = [0.28, 0.54, 0.80, 1.06, 1.32, 1.56]
var stackCourses = 0
for _ in 0..<4 {
    var laid = 0
    for xc in columns {
        guard let id = stackHeap.first else { break }
        let (rest, _) = stack.drop(id, at: xc, tilt: 0, orientation: .lengthIn)
        switch rest {
        case .settled, .rocking:
            stackHeap.removeFirst()
            laid += 1
        default:
            stackHeap.removeFirst()
        }
    }
    if laid > 0 { stackCourses += 1 }
    stack.raiseLine(to: stack.topMedian + 0.12)
    _ = stack.addHearting(stack.heartingPerCourse)
}
let stackSheet = WallJudge.sheet(stack)
let stackFrost = WallJudge.test(.frost, stack, sheet: stackSheet)
print("   stack bond: \(stack.placed.count - stack.placed.filter { $0.cls == .footing }.count) builders in \(stackCourses) courses, \(stackSheet.joints.count) running joints")
check(stackSheet.joints.count >= 2, "stack bond did not raise running joints")
check(!stackFrost.passed, "stack-bonded wall passes the frost test")
check(!stackFrost.lost.isEmpty, "frost failure lost no stones")

var jointsFound = 0, frostChecked = 0
for k in 0..<12 {
    let c = dailyCommissions[k * 5 % dailyCommissions.count]
    guard c.style.rules.form == .double || c.style.rules.form == .doubleThenSingle else { continue }
    let w = WallBuilder.attempt(c, variant: UInt64(k + 3), jitter: 90)
    let s = WallJudge.sheet(w)
    let frost = WallJudge.test(.frost, w, sheet: s)
    let longJoint = s.joints.contains { $0.y1 - $0.y0 > c.style.rules.courseHeight * 2.6 }
    let cracks = s.joints.count >= 2 || longJoint
    frostChecked += 1
    if cracks { jointsFound += 1; check(!frost.passed, "wall with running joints passed the frost test") }
    if s.joints.isEmpty && s.spallIds.count < 2 { check(frost.passed, "wall with no running joints failed the frost test") }
}
print("   frost rule checked on \(frostChecked) jittered walls, \(jointsFound) with cracks")

let plumb = WallBuilder.free(style: .dales, feature: .straightRun, kind: .gritstone, length: 1.8, height: 1.3, seed: 31)
var plumbWall = WallBuilder.attempt(plumb, variant: 0, jitter: 0)
plumbWall.batterSet = 0
plumbWall.frameSet = true
for i in 0..<plumbWall.stones.count where plumbWall.stones[i].placed && plumbWall.stones[i].cls == .through { plumbWall.stones[i].cls = .builder }
let plumbReport = score(plumbWall)
check(plumbReport.tests.first { $0.kind == .wind }?.passed == false, "plumb wall with no throughs passes the wind test")

let freeSeeds: [(WallStyle, WallFeature, StoneKind, Double, Double)] = [
    (.galloway, .straightRun, .greywacke, 2.0, 1.4), (.cornish, .straightRun, .granite, 2.0, 1.3), (.aran, .straightRun, .limestone, 2.0, 1.1),
    (.caithness, .straightRun, .flagstone, 2.0, 1.0), (.cotswold, .cheekEnd, .oolite, 1.8, 1.1), (.newEngland, .corner, .fieldstone, 2.0, 1.2),
    (.kentucky, .lunky, .limestone, 2.0, 1.2), (.dales, .stepStile, .gritstone, 2.2, 1.3), (.dales, .squeezeStile, .sandstone, 2.0, 1.2),
    (.dales, .gatePost, .gritstone, 2.0, 1.2), (.dales, .curve, .limestone, 2.0, 1.2), (.dales, .slope, .gritstone, 2.2, 1.2),
    (.dales, .retaining, .gritstone, 2.0, 1.2), (.dales, .beeBole, .gritstone, 2.0, 1.3)
]
var freeScores: [Int] = []
for (st, fe, kd, l, h) in freeSeeds {
    let c = WallBuilder.free(style: st, feature: fe, kind: kd, length: l, height: h, seed: seedOf("free.\(st.rawValue).\(fe.rawValue)"))
    let w = WallBuilder.reference(c, attempts: 4)
    let r = score(w)
    freeScores.append(r.score)
    check(r.complete, "free reference not complete (\(st.rawValue) \(fe.rawValue))")
    target(r.score >= 75, "free reference under 75 (\(st.rawValue) \(fe.rawValue): \(r.score))")
    check(!r.faults.contains { $0.kind == .wrongBatter }, "free reference outside the batter (\(st.rawValue) \(fe.rawValue))")
    if st.rules.form == .flags { check(w.placed.filter { $0.cls == .flag }.count >= 2, "flag fence reference laid too few flags") }
    if fe == .lunky || fe == .beeBole { check(!w.lintels.isEmpty, "opening feature reference has no lintel (\(fe.rawValue))") }
}
print("   free references: \(freeScores.map { String($0) }.joined(separator: " "))")
end("rules")

begin("weathering")
let now = Date().timeIntervalSince1970
var last = -1.0
var weatherOK = true
let sample = FieldWall(id: "w", name: "w", commission: dailyCommissions[0], score: 80, word: "sound", built: 0, builtAt: now, stones: [], faults: [:], tests: [:], throughs: 0, fallen: [], efficiency: 1, placedCount: 0, daily: false, critique: [], praise: [], frameLean: 0.1, lineHeight: 1.2)
for days in stride(from: 0, through: 40000, by: 5) {
    var w = sample
    w.builtAt = now - Double(days) * 86_400
    let v = w.weathering
    if v < last - 1e-9 { weatherOK = false }
    if v < 0 || v > 1 { weatherOK = false }
    last = v
}
check(weatherOK, "weathering not monotonic or outside 0-1")
var fresh = sample
fresh.builtAt = now
var old = sample
old.builtAt = now - 365 * 86_400 * 100
check(fresh.weathering < 0.02, "fresh wall already weathered")
check(old.weathering > 0.9, "century-old wall barely weathered")
check(WallReport.grade(for: 0) == 0 && WallReport.grade(for: 100) == 3, "grade bands wrong")
for s in 0...100 { check(!WallReport.word(for: s).isEmpty, "score word empty") }
end("weathering")

begin("content")
check(StoneLore.stones.count == StoneKind.allCases.count, "stone register count")
check(Set(StoneLore.stones.map { $0.kind }).count == StoneKind.allCases.count, "stone register kinds not unique")
check(Set(StoneLore.stones.map { $0.name }).count == StoneLore.stones.count, "stone register names not unique")
for e in StoneLore.stones {
    check([e.name, e.region, e.age].allSatisfy { !$0.isEmpty } && [e.splits, e.weathers, e.lichen, e.note].allSatisfy { $0.count > 12 }, "stone register entry has an empty field (\(e.kind.rawValue))")
    for cls in ["footing", "builder", "through", "cope", "hearting"] { check(plateExists("st_\(e.kind.rawValue)_\(cls)"), "missing stone class plate st_\(e.kind.rawValue)_\(cls)") }
}
for group in ["grit", "lime", "oolite", "slate", "hard", "field"] { for age in ["new", "year", "ten", "fifty", "century"] { check(plateExists("wx_\(group)_\(age)"), "missing weathering plate wx_\(group)_\(age)") } }
check(StoneLore.tools.count == 12, "tool register count")
check(Set(StoneLore.tools.map { $0.key }).count == StoneLore.tools.count, "tool keys not unique")
for t in StoneLore.tools {
    check(!t.name.isEmpty && [t.use, t.history, t.wrong].allSatisfy { $0.count > 12 }, "tool entry has an empty field (\(t.key))")
    check(plateExists(t.plate), "missing tool plate \(t.plate)")
}
check(StoneLore.faults.count == FaultKind.allCases.count, "fault register count")
check(Set(StoneLore.faults.map { $0.kind }).count == FaultKind.allCases.count, "fault register kinds not unique")
for f in StoneLore.faults {
    check([f.what, f.why, f.fix].allSatisfy { $0.count > 12 }, "fault entry has an empty field (\(f.kind.rawValue))")
    check(plateExists(f.plate), "missing fault plate \(f.plate)")
}
check(StoneLore.styles.count == WallStyle.allCases.count, "style register count")
check(Set(StoneLore.styles.map { $0.style }).count == WallStyle.allCases.count, "style register not unique")
for s in StoneLore.styles {
    check([s.region, s.history, s.stone].allSatisfy { $0.count > 12 } && s.rules.count >= 3, "style entry has an empty field (\(s.style.rawValue))")
    check(plateExists(s.facePlate) && plateExists(s.sectionPlate), "missing style plate \(s.style.rawValue)")
    check(!s.style.name.isEmpty && !s.style.shortName.isEmpty && !s.style.nativeKinds.isEmpty, "style names or native kinds empty")
}
check(StoneLore.features.count == WallFeature.allCases.count, "feature register count")
check(Set(StoneLore.features.map { $0.feature }).count == WallFeature.allCases.count, "feature register not unique")
for f in StoneLore.features {
    check([f.how, f.why, f.wrong].allSatisfy { $0.count > 12 }, "feature entry has an empty field (\(f.feature.rawValue))")
    check(plateExists(f.plate), "missing feature plate \(f.plate)")
}
check(StoneLore.ranks.count == 5 && StoneLore.ranks.map { $0.0 } == StoneLore.ranks.map { $0.0 }.sorted(), "ranks not ascending")
check(Lessons.all.count == 12, "lesson count")
check(Set(Lessons.all.map { $0.title }).count == Lessons.all.count, "lesson titles not unique")
check(Lessons.all.map { $0.index } == Array(0..<Lessons.all.count), "lesson indices not 0..11 in order")
for l in Lessons.all {
    check(l.words >= 300, "lesson under 300 words (\(l.index))")
    check(!l.sub.isEmpty, "lesson subtitle empty")
    check(plateExists(l.plate), "missing lesson plate \(l.plate)")
}
check(Lexicon.entries.count >= 60, "glossary under 60 entries")
check(Set(Lexicon.entries.map { $0.term.lowercased() }).count == Lexicon.entries.count, "glossary terms not unique")
for g in Lexicon.entries { check(g.means.count > 20, "glossary meaning too short (\(g.term))") }
check(Examiner.authored.count >= 36, "authored exam questions under 36")
check(Set(Examiner.authored.map { $0.id }).count == Examiner.authored.count, "authored exam ids not unique")
check(Set(Examiner.authored.map { $0.prompt }).count == Examiner.authored.count, "authored exam prompts not unique")
func validQuestion(_ q: ExamQuestion, _ tag: String) {
    check(q.options.count == 4, "exam question without four options (\(tag))")
    check(Set(q.options).count == q.options.count, "exam options not unique (\(tag))")
    check(q.answer >= 0 && q.answer < q.options.count, "exam answer index out of range (\(tag))")
    check(q.prompt.count > 15 && q.why.count > 15, "exam prompt or explanation too short (\(tag))")
    if let p = q.plate { check(plateExists(p), "missing exam plate \(p)") }
}
for q in Examiner.authored { validQuestion(q, q.id) }
for seed in 0..<300 {
    let paper = Examiner.paper(seed: seedOf("validate.exam.\(seed)"))
    check(paper.count == 14, "exam paper not 14 questions")
    check(Set(paper.map { $0.id }).count == paper.count, "exam paper repeats a question")
    for q in paper { validQuestion(q, q.kind) }
    let again = Examiner.paper(seed: seedOf("validate.exam.\(seed)"))
    check(again.map { $0.id } == paper.map { $0.id }, "exam paper not reproducible")
}
check(Badges.list.count == 20, "badge count")
check(Set(Badges.list.map { $0.0 }).count == Badges.list.count, "badge keys not unique")
for b in Badges.list { check(!b.1.isEmpty && !b.2.isEmpty, "badge text empty (\(b.0))") }
for i in 0..<7 { check(plateExists("fell_h\(i)"), "missing fell plate fell_h\(i)") }
for i in 0..<4 { check(plateExists("ob_\(i)"), "missing onboarding plate ob_\(i)") }
for k in ["sheep", "gate", "tree", "frame", "curlew", "hawthorn", "barn", "sky", "rowan", "bracken", "stile", "crag"] { check(plateExists("dc_\(k)"), "missing decor plate dc_\(k)") }
for kind in FaultKind.allCases { check(!kind.name.isEmpty && kind.weight > 0 && kind.cap >= kind.weight, "fault kind metadata (\(kind.rawValue))") }
for f in WallFeature.allCases { check(!f.name.isEmpty && !f.shortName.isEmpty, "feature names empty") }
end("content")

print("")
print("== summary")
for (name, n, f) in sections { print("   \(name.padding(toLength: 12, withPad: " ", startingAt: 0)) \(n) checks, \(f) failed") }
print("   total \(checks) checks, \(failures.values.reduce(0, +)) failed")
if !failures.isEmpty {
    print("== failures by message")
    for (message, n) in failures.sorted(by: { $0.value > $1.value }) { print("   \(n) x \(message)") }
}
if !shortfalls.isEmpty {
    print("== targets missed (reported, not counted as failures)")
    for (message, n) in shortfalls.sorted(by: { $0.value > $1.value }) { print("   \(n) x \(message)") }
}
exit(failures.isEmpty ? 0 : 1)
