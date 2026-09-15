import SwiftUI

enum Plates {
    private static var cache: [String: UIImage] = [:]

    static func load(_ name: String) -> UIImage? {
        if let hit = cache[name] { return hit }
        guard let path = Bundle.main.path(forResource: name, ofType: "jpg", inDirectory: "Art"),
              let image = UIImage(contentsOfFile: path) else { return nil }
        if cache.count > 36 { cache.removeAll() }
        cache[name] = image
        return image
    }

    static func exists(_ name: String) -> Bool {
        Bundle.main.path(forResource: name, ofType: "jpg", inDirectory: "Art") != nil
    }
}

struct PlateBox: View {
    let name: String
    var height: CGFloat = 0
    var corner: CGFloat = 4
    var fit: Bool = false
    var aspect: CGFloat? = nil

    var body: some View {
        Group {
            if let aspect = aspect {
                Color.clear
                    .aspectRatio(aspect, contentMode: .fit)
                    .overlay(picture)
                    .frame(maxWidth: .infinity)
            } else {
                Color.clear
                    .overlay(picture)
                    .frame(height: height)
            }
        }
        .clipped()
        .cornerRadius(corner)
        .overlay(RoundedRectangle(cornerRadius: corner).stroke(Fell.ink.opacity(0.16), lineWidth: 0.8))
    }

    private var picture: some View {
        Group {
            if let image = Plates.load(name) {
                if fit {
                    Image(uiImage: image).resizable().scaledToFit()
                } else {
                    Image(uiImage: image).resizable().scaledToFill()
                }
            } else {
                Fell.pageDeep
            }
        }
    }
}

struct SheetCard<Content: View>: View {
    var padding: CGFloat = 15
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 7)
                    .fill(Fell.card)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Fell.ink.opacity(0.13), lineWidth: 0.9))
                    .shadow(color: Fell.ink.opacity(0.07), radius: 5, x: 0, y: 3)
            )
    }
}

struct HeadRule: View {
    let text: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 9) {
            Text(text.uppercased())
                .font(Fell.title(11.5))
                .tracking(1.6)
                .foregroundColor(Fell.inkSoft)
                .fixedSize(horizontal: true, vertical: false)
            Rectangle().fill(Fell.ink.opacity(0.17)).frame(height: 0.8)
            if let trailing = trailing {
                Text(trailing)
                    .font(Fell.body(11.5))
                    .foregroundColor(Fell.inkFaint)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
    }
}

struct SealButton: View {
    let title: String
    var tone: Color = Fell.ink
    var filled: Bool = true
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: { if enabled { Knock.light(); action() } }) {
            Text(title)
                .font(Fell.title(14))
                .tracking(0.6)
                .foregroundColor(filled ? Fell.card : tone)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(filled ? tone : Color.clear)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(tone.opacity(filled ? 0 : 0.55), lineWidth: 1.1))
                )
                .opacity(enabled ? 1 : 0.42)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct MeterBar: View {
    var label: String
    var value: Double
    var tone: Color = Fell.moss
    var caption: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label).font(Fell.body(12.5)).foregroundColor(Fell.inkSoft)
                Spacer()
                Text("\(Int(min(1, max(0, value)) * 100))").font(Fell.title(12.5)).foregroundColor(Fell.ink)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Fell.ink.opacity(0.10))
                    Capsule().fill(tone).frame(width: max(2, geo.size.width * CGFloat(min(1, max(0, value)))))
                }
            }
            .frame(height: 6)
            if let caption = caption {
                Text(caption).font(Fell.note(11)).foregroundColor(Fell.inkFaint)
            }
        }
    }
}

struct NoticeBar: View {
    var text: String
    var tone: Color = Fell.query
    var action: (String, () -> Void)? = nil

    var body: some View {
        HStack(spacing: 11) {
            Rectangle().fill(tone).frame(width: 3)
            Text(text)
                .font(Fell.body(12.5))
                .foregroundColor(Fell.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 4)
            if let action = action {
                Button(action: { Knock.light(); action.1() }) {
                    Text(action.0)
                        .font(Fell.title(11))
                        .foregroundColor(tone)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(tone.opacity(0.6), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 6).fill(tone.opacity(0.09)))
    }
}

struct SheetHead: View {
    var title: String
    var subtitle: String? = nil
    var onClose: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(Fell.title(18)).foregroundColor(Fell.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle = subtitle {
                    Text(subtitle).font(Fell.note(12.5)).foregroundColor(Fell.inkFaint)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 10)
            Button(action: { Knock.light(); onClose() }) {
                CrossGlyph(size: 16, color: Fell.inkSoft)
                    .padding(9)
                    .background(Circle().fill(Fell.ink.opacity(0.07)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Fell.gutter)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }
}

struct CountTile: View {
    var value: String
    var label: String
    var tone: Color = Fell.ink

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(Fell.title(16))
                .foregroundColor(tone)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label.uppercased())
                .font(Fell.body(8.5))
                .tracking(1.0)
                .foregroundColor(Fell.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 6).fill(Fell.ink.opacity(0.045)))
    }
}

struct StampTag: View {
    var text: String
    var tone: Color
    var body: some View {
        Text(text.uppercased())
            .font(Fell.title(9))
            .tracking(1.3)
            .foregroundColor(tone)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(tone.opacity(0.7), lineWidth: 1))
    }
}

struct Column<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: 15) { content() }
                .frame(maxWidth: Fell.isPad ? 700 : .infinity)
            Spacer(minLength: 0)
        }
    }
}

struct BandPicker: View {
    var titles: [String]
    @Binding var index: Int
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(titles.enumerated()), id: \.offset) { i, title in
                Button(action: { Knock.light(); withAnimation(.easeOut(duration: 0.2)) { index = i } }) {
                    Text(title)
                        .font(Fell.title(10.5))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .foregroundColor(index == i ? Fell.card : Fell.inkSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 5).fill(index == i ? Fell.ink : Fell.ink.opacity(0.06)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ScoreWord: View {
    var score: Int
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(score)").font(Fell.title(30)).foregroundColor(scoreTone(score))
            Text(WallReport.word(for: score)).font(Fell.note(15)).foregroundColor(Fell.inkSoft)
        }
    }
}

func scoreTone(_ score: Int) -> Color {
    switch WallReport.grade(for: score) {
    case 0: return Fell.rubric
    case 1: return Fell.query
    case 2: return Fell.moss
    default: return Fell.good
    }
}

struct Celebration: View {
    var title: String
    var lines: [String]
    var button: String
    var onDone: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea().onTapGesture { onDone() }
            VStack(spacing: 14) {
                Text(title).font(Fell.title(22)).foregroundColor(Fell.ink).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(lines, id: \.self) { line in
                    Text(line).font(Fell.body(13.5)).foregroundColor(Fell.inkSoft).multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                SealButton(title: button, tone: Fell.grit) { onDone() }
            }
            .padding(22)
            .frame(maxWidth: 360)
            .background(RoundedRectangle(cornerRadius: 10).fill(Fell.card).shadow(color: .black.opacity(0.3), radius: 14, x: 0, y: 8))
            .padding(24)
        }
    }
}
