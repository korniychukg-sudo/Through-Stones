import Foundation
import SwiftUI

struct FieldStone: Codable, Hashable {
    var k: String
    var c: String
    var p: [Double]
    var t: Double
    var n: Bool

    var kind: StoneKind { StoneKind(rawValue: k) ?? .gritstone }
    var cls: StoneClass { StoneClass(rawValue: c) ?? .builder }
    var polygon: [Pt] {
        var out: [Pt] = []
        var i = 0
        while i + 1 < p.count { out.append(Pt(p[i], p[i + 1])); i += 2 }
        return out
    }
}

struct FieldWall: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var commission: Commission
    var score: Int
    var word: String
    var built: Int
    var builtAt: Double
    var stones: [FieldStone]
    var faults: [String: Int]
    var tests: [String: Bool]
    var throughs: Int
    var fallen: [Int]
    var efficiency: Double
    var placedCount: Int
    var daily: Bool
    var critique: [String]
    var praise: [String]
    var frameLean: Double
    var lineHeight: Double

    var style: WallStyle { commission.style }
    var feature: WallFeature { commission.feature }
    var kind: StoneKind { commission.kind }
    var grade: Int { WallReport.grade(for: score) }
    var standing: Bool { fallen.isEmpty }
    var passedAll: Bool { ["frost", "sheep", "wind"].allSatisfy { tests[$0] == true } }
    var ageDays: Double { max(0, (Date().timeIntervalSince1970 - builtAt) / 86_400) }
    var weathering: Double { min(1, ageDays / 365.0 * 0.6 + pow(min(1, ageDays / 3650.0), 0.7) * 0.4) }

    static func from(_ wall: Wall, report: WallReport, name: String, daily: Bool, day: Int) -> FieldWall {
        var stones: [FieldStone] = []
        for s in wall.placed {
            var flat: [Double] = []
            for q in s.polygon { flat.append((q.x * 1000).rounded() / 1000); flat.append((q.y * 1000).rounded() / 1000) }
            stones.append(FieldStone(k: s.kind.rawValue, c: s.cls.rawValue, p: flat, t: (s.tilt * 1000).rounded() / 1000, n: s.pinned))
        }
        var faults: [String: Int] = [:]
        for f in report.faults { faults[f.kind.rawValue] = f.count }
        var tests: [String: Bool] = [:]
        for t in report.tests { tests[t.kind.rawValue] = t.passed }
        var fallen: [Int] = []
        if let worst = report.tests.filter({ !$0.passed }).max(by: { $0.lost.count < $1.lost.count }) {
            let ids = wall.placed.map { $0.id }
            fallen = worst.lost.compactMap { ids.firstIndex(of: $0) }
        }
        let c = Commission(style: wall.style, feature: wall.feature, kind: wall.kind, length: wall.length, height: wall.height, seed: wall.seed, client: "", place: "", day: day)
        return FieldWall(id: "\(day).\(wall.style.rawValue).\(wall.feature.rawValue).\(wall.seed % 100000)", name: name, commission: c, score: report.score, word: report.word, built: day,
                         builtAt: Date().timeIntervalSince1970, stones: stones, faults: faults, tests: tests, throughs: wall.throughsPlaced.count, fallen: fallen,
                         efficiency: report.efficiency, placedCount: wall.placed.count, daily: daily, critique: report.critique, praise: report.praise,
                         frameLean: wall.batterSet, lineHeight: wall.builtHeight)
    }
}

struct Ledger: Codable {
    var walls: [FieldWall] = []
    var points: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    var lastDay: Int = -1
    var daysDone: [Int] = []
    var wallsBuilt: Int = 0
    var seenIntro: Bool? = nil
    var readLessons: [Int]? = nil
    var readTerms: [String]? = nil
    var readStyles: [String]? = nil
    var readFeatures: [String]? = nil
    var readStones: [String]? = nil
    var readTools: [String]? = nil
    var readFaults: [String]? = nil
    var examBest: Int? = nil
    var examsTaken: Int? = nil
    var badges: [String]? = nil
    var dailyScores: [String: Int]? = nil
    var dailyRank: [String: Int]? = nil
    var session: Wall? = nil
    var sessionName: String? = nil
    var sessionDaily: Bool? = nil
    var lastTab: Int? = nil
    var sections: [String: Int]? = nil
    var throughsLaid: Int? = nil
    var pinsBack: Int? = nil
    var pinsFront: Int? = nil
    var rebuilt: Int? = nil
    var dawnWalls: Int? = nil
    var stylesBuilt: [String]? = nil
    var kindsBuilt: [String]? = nil
    var featuresBuilt: [String]? = nil
    var frostPassed: Int? = nil
    var centuryPassed: Int? = nil
    var galePassed: Int? = nil
    var bestScore: Int? = nil
}

final class DykeStore: ObservableObject {
    @Published var ledger: Ledger { didSet { save() } }
    @Published var wantedTab: Int? = nil
    @Published var referenceCache: [String: Wall] = [:]
    private let key = "throughstones.ledger.v1"
    private var saveWork: DispatchWorkItem? = nil

    init() {
        if let data = UserDefaults.standard.data(forKey: key), let decoded = try? JSONDecoder().decode(Ledger.self, from: data) {
            ledger = decoded
        } else {
            ledger = Ledger()
        }
    }

    private func save() {
        saveWork?.cancel()
        let snapshot = ledger
        let work = DispatchWorkItem { [key] in
            if let data = try? JSONEncoder().encode(snapshot) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
        saveWork = work
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.4, execute: work)
    }

    func reset() {
        ledger = Ledger()
        ledger.seenIntro = true
        referenceCache.removeAll()
    }

    var today: Int { WallBuilder.dayIndex() }

    var liveStreak: Int {
        guard ledger.lastDay == today || ledger.lastDay == today - 1 else { return 0 }
        return ledger.streak
    }

    var rankIndex: Int {
        var index = 0
        for (i, step) in StoneLore.ranks.enumerated() where ledger.points >= step.0 { index = i }
        return index
    }

    var rank: (String, String, Int, Int) {
        let i = rankIndex
        let current = StoneLore.ranks[i]
        let ceiling = i + 1 < StoneLore.ranks.count ? StoneLore.ranks[i + 1].0 : current.0
        return (current.1, current.2, ledger.points, ceiling)
    }

    func award(_ n: Int) { ledger.points += n }

    var commission: Commission {
        WallBuilder.commission(day: today, rank: ledger.dailyRank?["\(today)"] ?? rankIndex)
    }

    func lockDaily() {
        var ranks = ledger.dailyRank ?? [:]
        guard ranks["\(today)"] == nil else { return }
        ranks["\(today)"] = rankIndex
        if ranks.count > 60 {
            let keep = ranks.keys.compactMap { Int($0) }.sorted().suffix(60)
            ranks = ranks.filter { keep.contains(Int($0.key) ?? -1) }
        }
        ledger.dailyRank = ranks
    }

    func workedToday() -> Bool { ledger.daysDone.contains(today) }

    func dailyScore(_ day: Int) -> Int? { ledger.dailyScores?["\(day)"] }

    func recordDay(score: Int) {
        let day = today
        var scores = ledger.dailyScores ?? [:]
        let previous = scores["\(day)"] ?? -1
        if score > previous { scores["\(day)"] = score }
        ledger.dailyScores = scores
        guard !ledger.daysDone.contains(day) else { return }
        ledger.daysDone.append(day)
        if ledger.daysDone.count > 400 { ledger.daysDone.removeFirst(ledger.daysDone.count - 400) }
        if ledger.lastDay == day - 1 { ledger.streak += 1 } else { ledger.streak = 1 }
        ledger.lastDay = day
        ledger.bestStreak = max(ledger.bestStreak, ledger.streak)
        award(25)
    }

    func section(_ key: String) -> Int { ledger.sections?[key] ?? 0 }

    func remember(_ key: String, _ value: Int) {
        var s = ledger.sections ?? [:]
        if s[key] == value { return }
        s[key] = value
        ledger.sections = s
    }

    @discardableResult
    func keep(_ wall: Wall, report: WallReport, name: String, daily: Bool) -> (FieldWall, Bool) {
        let entry = FieldWall.from(wall, report: report, name: name, daily: daily, day: today)
        ledger.wallsBuilt += 1
        var points = report.score / 4
        if report.score >= 85 { points += 20 } else if report.score >= 65 { points += 10 }
        for t in report.tests where t.passed { points += 3 }
        var improved = false
        let slot = entry.feature.rawValue
        if let i = ledger.walls.firstIndex(where: { $0.feature.rawValue == slot }) {
            if entry.score > ledger.walls[i].score || !ledger.walls[i].standing {
                ledger.walls[i] = entry
                points += 8
                improved = true
            }
        } else {
            ledger.walls.append(entry)
            points += 15
            improved = true
        }
        var styles = ledger.stylesBuilt ?? []
        if !styles.contains(wall.style.rawValue) { styles.append(wall.style.rawValue) }
        ledger.stylesBuilt = styles
        var kinds = ledger.kindsBuilt ?? []
        if !kinds.contains(wall.kind.rawValue) { kinds.append(wall.kind.rawValue) }
        ledger.kindsBuilt = kinds
        var features = ledger.featuresBuilt ?? []
        if !features.contains(wall.feature.rawValue) { features.append(wall.feature.rawValue) }
        ledger.featuresBuilt = features
        ledger.throughsLaid = (ledger.throughsLaid ?? 0) + wall.throughsPlaced.count
        ledger.pinsBack = (ledger.pinsBack ?? 0) + wall.placed.filter { $0.pinned && !$0.pinFront }.count
        ledger.pinsFront = (ledger.pinsFront ?? 0) + wall.placed.filter { $0.pinFront }.count
        if report.tests.contains(where: { $0.kind == .frost && $0.passed }) { ledger.frostPassed = (ledger.frostPassed ?? 0) + 1 }
        if report.tests.contains(where: { $0.kind == .century && $0.passed }) { ledger.centuryPassed = (ledger.centuryPassed ?? 0) + 1 }
        if wall.height > 1.25 && report.tests.contains(where: { $0.kind == .wind && $0.passed }) { ledger.galePassed = (ledger.galePassed ?? 0) + 1 }
        if Calendar.current.component(.hour, from: Date()) < 7 { ledger.dawnWalls = (ledger.dawnWalls ?? 0) + 1 }
        if report.score > (ledger.bestScore ?? 0) { ledger.bestScore = report.score }
        award(points)
        checkBadges()
        return (entry, improved)
    }

    func wall(for feature: WallFeature) -> FieldWall? { ledger.walls.first { $0.feature == feature } }

    func markRebuilt() {
        ledger.rebuilt = (ledger.rebuilt ?? 0) + 1
        checkBadges()
    }

    func markLesson(_ index: Int) {
        var read = ledger.readLessons ?? []
        if !read.contains(index) { read.append(index); award(6) }
        ledger.readLessons = read
        checkBadges()
    }

    func markTerm(_ term: String) {
        var read = ledger.readTerms ?? []
        if !read.contains(term) { read.append(term); award(1) }
        ledger.readTerms = read
        checkBadges()
    }

    func markRead(_ register: String, _ id: String) {
        func bump(_ list: [String]?) -> [String] {
            var seen = list ?? []
            if !seen.contains(id) { seen.append(id); award(2) }
            return seen
        }
        switch register {
        case "style": ledger.readStyles = bump(ledger.readStyles)
        case "feature": ledger.readFeatures = bump(ledger.readFeatures)
        case "stone": ledger.readStones = bump(ledger.readStones)
        case "tool": ledger.readTools = bump(ledger.readTools)
        default: ledger.readFaults = bump(ledger.readFaults)
        }
    }

    func hasRead(_ register: String, _ id: String) -> Bool {
        switch register {
        case "style": return (ledger.readStyles ?? []).contains(id)
        case "feature": return (ledger.readFeatures ?? []).contains(id)
        case "stone": return (ledger.readStones ?? []).contains(id)
        case "tool": return (ledger.readTools ?? []).contains(id)
        default: return (ledger.readFaults ?? []).contains(id)
        }
    }

    func recordExam(score: Int, total: Int) {
        ledger.examsTaken = (ledger.examsTaken ?? 0) + 1
        let pct = total > 0 ? score * 100 / total : 0
        if pct > (ledger.examBest ?? 0) { ledger.examBest = pct }
        if pct >= 70 { award(30) }
        if pct == 100 { award(50) }
        checkBadges()
    }

    var lessonsRead: Int { (ledger.readLessons ?? []).count }
    var termsRead: Int { (ledger.readTerms ?? []).count }
    var standingWalls: Int { ledger.walls.filter { $0.standing }.count }

    func hasBadge(_ key: String) -> Bool { (ledger.badges ?? []).contains(key) }

    func checkBadges() {
        var badges = ledger.badges ?? []
        func grant(_ key: String, _ condition: Bool) {
            if condition && !badges.contains(key) { badges.append(key); award(12) }
        }
        let best = ledger.bestScore ?? 0
        grant("first", ledger.wallsBuilt >= 1)
        grant("standing", best >= 40)
        grant("sound", best >= 65)
        grant("master", best >= 85)
        grant("frost", (ledger.frostPassed ?? 0) >= 1)
        grant("century", (ledger.centuryPassed ?? 0) >= 1)
        grant("throughs", (ledger.throughsLaid ?? 0) >= 10)
        grant("pinner", (ledger.pinsBack ?? 0) >= 20 && (ledger.pinsFront ?? 0) == 0)
        grant("styles", (ledger.stylesBuilt ?? []).count >= WallStyle.allCases.count)
        grant("features", (ledger.featuresBuilt ?? []).count >= WallFeature.allCases.count)
        grant("stones", (ledger.kindsBuilt ?? []).count >= StoneKind.allCases.count)
        grant("efficient", ledger.walls.contains { $0.placedCount >= 40 && $0.efficiency >= 0.999 })
        grant("rebuilt", (ledger.rebuilt ?? 0) >= 1)
        grant("reader", lessonsRead >= Lessons.all.count)
        grant("scholar", termsRead >= Lexicon.entries.count)
        grant("examined", (ledger.examBest ?? 0) >= 70)
        grant("streak", ledger.bestStreak >= 7)
        grant("field", standingWalls >= 12 || ledger.walls.count >= 11)
        grant("dawn", (ledger.dawnWalls ?? 0) >= 1)
        grant("gale", (ledger.galePassed ?? 0) >= 1)
        if badges != (ledger.badges ?? []) { ledger.badges = badges }
    }

    func reference(for c: Commission, completion: @escaping (Wall) -> Void) {
        if let hit = referenceCache[c.key] { completion(hit); return }
        DispatchQueue.global(qos: .userInitiated).async {
            let wall = WallBuilder.reference(c, attempts: 3)
            DispatchQueue.main.async {
                self.referenceCache[c.key] = wall
                completion(wall)
            }
        }
    }
}
