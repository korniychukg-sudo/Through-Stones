import SwiftUI

struct FellLight {
    var skyTop: Color
    var skyLow: Color
    var far: Color
    var mid: Color
    var near: Color
    var stone: Color
    var light: Double
    var stars: Double
    var sun: Double
    var moon: Double
    var warm: Double
}

enum FellClock {
    static let frames: [(Double, FellLight)] = [
        (0, FellLight(skyTop: Color(red: 0.06, green: 0.08, blue: 0.15), skyLow: Color(red: 0.14, green: 0.17, blue: 0.26), far: Color(red: 0.12, green: 0.14, blue: 0.20), mid: Color(red: 0.15, green: 0.18, blue: 0.20), near: Color(red: 0.17, green: 0.21, blue: 0.18), stone: Color(red: 0.22, green: 0.22, blue: 0.24), light: 0.18, stars: 1.0, sun: -1, moon: 1, warm: 0)),
        (5.5, FellLight(skyTop: Color(red: 0.30, green: 0.34, blue: 0.48), skyLow: Color(red: 0.85, green: 0.66, blue: 0.50), far: Color(red: 0.40, green: 0.42, blue: 0.52), mid: Color(red: 0.36, green: 0.42, blue: 0.36), near: Color(red: 0.40, green: 0.48, blue: 0.32), stone: Color(red: 0.42, green: 0.38, blue: 0.34), light: 0.45, stars: 0.15, sun: 0.02, moon: 0, warm: 0.5)),
        (8.5, FellLight(skyTop: Color(red: 0.50, green: 0.64, blue: 0.80), skyLow: Color(red: 0.80, green: 0.85, blue: 0.86), far: Color(red: 0.52, green: 0.60, blue: 0.68), mid: Color(red: 0.46, green: 0.56, blue: 0.38), near: Color(red: 0.50, green: 0.60, blue: 0.34), stone: Color(red: 0.52, green: 0.46, blue: 0.38), light: 0.8, stars: 0, sun: 0.25, moon: 0, warm: 0.3)),
        (12.5, FellLight(skyTop: Color(red: 0.42, green: 0.60, blue: 0.80), skyLow: Color(red: 0.75, green: 0.82, blue: 0.86), far: Color(red: 0.55, green: 0.63, blue: 0.70), mid: Color(red: 0.50, green: 0.60, blue: 0.38), near: Color(red: 0.52, green: 0.62, blue: 0.34), stone: Color(red: 0.56, green: 0.50, blue: 0.42), light: 1.0, stars: 0, sun: 0.8, moon: 0, warm: 0.1)),
        (16.0, FellLight(skyTop: Color(red: 0.48, green: 0.60, blue: 0.74), skyLow: Color(red: 0.82, green: 0.80, blue: 0.74), far: Color(red: 0.55, green: 0.58, blue: 0.62), mid: Color(red: 0.50, green: 0.56, blue: 0.36), near: Color(red: 0.55, green: 0.58, blue: 0.32), stone: Color(red: 0.56, green: 0.48, blue: 0.40), light: 0.9, stars: 0, sun: 0.6, moon: 0, warm: 0.35)),
        (19.5, FellLight(skyTop: Color(red: 0.30, green: 0.32, blue: 0.48), skyLow: Color(red: 0.85, green: 0.55, blue: 0.36), far: Color(red: 0.36, green: 0.32, blue: 0.42), mid: Color(red: 0.32, green: 0.36, blue: 0.30), near: Color(red: 0.34, green: 0.40, blue: 0.26), stone: Color(red: 0.44, green: 0.36, blue: 0.30), light: 0.5, stars: 0.2, sun: 0.03, moon: 0, warm: 0.7)),
        (22.0, FellLight(skyTop: Color(red: 0.10, green: 0.12, blue: 0.22), skyLow: Color(red: 0.22, green: 0.22, blue: 0.32), far: Color(red: 0.16, green: 0.17, blue: 0.24), mid: Color(red: 0.18, green: 0.21, blue: 0.22), near: Color(red: 0.20, green: 0.24, blue: 0.20), stone: Color(red: 0.26, green: 0.26, blue: 0.28), light: 0.25, stars: 0.8, sun: -1, moon: 0.7, warm: 0.05))
    ]

    static func at(_ hour: Double) -> FellLight {
        let h = hour.truncatingRemainder(dividingBy: 24)
        var lower = frames[frames.count - 1]
        var upper = frames[0]
        var lowerHour = lower.0 - 24
        var upperHour = upper.0
        for i in 0..<frames.count where frames[i].0 <= h {
            lower = frames[i]
            lowerHour = frames[i].0
            if i + 1 < frames.count { upper = frames[i + 1]; upperHour = frames[i + 1].0 }
            else { upper = frames[0]; upperHour = 24 + frames[0].0 }
        }
        let span = max(0.001, upperHour - lowerHour)
        let t = (h - lowerHour) / span
        let a = lower.1, b = upper.1
        func mix(_ x: Double, _ y: Double) -> Double { x + (y - x) * t }
        return FellLight(skyTop: Color.blend(a.skyTop, b.skyTop, t), skyLow: Color.blend(a.skyLow, b.skyLow, t), far: Color.blend(a.far, b.far, t),
                         mid: Color.blend(a.mid, b.mid, t), near: Color.blend(a.near, b.near, t), stone: Color.blend(a.stone, b.stone, t),
                         light: mix(a.light, b.light), stars: mix(a.stars, b.stars), sun: a.sun < 0 || b.sun < 0 ? (t < 0.5 ? a.sun : b.sun) : mix(a.sun, b.sun),
                         moon: mix(a.moon, b.moon), warm: mix(a.warm, b.warm))
    }

    static func hourValue(_ date: Date = Date()) -> Double {
        let cal = Calendar.current
        return Double(cal.component(.hour, from: date)) + Double(cal.component(.minute, from: date)) / 60
    }

    static func plateName(_ hour: Double) -> String {
        switch Int(hour) {
        case 0..<5: return "fell_h0"
        case 5..<8: return "fell_h1"
        case 8..<11: return "fell_h2"
        case 11..<14: return "fell_h3"
        case 14..<17: return "fell_h4"
        case 17..<20: return "fell_h5"
        default: return "fell_h6"
        }
    }
}

struct FellWeather {
    var rain: Double
    var snow: Double
    var wind: Double
    var mist: Double
    var cloud: Double
    var season: Int

    static func today(_ day: Int) -> FellWeather {
        var rng = Spool(seedOf("fell.weather.\(day)"))
        let month = Calendar.current.component(.month, from: Date())
        let winter = month == 12 || month <= 2
        let season = month <= 2 || month == 12 ? 3 : (month <= 5 ? 0 : (month <= 8 ? 1 : 2))
        let wet = rng.unit()
        let rain = wet > 0.62 && !winter ? rng.range(0.3, 1.0) : 0
        let snow = winter && wet > 0.5 ? rng.range(0.3, 1.0) : 0
        let wind = rng.range(0.1, 1.0)
        let mist = rng.chance(0.35) ? rng.range(0.4, 1.0) : 0
        let cloud = rng.range(0.1, 0.9)
        return FellWeather(rain: rain, snow: snow, wind: wind, mist: mist, cloud: cloud, season: season)
    }

    var words: String {
        if snow > 0 { return snow > 0.6 ? "Snow on the fell" : "A few flakes on the wind" }
        if rain > 0 { return rain > 0.6 ? "Rain across the tops" : "A soft rain" }
        if wind > 0.75 { return "A gale off the tops" }
        if mist > 0 { return "Mist in the bottoms" }
        if cloud > 0.7 { return "Overcast and still" }
        return "Clear over the fell"
    }
}

struct FellSheep {
    var u: Double
    var v: Double
    var size: Double
    var phase: Double
    var left: Bool
}

enum FellBits {
    static let sheep: [FellSheep] = {
        var rng = Spool(seedOf("fell.sheep"))
        var out: [FellSheep] = []
        for _ in 0..<7 {
            out.append(FellSheep(u: rng.range(0.42, 0.96), v: rng.range(0.55, 0.78), size: rng.range(0.03, 0.05), phase: rng.range(0, 6.28), left: rng.chance(0.5)))
        }
        return out.sorted { $0.v < $1.v }
    }()

    static let stars: [(Double, Double, Double)] = {
        var rng = Spool(seedOf("fell.stars"))
        return (0..<70).map { _ in (rng.unit(), rng.range(0.02, 0.5), rng.range(0, 6.28)) }
    }()

    static let flakes: [(Double, Double, Double)] = {
        var rng = Spool(seedOf("fell.flakes"))
        return (0..<60).map { _ in (rng.unit(), rng.unit(), rng.range(0.6, 1.4)) }
    }()

    static let tufts: [(Double, Double, Double)] = {
        var rng = Spool(seedOf("fell.tufts"))
        return (0..<48).map { _ in (rng.unit(), rng.range(0.52, 0.98), rng.range(0.6, 1.3)) }
    }()

    static let nearStones: [(Double, Double, Double, Double)] = {
        var rng = Spool(seedOf("fell.nearwall"))
        var out: [(Double, Double, Double, Double)] = []
        var t = 0.0
        while t < 1.0 {
            let w = rng.range(0.035, 0.07)
            for row in 0..<4 {
                out.append((t + (row % 2 == 0 ? 0 : w * 0.4), Double(row), w, rng.range(0.7, 1.0)))
            }
            t += w
        }
        return out
    }()
}

struct FellScene: View {
    var hour: Double
    var weather: FellWeather
    var standing: Int

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let w = Double(size.width), h = Double(size.height)
                let tone = FellClock.at(hour)
                let horizon = h * 0.46
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: [tone.skyTop, tone.skyLow]), startPoint: .zero, endPoint: CGPoint(x: 0, y: horizon + 40)))
                if tone.sun >= 0 {
                    let sx = w * (0.2 + tone.sun * 0.5), sy = horizon - h * (0.05 + tone.sun * 0.55)
                    ctx.fill(Path(ellipseIn: CGRect(x: sx - w * 0.5, y: sy - w * 0.5, width: w, height: w)), with: .radialGradient(Gradient(colors: [Color(red: 1, green: 0.92, blue: 0.7).opacity(0.35 + tone.warm * 0.3), Color.clear]), center: CGPoint(x: sx, y: sy), startRadius: 0, endRadius: w * 0.5))
                }
                if tone.moon > 0.05 {
                    let mx = w * 0.78, my = h * 0.16
                    ctx.fill(Path(ellipseIn: CGRect(x: mx - 60, y: my - 60, width: 120, height: 120)), with: .radialGradient(Gradient(colors: [Color(red: 0.85, green: 0.88, blue: 1).opacity(0.3 * tone.moon), Color.clear]), center: CGPoint(x: mx, y: my), startRadius: 0, endRadius: 60))
                    ctx.fill(Path(ellipseIn: CGRect(x: mx - 9, y: my - 9, width: 18, height: 18)), with: .color(Color(red: 0.94, green: 0.95, blue: 0.9).opacity(tone.moon)))
                    ctx.fill(Path(ellipseIn: CGRect(x: mx - 13, y: my - 11, width: 16, height: 16)), with: .color(tone.skyTop.opacity(tone.moon * 0.9)))
                }
                if tone.stars > 0.05 && weather.cloud < 0.75 {
                    for (u, v, ph) in FellBits.stars {
                        let twinkle = 0.5 + 0.5 * sin(t * 1.7 + ph * 4)
                        let r = 0.7 + twinkle * 0.8
                        ctx.fill(Path(ellipseIn: CGRect(x: u * w - r, y: v * horizon - r, width: r * 2, height: r * 2)), with: .color(Color.white.opacity(tone.stars * (0.3 + 0.6 * twinkle))))
                    }
                }
                let cloudShift = t * 4 * (0.3 + weather.wind)
                for k in 0..<4 {
                    let cx = (Double(k) * 0.28 * w + cloudShift).truncatingRemainder(dividingBy: w * 1.3) - w * 0.15
                    let cy = h * (0.08 + Double(k % 2) * 0.09)
                    let cw = w * (0.22 + Double(k % 3) * 0.05), ch = h * 0.05
                    ctx.fill(Path(ellipseIn: CGRect(x: cx, y: cy, width: cw, height: ch)), with: .color(Color.blend(tone.skyLow, Color.white, 0.35).opacity(0.25 + weather.cloud * 0.4)))
                }
                let ridges: [(Double, Double, Color)] = [(horizon - h * 0.19, h * 0.05, Color.blend(tone.far, tone.skyLow, 0.35)), (horizon - h * 0.11, h * 0.035, tone.far), (horizon - h * 0.04, h * 0.025, Color.blend(tone.mid, tone.far, 0.35))]
                for (k, ridge) in ridges.enumerated() {
                    var path = Path()
                    path.move(to: CGPoint(x: -10, y: h + 10))
                    var x = -10.0
                    while x <= w + 10 {
                        let y = ridge.0 + sin(x * 0.006 + Double(k) * 1.7) * ridge.1 + sin(x * 0.017 + Double(k)) * ridge.1 * 0.35
                        path.addLine(to: CGPoint(x: x, y: y))
                        x += 18
                    }
                    path.addLine(to: CGPoint(x: w + 10, y: h + 10))
                    path.closeSubpath()
                    ctx.fill(path, with: .color(ridge.2))
                    if weather.snow > 0 {
                        ctx.fill(path, with: .color(Color.white.opacity(0.35 * weather.snow)))
                    }
                }
                var near = Path()
                near.move(to: CGPoint(x: -10, y: h + 10))
                var x = -10.0
                while x <= w + 10 {
                    near.addLine(to: CGPoint(x: x, y: horizon + 6 + sin(x * 0.007 + 0.6) * h * 0.02))
                    x += 20
                }
                near.addLine(to: CGPoint(x: w + 10, y: h + 10))
                near.closeSubpath()
                let seasonNear: Color = weather.season == 3 ? Color.blend(tone.near, Color(red: 0.55, green: 0.48, blue: 0.32), 0.45) : (weather.season == 2 ? Color.blend(tone.near, Fell.dusk, 0.18) : tone.near)
                ctx.fill(near, with: .color(seasonNear))
                if weather.snow > 0.3 { ctx.fill(near, with: .color(Color.white.opacity(0.45 * weather.snow))) }
                if weather.mist > 0 && (hour < 9 || hour > 19) {
                    ctx.fill(Path(CGRect(x: 0, y: horizon - h * 0.16, width: w, height: h * 0.22)), with: .linearGradient(Gradient(colors: [Color.blend(tone.skyLow, Color.white, 0.3).opacity(0), Color.blend(tone.skyLow, Color.white, 0.3).opacity(0.7 * weather.mist), Color.blend(tone.skyLow, Color.white, 0.3).opacity(0)]), startPoint: CGPoint(x: 0, y: horizon - h * 0.16), endPoint: CGPoint(x: 0, y: horizon + h * 0.06)))
                }
                let gust = sin(t * 0.9) * 0.5 + 0.5 * sin(t * 2.3 + 1)
                let lean = weather.wind * (0.5 + 0.5 * gust) * 8
                for (u, v, s) in FellBits.tufts {
                    let bx = u * w, by = horizon + (v - 0.5) * (h - horizon) * 1.05 + h * 0.03
                    let tall = 6 * s * (0.6 + v)
                    var tuft = Path()
                    for blade in 0..<3 {
                        let ox = Double(blade - 1) * 2.2
                        tuft.move(to: CGPoint(x: bx + ox, y: by))
                        tuft.addQuadCurve(to: CGPoint(x: bx + ox + lean * s * 0.6 + Double(blade - 1) * 2, y: by - tall), control: CGPoint(x: bx + ox + lean * s * 0.2, y: by - tall * 0.6))
                    }
                    ctx.stroke(tuft, with: .color(Color.blend(seasonNear, Color.black, 0.35).opacity(0.7)), lineWidth: 1)
                }
                let sheepTone = Color.blend(Color(red: 0.88, green: 0.86, blue: 0.80), Color.black, 0.7 * (1 - tone.light))
                let sheepDark = Color.blend(Color(red: 0.07, green: 0.06, blue: 0.05), Color.white, 0.15 * tone.light)
                let flock = max(2, min(7, 2 + standing))
                for s in FellBits.sheep.prefix(flock) {
                    let drift = sin(t * 0.05 + s.phase) * 0.04
                    let sx = (s.u + drift) * w, sy = horizon + s.v * (h - horizon) * 0.45 + h * 0.06
                    let size = s.size * w * (0.8 + s.v * 0.6)
                    let graze = sin(t * 0.35 + s.phase * 3) > -0.2
                    let fleeceLean = lean * 0.08 * size / 20
                    var body = Path(ellipseIn: CGRect(x: sx - size * 0.62 + fleeceLean, y: sy - size * 0.9, width: size * 1.24, height: size * 0.8))
                    body.addEllipse(in: CGRect(x: sx - size * 0.3 + fleeceLean * 1.5, y: sy - size * 1.0, width: size * 0.7, height: size * 0.5))
                    ctx.fill(Path(ellipseIn: CGRect(x: sx - size * 0.6, y: sy - size * 0.12, width: size * 1.3, height: size * 0.24)), with: .color(sheepDark.opacity(0.18)))
                    for lx in [-0.34, -0.16, 0.14, 0.32] {
                        var leg = Path()
                        leg.move(to: CGPoint(x: sx + lx * size, y: sy - size * 0.3))
                        leg.addLine(to: CGPoint(x: sx + lx * size, y: sy))
                        ctx.stroke(leg, with: .color(sheepDark), lineWidth: max(1, size * 0.07))
                    }
                    ctx.fill(body, with: .color(sheepTone))
                    let dir: Double = s.left ? -1 : 1
                    let headX = sx + dir * (graze ? size * 0.68 : size * 0.72)
                    let headY = graze ? sy - size * 0.15 : sy - size * 0.75
                    var neck = Path()
                    neck.move(to: CGPoint(x: sx + dir * size * 0.45, y: sy - size * 0.55))
                    neck.addLine(to: CGPoint(x: headX, y: headY))
                    ctx.stroke(neck, with: .color(sheepDark), style: StrokeStyle(lineWidth: max(1.5, size * 0.16), lineCap: .round))
                    ctx.fill(Path(ellipseIn: CGRect(x: headX - size * 0.16, y: headY - size * 0.2, width: size * 0.32, height: size * 0.4)), with: .color(sheepDark))
                }
                let wallA = CGPoint(x: w * 0.06, y: h * 0.96), wallB = CGPoint(x: w * 0.55, y: horizon + h * 0.03)
                let nearH = h * 0.30, farH = h * 0.03
                var band = Path()
                band.move(to: wallA)
                band.addLine(to: wallB)
                band.addLine(to: CGPoint(x: wallB.x, y: wallB.y - farH))
                band.addLine(to: CGPoint(x: wallA.x, y: wallA.y - nearH))
                band.closeSubpath()
                ctx.fill(band, with: .color(Color.blend(tone.stone, Color.black, 0.55)))
                for (u, row, ww, shade) in FellBits.nearStones {
                    let x0 = Double(wallA.x) + (Double(wallB.x) - Double(wallA.x)) * u
                    let y0 = Double(wallA.y) + (Double(wallB.y) - Double(wallA.y)) * u
                    let hh = nearH + (farH - nearH) * pow(u, 0.8)
                    let sw = ww * (Double(wallB.x) - Double(wallA.x)) * 1.0
                    let sh = hh * 0.22
                    let sy = y0 - sh * (row + 0.55)
                    let rect = CGRect(x: x0, y: sy, width: max(2, sw - 1.5), height: max(1.5, sh - 1.5))
                    let stoneTone = Color.blend(tone.stone, Color.black, (1 - shade) * 0.5)
                    let snowy = weather.snow > 0.3 && row == 3
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 1.5), with: .color(snowy ? Color.blend(stoneTone, Color.white, 0.6 * weather.snow) : stoneTone))
                    if sw > 12 {
                        ctx.fill(Path(roundedRect: CGRect(x: rect.minX + 1, y: rect.minY + 1, width: rect.width * 0.5, height: rect.height * 0.35), cornerRadius: 1), with: .color(Color.white.opacity(0.10 + 0.12 * tone.light)))
                    }
                }
                let frameX = w * 0.20, frameBase = h * 0.94
                let frameH = h * 0.36
                for side in [-1.0, 1.0] {
                    var leg = Path()
                    leg.move(to: CGPoint(x: frameX + side * frameH * 0.22, y: frameBase))
                    leg.addLine(to: CGPoint(x: frameX + side * frameH * 0.10 + frameH * 0.12, y: frameBase - frameH))
                    ctx.stroke(leg, with: .color(Color.blend(Fell.woodDark, Color.black, 0.5 * (1 - tone.light))), style: StrokeStyle(lineWidth: max(2, w * 0.006), lineCap: .round))
                }
                var cross = Path()
                cross.move(to: CGPoint(x: frameX - frameH * 0.17 + frameH * 0.04, y: frameBase - frameH * 0.38))
                cross.addLine(to: CGPoint(x: frameX + frameH * 0.17 + frameH * 0.04, y: frameBase - frameH * 0.38))
                ctx.stroke(cross, with: .color(Color.blend(Fell.woodDark, Color.black, 0.5 * (1 - tone.light))), style: StrokeStyle(lineWidth: max(2, w * 0.005), lineCap: .round))
                var string = Path()
                let sway = lean * 0.6
                string.move(to: CGPoint(x: frameX + frameH * 0.08, y: frameBase - frameH * 0.66))
                string.addQuadCurve(to: CGPoint(x: wallB.x - 6, y: wallB.y - farH * 1.6), control: CGPoint(x: w * 0.38 + sway, y: frameBase - frameH * 0.5 + 8))
                ctx.stroke(string, with: .color(Fell.string.opacity(0.75 + 0.25 * tone.light)), lineWidth: 1.2)
                if hour >= 17.5 && hour <= 21 {
                    let flight = (t * 0.035).truncatingRemainder(dividingBy: 1)
                    let bx = w * (1.1 - flight * 1.3), by = h * (0.16 + sin(flight * 6) * 0.03)
                    let flap = sin(t * 7) * 6
                    var bird = Path()
                    bird.move(to: CGPoint(x: bx - 14, y: by - flap * 0.5))
                    bird.addQuadCurve(to: CGPoint(x: bx, y: by), control: CGPoint(x: bx - 7, y: by + 3))
                    bird.addQuadCurve(to: CGPoint(x: bx + 14, y: by - flap * 0.5), control: CGPoint(x: bx + 7, y: by + 3))
                    ctx.stroke(bird, with: .color(Color(red: 0.07, green: 0.06, blue: 0.05).opacity(0.85)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                }
                if weather.rain > 0 {
                    for (u, v, s) in FellBits.flakes {
                        let fall = (v + t * 0.7 * s).truncatingRemainder(dividingBy: 1)
                        let rx = (u * w + fall * lean * 3).truncatingRemainder(dividingBy: w)
                        let ry = fall * h
                        var drop = Path()
                        drop.move(to: CGPoint(x: rx, y: ry))
                        drop.addLine(to: CGPoint(x: rx - lean * 0.3, y: ry + 9 * s))
                        ctx.stroke(drop, with: .color(Color.white.opacity(0.28 * weather.rain)), lineWidth: 1)
                    }
                }
                if weather.snow > 0 {
                    for (u, v, s) in FellBits.flakes {
                        let fall = (v + t * 0.09 * s).truncatingRemainder(dividingBy: 1)
                        let rx = (u * w + sin(t * 1.3 + u * 20) * 12 + fall * lean * 6).truncatingRemainder(dividingBy: w + 20)
                        let r = 1.2 + s * 1.2
                        ctx.fill(Path(ellipseIn: CGRect(x: rx - r, y: fall * h - r, width: r * 2, height: r * 2)), with: .color(Color.white.opacity(0.75 * weather.snow)))
                    }
                }
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .radialGradient(Gradient(colors: [Color.clear, Color.black.opacity(0.18 + 0.22 * (1 - tone.light))]), center: CGPoint(x: w * 0.45, y: h * 0.45), startRadius: min(w, h) * 0.3, endRadius: max(w, h) * 0.85))
            }
        }
        .allowsHitTesting(false)
    }
}
