import SwiftUI

struct BookView: View {
    @EnvironmentObject var store: DykeStore
    @State private var section = 0
    @State private var openLesson: LessonPick? = nil
    @State private var openTerm: GlossEntry? = nil
    @State private var openExam = false
    @State private var search = ""

    var body: some View {
        ScrollView {
            Column {
                SheetCard(padding: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HeadRule(text: "The waller's book", trailing: "\(store.lessonsRead)/\(Lessons.all.count) lessons")
                        Text("Twelve lessons in the craft, a glossary of the words a waller uses, an examination set fresh each day, and the badges the guild gives for work on the bank.")
                            .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                    }
                }
                BandPicker(titles: ["Lessons", "Glossary", "Examination", "Badges"], index: $section)
                switch section {
                case 0: lessons
                case 1: glossary
                case 2: examination
                default: badges
                }
            }
            .padding(.horizontal, Fell.gutter)
            .padding(.bottom, 28)
        }
        .background(Fell.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Text("The Book").font(Fell.title(17)).foregroundColor(Fell.ink) }
        }
        .onAppear { section = store.section("book") }
        .onChange(of: section) { value in store.remember("book", value) }
        .sheet(item: $openLesson) { pick in
            LessonSheet(index: pick.id) { openLesson = nil }.environmentObject(store)
        }
        .sheet(item: $openTerm) { entry in
            TermSheet(entry: entry) { openTerm = nil }.environmentObject(store)
        }
        .fullScreenCover(isPresented: $openExam) {
            ExamView { openExam = false }.environmentObject(store)
        }
    }

    private var lessons: some View {
        VStack(spacing: 12) {
            ForEach(Lessons.all) { lesson in
                let read = (store.ledger.readLessons ?? []).contains(lesson.index)
                Button(action: { Knock.light(); openLesson = LessonPick(id: lesson.index) }) {
                    SheetCard(padding: 11) {
                        HStack(alignment: .top, spacing: 10) {
                            PlateBox(name: lesson.plate, height: 86).frame(width: 126)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text("\(lesson.index + 1).").font(Fell.title(12)).foregroundColor(Fell.grit)
                                    Text(lesson.title).font(Fell.title(13)).foregroundColor(Fell.ink).lineLimit(2)
                                    Spacer(minLength: 4)
                                    if read { TickGlyph(size: 14, color: Fell.good) }
                                }
                                Text(lesson.sub).font(Fell.note(12)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                                Text("\(lesson.words) words").font(Fell.body(11)).foregroundColor(Fell.inkFaint)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var filteredTerms: [GlossEntry] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        let all = Lexicon.entries.sorted { $0.term.lowercased() < $1.term.lowercased() }
        if q.isEmpty { return all }
        return all.filter { $0.term.lowercased().contains(q) || $0.means.lowercased().contains(q) }
    }

    private var glossary: some View {
        VStack(spacing: 12) {
            SheetCard(padding: 10) {
                HStack(spacing: 8) {
                    Text("Find").font(Fell.title(11)).foregroundColor(Fell.inkFaint)
                    TextField("a word, or part of one", text: $search)
                        .font(Fell.body(14))
                        .foregroundColor(Fell.ink)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    if !search.isEmpty {
                        Button(action: { Knock.light(); search = "" }) { CrossGlyph(size: 12, color: Fell.inkSoft) }
                            .buttonStyle(.plain)
                    }
                }
            }
            HStack {
                Text("\(store.termsRead) of \(Lexicon.entries.count) read").font(Fell.note(12)).foregroundColor(Fell.inkFaint)
                Spacer(minLength: 0)
                Text(filteredTerms.count == Lexicon.entries.count ? "" : "\(filteredTerms.count) found").font(Fell.note(12)).foregroundColor(Fell.inkFaint)
            }
            if filteredTerms.isEmpty {
                NoticeBar(text: "No word in the glossary matches that. Try a shorter piece of it.", tone: Fell.query)
            }
            SheetCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(filteredTerms.enumerated()), id: \.element.id) { i, entry in
                        let read = (store.ledger.readTerms ?? []).contains(entry.term)
                        Button(action: { Knock.light(); openTerm = entry }) {
                            HStack(alignment: .top, spacing: 10) {
                                Rectangle().fill(read ? Fell.good : Fell.inkFaint.opacity(0.35)).frame(width: 3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.term).font(Fell.title(12.5)).foregroundColor(Fell.ink)
                                    Text(entry.means).font(Fell.body(12)).foregroundColor(Fell.inkSoft).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 4)
                                ChevGlyph(size: 12, color: Fell.inkFaint, back: false).padding(.top, 4)
                            }
                            .padding(.vertical, 9)
                            .padding(.trailing, 12)
                            .padding(.leading, 0)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if i + 1 < filteredTerms.count {
                            Rectangle().fill(Fell.ink.opacity(0.08)).frame(height: 0.8).padding(.leading, 13)
                        }
                    }
                }
            }
        }
    }

    private var examination: some View {
        VStack(spacing: 12) {
            SheetCard(padding: 9) { PlateBox(name: "ls_2", aspect: 4 / 3) }
            SheetCard {
                VStack(alignment: .leading, spacing: 10) {
                    HeadRule(text: "The examination")
                    Text("Fourteen questions: six from the book, two on the faults, two on the styles, two on the tests and two on the stones. The paper is set fresh for each sitting, and each answer comes with the reason once it is given.")
                        .font(Fell.body(13)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 9) {
                        CountTile(value: store.ledger.examBest.map { "\($0) %" } ?? "none", label: "best", tone: (store.ledger.examBest ?? 0) >= 70 ? Fell.good : Fell.ink)
                        CountTile(value: "\(store.ledger.examsTaken ?? 0)", label: "sittings")
                        CountTile(value: "70 %", label: "to pass")
                    }
                    Text("Seventy percent earns thirty points and the Examined badge; a full paper earns fifty more.").font(Fell.note(12)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                    SealButton(title: "Sit the paper", tone: Fell.grit) { openExam = true }
                }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "What it covers")
                    ForEach(["Bed, face and length, and the four classes of stone", "One over two, running joints and the heads", "Batter, hearting, throughs and pinning", "The copes and the eight regional styles", "The four tests and which faults each one finds"], id: \.self) { line in
                        HStack(alignment: .top, spacing: 8) {
                            Rectangle().fill(Fell.moss).frame(width: 3, height: 14).padding(.top, 3)
                            Text(line).font(Fell.body(13)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private var badges: some View {
        let earned = Badges.list.filter { store.hasBadge($0.0) }.count
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return VStack(spacing: 12) {
            SheetCard(padding: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HeadRule(text: "The guild's badges", trailing: "\(earned) of \(Badges.list.count)")
                    MeterBar(label: "Earned", value: Double(earned) / Double(Badges.list.count), tone: Fell.moss, caption: "Each badge is worth twelve points when it is granted.")
                }
            }
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(Badges.list.enumerated()), id: \.offset) { _, badge in
                    let has = store.hasBadge(badge.0)
                    SheetCard(padding: 11) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                BadgeMark(key: badge.0, size: 34, earned: has)
                                Spacer(minLength: 0)
                                if has { TickGlyph(size: 14, color: Fell.good) }
                            }
                            Text(badge.1).font(Fell.title(12)).foregroundColor(has ? Fell.ink : Fell.inkFaint).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                            Text(badge.2).font(Fell.body(11.5)).foregroundColor(has ? Fell.inkSoft : Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
                    }
                    .opacity(has ? 1 : 0.82)
                }
            }
        }
    }
}

struct BadgeMark: View {
    var key: String
    var size: CGFloat
    var earned: Bool

    var body: some View {
        Canvas { ctx, area in
            let c = CGPoint(x: area.width / 2, y: area.height / 2)
            let r = min(area.width, area.height) / 2
            let ink = earned ? Fell.ink : Fell.inkFaint
            let fill = earned ? Fell.lichen : Fell.pageDeep
            var seal = Path()
            let n = 12
            for i in 0..<(n * 2) {
                let a = Double(i) / Double(n * 2) * .pi * 2
                let rr = i % 2 == 0 ? r : r * 0.86
                let p = CGPoint(x: c.x + CGFloat(cos(a)) * rr, y: c.y + CGFloat(sin(a)) * rr)
                if i == 0 { seal.move(to: p) } else { seal.addLine(to: p) }
            }
            seal.closeSubpath()
            ctx.fill(seal, with: .color(fill))
            ctx.stroke(seal, with: .color(ink.opacity(0.7)), lineWidth: 1)
            let inner = r * 0.5
            var glyph = Path()
            switch key {
            case "first", "standing", "sound", "master":
                let rows = key == "first" ? 1 : (key == "standing" ? 2 : (key == "sound" ? 3 : 4))
                for row in 0..<rows {
                    let y = c.y + inner * 0.7 - CGFloat(row) * inner * 0.45
                    let off: CGFloat = row % 2 == 0 ? 0 : inner * 0.3
                    glyph.addRect(CGRect(x: c.x - inner * 0.8 + off, y: y - inner * 0.2, width: inner * 0.6, height: inner * 0.38))
                    glyph.addRect(CGRect(x: c.x - inner * 0.1 + off, y: y - inner * 0.2, width: inner * 0.6, height: inner * 0.38))
                }
            case "frost":
                for i in 0..<3 {
                    let a = Double(i) * .pi / 3
                    glyph.move(to: CGPoint(x: c.x - CGFloat(cos(a)) * inner, y: c.y - CGFloat(sin(a)) * inner))
                    glyph.addLine(to: CGPoint(x: c.x + CGFloat(cos(a)) * inner, y: c.y + CGFloat(sin(a)) * inner))
                }
            case "century":
                glyph.addEllipse(in: CGRect(x: c.x - inner, y: c.y - inner, width: inner * 2, height: inner * 2))
                glyph.move(to: c)
                glyph.addLine(to: CGPoint(x: c.x, y: c.y - inner * 0.75))
                glyph.move(to: c)
                glyph.addLine(to: CGPoint(x: c.x + inner * 0.55, y: c.y + inner * 0.2))
            case "throughs":
                glyph.addRect(CGRect(x: c.x - inner * 1.1, y: c.y - inner * 0.18, width: inner * 2.2, height: inner * 0.36))
                glyph.addRect(CGRect(x: c.x - inner * 0.7, y: c.y - inner * 0.75, width: inner * 1.4, height: inner * 0.45))
                glyph.addRect(CGRect(x: c.x - inner * 0.7, y: c.y + inner * 0.3, width: inner * 1.4, height: inner * 0.45))
            case "pinner":
                glyph.move(to: CGPoint(x: c.x - inner * 0.9, y: c.y + inner * 0.6))
                glyph.addLine(to: CGPoint(x: c.x + inner * 0.9, y: c.y - inner * 0.6))
                glyph.addLine(to: CGPoint(x: c.x + inner * 0.5, y: c.y - inner * 0.9))
                glyph.closeSubpath()
            case "styles", "features", "stones":
                for i in 0..<4 {
                    let a = Double(i) * .pi / 2 + .pi / 4
                    glyph.addRect(CGRect(x: c.x + CGFloat(cos(a)) * inner * 0.6 - inner * 0.3, y: c.y + CGFloat(sin(a)) * inner * 0.6 - inner * 0.3, width: inner * 0.6, height: inner * 0.6))
                }
            case "efficient":
                glyph.move(to: CGPoint(x: c.x - inner, y: c.y))
                glyph.addLine(to: CGPoint(x: c.x - inner * 0.3, y: c.y + inner * 0.7))
                glyph.addLine(to: CGPoint(x: c.x + inner, y: c.y - inner * 0.8))
            case "rebuilt":
                glyph.move(to: CGPoint(x: c.x - inner, y: c.y + inner * 0.8))
                glyph.addLine(to: CGPoint(x: c.x - inner * 0.2, y: c.y - inner * 0.9))
                glyph.addLine(to: CGPoint(x: c.x + inner * 0.3, y: c.y + inner * 0.1))
                glyph.addLine(to: CGPoint(x: c.x + inner, y: c.y - inner * 0.5))
            case "reader", "scholar", "examined":
                glyph.addRect(CGRect(x: c.x - inner * 0.9, y: c.y - inner * 0.7, width: inner * 0.8, height: inner * 1.4))
                glyph.addRect(CGRect(x: c.x + inner * 0.1, y: c.y - inner * 0.7, width: inner * 0.8, height: inner * 1.4))
                if key != "reader" {
                    glyph.move(to: CGPoint(x: c.x - inner * 0.7, y: c.y - inner * 0.3))
                    glyph.addLine(to: CGPoint(x: c.x - inner * 0.3, y: c.y - inner * 0.3))
                    glyph.move(to: CGPoint(x: c.x - inner * 0.7, y: c.y))
                    glyph.addLine(to: CGPoint(x: c.x - inner * 0.3, y: c.y))
                }
            case "streak":
                for i in 0..<7 {
                    let x = c.x - inner + CGFloat(i) * inner * 2 / 6
                    glyph.move(to: CGPoint(x: x, y: c.y + inner * 0.5))
                    glyph.addLine(to: CGPoint(x: x, y: c.y - inner * (0.2 + 0.1 * CGFloat(i % 3))))
                }
            case "field":
                glyph.move(to: CGPoint(x: c.x - inner, y: c.y + inner * 0.3))
                glyph.addQuadCurve(to: CGPoint(x: c.x + inner, y: c.y + inner * 0.3), control: CGPoint(x: c.x, y: c.y - inner * 0.9))
                glyph.move(to: CGPoint(x: c.x - inner * 0.6, y: c.y + inner * 0.3))
                glyph.addLine(to: CGPoint(x: c.x - inner * 0.6, y: c.y + inner * 0.8))
                glyph.move(to: CGPoint(x: c.x + inner * 0.2, y: c.y + inner * 0.3))
                glyph.addLine(to: CGPoint(x: c.x + inner * 0.2, y: c.y + inner * 0.8))
            case "dawn":
                glyph.addArc(center: CGPoint(x: c.x, y: c.y + inner * 0.4), radius: inner * 0.7, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                glyph.move(to: CGPoint(x: c.x - inner, y: c.y + inner * 0.4))
                glyph.addLine(to: CGPoint(x: c.x + inner, y: c.y + inner * 0.4))
            default:
                glyph.move(to: CGPoint(x: c.x - inner, y: c.y - inner * 0.3))
                glyph.addQuadCurve(to: CGPoint(x: c.x + inner, y: c.y - inner * 0.3), control: CGPoint(x: c.x, y: c.y - inner * 0.9))
                glyph.move(to: CGPoint(x: c.x - inner, y: c.y + inner * 0.4))
                glyph.addQuadCurve(to: CGPoint(x: c.x + inner, y: c.y + inner * 0.4), control: CGPoint(x: c.x, y: c.y - inner * 0.2))
            }
            ctx.stroke(glyph, with: .color(ink), style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
            if ["first", "standing", "sound", "master", "throughs", "styles", "features", "stones", "reader", "scholar", "examined"].contains(key) {
                ctx.fill(glyph, with: .color(ink.opacity(0.18)))
            }
        }
        .frame(width: size, height: size)
    }
}

struct LessonPick: Identifiable {
    var id: Int
}
