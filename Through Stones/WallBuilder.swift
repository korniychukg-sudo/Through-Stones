import Foundation

enum WallBuilder {
    static let epoch: Double = 1_767_225_600

    static func dayIndex(_ date: Date = Date()) -> Int {
        max(0, Int((date.timeIntervalSince1970 - epoch) / 86_400))
    }

    static func daySeed(_ day: Int) -> UInt64 { seedOf("throughstones.day.\(day)") }

    private static let placesA: [String] = ["Gunnerside", "Malham", "Hawes", "Kettlewell", "Reeth", "Arncliffe", "Bibury", "Naunton", "Snowshill", "Stow"]
    private static let placesB: [String] = ["Dalry", "Kirkcudbright", "Zennor", "St Just", "Kilronan", "Inishmaan", "Thurso", "Castletown", "Stonington", "Concord", "Lexington", "Paris"]
    private static let clientsA: [String] = ["the farmer", "the shepherd", "the estate", "the widow", "the new tenant", "the parish", "the innkeeper", "the miller"]
    private static let clientsB: [String] = ["the schoolmaster", "the vicar", "the auctioneer", "the quarry master", "the grazier", "the hill farm", "the smallholder", "the drover"]

    static func placeFor(_ style: WallStyle, rng: inout Spool) -> String {
        switch style {
        case .dales: return rng.pick(["Gunnerside", "Malham", "Hawes", "Kettlewell", "Reeth", "Arncliffe"])
        case .cotswold: return rng.pick(["Bibury", "Naunton", "Snowshill", "Stow", "Guiting Power"])
        case .galloway: return rng.pick(["Dalry", "Kirkcudbright", "New Galloway", "Gatehouse"])
        case .cornish: return rng.pick(["Zennor", "St Just", "Morvah", "Lamorna"])
        case .aran: return rng.pick(["Kilronan", "Inishmaan", "Inisheer", "Kilmurvey"])
        case .caithness: return rng.pick(["Thurso", "Castletown", "Halkirk", "Dunnet"])
        case .newEngland: return rng.pick(["Stonington", "Concord", "Lexington", "Woodstock"])
        case .kentucky: return rng.pick(["Paris", "Lexington", "Midway", "Versailles"])
        }
    }

    static func commission(day: Int, rank: Int) -> Commission {
        var rng = Spool(daySeed(day))
        var styles: [WallStyle] = [.dales, .cotswold, .newEngland, .kentucky, .dales]
        if rank >= 1 { styles += [.galloway, .cornish] }
        if rank >= 2 { styles += [.aran, .caithness, .galloway] }
        if rank >= 3 { styles += [.cornish, .aran, .caithness] }
        let style = rng.pick(styles)
        var features: [WallFeature] = [.straightRun, .straightRun, .cheekEnd, .slope]
        if rank >= 1 { features += [.corner, .curve, .lunky] }
        if rank >= 2 { features += [.stepStile, .gatePost, .squeezeStile] }
        if rank >= 3 { features += [.retaining, .beeBole] }
        var feature = rng.pick(features)
        if style == .caithness { feature = rng.pick([.straightRun, .straightRun, .cheekEnd, .curve]) }
        if style == .aran { feature = rng.pick([.straightRun, .straightRun, .cheekEnd, .slope, .curve]) }
        if style == .cornish && (feature == .lunky || feature == .beeBole || feature == .stepStile) { feature = .straightRun }
        var kind = rng.pick(style.nativeKinds)
        if rank >= 2 && rng.chance(0.18) && style != .caithness && style != .cotswold {
            kind = rng.pick(StoneKind.allCases.filter { $0 != .flagstone })
        }
        var length: Double
        switch rank {
        case 0: length = rng.range(1.3, 1.8)
        case 1: length = rng.range(1.5, 2.1)
        default: length = rng.range(1.7, 2.5)
        }
        if style == .cotswold { length = min(length, 1.9) }
        if style == .caithness { length = rng.range(1.6, 2.6) }
        if feature == .squeezeStile || feature == .stepStile { length = max(length, 1.7) }
        length = (length * 20).rounded() / 20
        var height: Double
        switch style {
        case .caithness: height = rng.range(0.90, 1.05)
        case .aran: height = rng.range(1.00, 1.12)
        default: height = style.rules.typicalHeight + rng.signed() * 0.14
        }
        if rank == 0 && style != .caithness && style != .aran { height *= 0.9 }
        if feature == .beeBole { height = max(height, 1.25) }
        if feature == .lunky { height = max(height, 0.95) }
        if feature == .stepStile { height = max(height, 1.15) }
        if feature == .gatePost { height = max(height, 1.1) }
        height = (height * 20).rounded() / 20
        let client = rng.pick(rank >= 2 ? clientsB : clientsA)
        let place = placeFor(style, rng: &rng)
        return Commission(style: style, feature: feature, kind: kind, length: length, height: height,
                          seed: daySeed(day) ^ 0xC0FFEE, client: client, place: place, day: day)
    }

    static func free(style: WallStyle, feature: WallFeature, kind: StoneKind, length: Double, height: Double, seed: UInt64) -> Commission {
        var rng = Spool(seed)
        let client = rng.pick(clientsA + clientsB)
        let place = placeFor(style, rng: &rng)
        var h = height
        if feature == .beeBole { h = max(h, 1.25) }
        if feature == .lunky { h = max(h, 0.95) }
        if feature == .stepStile { h = max(h, 1.15) }
        if feature == .gatePost { h = max(h, 1.1) }
        return Commission(style: style, feature: feature, kind: kind, length: length, height: h, seed: seed, client: client, place: place, day: -1)
    }

    static func line(for c: Commission) -> String {
        let cm = Int((c.length * 100).rounded())
        let hm = Int((c.height * 100).rounded())
        let metres = c.length >= 1 ? String(format: "%.2f", c.length).replacingOccurrences(of: ".00", with: "") : "\(cm) cm"
        let word = c.feature == .straightRun ? "a straight run" : c.feature.name.lowercased()
        return "\(c.client.prefix(1).uppercased() + c.client.dropFirst()) at \(c.place) wants \(word) in \(StoneLore.name(c.kind).lowercased()), \(c.style.shortName) fashion, \(metres) m long and \(hm) cm to the cope."
    }

    static func heap(for c: Commission) -> (stones: [Stone], hearting: Int, pinnings: Int) {
        var rng = Spool(c.seed &+ 0x5EED)
        let r = c.style.rules
        var stones: [Stone] = []
        var nextID = 1
        func push(_ cls: StoneClass, _ count: Int, tweak: ((inout Stone, inout Spool) -> Void)? = nil) {
            for _ in 0..<max(0, count) {
                var s = StoneForge.make(id: nextID, kind: c.kind, cls: cls, wallWidth: r.baseWidth, rng: &rng)
                if let t = tweak { t(&s, &rng) }
                stones.append(s)
                nextID += 1
            }
        }
        let fam = c.kind.family
        let thickMean: Double = fam == .thinBedded ? 0.085 : (fam == .blocky ? 0.15 : (fam == .rounded ? 0.16 : 0.14))
        if r.form == .flags {
            push(.flag, Int((c.length / 0.7).rounded(.up)) + 3)
            push(.pinning, 8)
            return (stones, 0, 8)
        }
        push(.footing, Int((c.length / 0.32).rounded(.up)) + 3) { s, rng in
            if c.feature == .curve { s.short = min(s.short, 0.34) }
            _ = rng
        }
        push(.footing, 3) { s, rng in
            s.long = rng.range(0.36, 0.50)
            s.short = rng.range(0.18, 0.27)
            s.thick = rng.range(0.22, 0.30)
        }
        let courseArea: Double
        switch r.form {
        case .doubleThenSingle: courseArea = c.length * (c.height * r.doubleShare - 0.16)
        default: courseArea = c.length * (c.height - 0.18)
        }
        let avgFace = 0.245 * thickMean
        var builders = Int((max(0.2, courseArea) / avgFace * 1.28).rounded(.up))
        if c.style == .cornish { builders = Int(Double(builders) * 1.1) }
        push(.builder, builders) { s, rng in
            if c.feature == .curve { s.long = min(s.long, 0.40); s.short = min(s.short, 0.28) }
            if c.style == .cornish { s.thick = max(s.thick, 0.10); s.short = min(s.short, 0.26) }
            if s.kind == .clunch { s.short = max(s.short, 0.2) }
            _ = rng
        }
        if r.form != .flags {
            push(.builder, 6 + Int(c.length * 5)) { s, rng in
                s.long = rng.range(0.26, 0.40)
                s.short = rng.range(0.10, 0.17)
                s.thick = min(s.thick, rng.range(0.07, 0.14))
            }
        }
        if c.style == .aran {
            let slabs = Int((c.length / 0.42 * 1.3).rounded(.up)) + 2
            push(.builder, slabs) { s, rng in
                s.long = rng.range(0.30, 0.46)
                s.short = rng.range(0.52, 0.70)
                s.thick = rng.range(0.06, 0.10)
            }
        }
        if c.style == .galloway {
            let uppers = Int((c.length * (c.height * (1 - r.doubleShare)) / (0.27 * 0.16) * 1.15).rounded(.up)) + 2
            push(.builder, uppers) { s, rng in
                s.long = rng.range(0.46, 0.62)
                s.short = rng.range(0.20, 0.34)
                s.thick = rng.range(0.13, 0.20)
            }
            push(.through, Int((c.length / 0.5).rounded(.up)) + 2)
        } else if r.wantsThroughs {
            var throughs = max(1, Int((c.length / r.throughSpacing).rounded(.up))) + 2
            if c.feature == .stepStile { throughs += 3 }
            if c.feature == .gatePost { throughs += 1 }
            push(.through, throughs)
        }
        if c.feature == .gatePost && !r.wantsThroughs { push(.through, 2) }
        if c.feature == .lunky || c.feature == .beeBole {
            let width = c.feature == .lunky ? 0.50 : 0.44
            push(.through, 2) { s, rng in
                s.long = width + rng.range(0.32, 0.42)
                s.short = rng.range(0.22, 0.30)
                s.thick = rng.range(0.10, 0.15)
                s.flatBottom = true
            }
        }
        switch r.cope {
        case .none, .turf:
            break
        case .flat:
            push(.cope, Int((c.length / 0.22).rounded(.up)) + 4) { s, rng in
                s.long = rng.range(0.40, 0.55)
                s.short = rng.range(0.14, 0.30)
                s.thick = rng.range(0.07, 0.11)
                s.flatBottom = true
            }
        case .cockAndHen:
            let n = Int((c.length / 0.13).rounded(.up)) + 4
            var tall = false
            push(.cope, n) { s, rng in
                tall.toggle()
                s.thick = tall ? rng.range(0.30, 0.36) : rng.range(0.19, 0.24)
            }
        default:
            push(.cope, Int((c.length / 0.13).rounded(.up)) + 4)
        }
        let guess = courseGuess(stones, rules: r)
        var heartCourses = Int((c.height / guess).rounded()) + 1
        if r.form == .doubleThenSingle { heartCourses = Int((Double(heartCourses) * r.doubleShare).rounded(.up)) }
        let hearting = r.core == .none ? 0 : max(16, (heartCourses + 2) * 12)
        let pinnings = 14 + Int(c.length * 5)
        return (stones, hearting, pinnings)
    }

    static func courseGuess(_ stones: [Stone], rules r: StyleRules) -> Double {
        let hs = stones.filter { !$0.placed && $0.cls == .builder }.map { $0.thick }.sorted()
        guard hs.count > 2 else { return r.courseHeight }
        let median = hs[hs.count / 2]
        return max(r.courseHeight * 0.6, min(r.courseHeight * 1.5, median + 0.008))
    }

    static func openings(for c: Commission) -> [Opening] {
        let mid = c.length * 0.5
        let depth = c.style.rules.form == .flags ? 0.30 : 0.14
        switch c.feature {
        case .lunky: return [Opening(kind: .lunky, x0: mid - 0.25, x1: mid + 0.25, y0: -depth, y1: 0.48)]
        case .beeBole: return [Opening(kind: .beeBole, x0: mid - 0.22, x1: mid + 0.22, y0: 0.55, y1: 0.95)]
        case .squeezeStile: return [Opening(kind: .stile, x0: mid - 0.15, x1: mid + 0.15, y0: -depth, y1: c.height + 2)]
        default: return []
        }
    }

    static func newWall(_ c: Commission) -> Wall {
        let h = heap(for: c)
        var probe = Wall(style: c.style, feature: c.feature, kind: c.kind, length: c.length, height: c.height, seed: c.seed,
                         stones: h.stones, sky: Skyline(from: -0.2, to: c.length + 0.2) { _ in 0 }, ground: [], cut: [])
        var sky = Skyline(from: -0.2, to: c.length + 0.2) { _ in 0 }
        for i in 0..<sky.count { sky.h[i] = probe.rawGround(sky.xAt(i)) }
        probe.sky = sky
        probe.ground = sky.h
        probe.cut = [Bool](repeating: false, count: sky.count)
        probe.heartingTotal = h.hearting
        probe.heartingLeft = h.hearting
        probe.courseGuess = courseGuess(h.stones, rules: c.style.rules)
        probe.pinningsLeft = h.pinnings
        probe.openings = openings(for: c)
        probe.heartFill = [0]
        if c.style.rules.batter.upperBound <= 0.03 { probe.frameSet = true }
        return probe
    }

    static func reference(_ c: Commission, attempts: Int = 6) -> Wall {
        var best: (Wall, Int)? = nil
        for k in 0..<max(1, attempts) {
            let w = attempt(c, variant: UInt64(k), jitter: k == 0 ? 0 : 14)
            let sheet = WallJudge.sheet(w)
            let tests = TestKind.allCases.map { WallJudge.test($0, w, sheet: sheet) }
            let score = WallJudge.report(w, tests: tests).score
            if best == nil || score > best!.1 { best = (w, score) }
            if score >= 94 { break }
        }
        return best!.0
    }

    static func attempt(_ c: Commission, variant: UInt64, jitter: Double) -> Wall {
        var w = newWall(c)
        let r = w.rules
        w.cutTrench(from: -0.1, to: w.length + 0.1)
        if r.batter.upperBound > 0.03 {
            let low = max(r.batter.lowerBound, c.feature.minBatter)
            w.setBatter(min(r.batter.upperBound, (low + r.batter.upperBound) * 0.5))
        }
        w.stage = .footings
        if r.form == .flags {
            layFlags(&w)
            w.stage = .test
            return w
        }
        layFootings(&w)
        w.stage = .courses
        var guardCount = 0
        while w.topMedian < w.height - w.heapCourseHeight * 0.6 && guardCount < 40 {
            guardCount += 1
            let before = w.placed.count
            levelLow(&w)
            layCourse(&w, variant: variant, jitter: jitter)
            if w.placed.count == before { break }
            if w.style == .aran && w.placed.contains(where: { $0.orientation == .faced }) { break }
        }
        levelTop(&w)
        w.stage = .cope
        layCope(&w)
        repairCopes(&w)
        w.stage = .test
        w.picks = w.placed.count
        w.returns = 0
        return w
    }

    static func levelTop(_ w: inout Wall) {
        guard w.rules.cope != .none, w.style != .aran else { return }
        levelRun(&w, top: w.topMedian, lowBy: 0.035, passes: 8, widest: false)
    }

    static func levelLow(_ w: inout Wall) {
        guard w.style != .aran, w.rules.form != .flags, w.lineIndex >= 1, w.feature == .slope else { return }
        let lowBy = max(0.07, w.heapCourseHeight * 0.8)
        levelRun(&w, top: w.topMedian, lowBy: lowBy, passes: 6, widest: true)
    }

    static func levelRun(_ w: inout Wall, top: Double, lowBy: Double, passes: Int, widest: Bool) {
        for _ in 0..<passes {
            var runs: [(Double, Double, Double)] = []
            var runStart: Double? = nil
            var i = w.sky.firstIndex(atOrAfter: 0.0)
            let end = w.sky.lastIndex(atOrBefore: w.length)
            while i <= end {
                let x = w.sky.xAt(i)
                let overOpening = w.openings.contains { $0.x0 - 0.02 < x && $0.x1 + 0.02 > x && !w.isLintelled($0) }
                let onFloor = widest && w.sky.h[i] < w.trenchFloor(x) + 0.10
                let low = w.sky.h[i] < top - lowBy && !overOpening && !onFloor
                if low && runStart == nil { runStart = x }
                if (!low || i == end), let start = runStart {
                    let stop = x
                    if stop - start >= 0.10 {
                        let depth = top - w.sky.lowest(from: start, to: stop)
                        runs.append((start, stop, depth))
                    }
                    runStart = nil
                }
                i += 1
            }
            var done = false
            for (a, b, depth) in runs {
                var edges: [Double] = []
                for st in w.placed where st.cls != .cope {
                    let sb = Geometry.bounds(st.polygon)
                    guard sb.maxY > top - depth - 0.05 && sb.maxY < top + 0.02 && sb.maxX > a - 0.02 && sb.minX < b + 0.02 else { continue }
                    edges.append(sb.minX)
                    edges.append(sb.maxX)
                }
                var startX = a + 0.006
                if widest {
                    for offset in [0.006, 0.05, 0.09, 0.13] where !edges.contains(where: { abs($0 - (a + offset)) < 0.04 }) {
                        startX = a + offset
                        break
                    }
                }
                var ids = heapIDs(w, .builder).filter { w.stone($0)!.short <= b - startX - 0.012 && w.stone($0)!.thick <= depth + 0.04 }
                if w.style == .galloway { ids = ids.filter { w.stone($0)!.long <= 0.44 || w.lineHeight > w.doubleTop } }
                func clash(_ id: Int) -> Bool {
                    let right = startX + w.stone(id)!.short
                    return edges.contains { abs($0 - right) < 0.045 && $0 > a + 0.03 && $0 < b - 0.03 }
                }
                if widest {
                    ids.sort { (clash($0) ? 0 : 1, w.stone($0)!.short, w.stone($0)!.thick) > (clash($1) ? 0 : 1, w.stone($1)!.short, w.stone($1)!.thick) }
                } else {
                    ids.sort { abs(w.stone($0)!.thick - depth) < abs(w.stone($1)!.thick - depth) }
                }
                for id in ids.prefix(8) {
                    let width = w.stone(id)!.short
                    let x = startX + width * 0.5
                    let (probe, landing) = w.preview(id, at: x, tilt: 0, orientation: .lengthIn)
                    guard let l = landing, l.top <= top + 0.03 else { continue }
                    switch probe {
                    case .settled, .rocking: break
                    default: continue
                    }
                    if tryPlace(&w, id: id, x: x, tilt: 0, orientation: .lengthIn) { done = true; break }
                }
                if done { break }
            }
            if !done { return }
        }
    }

    static func heapIDs(_ w: Wall, _ cls: StoneClass) -> [Int] {
        w.stones.filter { !$0.placed && $0.cls == cls }.map { $0.id }
    }

    static func jambEdges(_ w: Wall, at y: Double) -> [(x0: Double, x1: Double)] {
        w.openings.filter { y > $0.y0 - 0.02 && y < $0.y1 - 0.02 }.map { (x0: $0.x0, x1: $0.x1) }
    }

    static func belowEdges(_ w: Wall, course: Int) -> [Double] {
        var out: [Double] = []
        for s in w.placed where s.course == course - 1 && s.cls != .cope {
            let b = Geometry.bounds(s.polygon)
            out.append(b.minX)
            out.append(b.maxX)
        }
        return out
    }

    static func tryPlace(_ w: inout Wall, id: Int, x: Double, tilt: Double, orientation: Orientation) -> Bool {
        let (probe, _) = w.preview(id, at: x, tilt: tilt, orientation: orientation)
        switch probe {
        case .settled, .rocking: break
        default: return false
        }
        let (rest, _) = w.drop(id, at: x, tilt: tilt, orientation: orientation)
        switch rest {
        case .settled: return true
        case .rocking:
            _ = w.pin(id, front: false)
            return true
        default: return false
        }
    }

    static let gap = 0.012

    static func layFlags(_ w: inout Wall) {
        var cursor = 0.0
        var guardCount = 0
        while cursor < w.length - 0.05 && guardCount < 60 {
            guardCount += 1
            let ids = heapIDs(w, .flag)
            guard !ids.isEmpty else { break }
            let remaining = w.length - cursor
            let choice = ids.sorted { (w.stone($0)!.faceWidth) > (w.stone($1)!.faceWidth) }
            var placedOne = false
            for id in choice {
                let width = w.stone(id)!.faceWidth
                guard width <= remaining + 0.04 || id == choice.last else { continue }
                if tryPlace(&w, id: id, x: cursor + width * 0.5 + gap, tilt: 0, orientation: .lengthIn) {
                    cursor = Geometry.bounds(w.stone(id)!.polygon).maxX + gap
                    placedOne = true
                    break
                }
            }
            if !placedOne { break }
        }
        w.lineHeight = w.builtHeight
    }

    static func layFootings(_ w: inout Wall) {
        var cursor = 0.0
        let jambs = jambEdges(w, at: 0.05)
        var guardCount = 0
        var rightStop = w.length
        if w.feature.rightHead {
            let ids = heapIDs(w, .footing).sorted { w.stone($0)!.faceWidth > w.stone($1)!.faceWidth }
            for id in ids {
                let width = w.stone(id)!.faceWidth
                if tryPlace(&w, id: id, x: w.length - 0.004 - width * 0.5, tilt: 0, orientation: .lengthIn) {
                    rightStop = Geometry.bounds(w.stone(id)!.polygon).minX
                    break
                }
            }
        }
        while cursor < rightStop - 0.05 && guardCount < 60 {
            guardCount += 1
            if let j = jambs.first(where: { cursor > $0.x0 - 0.06 && cursor < $0.x1 - 0.01 }) { cursor = j.x1 + gap; continue }
            let stop = min(rightStop, jambs.first { $0.x0 > cursor + 0.02 }.map { $0.x0 } ?? w.length)
            let remaining = stop - cursor
            let ids = heapIDs(w, .footing).sorted { w.stone($0)!.faceWidth > w.stone($1)!.faceWidth }
            guard !ids.isEmpty else { break }
            var placedOne = false
            let fitting = ids.filter { w.stone($0)!.faceWidth <= remaining + 0.03 }
            func canClose(_ rest: Double, _ widths: [Double], _ depth: Int) -> Bool {
                if rest <= 0.05 { return true }
                if depth == 0 { return false }
                for (k, width) in widths.enumerated() where width <= rest + 0.03 {
                    var others = widths
                    others.remove(at: k)
                    if canClose(rest - width - gap, others, depth - 1) { return true }
                }
                return false
            }
            func tidy(_ id: Int) -> Bool {
                let left = remaining - w.stone(id)!.faceWidth - gap
                let others = ids.filter { $0 != id }.map { w.stone($0)!.faceWidth }
                return canClose(left, others, 3)
            }
            let planned = fitting.filter { tidy($0) }
            let order = planned.isEmpty ? fitting : planned
            for id in (order.isEmpty ? [ids.last!] : order).prefix(6) {
                let width = w.stone(id)!.faceWidth
                if tryPlace(&w, id: id, x: cursor + width * 0.5 + gap, tilt: 0, orientation: .lengthIn) {
                    cursor = Geometry.bounds(w.stone(id)!.polygon).maxX + gap
                    placedOne = true
                    break
                }
            }
            if !placedOne {
                if remaining < 0.16 { cursor = stop + gap } else { cursor += 0.10 }
            }
        }
        if w.rules.core != .none {
            var taps = 0
            while w.currentHeartFill < 1.0 && taps < 40 && w.heartingLeft > 0 { _ = w.addHearting(1); taps += 1 }
        }
        let tops = w.courseTops(0)
        let median = tops.isEmpty ? 0.2 : tops[tops.count / 2]
        w.raiseLine(to: min(w.height + 0.02, median + w.heapCourseHeight))
    }

    static func lintelled(_ w: Wall, _ o: Opening) -> Bool {
        w.lintels.contains { lid in w.stone(lid).map { Geometry.bounds($0.polygon).minX < o.x1 && Geometry.bounds($0.polygon).maxX > o.x0 } ?? false }
    }

    static func placeLintel(_ w: inout Wall, _ o: Opening) -> Bool {
        let jambL = w.sky.highest(from: o.x0 - 0.12, to: o.x0 - 0.005)
        let jambR = w.sky.highest(from: o.x1 + 0.005, to: o.x1 + 0.12)
        guard min(jambL, jambR) >= o.y1 - 0.07 else { return false }
        let ids = heapIDs(w, .through).sorted { w.stone($0)!.long > w.stone($1)!.long }
        for id in ids where w.stone(id)!.long >= o.width + 0.2 {
            if tryPlace(&w, id: id, x: (o.x0 + o.x1) * 0.5, tilt: 0, orientation: .traced) { return true }
        }
        return false
    }

    struct Segment {
        var from: Double
        var to: Double
    }

    static func placeHeadStone(_ w: inout Wall, edge: Double, flushRight: Bool, want: Orientation, lineTop: Double, courseBottom: Double, below: [Double], cls: StoneClass = .builder) -> Int? {
        let r = w.rules
        var best: (Int, Double, Double)? = nil
        for id in heapIDs(w, cls) {
            let st = w.stone(id)!
            if cls == .builder && w.style == .aran && st.short > 0.40 { continue }
            if cls == .builder && w.style == .galloway && st.long > 0.44 { continue }
            let width = want == .traced ? st.long : st.short
            guard width <= w.length * 0.5 else { continue }
            let x = flushRight ? edge - 0.004 - width * 0.5 : edge + 0.004 + width * 0.5
            let (probe, landing) = w.preview(id, at: x, tilt: 0, orientation: want)
            var v = 0.0
            switch probe {
            case .settled: break
            case .rocking: v += 6
            default: continue
            }
            guard let l = landing else { continue }
            if l.top < courseBottom + 0.03 { continue }
            let proud = l.top - lineTop
            if proud > r.courseTol { v += 60 + proud * 300 }
            if proud < -0.02 { v += (-proud - 0.02) * 220 }
            v += abs(l.top - lineTop) * 40 + abs(l.tilt) * 120
            let farEdge = flushRight ? x - width * 0.5 : x + width * 0.5
            var nearest = 1.0
            for e in below where e > 0.03 && e < w.length - 0.03 { nearest = min(nearest, abs(farEdge - e)) }
            if nearest < 0.045 { v += 120 } else if nearest < 0.07 { v += 25 }
            if best == nil || v < best!.1 { best = (id, v, x) }
        }
        guard let choice = best else { return nil }
        if tryPlace(&w, id: choice.0, x: choice.2, tilt: 0, orientation: want) { return choice.0 }
        return nil
    }

    static func layCourse(_ w: inout Wall, variant: UInt64 = 0, jitter: Double = 0) {
        let r = w.rules
        let course = w.lineIndex
        let lineTop = w.lineHeight
        let lastCourse = lineTop >= w.height - 0.06
        let prevTops = w.courseTops(course - 1)
        let courseBottom = prevTops.isEmpty ? max(0, lineTop - r.courseHeight) : prevTops[prevTops.count / 2]
        let centreY = (courseBottom + lineTop) * 0.5
        let below = belowEdges(w, course: course)
        let single = r.form == .doubleThenSingle && centreY > w.doubleTop + 0.01
        let aranUpright = w.style == .aran && single
        let gapWanted: Double = single ? (w.style == .aran ? 0.10 : 0.05) : gap
        let wantTie: Orientation = course % 2 == 1 ? .traced : .lengthIn
        var throughXs: [Double] = []
        let halfThroughs = w.placed.filter { $0.cls == .through && $0.orientation == .lengthIn && $0.y > w.height * 0.30 && $0.y < w.height * 0.70 }
        if w.style == .galloway {
            if centreY >= w.doubleTop - r.courseHeight * 0.6 && centreY < w.doubleTop + r.courseHeight * 1.2 {
                let band = w.placed.filter { $0.cls == .through && abs($0.y - w.doubleTop) < 0.16 }
                let n = max(1, Int((w.length / 0.5).rounded(.up)))
                for i in 0..<n {
                    let tx = w.length * (Double(i) + 0.5) / Double(n)
                    if !band.contains(where: { abs($0.x - tx) < 0.3 }) { throughXs.append(tx) }
                }
            }
        } else if r.wantsThroughs && w.throughsWanted > 0 && centreY >= w.height * 0.38 && centreY <= w.height * 0.66 {
            let n = w.throughsWanted
            for i in 0..<n {
                let tx = w.length * (Double(i) + 0.5) / Double(n)
                if !halfThroughs.contains(where: { abs($0.x - tx) < 0.32 }) { throughXs.append(tx) }
            }
        }
        var fixed: [(Double, Double)] = []
        for o in w.openings where centreY > o.y0 - 0.02 && !lintelled(w, o) {
            if o.needsLintel && placeLintel(&w, o) {
                if let lintel = w.placed.first(where: { w.lintels.contains($0.id) && abs($0.x - (o.x0 + o.x1) * 0.5) < 0.2 }) {
                    let b = Geometry.bounds(lintel.polygon)
                    fixed.append((b.minX, b.maxX))
                }
                continue
            }
            fixed.append((o.x0, o.x1))
            if !single {
                let leftWants = throughXs.contains { $0 > o.x0 - 0.45 && $0 < o.x0 + 0.05 }
                if leftWants, let id = placeHeadStone(&w, edge: o.x0, flushRight: true, want: .lengthIn, lineTop: lineTop, courseBottom: courseBottom, below: below, cls: .through) {
                    let b = Geometry.bounds(w.stone(id)!.polygon)
                    fixed.append((b.minX, b.maxX))
                    throughXs.removeAll { $0 > o.x0 - 0.45 && $0 < o.x0 + 0.05 }
                } else if let id = placeHeadStone(&w, edge: o.x0, flushRight: true, want: wantTie, lineTop: lineTop, courseBottom: courseBottom, below: below) {
                    let b = Geometry.bounds(w.stone(id)!.polygon)
                    fixed.append((b.minX, b.maxX))
                }
                let rightWants = throughXs.contains { $0 > o.x1 - 0.05 && $0 < o.x1 + 0.45 }
                if rightWants, let id = placeHeadStone(&w, edge: o.x1, flushRight: false, want: .lengthIn, lineTop: lineTop, courseBottom: courseBottom, below: below, cls: .through) {
                    let b = Geometry.bounds(w.stone(id)!.polygon)
                    fixed.append((b.minX, b.maxX))
                    throughXs.removeAll { $0 > o.x1 - 0.05 && $0 < o.x1 + 0.45 }
                } else if let id = placeHeadStone(&w, edge: o.x1, flushRight: false, want: wantTie, lineTop: lineTop, courseBottom: courseBottom, below: below) {
                    let b = Geometry.bounds(w.stone(id)!.polygon)
                    fixed.append((b.minX, b.maxX))
                }
            }
        }
        var rightStop = w.length
        let hangerDue = w.feature == .gatePost && centreY >= w.height * 0.62 && centreY < w.height * 0.92 && !w.placed.contains(where: { $0.cls == .through && $0.x > w.length - 0.55 && $0.y > w.height * 0.55 })
        let endWantsThrough = throughXs.contains { $0 > w.length - 0.45 }
        if !aranUpright {
            let endOrientation: Orientation = w.feature.rightHead ? wantTie : .lengthIn
            if hangerDue || endWantsThrough, let id = placeHeadStone(&w, edge: w.length, flushRight: true, want: .lengthIn, lineTop: lineTop, courseBottom: courseBottom, below: below, cls: .through) {
                rightStop = Geometry.bounds(w.stone(id)!.polygon).minX
                throughXs.removeAll { $0 > w.length - 0.45 }
            } else if let id = placeHeadStone(&w, edge: w.length, flushRight: true, want: endOrientation, lineTop: lineTop, courseBottom: courseBottom, below: below) {
                rightStop = Geometry.bounds(w.stone(id)!.polygon).minX
            }
        }
        fixed.sort { $0.0 < $1.0 }
        var segments: [Segment] = []
        var from = 0.0
        for f in fixed {
            if f.0 - from > 0.05 { segments.append(Segment(from: from, to: f.0)) }
            from = max(from, f.1)
        }
        if rightStop - from > 0.05 { segments.append(Segment(from: from, to: rightStop)) }

        var stepX: Double? = nil
        if w.feature == .stepStile {
            let zoneThroughs = w.placed.filter { $0.cls == .through && abs($0.x - w.length * 0.5) < 0.7 && $0.orientation == .lengthIn }
            let stepHeights = WallJudge.stepBands
            if let band = stepHeights.firstIndex(where: { h in !zoneThroughs.contains { abs($0.y - h) < 0.13 } }) {
                if centreY >= stepHeights[band] - r.courseHeight * 0.5 && centreY <= stepHeights[band] + 0.22 {
                    stepX = w.length * 0.5 - 0.42 + Double(band) * 0.42
                }
            }
        }
        var specials: [Double] = throughXs
        if let sx = stepX { specials.append(sx) }

        for seg in segments {
            var cursor = seg.from
            var startOffset = 0.0
            if single {
                var bestStart = 0.0
                var bestDist = -1.0
                for start in [0.0, 0.06, 0.10, 0.14, 0.18, 0.22] {
                    let left = cursor + start + gapWanted
                    var dist = 1.0
                    for e in below where e > cursor + 0.03 { dist = min(dist, abs(left - e)) }
                    if dist > bestDist { bestDist = dist; bestStart = start }
                }
                startOffset = bestStart
            }
            cursor += startOffset
            var mine = specials.filter { $0 > seg.from - 0.05 && $0 < seg.to + 0.05 }
            var guardCount = 0
            while cursor < seg.to - 0.03 && guardCount < 60 {
                guardCount += 1
                mine = mine.map { $0 < cursor - 0.02 ? cursor + 0.04 : $0 }
                if let sx = stepX, mine.contains(where: { abs($0 - sx) < 0.001 }) == false, cursor > sx + 0.25 { }
                mine.removeAll { tx in stepX != nil && abs(tx - (cursor + 0.04)) < 0.001 && tx > w.length * 0.5 + 0.62 }
                var startGap = gapWanted
                if cursor > seg.from + 0.03 || single {
                    for e in below where e > cursor - 0.02 && e < w.length - 0.04 && abs(cursor + gapWanted - e) < 0.045 {
                        startGap = max(startGap, e + 0.05 - cursor)
                    }
                }
                let remaining = seg.to - cursor - startGap
                if remaining < 0.08 { break }
                let bandCourse = w.style == .galloway && !throughXs.isEmpty
                let useThrough = bandCourse || mine.contains { $0 > cursor - 0.02 && $0 < cursor + 0.32 }
                var candidates: [(Int, Double, Orientation, Double)] = []
                if useThrough {
                    for id in heapIDs(w, .through).sorted(by: { w.stone($0)!.long < w.stone($1)!.long }) {
                        candidates.append((id, w.stone(id)!.short, .lengthIn, 0))
                    }
                }
                if (candidates.isEmpty || !aranUpright) && !(bandCourse && !candidates.isEmpty) {
                    for id in heapIDs(w, .builder) {
                        let st = w.stone(id)!
                        if aranUpright {
                            guard st.short > 0.40 else { continue }
                            candidates.append((id, st.long, .faced, 0))
                        } else if single && w.style == .galloway {
                            guard st.long > 0.44 else { continue }
                            candidates.append((id, st.short, .lengthIn, 0))
                        } else {
                            if w.style == .aran && st.short > 0.40 { continue }
                            if w.style == .galloway && st.long > 0.44 { continue }
                            let tilt: Double = r.herringbone && course >= 1 ? (course % 2 == 1 ? 0.72 : -0.72) : 0
                            candidates.append((id, st.short, .lengthIn, tilt))
                        }
                    }
                }
                candidates = candidates.filter { $0.1 <= remaining + 0.03 }
                if candidates.isEmpty {
                    if remaining < 0.24 { break }
                    cursor += 0.10
                    continue
                }
                var otherWidths: [Double] = []
                if remaining < 0.8 {
                    for id in heapIDs(w, .builder) {
                        let st = w.stone(id)!
                        otherWidths.append(aranUpright ? st.long : st.short)
                    }
                }
                let target = lineTop - courseBottom
                var noise = Spool(w.seed ^ UInt64(course * 977 + Int(cursor * 1000)) ^ variant)
                func score(_ c: (Int, Double, Orientation, Double)) -> Double {
                    let width = c.1
                    let st = w.stone(c.0)!
                    var v = 0.0
                    let left = cursor + startGap
                    let right = left + width
                    var nearest = 1.0
                    for e in below where e > cursor + 0.02 && e < w.length - 0.03 { nearest = min(nearest, abs(right - e)) }
                    if single {
                        for e in below where e > 0.03 && e < w.length - 0.03 { nearest = min(nearest, abs(left - e)) }
                    }
                    if nearest < 0.045 { v += 120 } else if nearest < 0.07 { v += 25 }
                    let leftover = remaining - width
                    if abs(leftover) <= 0.035 { v -= 14 }
                    else if leftover < 0.16 { v += 70 }
                    else if !otherWidths.isEmpty {
                        let rest = leftover - gapWanted
                        let pairFits = otherWidths.contains { abs(rest - $0) <= 0.035 }
                        v += pairFits ? -16 : 40
                    }
                    if useThrough && st.cls == .through { v -= 5 }
                    if useThrough && st.cls != .through { v += 30 }
                    if !aranUpright { v += abs(st.faceHeight - target) * 30 }
                    let x = left + width * 0.5
                    let (probe, landing) = w.preview(c.0, at: x, tilt: c.3, orientation: c.2)
                    switch probe {
                    case .settled: break
                    case .rocking: v += 6
                    default: v += 500
                    }
                    if let l = landing, l.top < courseBottom + 0.03 { v += 500 }
                    if let l = landing, !aranUpright {
                        let proud = l.top - lineTop
                        if proud > r.courseTol { v += 60 + proud * 300 }
                        if proud < -0.02 { v += (-proud - 0.02) * (lastCourse ? 600 : 260) }
                        v += abs(l.top - lineTop) * 40
                        v += abs(l.tilt - c.3) * 120
                    } else if let l = landing {
                        v += abs(l.tilt) * 120
                    }
                    v += noise.range(0, jitter)
                    return v
                }
                var scored: [((Int, Double, Orientation, Double), Double)] = []
                for c in candidates { scored.append((c, score(c))) }
                scored = scored.filter { $0.1 < 400 }
                scored.sort { $0.1 < $1.1 }
                let ordered: [(Int, Double, Orientation, Double)] = scored.map { $0.0 }
                var placedOne = false
                for c in ordered.prefix(4) {
                    let x = cursor + startGap + c.1 * 0.5
                    if tryPlace(&w, id: c.0, x: x, tilt: c.3, orientation: c.2) {
                        let b = Geometry.bounds(w.stone(c.0)!.polygon)
                        if b.maxX > seg.to + 0.035 && seg.to < w.length - 0.01 {
                            _ = w.lift(c.0)
                            continue
                        }
                        cursor = b.maxX
                        placedOne = true
                        if w.stone(c.0)!.cls == .through { mine.removeAll { $0 > b.minX - 0.12 && $0 < b.maxX + 0.12 } }
                        break
                    }
                }
                if !placedOne {
                    if remaining < 0.24 { break }
                    cursor += 0.10
                }
            }
        }
        repairJoints(&w, course: course, lineTop: lineTop, courseBottom: courseBottom, below: below)
        if r.core != .none && (r.form != .doubleThenSingle || centreY <= w.doubleTop + 0.01) {
            var taps = 0
            while w.currentHeartFill < 1.0 && taps < 40 && w.heartingLeft > 0 {
                _ = w.addHearting(1)
                taps += 1
            }
        }
        let tops = w.courseTops(course)
        guard !tops.isEmpty else { w.raiseLine(to: lineTop + r.courseHeight); return }
        let median = tops[tops.count / 2]
        var next = w.heapCourseHeight
        if r.form == .doubleThenSingle && median + 0.02 > w.doubleTop && w.style == .aran { next = 0.60 }
        w.raiseLine(to: min(w.height + 0.02, max(lineTop + 0.03, median + next)))
    }

    static func repairJoints(_ w: inout Wall, course: Int, lineTop: Double, courseBottom: Double, below: [Double]) {
        let r = w.rules
        for _ in 0..<3 {
            let joints = WallJudge.sheet(w).joints.filter { w.stone($0.upper)?.course == course }
            guard let j = joints.first, let u = w.stone(j.upper), w.canLift(u.id), u.cls == .builder || u.cls == .through else { return }
            let ub = Geometry.bounds(u.polygon)
            let leftEdge = ub.minX
            let rightLimit: Double = {
                var limit = w.length + 0.03
                for other in w.placed where other.course == course && other.id != u.id {
                    let ob = Geometry.bounds(other.polygon)
                    if ob.minX > ub.maxX - 0.01 { limit = min(limit, ob.minX) }
                }
                return limit
            }()
            guard w.lift(u.id) else { return }
            var best: (Int, Double, Double)? = nil
            let pool = u.cls == .through ? heapIDs(w, .through) : heapIDs(w, .builder)
            for id in pool {
                let st = w.stone(id)!
                if u.cls == .builder && w.style == .aran && st.short > 0.40 { continue }
                if u.cls == .builder && w.style == .galloway && st.long > 0.44 { continue }
                let width = st.short
                for shift in [0.0, 0.03, 0.06] {
                    let left = leftEdge + shift
                    let right = left + width
                    guard right <= rightLimit - 0.008 else { continue }
                    var nearest = 1.0
                    for e in below where e > 0.03 && e < w.length - 0.03 {
                        nearest = min(nearest, abs(right - e))
                        nearest = min(nearest, abs(left - e))
                    }
                    guard nearest >= 0.045 else { continue }
                    let x = left + width * 0.5
                    let (probe, landing) = w.preview(id, at: x, tilt: 0, orientation: .lengthIn)
                    var v = shift * 100
                    switch probe {
                    case .settled: break
                    case .rocking: v += 6
                    default: continue
                    }
                    guard let l = landing, l.top >= courseBottom + 0.03 else { continue }
                    let proud = l.top - lineTop
                    if proud > r.courseTol { v += 60 + proud * 300 }
                    v += abs(l.top - lineTop) * 40 + abs(l.tilt) * 120
                    if best == nil || v < best!.1 { best = (id, v, x) }
                }
            }
            if let b = best, tryPlace(&w, id: b.0, x: b.2, tilt: 0, orientation: .lengthIn) { continue }
            _ = tryPlace(&w, id: u.id, x: u.x, tilt: 0, orientation: u.orientation)
        }
    }

    static func repairCopes(_ w: inout Wall) {
        let r = w.rules
        guard r.cope != .none, r.cope != .turf else { return }
        for _ in 0..<6 {
            let copes = w.copesPlaced
            guard copes.count > 1 else { return }
            var gapAt: (Double, Double)? = nil
            for i in 0..<(copes.count - 1) {
                let a = Geometry.bounds(copes[i].polygon).maxX, b = Geometry.bounds(copes[i + 1].polygon).minX
                let gapLimit = r.cope == .locked ? 0.14 : 0.03
                if b - a > gapLimit && b - a > 0.09 { gapAt = (a, b); break }
            }
            let last = Geometry.bounds(copes[copes.count - 1].polygon).maxX
            if gapAt == nil && w.length - last > 0.09 { gapAt = (last, w.length + 0.03) }
            guard let (a, b) = gapAt else { break }
            let ids = heapIDs(w, .cope).filter { w.stone($0)!.faceWidth <= b - a - 0.012 }.sorted { w.stone($0)!.faceWidth > w.stone($1)!.faceWidth }
            var done = false
            let topMedian = w.topMedian
            for id in ids.prefix(10) {
                let width = w.stone(id)!.faceWidth
                let (_, landing) = w.preview(id, at: a + 0.006 + width * 0.5, tilt: 0, orientation: .lengthIn)
                guard let l = landing, l.bottom >= topMedian - 0.20 else { continue }
                if tryPlace(&w, id: id, x: a + 0.006 + width * 0.5, tilt: 0, orientation: .lengthIn) {
                    if abs(w.stone(id)!.tilt) > 0.2 { _ = w.chock(id) }
                    if r.cope == .locked {
                        let nb = Geometry.bounds(w.stone(id)!.polygon)
                        _ = w.lock(at: (a + nb.minX) * 0.5)
                        _ = w.lock(at: (nb.maxX + b) * 0.5)
                    }
                    done = true
                    break
                }
            }
            if !done { break }
        }
        for c in w.copesPlaced where abs(c.tilt) > 0.25 && !c.pinned { _ = w.chock(c.id) }
    }

    static func layCope(_ w: inout Wall) {
        let r = w.rules
        switch r.cope {
        case .none:
            return
        case .turf:
            w.layTurf(1)
            return
        default:
            break
        }
        var cursor = 0.0
        var guardCount = 0
        var tallNext = true
        let copeGap = r.cope == .locked ? 0.05 : 0.008
        while cursor < w.length - 0.03 && guardCount < 80 {
            guardCount += 1
            let ids = heapIDs(w, .cope)
            guard !ids.isEmpty else { break }
            let remaining = w.length - cursor
            var chosen = ids
            if r.cope == .cockAndHen {
                let tall = ids.filter { w.stone($0)!.thick >= 0.27 }
                let short = ids.filter { w.stone($0)!.thick < 0.27 }
                let pool = tallNext ? tall : short
                if !pool.isEmpty { chosen = pool }
            }
            let fitting = chosen.filter { w.stone($0)!.faceWidth <= remaining + 0.05 }
            let pool = fitting.isEmpty ? chosen : fitting
            let topMedian = w.topMedian
            let minCope = ids.map { w.stone($0)!.faceWidth }.min() ?? 0.1
            let startGap = cursor < 0.01 ? 0.006 : copeGap
            func fillable(_ left: Double, without id: Int) -> Bool {
                if left <= 0.05 { return true }
                if left >= minCope * 2 + copeGap { return true }
                for other in ids where other != id {
                    let rest = left - w.stone(other)!.faceWidth - copeGap
                    if rest <= 0.05 && rest >= -0.03 { return true }
                }
                return false
            }
            func copeScore(_ id: Int) -> Double {
                let width = w.stone(id)!.faceWidth
                let (probe, landing) = w.preview(id, at: cursor + startGap + width * 0.5, tilt: 0, orientation: .lengthIn)
                var v = 0.0
                switch probe {
                case .settled: break
                case .rocking: v += 4
                default: v += 500
                }
                if let l = landing { v += abs(l.tilt) * 60 }
                if let l = landing, l.bottom < topMedian - 0.20 { v += 500 }
                v += abs(width - min(remaining, 0.2)) * 10
                let left = remaining - width - startGap
                if !fillable(left, without: id) { v += 80 }
                if left < -0.035 { v += 80 }
                return v
            }
            func rank(_ list: [Int]) -> [Int] {
                var scored: [(Int, Double)] = []
                for id in list { scored.append((id, copeScore(id))) }
                scored = scored.filter { $0.1 < 400 }
                scored.sort { $0.1 < $1.1 }
                return scored.map { $0.0 }
            }
            var ordered: [Int] = rank(pool)
            if ordered.isEmpty { ordered = rank(ids) }
            var placedOne = false
            for id in ordered.prefix(8) {
                let width = w.stone(id)!.faceWidth
                if tryPlace(&w, id: id, x: cursor + startGap + width * 0.5, tilt: 0, orientation: .lengthIn) {
                    let b = Geometry.bounds(w.stone(id)!.polygon)
                    if abs(w.stone(id)!.tilt) > 0.2 { _ = w.chock(id) }
                    if r.cope == .locked && cursor > 0.01 { _ = w.lock(at: (cursor + b.minX) * 0.5) }
                    cursor = b.maxX
                    placedOne = true
                    tallNext.toggle()
                    break
                }
            }
            if !placedOne { cursor += 0.02 }
        }
    }
}
