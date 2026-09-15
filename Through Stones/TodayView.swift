import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: DykeStore
    @EnvironmentObject var session: WallSession
    @State private var now = Date()
    @State private var openSettings = false
    @State private var openTerm: GlossEntry? = nil
    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var hour: Double { FellClock.hourValue(now) }
    private var weather: FellWeather { FellWeather.today(store.today) }

    var body: some View {
        ScrollView {
            Column {
                sceneCard
                commissionCard
                standingCard
                fieldCard
                wordCard
            }
            .padding(.horizontal, Fell.gutter)
            .padding(.bottom, 28)
        }
        .background(Fell.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Text("The Fell").font(Fell.title(17)).foregroundColor(Fell.ink) }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { Knock.light(); openSettings = true }) { GearMark(size: 20, color: Fell.inkSoft) }
                    .buttonStyle(.plain)
            }
        }
        .onReceive(clock) { _ in now = Date() }
        .onAppear { now = Date() }
        .fullScreenCover(isPresented: $openSettings) {
            SettingsView { openSettings = false }.environmentObject(store).environmentObject(session)
        }
        .sheet(item: $openTerm) { entry in
            TermSheet(entry: entry) { openTerm = nil }.environmentObject(store)
        }
    }

    private var sceneCard: some View {
        SheetCard(padding: 0) {
            VStack(spacing: 0) {
                ZStack {
                    FellScene(hour: hour, weather: weather, standing: store.standingWalls)
                }
                .frame(height: Fell.isPad ? 300 : 210)
                .clipped()
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hourWords).font(Fell.title(14)).foregroundColor(Fell.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(weather.words). \(hourNote)").font(Fell.body(12)).foregroundColor(Fell.inkFaint)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(13)
            }
        }
        .rising(0)
    }

    private var hourWords: String {
        switch Int(hour) {
        case 0..<5: return "The wall keeps the flock without a hand on it"
        case 5..<8: return "First light on the bank, the heap still wet"
        case 8..<11: return "The best hour for walling, before the hands tire"
        case 11..<14: return "Full light on the face and every joint showing"
        case 14..<17: return "The sun has crossed the wall"
        case 17..<20: return "Curlews over the fell and the last course to the line"
        case 20..<23: return "The frame left against the wall for the morning"
        default: return "Late, and the stones cold to the touch"
        }
    }

    private var hourNote: String {
        let sheep = store.standingWalls
        if sheep == 0 { return "No walls in the field yet; the sheep have the whole fell." }
        return sheep == 1 ? "One wall standing in the field." : "\(sheep) walls standing in the field."
    }

    private var commissionCard: some View {
        let c = store.commission
        let done = store.workedToday()
        let best = store.dailyScore(store.today)
        let inProgress = session.active && session.daily
        return SheetCard {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    HeadRule(text: "Wall of the day")
                    if done { StampTag(text: "in the field", tone: Fell.good) }
                }
                Text(c.feature.name).font(Fell.title(16)).foregroundColor(Fell.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(WallBuilder.line(for: c)).font(Fell.note(13.5)).foregroundColor(Fell.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 9) {
                    CountTile(value: c.style.shortName, label: "style")
                    CountTile(value: StoneLore.name(c.kind).components(separatedBy: " ").last ?? "", label: "stone")
                    CountTile(value: Words.metres(c.length), label: "run")
                    CountTile(value: Words.centimetres(c.height), label: "to the cope")
                }
                if let best = best {
                    HStack(spacing: 8) {
                        Text("Best today").font(Fell.body(12.5)).foregroundColor(Fell.inkFaint)
                        ScoreWord(score: best)
                    }
                }
                HStack(spacing: 10) {
                    PlateBox(name: StoneLore.style(c.style).facePlate, height: 74).frame(width: 110)
                    Text(StoneLore.style(c.style).rules.prefix(3).joined(separator: ". ") + ".")
                        .font(Fell.body(12)).foregroundColor(Fell.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                SealButton(title: inProgress ? "Back to the bank" : (done ? "Build it again" : "Go to the bank"), tone: done && !inProgress ? Fell.inkSoft : Fell.grit, filled: !(done && !inProgress)) {
                    if !inProgress {
                        store.lockDaily()
                        session.start(c, name: "\(c.feature.shortName) at \(c.place)", daily: true)
                    }
                    store.wantedTab = 1
                }
                if session.active && !session.daily {
                    NoticeBar(text: "A free wall is on the bank; starting the day's wall puts it back on the heap.", tone: Fell.query)
                }
            }
        }
        .rising(1)
    }

    private var standingCard: some View {
        let (name, note, points, ceiling) = store.rank
        let progress = ceiling > points ? Double(points) / Double(max(1, ceiling)) : 1
        return SheetCard {
            VStack(alignment: .leading, spacing: 11) {
                HeadRule(text: "Standing on the bank")
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(name).font(Fell.title(17)).foregroundColor(Fell.ink)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(note).font(Fell.note(12)).foregroundColor(Fell.inkFaint)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    VStack(spacing: 1) {
                        Text("\(store.liveStreak)").font(Fell.title(22)).foregroundColor(Fell.moss)
                        Text("STREAK").font(Fell.body(8)).tracking(1).foregroundColor(Fell.inkFaint)
                        Text("best \(store.ledger.bestStreak)").font(Fell.body(9)).foregroundColor(Fell.inkFaint)
                    }
                }
                MeterBar(label: "Toward the next rank", value: progress, tone: Fell.moss,
                         caption: ceiling > points ? "\(ceiling - points) points to go" : "The head of the craft, and nothing above it")
                HStack(spacing: 9) {
                    CountTile(value: "\(store.ledger.wallsBuilt)", label: "walls built")
                    CountTile(value: "\(store.standingWalls)", label: "standing")
                    CountTile(value: "\(store.ledger.bestScore ?? 0)", label: "best score", tone: Fell.moss)
                }
                NoticeBar(text: "Rank never locks the bank, the register or the book. It only opens harder kinds of commission: corners and curves, then stiles and gate posts, then retaining walls and bee boles.", tone: Fell.sky)
            }
        }
        .rising(2)
    }

    private var fieldCard: some View {
        Group {
            if let last = store.ledger.walls.max(by: { $0.builtAt < $1.builtAt }) {
                SheetCard {
                    VStack(alignment: .leading, spacing: 9) {
                        HeadRule(text: "Last into the field", trailing: last.word)
                        HStack(alignment: .top, spacing: 12) {
                            FieldWallThumb(wall: last, height: 74).frame(width: 130)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(last.name).font(Fell.title(13.5)).foregroundColor(Fell.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("\(last.style.name) in \(StoneLore.name(last.kind).lowercased()), built \(Words.days(store.today - last.built)).")
                                    .font(Fell.body(12)).foregroundColor(Fell.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(last.standing ? "Standing." : "A section down; it can be rebuilt from the field.")
                                    .font(Fell.note(12)).foregroundColor(last.standing ? Fell.good : Fell.rubric)
                            }
                            Spacer(minLength: 0)
                        }
                        Button(action: { Knock.light(); store.wantedTab = 3 }) {
                            Text("Walk the field").font(Fell.title(11.5)).foregroundColor(Fell.moss)
                                .padding(.horizontal, 10).padding(.vertical, 7)
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.moss.opacity(0.5), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .rising(3)
            } else {
                SheetCard {
                    VStack(alignment: .leading, spacing: 9) {
                        HeadRule(text: "The field")
                        PlateBox(name: "ob_3", height: Fell.isPad ? 200 : 140)
                        Text("Nothing stands in the field yet. The first wall you leave there will weather with the real days, and the sheep will graze behind it if it held.")
                            .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .rising(3)
            }
        }
    }

    private var wordCard: some View {
        var rng = Spool(seedOf("word.\(store.today)"))
        let entry = Lexicon.entries[rng.int(0, Lexicon.entries.count - 1)]
        let tool = StoneLore.tools[rng.int(0, StoneLore.tools.count - 1)]
        return SheetCard {
            VStack(alignment: .leading, spacing: 9) {
                HeadRule(text: "A word from the book")
                Text(entry.term).font(Fell.title(15)).foregroundColor(Fell.ink)
                Text(entry.means).font(Fell.body(13)).foregroundColor(Fell.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: { Knock.light(); openTerm = entry }) {
                    HStack(spacing: 6) {
                        BookMark(size: 14, color: Fell.sky)
                        Text("Read it in the glossary").font(Fell.title(11)).foregroundColor(Fell.sky)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.sky.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(.plain)
                HeadRule(text: "On the bench today")
                HStack(alignment: .top, spacing: 12) {
                    PlateBox(name: tool.plate, height: 80).frame(width: 118)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tool.name).font(Fell.title(13)).foregroundColor(Fell.ink)
                        Text(tool.wrong).font(Fell.note(12)).foregroundColor(Fell.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .rising(4)
    }
}

struct FieldWallThumb: View {
    var wall: FieldWall
    var height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(Gradient(colors: [Fell.sky.opacity(0.6), Fell.grass]), startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
            let map = PaintMap.fit(length: wall.commission.length, height: wall.commission.height, slope: wall.feature.slopeRate, in: size, margin: 0.1, topRoom: 0.4, bottomRoom: 0.12)
            WallPaint.drawField(&ctx, stones: wall.stones, fallen: wall.fallen, map: map, age: wall.weathering, detail: 0, coreKind: wall.kind)
            ctx.fill(Path(CGRect(x: 0, y: map.at(0, 0).y, width: size.width, height: size.height - map.at(0, 0).y)), with: .color(Fell.grassDeep.opacity(0.9)))
        }
        .frame(height: height)
        .clipped()
        .cornerRadius(4)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Fell.ink.opacity(0.16), lineWidth: 0.8))
    }
}
