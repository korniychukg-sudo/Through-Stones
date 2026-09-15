import SwiftUI

struct LessonSheet: View {
    @EnvironmentObject var store: DykeStore
    var index: Int
    var onClose: () -> Void
    @State private var current: Int
    @State private var openTerm: GlossEntry? = nil

    init(index: Int, onClose: @escaping () -> Void) {
        self.index = index
        self.onClose = onClose
        _current = State(initialValue: index)
    }

    var body: some View {
        let lesson = Lessons.lesson(current)
        let read = (store.ledger.readLessons ?? []).contains(current)
        return ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: lesson.title, subtitle: "Lesson \(current + 1) of \(Lessons.all.count): \(lesson.sub)") { onClose() }
                ScrollView {
                    Column {
                        SheetCard(padding: 9) { PlateBox(name: lesson.plate, height: Fell.isPad ? 340 : 226) }
                            .id("plate\(current)")
                        SheetCard {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(lesson.text.components(separatedBy: "\n\n").enumerated()), id: \.offset) { i, para in
                                    Text(para)
                                        .font(Fell.body(i == 0 ? 14.5 : 13.5))
                                        .foregroundColor(i == 0 ? Fell.ink : Fell.inkSoft)
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Text("\(lesson.words) words").font(Fell.note(11)).foregroundColor(Fell.inkFaint)
                            }
                        }
                        let terms = relatedTerms(lesson)
                        if !terms.isEmpty {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 9) {
                                    HeadRule(text: "Words in this lesson")
                                    FlowTerms(terms: terms) { openTerm = $0 }
                                }
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    if read {
                                        StampTag(text: "read", tone: Fell.good)
                                        Text("Six points were awarded for this lesson.").font(Fell.note(12)).foregroundColor(Fell.inkFaint)
                                    } else {
                                        Text("Reading a lesson to the end is worth six points, once.").font(Fell.note(12)).foregroundColor(Fell.inkFaint)
                                    }
                                    Spacer(minLength: 0)
                                }
                                if !read {
                                    SealButton(title: "Read and understood", tone: Fell.moss) { store.markLesson(current) }
                                }
                                HStack(spacing: 10) {
                                    SealButton(title: "Previous", tone: Fell.inkSoft, filled: false, enabled: current > 0) { turn(-1) }
                                    SealButton(title: "Next lesson", tone: Fell.grit, filled: true, enabled: current + 1 < Lessons.all.count) { turn(1) }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(item: $openTerm) { entry in
            TermSheet(entry: entry) { openTerm = nil }.environmentObject(store)
        }
    }

    private func turn(_ d: Int) {
        let next = current + d
        guard next >= 0 && next < Lessons.all.count else { return }
        withAnimation(.easeOut(duration: 0.25)) { current = next }
    }

    private func relatedTerms(_ lesson: Lesson) -> [GlossEntry] {
        let lower = lesson.text.lowercased()
        var out: [GlossEntry] = []
        for entry in Lexicon.entries {
            let t = entry.term.lowercased()
            if t.count >= 4 && lower.contains(t) { out.append(entry) }
            if out.count >= 12 { break }
        }
        return out
    }
}

struct FlowTerms: View {
    var terms: [GlossEntry]
    var onTap: (GlossEntry) -> Void

    var body: some View {
        let rows = split(terms, per: Fell.isPad ? 4 : 3)
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 6) {
                    ForEach(row) { entry in
                        Button(action: { Knock.light(); onTap(entry) }) {
                            Text(entry.term)
                                .font(Fell.title(10.5))
                                .foregroundColor(Fell.ink)
                                .lineLimit(1)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 6)
                                .background(Fell.pageDeep)
                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(Fell.ink.opacity(0.2), lineWidth: 0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func split(_ list: [GlossEntry], per: Int) -> [[GlossEntry]] {
        var rows: [[GlossEntry]] = []
        var row: [GlossEntry] = []
        var width = 0
        for e in list {
            let w = e.term.count + 4
            if width + w > per * 9 && !row.isEmpty { rows.append(row); row = []; width = 0 }
            row.append(e)
            width += w
        }
        if !row.isEmpty { rows.append(row) }
        return rows
    }
}

struct TermSheet: View {
    @EnvironmentObject var store: DykeStore
    var entry: GlossEntry
    var onClose: () -> Void

    var body: some View {
        let lessons = Lessons.all.filter { $0.text.lowercased().contains(entry.term.lowercased()) }
        let related = Lexicon.entries.filter { $0.term != entry.term && $0.means.lowercased().contains(entry.term.lowercased()) }.prefix(6)
        return ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: entry.term, subtitle: "From the glossary") { onClose() }
                ScrollView {
                    Column {
                        SheetCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(entry.means).font(Fell.body(15)).foregroundColor(Fell.ink).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
                                if (store.ledger.readTerms ?? []).contains(entry.term) { StampTag(text: "read", tone: Fell.good) }
                            }
                        }
                        if let plate = termPlate {
                            SheetCard(padding: 9) { PlateBox(name: plate, height: Fell.isPad ? 300 : 200) }
                        }
                        if !lessons.isEmpty {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HeadRule(text: "In the lessons")
                                    ForEach(lessons) { lesson in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("\(lesson.index + 1).").font(Fell.title(12)).foregroundColor(Fell.grit)
                                            Text(lesson.title).font(Fell.body(13)).foregroundColor(Fell.inkSoft)
                                        }
                                    }
                                }
                            }
                        }
                        if !related.isEmpty {
                            SheetCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HeadRule(text: "See also")
                                    ForEach(Array(related)) { other in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(other.term).font(Fell.title(12)).foregroundColor(Fell.ink)
                                            Text(other.means).font(Fell.body(12)).foregroundColor(Fell.inkSoft).lineLimit(3).fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear { store.markTerm(entry.term) }
    }

    private var termPlate: String? {
        let t = entry.term.lowercased()
        let pairs: [(String, String)] = [
            ("batter", "tl_frame"), ("frame", "tl_frame"), ("through", "st_gritstone_through"), ("cope", "st_gritstone_cope"), ("hearting", "st_gritstone_hearting"),
            ("footing", "st_gritstone_footing"), ("pinning", "ft_pinFront"), ("running joint", "ft_runningJoint"), ("traced", "ft_traced"), ("on edge", "ft_onEdge"),
            ("face-bedded", "ft_faceBedded"), ("belly", "ft_belly"), ("lunky", "fe_lunky"), ("stile", "fe_stepStile"), ("squeeze", "fe_squeezeStile"), ("bee bole", "fe_beeBole"),
            ("head", "fe_cheekEnd"), ("cheek", "fe_cheekEnd"), ("lintel", "fe_lunky"), ("hedge", "sy_face_cornish"), ("feidin", "sy_face_aran"), ("dyke", "sy_face_galloway"),
            ("flag", "sy_face_caithness"), ("line", "tl_line"), ("hammer", "tl_hammer"), ("bar", "tl_bar"), ("chisel", "tl_chisel"), ("lump", "tl_lump"), ("turf", "sy_sec_cornish"),
            ("lichen", "wx_grit_fifty"), ("string", "tl_line"), ("gate", "fe_gatePost"), ("retaining", "fe_retaining"), ("corner", "fe_corner"), ("curve", "fe_curve"), ("slope", "fe_slope")
        ]
        for (key, plate) in pairs where t.contains(key) { return Plates.exists(plate) ? plate : nil }
        return nil
    }
}
