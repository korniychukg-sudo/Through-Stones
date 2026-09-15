import SwiftUI

struct ExamView: View {
    @EnvironmentObject var store: DykeStore
    var onClose: () -> Void
    @State private var paper: [ExamQuestion] = []
    @State private var index = 0
    @State private var chosen: Int? = nil
    @State private var right = 0
    @State private var answers: [Bool] = []
    @State private var finished = false
    @State private var recorded = false
    @State private var askLeave = false

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: finished ? "The paper marked" : "Question \(min(index + 1, max(paper.count, 1))) of \(paper.count)", subtitle: finished ? nil : "\(right) right so far") {
                    if finished || answers.isEmpty { onClose() } else { askLeave = true }
                }
                progress
                ScrollView {
                    Column {
                        if finished {
                            results
                        } else if index < paper.count {
                            question(paper[index])
                                .id("q\(index)")
                                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            if paper.isEmpty {
                paper = Examiner.paper(seed: seedOf("exam.\(store.today).\((store.ledger.examsTaken ?? 0))"))
            }
        }
        .alert("Leave the paper?", isPresented: $askLeave) {
            Button("Keep going", role: .cancel) {}
            Button("Leave it unmarked", role: .destructive) { onClose() }
        } message: {
            Text("An unfinished paper is not recorded. The next sitting sets a fresh one.")
        }
    }

    private var progress: some View {
        HStack(spacing: 3) {
            ForEach(0..<max(paper.count, 1), id: \.self) { i in
                Rectangle()
                    .fill(i < answers.count ? (answers[i] ? Fell.good : Fell.rubric) : (i == index && !finished ? Fell.grit : Fell.inkFaint.opacity(0.3)))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, Fell.gutter)
        .padding(.bottom, 10)
    }

    private func question(_ q: ExamQuestion) -> some View {
        VStack(spacing: 12) {
            if let plate = q.plate, Plates.exists(plate) {
                SheetCard(padding: 9) { PlateBox(name: plate, aspect: 4 / 3) }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        StampTag(text: kindWord(q.kind), tone: Fell.grit)
                        Spacer(minLength: 0)
                    }
                    Text(q.prompt).font(Fell.body(15)).foregroundColor(Fell.ink).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                }
            }
            VStack(spacing: 8) {
                ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                    Button(action: { choose(i, q) }) {
                        HStack(alignment: .top, spacing: 10) {
                            Text(["A", "B", "C", "D"][min(i, 3)]).font(Fell.title(12)).foregroundColor(optionInk(i, q)).frame(width: 18)
                            Text(option).font(Fell.body(13.5)).foregroundColor(optionInk(i, q)).fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            if chosen != nil {
                                if i == q.answer { TickGlyph(size: 15, color: Fell.good) }
                                else if i == chosen { CrossGlyph(size: 13, color: Fell.rubric) }
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(optionFill(i, q))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(optionStroke(i, q), lineWidth: 1))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(chosen != nil)
                }
            }
            if let c = chosen {
                SheetCard {
                    VStack(alignment: .leading, spacing: 9) {
                        HeadRule(text: c == q.answer ? "Right" : "Not that one", trailing: c == q.answer ? "one point" : nil)
                        Text(q.why).font(Fell.body(13.5)).foregroundColor(Fell.inkSoft).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                        SealButton(title: index + 1 < paper.count ? "Next question" : "Mark the paper", tone: Fell.grit) { advance() }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    private var results: some View {
        let total = max(paper.count, 1)
        let pct = right * 100 / total
        let passed = pct >= 70
        return VStack(spacing: 12) {
            SheetCard(padding: 9) { PlateBox(name: passed ? "dc_gate" : "dc_frame", aspect: 4 / 3) }
            SheetCard {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(right) of \(total)").font(Fell.title(30)).foregroundColor(passed ? Fell.good : Fell.rubric)
                        Text("\(pct) percent").font(Fell.note(15)).foregroundColor(Fell.inkSoft)
                    }
                    Text(verdict(pct)).font(Fell.body(13.5)).foregroundColor(Fell.inkSoft).lineSpacing(2).fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 9) {
                        CountTile(value: passed ? (pct == 100 ? "+80" : "+30") : "0", label: "points", tone: passed ? Fell.good : Fell.inkFaint)
                        CountTile(value: "\(store.ledger.examBest ?? pct) %", label: "best", tone: Fell.ink)
                        CountTile(value: "\(store.ledger.examsTaken ?? 1)", label: "sittings")
                    }
                }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 8) {
                    HeadRule(text: "The paper")
                    ForEach(Array(paper.enumerated()), id: \.element.id) { i, q in
                        HStack(alignment: .top, spacing: 8) {
                            if i < answers.count && answers[i] { TickGlyph(size: 13, color: Fell.good).padding(.top, 2) } else { CrossGlyph(size: 11, color: Fell.rubric).padding(.top, 3) }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(q.prompt).font(Fell.body(12.5)).foregroundColor(Fell.ink).fixedSize(horizontal: false, vertical: true)
                                Text(q.options[min(q.answer, q.options.count - 1)]).font(Fell.note(12)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            SealButton(title: "Close the book", tone: Fell.ink) { onClose() }
        }
    }

    private func choose(_ i: Int, _ q: ExamQuestion) {
        guard chosen == nil else { return }
        let ok = i == q.answer
        if ok { Knock.crisp(); right += 1 } else { Knock.hard() }
        withAnimation(.easeOut(duration: 0.25)) {
            chosen = i
            answers.append(ok)
        }
    }

    private func advance() {
        if index + 1 < paper.count {
            withAnimation(.easeInOut(duration: 0.3)) {
                index += 1
                chosen = nil
            }
        } else {
            if !recorded {
                recorded = true
                store.recordExam(score: right, total: paper.count)
            }
            withAnimation(.easeInOut(duration: 0.3)) { finished = true }
        }
    }

    private func verdict(_ pct: Int) -> String {
        if pct == 100 { return "A full paper. The examiners have nothing to add; go and build." }
        if pct >= 85 { return "A pass with credit. Read the lessons on the questions you missed and the next paper will be clean." }
        if pct >= 70 { return "A pass. The craft is in your head; the bank will put it in your hands." }
        if pct >= 50 { return "Not yet. Half the answers are there. The lessons on throughs, the batter and the tests are worth another reading." }
        return "The examiners send you back to the book. Start with the first three lessons and read them to the end."
    }

    private func kindWord(_ kind: String) -> String {
        switch kind {
        case "face", "fault": return "the faults"
        case "style": return "the styles"
        case "test": return "the tests"
        case "stone": return "the stones"
        default: return "from the book"
        }
    }

    private func optionInk(_ i: Int, _ q: ExamQuestion) -> Color {
        guard let c = chosen else { return Fell.ink }
        if i == q.answer { return Fell.good }
        if i == c { return Fell.rubric }
        return Fell.inkFaint
    }

    private func optionFill(_ i: Int, _ q: ExamQuestion) -> Color {
        guard let c = chosen else { return Fell.card }
        if i == q.answer { return Fell.good.opacity(0.12) }
        if i == c { return Fell.rubric.opacity(0.1) }
        return Fell.card
    }

    private func optionStroke(_ i: Int, _ q: ExamQuestion) -> Color {
        guard let c = chosen else { return Fell.ink.opacity(0.18) }
        if i == q.answer { return Fell.good.opacity(0.7) }
        if i == c { return Fell.rubric.opacity(0.7) }
        return Fell.ink.opacity(0.1)
    }
}
