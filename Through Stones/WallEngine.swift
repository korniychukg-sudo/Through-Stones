import Foundation

struct Spool {
    var s: UInt64
    init(_ seed: UInt64) { s = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 { s ^= s << 13; s ^= s >> 7; s ^= s << 17; return s }
    mutating func unit() -> Double { Double(next() % 1_000_000) / 1_000_000.0 }
    mutating func range(_ a: Double, _ b: Double) -> Double { a + unit() * (b - a) }
    mutating func int(_ a: Int, _ b: Int) -> Int { a + Int(next() % UInt64(max(1, b - a + 1))) }
    mutating func chance(_ p: Double) -> Bool { unit() < p }
    mutating func signed() -> Double { unit() * 2 - 1 }
    mutating func pick<T>(_ list: [T]) -> T { list[int(0, list.count - 1)] }
}

func seedOf(_ name: String) -> UInt64 {
    var h: UInt64 = 14695981039346656037
    for b in name.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
    return h
}

struct Pt: Codable, Equatable {
    var x: Double
    var y: Double
    init(_ x: Double, _ y: Double) { self.x = x; self.y = y }
}

enum Geometry {
    static func area(_ poly: [Pt]) -> Double {
        guard poly.count > 2 else { return 0 }
        var twice = 0.0
        for i in 0..<poly.count {
            let a = poly[i], b = poly[(i + 1) % poly.count]
            twice += a.x * b.y - b.x * a.y
        }
        return abs(twice) * 0.5
    }

    static func centroid(_ poly: [Pt]) -> Pt {
        guard poly.count > 2 else { return poly.first ?? Pt(0, 0) }
        var cx = 0.0, cy = 0.0, twice = 0.0
        for i in 0..<poly.count {
            let a = poly[i], b = poly[(i + 1) % poly.count]
            let cross = a.x * b.y - b.x * a.y
            twice += cross
            cx += (a.x + b.x) * cross
            cy += (a.y + b.y) * cross
        }
        guard abs(twice) > 1e-12 else {
            var sx = 0.0, sy = 0.0
            for q in poly { sx += q.x; sy += q.y }
            return Pt(sx / Double(poly.count), sy / Double(poly.count))
        }
        return Pt(cx / (3 * twice), cy / (3 * twice))
    }

    static func hull(_ pts: [Pt]) -> [Pt] {
        let sorted = pts.sorted { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
        guard sorted.count > 2 else { return sorted }
        func cross(_ o: Pt, _ a: Pt, _ b: Pt) -> Double { (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x) }
        var lower: [Pt] = []
        for q in sorted {
            while lower.count >= 2 && cross(lower[lower.count - 2], lower[lower.count - 1], q) <= 1e-12 { lower.removeLast() }
            lower.append(q)
        }
        var upper: [Pt] = []
        for q in sorted.reversed() {
            while upper.count >= 2 && cross(upper[upper.count - 2], upper[upper.count - 1], q) <= 1e-12 { upper.removeLast() }
            upper.append(q)
        }
        lower.removeLast()
        upper.removeLast()
        return lower + upper
    }

    static func isConvex(_ poly: [Pt]) -> Bool {
        guard poly.count > 2 else { return false }
        var sign = 0.0
        for i in 0..<poly.count {
            let a = poly[i], b = poly[(i + 1) % poly.count], c = poly[(i + 2) % poly.count]
            let cross = (b.x - a.x) * (c.y - b.y) - (b.y - a.y) * (c.x - b.x)
            if abs(cross) < 1e-12 { continue }
            if sign == 0 { sign = cross > 0 ? 1 : -1 } else if (cross > 0 ? 1.0 : -1.0) != sign { return false }
        }
        return true
    }

    static func bounds(_ poly: [Pt]) -> (minX: Double, maxX: Double, minY: Double, maxY: Double) {
        var minX = Double.infinity, maxX = -Double.infinity, minY = Double.infinity, maxY = -Double.infinity
        for q in poly {
            minX = min(minX, q.x); maxX = max(maxX, q.x)
            minY = min(minY, q.y); maxY = max(maxY, q.y)
        }
        return (minX, maxX, minY, maxY)
    }

    static func verticalSpan(_ poly: [Pt], at x: Double) -> (bottom: Double, top: Double)? {
        var lo = Double.infinity, hi = -Double.infinity
        for i in 0..<poly.count {
            let a = poly[i], b = poly[(i + 1) % poly.count]
            if a.x == b.x {
                if abs(a.x - x) < 1e-9 { lo = min(lo, min(a.y, b.y)); hi = max(hi, max(a.y, b.y)) }
                continue
            }
            let lowX = min(a.x, b.x), highX = max(a.x, b.x)
            if x < lowX - 1e-9 || x > highX + 1e-9 { continue }
            let t = (x - a.x) / (b.x - a.x)
            let y = a.y + (b.y - a.y) * t
            lo = min(lo, y); hi = max(hi, y)
        }
        if lo == Double.infinity { return nil }
        return (lo, hi)
    }

    static func contains(_ poly: [Pt], _ q: Pt) -> Bool {
        var inside = false
        var j = poly.count - 1
        for i in 0..<poly.count {
            let a = poly[i], b = poly[j]
            if (a.y > q.y) != (b.y > q.y) {
                let xCross = (b.x - a.x) * (q.y - a.y) / (b.y - a.y) + a.x
                if q.x < xCross { inside.toggle() }
            }
            j = i
        }
        return inside
    }

    static func transform(_ unit: [Pt], width: Double, height: Double, tilt: Double, x: Double, y: Double) -> [Pt] {
        let c = cos(tilt), s = sin(tilt)
        return unit.map { u in
            let px = u.x * width, py = u.y * height
            return Pt(x + px * c - py * s, y + px * s + py * c)
        }
    }
}

enum ShapeFamily: String, Codable, CaseIterable {
    case blocky, thinBedded, rounded, irregular

    var name: String {
        switch self {
        case .blocky: return "Blocky"
        case .thinBedded: return "Thin-bedded"
        case .rounded: return "Rounded"
        case .irregular: return "Irregular"
        }
    }

    var aspectMean: Double {
        switch self {
        case .blocky: return 1.45
        case .thinBedded: return 2.7
        case .rounded: return 1.35
        case .irregular: return 1.75
        }
    }

    var aspectSpread: Double {
        switch self {
        case .blocky: return 0.22
        case .thinBedded: return 0.55
        case .rounded: return 0.18
        case .irregular: return 0.40
        }
    }

    var exponent: Double {
        switch self {
        case .blocky: return 5.0
        case .thinBedded: return 6.5
        case .rounded: return 2.1
        case .irregular: return 3.4
        }
    }

    var roughness: Double {
        switch self {
        case .blocky: return 0.05
        case .thinBedded: return 0.045
        case .rounded: return 0.025
        case .irregular: return 0.16
        }
    }

    var vertices: ClosedRange<Int> {
        switch self {
        case .blocky: return 6...7
        case .thinBedded: return 6...8
        case .rounded: return 8...9
        case .irregular: return 7...9
        }
    }
}

enum StoneKind: String, Codable, CaseIterable {
    case gritstone, limestone, oolite, sandstone, slate, granite, whinstone, greywacke, schist, fieldstone, flagstone, clunch

    var family: ShapeFamily {
        switch self {
        case .gritstone, .limestone, .granite, .clunch: return .blocky
        case .oolite, .sandstone, .slate, .schist, .flagstone: return .thinBedded
        case .fieldstone: return .rounded
        case .whinstone, .greywacke: return .irregular
        }
    }

    var density: Double {
        switch self {
        case .gritstone: return 2300
        case .limestone: return 2500
        case .oolite: return 2100
        case .sandstone: return 2300
        case .slate: return 2700
        case .granite: return 2650
        case .whinstone: return 2900
        case .greywacke: return 2650
        case .schist: return 2750
        case .fieldstone: return 2600
        case .flagstone: return 2400
        case .clunch: return 1900
        }
    }

    var weakness: Double {
        switch self {
        case .clunch: return 0.9
        case .oolite: return 0.45
        case .sandstone: return 0.35
        case .schist: return 0.4
        case .slate: return 0.2
        case .limestone: return 0.25
        default: return 0.15
        }
    }

    var lichenRate: Double {
        switch self {
        case .limestone, .oolite, .clunch: return 1.25
        case .gritstone, .sandstone, .flagstone: return 1.0
        case .granite, .whinstone, .greywacke: return 0.75
        case .slate, .schist: return 0.6
        case .fieldstone: return 0.9
        }
    }
}

enum StoneClass: String, Codable, CaseIterable {
    case footing, builder, through, hearting, pinning, cope, flag

    var name: String {
        switch self {
        case .footing: return "Footing"
        case .builder: return "Builder"
        case .through: return "Through"
        case .hearting: return "Hearting"
        case .pinning: return "Pinning"
        case .cope: return "Cope"
        case .flag: return "Flag"
        }
    }
}

enum Orientation: String, Codable, CaseIterable {
    case lengthIn, traced, faced

    var name: String {
        switch self {
        case .lengthIn: return "Length into the wall"
        case .traced: return "Traced along the face"
        case .faced: return "Bed turned to the face"
        }
    }
}

struct Stone: Codable, Identifiable, Equatable {
    var id: Int
    var kind: StoneKind
    var cls: StoneClass
    var long: Double
    var short: Double
    var thick: Double
    var unit: [Pt]
    var orientation: Orientation = .lengthIn
    var tilt: Double = 0
    var x: Double = 0
    var y: Double = 0
    var placed: Bool = false
    var course: Int = 0
    var pinned: Bool = false
    var pinFront: Bool = false
    var pinX: Double? = nil
    var rocking: Bool = false
    var under: [Int] = []
    var flatBottom: Bool = false
    var seed: UInt64 = 0

    var faceWidth: Double {
        switch orientation {
        case .lengthIn: return short
        case .traced: return long
        case .faced: return long
        }
    }

    var faceHeight: Double {
        switch orientation {
        case .lengthIn: return cls == .flag ? long : thick
        case .traced: return thick
        case .faced: return short
        }
    }

    var reach: Double {
        switch orientation {
        case .lengthIn: return cls == .flag ? thick : long
        case .traced: return short
        case .faced: return thick
        }
    }

    var polygon: [Pt] {
        Geometry.transform(unit, width: faceWidth, height: faceHeight, tilt: tilt, x: x, y: y)
    }

    func polygon(at px: Double, _ py: Double, tilt t: Double) -> [Pt] {
        Geometry.transform(unit, width: faceWidth, height: faceHeight, tilt: t, x: px, y: py)
    }

    var faceArea: Double { Geometry.area(unit) * faceWidth * faceHeight }
    var volume: Double { Geometry.area(unit) * long * short * thick * 0.92 }
    var mass: Double { volume * kind.density }

    var onEdge: Bool {
        let a = abs(tilt.truncatingRemainder(dividingBy: .pi))
        let bedAngle = min(a, .pi - a)
        return bedAngle > .pi / 3
    }

    var flipped: Bool {
        let a = abs(tilt)
        return a > .pi * 2 / 3
    }

    var name: String {
        "\(cls.name) \(Int((long * 100).rounded()))x\(Int((short * 100).rounded()))x\(Int((thick * 100).rounded()))"
    }
}

enum StoneForge {
    static func unitPolygon(family: ShapeFamily, flatBase: Bool, rng: inout Spool) -> [Pt] {
        for _ in 0..<10 {
            let n = rng.int(family.vertices.lowerBound, family.vertices.upperBound) + 2
            var raw: [Pt] = []
            let p = family.exponent
            let phase = rng.range(0, .pi * 2)
            for k in 0..<n {
                let a = phase + Double(k) / Double(n) * .pi * 2 + rng.signed() * (.pi / Double(n)) * 0.55
                let ca = cos(a), sa = sin(a)
                let ex = (ca < 0 ? -1.0 : 1.0) * pow(abs(ca), 2 / p)
                let ey = (sa < 0 ? -1.0 : 1.0) * pow(abs(sa), 2 / p)
                let jitter = 1 + rng.signed() * family.roughness
                raw.append(Pt(ex * 0.5 * jitter, ey * 0.5 * jitter))
            }
            var hull = Geometry.hull(raw)
            if flatBase {
                hull = hull.map { q in q.y < -0.30 ? Pt(q.x, -0.5) : q }
                hull = Geometry.hull(hull)
            }
            guard hull.count >= 5, hull.count <= 10 else { continue }
            let b = Geometry.bounds(hull)
            let w = max(1e-6, b.maxX - b.minX), h = max(1e-6, b.maxY - b.minY)
            let norm = hull.map { Pt(($0.x - b.minX) / w - 0.5, ($0.y - b.minY) / h - 0.5) }
            if Geometry.isConvex(norm) && Geometry.area(norm) > 0.55 { return norm }
        }
        return [Pt(-0.5, -0.5), Pt(0.5, -0.5), Pt(0.5, 0.5), Pt(-0.5, 0.5)]
    }

    static func make(id: Int, kind: StoneKind, cls: StoneClass, wallWidth: Double, rng: inout Spool) -> Stone {
        let fam = kind.family
        var long = 0.0, short = 0.0, thick = 0.0
        var flat = false
        var aspect = max(1.1, fam.aspectMean + rng.signed() * fam.aspectSpread)
        switch cls {
        case .footing:
            long = rng.range(0.42, 0.66)
            short = rng.range(0.28, 0.42)
            aspect = max(1.3, aspect * 0.85)
            thick = min(0.30, max(0.14, short / aspect))
            flat = true
        case .builder:
            long = rng.range(0.28, 0.48)
            short = rng.range(0.15, 0.30)
            thick = min(0.24, max(0.06, short / aspect))
        case .through:
            long = wallWidth + rng.range(0.04, 0.16)
            short = rng.range(0.18, 0.30)
            thick = min(0.20, max(0.07, short / max(1.4, aspect)))
            flat = true
        case .hearting:
            long = rng.range(0.06, 0.13)
            short = rng.range(0.04, 0.09)
            thick = rng.range(0.03, 0.06)
        case .pinning:
            long = rng.range(0.07, 0.13)
            short = rng.range(0.04, 0.07)
            thick = rng.range(0.015, 0.035)
        case .cope:
            long = rng.range(0.34, 0.50)
            short = rng.range(0.09, 0.17)
            thick = rng.range(0.24, 0.36)
        case .flag:
            long = rng.range(1.25, 1.55)
            short = rng.range(0.55, 0.95)
            thick = rng.range(0.045, 0.08)
        }
        if short > long { swap(&long, &short) }
        if fam == .thinBedded && cls == .builder { thick = min(thick, 0.13) }
        if fam == .rounded && (cls == .builder || cls == .footing) { thick = max(thick, short * 0.62) }
        let unit = unitPolygon(family: cls == .flag ? .thinBedded : (cls == .cope ? .blocky : fam), flatBase: flat, rng: &rng)
        var s = Stone(id: id, kind: kind, cls: cls, long: long, short: short, thick: thick, unit: unit)
        s.flatBottom = flat
        s.seed = rng.next()
        return s
    }
}

struct Skyline: Codable {
    var x0: Double
    var dx: Double
    var h: [Double]

    init(from x0: Double, to x1: Double, dx: Double = 0.01, ground: (Double) -> Double) {
        self.x0 = x0
        self.dx = dx
        let n = max(2, Int(((x1 - x0) / dx).rounded()) + 1)
        h = (0..<n).map { ground(x0 + Double($0) * dx) }
    }

    var count: Int { h.count }
    var x1: Double { x0 + Double(h.count - 1) * dx }

    func index(_ x: Double) -> Int { max(0, min(h.count - 1, Int(((x - x0) / dx).rounded()))) }
    func firstIndex(atOrAfter x: Double) -> Int { max(0, min(h.count - 1, Int(((x - x0) / dx).rounded(.up)))) }
    func lastIndex(atOrBefore x: Double) -> Int { max(0, min(h.count - 1, Int(((x - x0) / dx).rounded(.down)))) }
    func xAt(_ i: Int) -> Double { x0 + Double(i) * dx }
    func at(_ x: Double) -> Double { h[index(x)] }

    mutating func raise(_ poly: [Pt]) {
        let b = Geometry.bounds(poly)
        let i0 = firstIndex(atOrAfter: b.minX), i1 = lastIndex(atOrBefore: b.maxX)
        guard i1 >= i0 else { return }
        for i in i0...i1 {
            if let span = Geometry.verticalSpan(poly, at: xAt(i)) { h[i] = max(h[i], span.top) }
        }
    }

    func highest(from a: Double, to b: Double) -> Double {
        let i0 = firstIndex(atOrAfter: a), i1 = lastIndex(atOrBefore: b)
        guard i1 >= i0 else { return h[index((a + b) * 0.5)] }
        var m = -Double.infinity
        for i in i0...i1 { m = max(m, h[i]) }
        return m
    }

    func lowest(from a: Double, to b: Double) -> Double {
        let i0 = firstIndex(atOrAfter: a), i1 = lastIndex(atOrBefore: b)
        guard i1 >= i0 else { return h[index((a + b) * 0.5)] }
        var m = Double.infinity
        for i in i0...i1 { m = min(m, h[i]) }
        return m
    }

    func median(from a: Double, to b: Double) -> Double {
        let i0 = firstIndex(atOrAfter: a), i1 = lastIndex(atOrBefore: b)
        guard i1 >= i0 else { return h[index((a + b) * 0.5)] }
        let vals = Array(h[i0...i1]).sorted()
        return vals[vals.count / 2]
    }
}

struct Landing: Codable {
    var y: Double
    var tilt: Double
    var contacts: [Double]
    var supportA: Double
    var supportB: Double
    var com: Pt
    var minX: Double
    var maxX: Double
    var top: Double
    var bottom: Double

    var supportWidth: Double { supportB - supportA }
    var comInside: Bool { com.x >= supportA - 0.004 && com.x <= supportB + 0.004 }
    var margin: Double {
        let w = max(0.001, supportWidth)
        let d = min(com.x - supportA, supportB - com.x)
        return max(0, min(1, d / (w * 0.5)))
    }
}

enum Rest: Codable, Equatable {
    case settled
    case rocking(side: Int)
    case topple(direction: Int)
    case refused(reason: String)
}

enum Physics {
    static let contactTol = 0.007
    static let minSupport = 0.028
    static let settleSteps = 22

    static func land(_ stone: Stone, x: Double, tilt: Double, on sky: Skyline) -> Landing? {
        let base = stone.polygon(at: x, 0, tilt: tilt)
        let b = Geometry.bounds(base)
        let i0 = sky.firstIndex(atOrAfter: b.minX + 0.003), i1 = sky.lastIndex(atOrBefore: b.maxX - 0.003)
        guard i1 >= i0 else { return nil }
        var offsets: [(Double, Double)] = []
        var best = -Double.infinity
        for i in i0...i1 {
            let sx = sky.xAt(i)
            guard let span = Geometry.verticalSpan(base, at: sx) else { continue }
            let off = sky.h[i] - span.bottom
            offsets.append((sx, off))
            best = max(best, off)
        }
        guard best > -Double.infinity else { return nil }
        var contacts: [Double] = []
        for (sx, off) in offsets where off >= best - contactTol { contacts.append(sx) }
        guard let a = contacts.first, let c = contacts.last else { return nil }
        let poly = base.map { Pt($0.x, $0.y + best) }
        let com = Geometry.centroid(poly)
        let pb = Geometry.bounds(poly)
        return Landing(y: best, tilt: tilt, contacts: contacts, supportA: a, supportB: c, com: com,
                       minX: pb.minX, maxX: pb.maxX, top: pb.maxY, bottom: pb.minY)
    }

    static func settle(_ stone: Stone, x: Double, tilt: Double, on sky: Skyline) -> (Rest, Landing)? {
        guard let first = land(stone, x: x, tilt: tilt, on: sky) else { return nil }
        if first.comInside && first.supportWidth >= minSupport { return (.settled, first) }
        let pivot = (first.supportA + first.supportB) * 0.5
        let width = max(0.02, first.maxX - first.minX)
        let lean = first.com.x - pivot
        let dir: Double = lean < -0.002 ? 1 : (lean > 0.002 ? -1 : 0)
        if dir == 0 { return (.rocking(side: 1), first) }
        var best = first
        for k in 1...settleSteps {
            let t = tilt + dir * Double(k) * (.pi / 180)
            guard let trial = land(stone, x: x, tilt: t, on: sky) else { break }
            if trial.comInside && trial.supportWidth >= minSupport { return (.settled, trial) }
            best = trial
        }
        if abs(lean) > width * 0.24 || !best.comInside && abs(best.com.x - (best.supportA + best.supportB) * 0.5) > width * 0.2 {
            return (.topple(direction: lean < 0 ? -1 : 1), first)
        }
        return (.rocking(side: lean < 0 ? -1 : 1), first)
    }

    static func pinSlot(_ stone: Stone, landing: Landing, on sky: Skyline, side: Int) -> (x: Double, gap: Double)? {
        let poly = stone.polygon(at: stone.x, landing.y, tilt: landing.tilt)
        let width = landing.maxX - landing.minX
        let probes: [Double] = side < 0
            ? [landing.minX + width * 0.12, landing.minX + width * 0.22, landing.minX + width * 0.32]
            : [landing.maxX - width * 0.12, landing.maxX - width * 0.22, landing.maxX - width * 0.32]
        var best: (Double, Double)? = nil
        for px in probes {
            guard let span = Geometry.verticalSpan(poly, at: px) else { continue }
            let gap = span.bottom - sky.at(px)
            if gap >= 0.006 && (best == nil || gap > best!.1) { best = (px, gap) }
        }
        return best.map { (x: $0.0, gap: $0.1) }
    }
}
