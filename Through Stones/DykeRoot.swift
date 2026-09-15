import SwiftUI

struct DykeRoot: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    @State private var tab = 0
    @State private var lastTab = 0
    @State private var restored = false

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                Group {
                    switch tab {
                    case 0:
                        NavigationView { TodayView().environmentObject(store).environmentObject(session) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { BankView().environmentObject(store).environmentObject(session) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 2:
                        NavigationView { RegisterView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 3:
                        NavigationView { FieldView().environmentObject(store).environmentObject(session) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { BookView().environmentObject(store) }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .id(tab)
                .transition(.asymmetric(insertion: .move(edge: tab > lastTab ? .trailing : .leading).combined(with: .opacity), removal: .opacity))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                bar
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            guard !restored else { return }
            restored = true
            let saved = store.ledger.lastTab ?? 0
            if saved != tab && saved >= 0 && saved < 5 { tab = saved; lastTab = saved }
            if let w = store.ledger.session, !session.active {
                session.restore(w, name: store.ledger.sessionName ?? "A wall", daily: store.ledger.sessionDaily ?? false)
            }
            session.onChange = { [weak store, weak session] in
                guard let store = store, let session = session else { return }
                store.ledger.session = session.wall
                store.ledger.sessionName = session.wall == nil ? nil : session.name
                store.ledger.sessionDaily = session.wall == nil ? nil : session.daily
            }
        }
        .onChange(of: tab) { value in if store.ledger.lastTab != value { store.ledger.lastTab = value } }
        .onReceive(store.$wantedTab) { wanted in
            guard let wanted = wanted else { return }
            lastTab = tab
            withAnimation(.easeInOut(duration: 0.22)) { tab = wanted }
            store.wantedTab = nil
        }
    }

    private var bar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Today")
            tabButton(1, "Bank")
            tabButton(2, "Register")
            tabButton(3, "Field")
            tabButton(4, "Book")
        }
        .padding(.top, 7)
        .padding(.bottom, 3)
        .background(
            Fell.card
                .overlay(Rectangle().fill(Fell.ink.opacity(0.12)).frame(height: 0.7), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(_ index: Int, _ label: String) -> some View {
        let active = tab == index
        let tone = active ? Fell.ink : Fell.inkFaint
        return Button(action: {
            Knock.light()
            lastTab = tab
            withAnimation(.easeInOut(duration: 0.22)) { tab = index }
        }) {
            VStack(spacing: 3) {
                Group {
                    switch index {
                    case 0: FellMark(size: 22, color: tone)
                    case 1: BankMark(size: 22, color: tone)
                    case 2: RegisterMark(size: 22, color: tone)
                    case 3: FieldMark(size: 22, color: tone)
                    default: BookMark(size: 22, color: tone)
                    }
                }
                Text(label).font(Fell.body(9.5)).foregroundColor(tone)
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct DykeIntro: View {
    var onDone: () -> Void
    @State private var page = 0

    private let pages: [(String, String, String)] = [
        ("Through Stones",
         "A dry stone wall has no mortar. It stands for two hundred years on nothing but the weight of its stones and the way they are arranged: one over two, length into the wall, hearting packed in the core, throughs at half height, a cope to hold it down.",
         "ob_0"),
        ("The bank",
         "Every stone comes off the heap by hand. Drag it to the wall and it falls and settles on what is below; if its weight sits outside its bearing it goes over, if it rocks you pin it. Hearting goes in with a tap, the string line goes up a course at a time, the throughs go in at half height.",
         "ob_1"),
        ("The judge",
         "Then the frost, the sheep and the wind test what you built. Running joints crack open, hollow cores belly out, loose copes go over, and a wall over head height with nothing tying its faces sheds its top. The critique tells you exactly what let it down.",
         "ob_2"),
        ("The field",
         "Every wall you leave in the field stands on the hillside in its own style and stone, growing lichen with the real days, the sheep grazing behind the ones that held. A fallen section can be rebuilt with the same stones. Eight styles, eleven features, twelve stones.",
         "ob_3")
    ]

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    if page > 0 {
                        Button(action: { Knock.light(); withAnimation { page -= 1 } }) {
                            HStack(spacing: 4) {
                                ChevGlyph(size: 15, color: Fell.inkSoft)
                                Text("Back").font(Fell.body(13.5)).foregroundColor(Fell.inkSoft)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                    Button(action: { Knock.light(); onDone() }) {
                        Text("Skip").font(Fell.body(13.5)).foregroundColor(Fell.inkFaint)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Fell.gutter)
                .padding(.top, 14)
                Spacer(minLength: 0)
                ScrollView {
                    Column {
                        SheetCard(padding: 9) {
                            PlateBox(name: pages[page].2, aspect: 4 / 3)
                        }
                        VStack(alignment: .leading, spacing: 9) {
                            Text(pages[page].0).font(Fell.title(22)).foregroundColor(Fell.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(pages[page].1).font(Fell.body(14.5)).foregroundColor(Fell.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, Fell.gutter)
                    .id(page)
                    .transition(.opacity)
                }
                Spacer(minLength: 0)
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Circle().fill(i == page ? Fell.ink : Fell.ink.opacity(0.20)).frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 13)
                SealButton(title: page == pages.count - 1 ? "Onto the bank" : "Next", tone: Fell.grit) {
                    if page == pages.count - 1 { onDone() } else { withAnimation { page += 1 } }
                }
                .padding(.horizontal, Fell.gutter)
                .padding(.bottom, 20)
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    var onClose: () -> Void
    @State private var confirmReset = false

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: "About the bank", subtitle: "Through Stones 1.0") { onClose() }
                ScrollView {
                    Column {
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "What this is")
                                Text("A waller's bank on a hillside. Irregular stones come off the heap and fall under gravity onto the wall; a quasi-static model decides whether each one stands, rocks or goes over, and the rules of the craft are read from the finished face: crossed joints, length into the wall, a packed core, throughs at half height, a tight cope, a plumb head. Frost, sheep and wind test what you built.")
                                    .font(Fell.body(13.5)).foregroundColor(Fell.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Eight regional styles with their own rules, eleven features, twelve stones, twelve tools, a gallery of twelve faults, twelve lessons, a glossary and an examination. The field keeps the best wall of every feature and weathers it with the real days.")
                                    .font(Fell.body(13.5)).foregroundColor(Fell.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "Your standing")
                                HStack(spacing: 9) {
                                    CountTile(value: "\(store.ledger.points)", label: "points")
                                    CountTile(value: "\(store.ledger.wallsBuilt)", label: "walls built")
                                    CountTile(value: "\(store.ledger.bestStreak)", label: "best streak")
                                }
                                Text("Everything is stored on this device only. There is no account, no network and nothing leaves the bank.")
                                    .font(Fell.body(12.5)).foregroundColor(Fell.inkFaint)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        SheetCard {
                            VStack(alignment: .leading, spacing: 9) {
                                HeadRule(text: "Start again")
                                Text("Clears the field, the wall on the bank, the streak, the badges and the examination, and returns you to Labourer.")
                                    .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                                if confirmReset {
                                    NoticeBar(text: "This cannot be undone. Clear the field?", tone: Fell.rubric,
                                              action: ("Clear it", { session.abandon(); store.reset(); confirmReset = false; onClose() }))
                                    SealButton(title: "Keep everything", tone: Fell.inkSoft, filled: false) { confirmReset = false }
                                } else {
                                    SealButton(title: "Reset progress", tone: Fell.rubric, filled: false) { confirmReset = true }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Fell.gutter)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
