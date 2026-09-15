import SwiftUI

struct FellMark: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            var hill = Path()
            hill.move(to: CGPoint(x: 0, y: h * 0.72))
            hill.addQuadCurve(to: CGPoint(x: w * 0.55, y: h * 0.36), control: CGPoint(x: w * 0.25, y: h * 0.34))
            hill.addQuadCurve(to: CGPoint(x: w, y: h * 0.62), control: CGPoint(x: w * 0.8, y: h * 0.40))
            hill.addLine(to: CGPoint(x: w, y: h * 0.92))
            hill.addLine(to: CGPoint(x: 0, y: h * 0.92))
            hill.closeSubpath()
            ctx.fill(hill, with: .color(color.opacity(0.28)))
            ctx.stroke(hill, with: .color(color), lineWidth: w * 0.06)
            var wall = Path()
            wall.move(to: CGPoint(x: w * 0.12, y: h * 0.90))
            wall.addLine(to: CGPoint(x: w * 0.50, y: h * 0.52))
            ctx.stroke(wall, with: .color(color), style: StrokeStyle(lineWidth: w * 0.09, lineCap: .round))
            ctx.fill(Path(ellipseIn: CGRect(x: w * 0.68, y: h * 0.10, width: w * 0.18, height: w * 0.18)), with: .color(color.opacity(0.85)))
        }
        .frame(width: size, height: size)
    }
}

struct BankMark: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            var handle = Path()
            handle.move(to: CGPoint(x: w * 0.18, y: h * 0.88))
            handle.addLine(to: CGPoint(x: w * 0.62, y: h * 0.40))
            ctx.stroke(handle, with: .color(color), style: StrokeStyle(lineWidth: w * 0.10, lineCap: .round))
            var head = Path()
            head.move(to: CGPoint(x: w * 0.48, y: h * 0.22))
            head.addLine(to: CGPoint(x: w * 0.90, y: h * 0.42))
            head.addLine(to: CGPoint(x: w * 0.80, y: h * 0.58))
            head.addLine(to: CGPoint(x: w * 0.40, y: h * 0.36))
            head.closeSubpath()
            ctx.fill(head, with: .color(color))
            var chip = Path()
            chip.move(to: CGPoint(x: w * 0.40, y: h * 0.36))
            chip.addLine(to: CGPoint(x: w * 0.48, y: h * 0.22))
            chip.addLine(to: CGPoint(x: w * 0.30, y: h * 0.16))
            chip.closeSubpath()
            ctx.fill(chip, with: .color(color.opacity(0.7)))
        }
        .frame(width: size, height: size)
    }
}

struct RegisterMark: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            let rows: [[(Double, Double)]] = [[(0.10, 0.40), (0.52, 0.38)], [(0.30, 0.40), (0.72, 0.18)], [(0.12, 0.34), (0.48, 0.42)]]
            for (r, row) in rows.enumerated() {
                let y = h * (0.20 + Double(r) * 0.24)
                for (x, wd) in row {
                    let rect = CGRect(x: w * x, y: y, width: w * wd, height: h * 0.20)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: w * 0.03), with: .color(color.opacity(r == 1 ? 0.55 : 0.85)))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

struct FieldMark: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            var ground = Path()
            ground.move(to: CGPoint(x: 0, y: h * 0.70))
            ground.addQuadCurve(to: CGPoint(x: w, y: h * 0.62), control: CGPoint(x: w * 0.5, y: h * 0.48))
            ctx.stroke(ground, with: .color(color.opacity(0.6)), lineWidth: w * 0.05)
            for k in 0..<3 {
                let x = w * (0.12 + Double(k) * 0.30)
                let rect = CGRect(x: x, y: h * 0.50 - Double(k) * h * 0.03, width: w * 0.22, height: h * 0.22)
                ctx.fill(Path(rect), with: .color(color))
                var joint = Path()
                joint.move(to: CGPoint(x: x, y: rect.midY))
                joint.addLine(to: CGPoint(x: x + w * 0.22, y: rect.midY))
                ctx.stroke(joint, with: .color(Fell.page.opacity(0.7)), lineWidth: w * 0.03)
            }
            ctx.fill(Path(ellipseIn: CGRect(x: w * 0.62, y: h * 0.78, width: w * 0.16, height: h * 0.10)), with: .color(color.opacity(0.7)))
            ctx.fill(Path(ellipseIn: CGRect(x: w * 0.30, y: h * 0.80, width: w * 0.14, height: h * 0.09)), with: .color(color.opacity(0.7)))
        }
        .frame(width: size, height: size)
    }
}

struct BookMark: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            var left = Path()
            left.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
            left.addQuadCurve(to: CGPoint(x: w * 0.10, y: h * 0.18), control: CGPoint(x: w * 0.30, y: h * 0.10))
            left.addLine(to: CGPoint(x: w * 0.10, y: h * 0.80))
            left.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.86), control: CGPoint(x: w * 0.30, y: h * 0.74))
            left.closeSubpath()
            var right = Path()
            right.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
            right.addQuadCurve(to: CGPoint(x: w * 0.90, y: h * 0.18), control: CGPoint(x: w * 0.70, y: h * 0.10))
            right.addLine(to: CGPoint(x: w * 0.90, y: h * 0.80))
            right.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.86), control: CGPoint(x: w * 0.70, y: h * 0.74))
            right.closeSubpath()
            ctx.fill(left, with: .color(color.opacity(0.22)))
            ctx.fill(right, with: .color(color.opacity(0.22)))
            ctx.stroke(left, with: .color(color), lineWidth: w * 0.06)
            ctx.stroke(right, with: .color(color), lineWidth: w * 0.06)
            for k in 0..<3 {
                let y = h * (0.36 + Double(k) * 0.14)
                var line = Path()
                line.move(to: CGPoint(x: w * 0.20, y: y))
                line.addLine(to: CGPoint(x: w * 0.42, y: y + h * 0.02))
                line.move(to: CGPoint(x: w * 0.58, y: y + h * 0.02))
                line.addLine(to: CGPoint(x: w * 0.80, y: y))
                ctx.stroke(line, with: .color(color.opacity(0.7)), lineWidth: w * 0.035)
            }
        }
        .frame(width: size, height: size)
    }
}

struct ChevGlyph: View {
    var size: CGFloat
    var color: Color
    var back: Bool = true
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            var p = Path()
            if back {
                p.move(to: CGPoint(x: w * 0.68, y: h * 0.14))
                p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.50))
                p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.86))
            } else {
                p.move(to: CGPoint(x: w * 0.32, y: h * 0.14))
                p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.50))
                p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.86))
            }
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: w * 0.13, lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

struct CrossGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            var p = Path()
            p.move(to: CGPoint(x: w * 0.2, y: h * 0.2))
            p.addLine(to: CGPoint(x: w * 0.8, y: h * 0.8))
            p.move(to: CGPoint(x: w * 0.8, y: h * 0.2))
            p.addLine(to: CGPoint(x: w * 0.2, y: h * 0.8))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: w * 0.13, lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}

struct TickGlyph: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            var p = Path()
            p.move(to: CGPoint(x: w * 0.16, y: h * 0.54))
            p.addLine(to: CGPoint(x: w * 0.40, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.26))
            ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: w * 0.14, lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

struct GearMark: View {
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            for k in 0..<3 {
                let y = h * (0.28 + Double(k) * 0.22)
                var line = Path()
                line.move(to: CGPoint(x: w * 0.16, y: y))
                line.addLine(to: CGPoint(x: w * 0.84, y: y))
                ctx.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: w * 0.09, lineCap: .round))
                let kx = w * [0.62, 0.34, 0.50][k]
                ctx.fill(Path(ellipseIn: CGRect(x: kx - w * 0.09, y: y - w * 0.09, width: w * 0.18, height: w * 0.18)), with: .color(color))
                ctx.fill(Path(ellipseIn: CGRect(x: kx - w * 0.045, y: y - w * 0.045, width: w * 0.09, height: w * 0.09)), with: .color(Fell.card))
            }
        }
        .frame(width: size, height: size)
    }
}

struct StageMark: View {
    var stage: BuildStage
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            switch stage {
            case .strip:
                var blade = Path()
                blade.move(to: CGPoint(x: w * 0.30, y: h * 0.50))
                blade.addLine(to: CGPoint(x: w * 0.70, y: h * 0.50))
                blade.addLine(to: CGPoint(x: w * 0.62, y: h * 0.90))
                blade.addLine(to: CGPoint(x: w * 0.38, y: h * 0.90))
                blade.closeSubpath()
                ctx.fill(blade, with: .color(color))
                var shaft = Path()
                shaft.move(to: CGPoint(x: w * 0.50, y: h * 0.50))
                shaft.addLine(to: CGPoint(x: w * 0.50, y: h * 0.10))
                ctx.stroke(shaft, with: .color(color), style: StrokeStyle(lineWidth: w * 0.10, lineCap: .round))
            case .footings:
                ctx.fill(Path(roundedRect: CGRect(x: w * 0.10, y: h * 0.52, width: w * 0.80, height: h * 0.34), cornerRadius: w * 0.04), with: .color(color))
                var ground = Path()
                ground.move(to: CGPoint(x: 0, y: h * 0.90))
                ground.addLine(to: CGPoint(x: w, y: h * 0.90))
                ctx.stroke(ground, with: .color(color.opacity(0.5)), lineWidth: w * 0.05)
            case .courses:
                for k in 0..<3 {
                    let y = h * (0.18 + Double(k) * 0.26)
                    let off = k % 2 == 0 ? 0.0 : 0.16
                    ctx.fill(Path(roundedRect: CGRect(x: w * (0.08 + off), y: y, width: w * 0.36, height: h * 0.20), cornerRadius: w * 0.03), with: .color(color))
                    ctx.fill(Path(roundedRect: CGRect(x: w * (0.50 + off), y: y, width: w * 0.36, height: h * 0.20), cornerRadius: w * 0.03), with: .color(color))
                }
            case .throughs:
                ctx.fill(Path(roundedRect: CGRect(x: w * 0.04, y: h * 0.40, width: w * 0.92, height: h * 0.22), cornerRadius: w * 0.03), with: .color(color))
                ctx.fill(Path(roundedRect: CGRect(x: w * 0.20, y: h * 0.14, width: w * 0.60, height: h * 0.20), cornerRadius: w * 0.03), with: .color(color.opacity(0.5)))
                ctx.fill(Path(roundedRect: CGRect(x: w * 0.20, y: h * 0.68, width: w * 0.60, height: h * 0.20), cornerRadius: w * 0.03), with: .color(color.opacity(0.5)))
            case .cope:
                for k in 0..<4 {
                    let x = w * (0.10 + Double(k) * 0.22)
                    ctx.fill(Path(roundedRect: CGRect(x: x, y: h * (k % 2 == 0 ? 0.16 : 0.30), width: w * 0.16, height: h * (k % 2 == 0 ? 0.44 : 0.30)), cornerRadius: w * 0.03), with: .color(color))
                }
                ctx.fill(Path(roundedRect: CGRect(x: w * 0.06, y: h * 0.66, width: w * 0.88, height: h * 0.22), cornerRadius: w * 0.03), with: .color(color.opacity(0.5)))
            case .test:
                var arrow = Path()
                arrow.move(to: CGPoint(x: w * 0.08, y: h * 0.50))
                arrow.addLine(to: CGPoint(x: w * 0.56, y: h * 0.50))
                ctx.stroke(arrow, with: .color(color), style: StrokeStyle(lineWidth: w * 0.10, lineCap: .round))
                var tip = Path()
                tip.move(to: CGPoint(x: w * 0.44, y: h * 0.32))
                tip.addLine(to: CGPoint(x: w * 0.62, y: h * 0.50))
                tip.addLine(to: CGPoint(x: w * 0.44, y: h * 0.68))
                ctx.stroke(tip, with: .color(color), style: StrokeStyle(lineWidth: w * 0.10, lineCap: .round, lineJoin: .round))
                ctx.fill(Path(roundedRect: CGRect(x: w * 0.68, y: h * 0.22, width: w * 0.26, height: h * 0.56), cornerRadius: w * 0.03), with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

struct TestMark: View {
    var kind: TestKind
    var size: CGFloat
    var color: Color
    var body: some View {
        Canvas { ctx, area in
            let w = Double(area.width), h = Double(area.height)
            switch kind {
            case .frost:
                for k in 0..<3 {
                    let a = Double(k) * .pi / 3
                    var line = Path()
                    line.move(to: CGPoint(x: w * 0.5 - cos(a) * w * 0.40, y: h * 0.5 - sin(a) * h * 0.40))
                    line.addLine(to: CGPoint(x: w * 0.5 + cos(a) * w * 0.40, y: h * 0.5 + sin(a) * h * 0.40))
                    ctx.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: w * 0.09, lineCap: .round))
                }
            case .sheep:
                ctx.fill(Path(ellipseIn: CGRect(x: w * 0.12, y: h * 0.30, width: w * 0.66, height: h * 0.40)), with: .color(color))
                ctx.fill(Path(ellipseIn: CGRect(x: w * 0.68, y: h * 0.26, width: w * 0.22, height: h * 0.26)), with: .color(color.opacity(0.8)))
                for x in [0.24, 0.40, 0.56, 0.68] {
                    ctx.fill(Path(CGRect(x: w * x, y: h * 0.64, width: w * 0.06, height: h * 0.22)), with: .color(color))
                }
            case .wind:
                for k in 0..<3 {
                    let y = h * (0.28 + Double(k) * 0.22)
                    var line = Path()
                    line.move(to: CGPoint(x: w * 0.10, y: y))
                    line.addQuadCurve(to: CGPoint(x: w * (0.90 - Double(k) * 0.12), y: y), control: CGPoint(x: w * 0.5, y: y - h * 0.10))
                    ctx.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: w * 0.09, lineCap: .round))
                }
            case .century:
                ctx.stroke(Path(ellipseIn: CGRect(x: w * 0.12, y: h * 0.12, width: w * 0.76, height: h * 0.76)), with: .color(color), lineWidth: w * 0.08)
                var hand = Path()
                hand.move(to: CGPoint(x: w * 0.5, y: h * 0.5))
                hand.addLine(to: CGPoint(x: w * 0.5, y: h * 0.24))
                hand.move(to: CGPoint(x: w * 0.5, y: h * 0.5))
                hand.addLine(to: CGPoint(x: w * 0.70, y: h * 0.60))
                ctx.stroke(hand, with: .color(color), style: StrokeStyle(lineWidth: w * 0.08, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}
