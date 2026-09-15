import SwiftUI

struct RegisterShell<Content: View>: View {
    var title: String
    var subtitle: String?
    var onClose: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Fell.page.ignoresSafeArea()
            VStack(spacing: 0) {
                SheetHead(title: title, subtitle: subtitle) { onClose() }
                ScrollView {
                    Column { content() }
                        .padding(.horizontal, Fell.gutter)
                        .padding(.bottom, 24)
                }
            }
        }
    }
}

struct Paragraph: View {
    var text: String
    var body: some View {
        Text(text).font(Fell.body(13.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
    }
}

struct StyleSheet: View {
    @EnvironmentObject var store: DykeStore
    var entry: StyleEntry
    var onClose: () -> Void

    var body: some View {
        let r = entry.style.rules
        return RegisterShell(title: entry.style.name, subtitle: entry.region, onClose: onClose) {
            SheetCard(padding: 9) { PlateBox(name: entry.facePlate, height: Fell.isPad ? 330 : 224) }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "History")
                    Paragraph(text: entry.history)
                    Text("Stone: \(entry.stone)").font(Fell.note(12.5)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                }
            }
            SheetCard(padding: 9) {
                VStack(alignment: .leading, spacing: 6) {
                    PlateBox(name: entry.sectionPlate, height: Fell.isPad ? 330 : 224)
                    Text("The section: what the judge reads").font(Fell.note(12)).foregroundColor(Fell.inkFaint)
                }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "The rules")
                    ForEach(Array(entry.rules.enumerated()), id: \.offset) { _, rule in
                        HStack(alignment: .top, spacing: 8) {
                            Rectangle().fill(Fell.moss).frame(width: 3, height: 14).padding(.top, 3)
                            Text(rule).font(Fell.body(13)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    HStack(spacing: 9) {
                        CountTile(value: Words.centimetres(r.baseWidth), label: "at the base")
                        CountTile(value: Words.centimetres(r.topWidth), label: "at the top")
                        CountTile(value: r.batter.upperBound > 0.03 ? "1 in \(Int((1 / ((r.batter.lowerBound + r.batter.upperBound) * 0.5)).rounded()))" : "plumb", label: "batter")
                        CountTile(value: Words.centimetres(r.typicalHeight), label: "typical height")
                    }
                    HStack(spacing: 9) {
                        CountTile(value: r.wantsThroughs ? "every \(Words.metres(r.throughSpacing))" : (r.form == .doubleThenSingle ? "cover band" : "none"), label: "throughs")
                        CountTile(value: copeName(r.cope), label: "cope")
                        CountTile(value: coreName(r.core), label: "core")
                    }
                }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "Build one")
                    Text("Set out a wall in this style from the bank: any feature, any stone, any length.")
                        .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                    if (store.ledger.stylesBuilt ?? []).contains(entry.style.rawValue) {
                        StampTag(text: "built before", tone: Fell.moss)
                    }
                }
            }
        }
        .onAppear { store.markRead("style", entry.id) }
    }

    private func copeName(_ c: CopeKind) -> String {
        switch c {
        case .flat: return "flat"
        case .upright: return "upright"
        case .cockAndHen: return "cock and hen"
        case .buckAndDoe: return "buck and doe"
        case .locked: return "locked"
        case .turf: return "turf"
        case .none: return "none"
        }
    }

    private func coreName(_ c: CoreKind) -> String {
        switch c {
        case .hearting: return "hearting"
        case .earth: return "rammed earth"
        case .none: return "single"
        }
    }
}

struct FeatureSheet: View {
    @EnvironmentObject var store: DykeStore
    var entry: FeatureEntry
    var onClose: () -> Void

    var body: some View {
        RegisterShell(title: entry.feature.name, subtitle: nil, onClose: onClose) {
            SheetCard(padding: 9) { PlateBox(name: entry.plate, height: Fell.isPad ? 330 : 224) }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "How it is built")
                    Paragraph(text: entry.how)
                    HeadRule(text: "Why")
                    Paragraph(text: entry.why)
                    HeadRule(text: "How it goes wrong")
                    Text(entry.wrong).font(Fell.body(13.5)).foregroundColor(Fell.rubric).fixedSize(horizontal: false, vertical: true)
                }
            }
            if let wall = store.wall(for: entry.feature) {
                SheetCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HeadRule(text: "Yours in the field", trailing: wall.word)
                        FieldWallThumb(wall: wall, height: 120)
                        Text("\(wall.style.name) in \(StoneLore.name(wall.kind).lowercased()), \(wall.score) points, built \(Words.days(store.today - wall.built)).")
                            .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .onAppear { store.markRead("feature", entry.id) }
    }
}

struct StoneSheet: View {
    @EnvironmentObject var store: DykeStore
    var entry: StoneEntry
    var onClose: () -> Void
    @State private var age = 0

    var body: some View {
        let group = weatherGroup(entry.kind)
        let ages = ["new", "year", "ten", "fifty", "century"]
        let ageWords = ["Newly built", "One winter", "Ten years", "Fifty years", "150 years"]
        return RegisterShell(title: entry.name, subtitle: entry.region, onClose: onClose) {
            SheetCard(padding: 9) { PlateBox(name: entry.plate, height: Fell.isPad ? 300 : 200) }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "The stone", trailing: entry.age)
                    HStack(spacing: 9) {
                        CountTile(value: entry.kind.family.name, label: "shape")
                        CountTile(value: "\(Int(entry.kind.density))", label: "kg per cubic m")
                        CountTile(value: entry.kind.weakness > 0.4 ? "weak" : (entry.kind.weakness > 0.25 ? "middling" : "sound"), label: "in frost")
                    }
                    HeadRule(text: "How it splits")
                    Paragraph(text: entry.splits)
                    HeadRule(text: "How it weathers")
                    Paragraph(text: entry.weathers)
                    HeadRule(text: "Lichen")
                    Paragraph(text: entry.lichen)
                    HeadRule(text: "On the bank")
                    Paragraph(text: entry.note)
                }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "The same stone by class")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["footing", "builder", "through", "cope", "hearting"], id: \.self) { cls in
                                VStack(spacing: 4) {
                                    PlateBox(name: "st_\(entry.kind.rawValue)_\(cls)", height: 90).frame(width: 134)
                                    Text(cls).font(Fell.note(11)).foregroundColor(Fell.inkFaint)
                                }
                            }
                        }
                    }
                }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "Weathering", trailing: ageWords[age])
                    PlateBox(name: "wx_\(group)_\(ages[age])", height: Fell.isPad ? 300 : 200)
                    BandPicker(titles: ["New", "1 yr", "10", "50", "150"], index: $age)
                    Text("The field weathers your walls the same way, with the real days since they were built.")
                        .font(Fell.note(12)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .onAppear { store.markRead("stone", entry.id) }
    }
}

func weatherGroup(_ kind: StoneKind) -> String {
    switch kind {
    case .gritstone, .sandstone, .flagstone: return "grit"
    case .limestone, .clunch: return "lime"
    case .oolite: return "oolite"
    case .slate, .schist: return "slate"
    case .granite, .whinstone, .greywacke: return "hard"
    case .fieldstone: return "field"
    }
}

struct ToolSheet: View {
    @EnvironmentObject var store: DykeStore
    var entry: ToolEntry
    var onClose: () -> Void

    var body: some View {
        RegisterShell(title: entry.name, subtitle: nil, onClose: onClose) {
            SheetCard(padding: 9) { PlateBox(name: entry.plate, height: Fell.isPad ? 330 : 224) }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "Use")
                    Paragraph(text: entry.use)
                    HeadRule(text: "History")
                    Paragraph(text: entry.history)
                    HeadRule(text: "How it goes wrong")
                    Text(entry.wrong).font(Fell.body(13.5)).foregroundColor(Fell.rubric).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .onAppear { store.markRead("tool", entry.id) }
    }
}

struct FaultSheetView: View {
    @EnvironmentObject var store: DykeStore
    var entry: FaultEntry
    var onClose: () -> Void

    var body: some View {
        RegisterShell(title: entry.kind.name, subtitle: "Costs \(Int(entry.kind.weight)) points each, up to \(Int(entry.kind.cap))", onClose: onClose) {
            SheetCard(padding: 9) { PlateBox(name: entry.plate, height: Fell.isPad ? 330 : 224) }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "What it is")
                    Paragraph(text: entry.what)
                    HeadRule(text: "Why it matters")
                    Paragraph(text: entry.why)
                    HeadRule(text: "The cure")
                    Text(entry.fix).font(Fell.body(13.5)).foregroundColor(Fell.good).fixedSize(horizontal: false, vertical: true)
                }
            }
            SheetCard {
                VStack(alignment: .leading, spacing: 9) {
                    HeadRule(text: "Which test finds it")
                    Paragraph(text: testWords)
                }
            }
        }
        .onAppear { store.markRead("fault", entry.id) }
    }

    private var testWords: String {
        switch entry.kind {
        case .runningJoint, .onEdge, .faceBedded: return "Frost. Ice gets into the joint or the bed and opens it a little each winter."
        case .hollowCore, .looseCope, .belly: return "Sheep. A ewe leans on the cope; a loose cope goes over and a hollow core lets the face belly out."
        case .noThroughs, .wrongBatter: return "Wind. Over head height a face with nothing tying it in, or a plumb face, bulges and sheds its top."
        case .poorFooting, .pinFront: return "The hundred years. Roots heave a poor footing; a pin from the face is kicked out and the stone above it drops."
        case .traced: return "The hundred years, through every other fault: a traced stone holds nothing, and the hearting behind it settles until the face bellies."
        case .badHead: return "The hundred years. A head that is not bonded unzips from the top down once the cope is knocked."
        }
    }
}
