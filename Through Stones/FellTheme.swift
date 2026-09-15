import SwiftUI

enum Fell {
    static let page = Color(red: 0.933, green: 0.910, blue: 0.855)
    static let pageDeep = Color(red: 0.867, green: 0.835, blue: 0.770)
    static let card = Color(red: 0.965, green: 0.953, blue: 0.918)
    static let ink = Color(red: 0.118, green: 0.106, blue: 0.094)
    static let inkSoft = Color(red: 0.290, green: 0.262, blue: 0.231)
    static let inkFaint = Color(red: 0.500, green: 0.463, blue: 0.420)
    static let stone = Color(red: 0.549, green: 0.541, blue: 0.510)
    static let stoneDark = Color(red: 0.360, green: 0.352, blue: 0.325)
    static let stoneLight = Color(red: 0.720, green: 0.710, blue: 0.675)
    static let grit = Color(red: 0.478, green: 0.369, blue: 0.267)
    static let gritDeep = Color(red: 0.310, green: 0.235, blue: 0.165)
    static let moss = Color(red: 0.369, green: 0.478, blue: 0.275)
    static let mossDeep = Color(red: 0.230, green: 0.330, blue: 0.170)
    static let lichen = Color(red: 0.725, green: 0.702, blue: 0.408)
    static let sky = Color(red: 0.655, green: 0.737, blue: 0.788)
    static let dusk = Color(red: 0.788, green: 0.541, blue: 0.353)
    static let rubric = Color(red: 0.640, green: 0.196, blue: 0.160)
    static let good = Color(red: 0.302, green: 0.447, blue: 0.318)
    static let query = Color(red: 0.694, green: 0.478, blue: 0.180)
    static let grass = Color(red: 0.490, green: 0.560, blue: 0.330)
    static let grassDeep = Color(red: 0.330, green: 0.420, blue: 0.230)
    static let earth = Color(red: 0.400, green: 0.310, blue: 0.220)
    static let wood = Color(red: 0.560, green: 0.430, blue: 0.290)
    static let woodDark = Color(red: 0.330, green: 0.240, blue: 0.150)
    static let string = Color(red: 0.95, green: 0.90, blue: 0.70)

    static func title(_ size: CGFloat) -> Font { .custom("Copperplate-Bold", size: size) }
    static func body(_ size: CGFloat) -> Font { .custom("Georgia", size: size) }
    static func bodyBold(_ size: CGFloat) -> Font { .custom("Georgia-Bold", size: size) }
    static func note(_ size: CGFloat) -> Font { .custom("Georgia-Italic", size: size) }

    static var isPad: Bool { UIScreen.main.bounds.width >= 700 }
    static var isNarrow: Bool { UIScreen.main.bounds.width <= 340 }
    static var gutter: CGFloat { isPad ? 32 : (isNarrow ? 12 : 17) }
    static var plateHeight: CGFloat { isPad ? 300 : 206 }
}

enum Knock {
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func firm() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func hard() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    static func crisp() { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
    static func soft() { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
}

struct RiseIn: ViewModifier {
    let index: Int
    @State private var shown = false
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 14)
            .onAppear {
                withAnimation(.easeOut(duration: 0.38).delay(Double(index) * 0.05)) { shown = true }
            }
    }
}

extension View {
    func rising(_ index: Int) -> some View { modifier(RiseIn(index: index)) }
}

extension Color {
    static func blend(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let ua = UIColor(a), ub = UIColor(b)
        var r0: CGFloat = 0, g0: CGFloat = 0, b0: CGFloat = 0, a0: CGFloat = 0
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        ua.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
        ub.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        let k = CGFloat(max(0, min(1, t)))
        return Color(red: Double(r0 + (r1 - r0) * k), green: Double(g0 + (g1 - g0) * k),
                     blue: Double(b0 + (b1 - b0) * k), opacity: Double(a0 + (a1 - a0) * k))
    }

    static func grey(_ v: Double) -> Color { Color(red: v, green: v, blue: v) }
}

enum Words {
    static func metres(_ m: Double) -> String {
        if m >= 1 {
            let text = String(format: "%.2f", m)
            return text.replacingOccurrences(of: ".00", with: "") + " m"
        }
        return "\(Int((m * 100).rounded())) cm"
    }

    static func centimetres(_ m: Double) -> String { "\(Int((m * 100).rounded())) cm" }

    static func percent(_ v: Double) -> String { "\(Int((v * 100).rounded())) %" }

    static func days(_ n: Int) -> String {
        switch n {
        case 0: return "today"
        case 1: return "yesterday"
        case 2..<30: return "\(n) days ago"
        case 30..<365: return "\(n / 30) month\(n / 30 == 1 ? "" : "s") ago"
        default: return "\(n / 365) year\(n / 365 == 1 ? "" : "s") ago"
        }
    }
}
