import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var store: DykeStore
    @State private var section = 0
    @State private var openStyle: StyleEntry? = nil
    @State private var openFeature: FeatureEntry? = nil
    @State private var openStone: StoneEntry? = nil
    @State private var openTool: ToolEntry? = nil
    @State private var openFault: FaultEntry? = nil

    var body: some View {
        ScrollView {
            Column {
                SheetCard(padding: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HeadRule(text: "The register", trailing: readCount)
                        Text("Eight regional styles with their own rules, eleven features and how they are built, twelve stones with how they split and weather, twelve tools, and a gallery of the twelve faults a judge looks for.")
                            .font(Fell.body(12.5)).foregroundColor(Fell.inkSoft).fixedSize(horizontal: false, vertical: true)
                    }
                }
                BandPicker(titles: ["Styles", "Features", "Stones", "Tools", "Faults"], index: $section)
                switch section {
                case 0: styles
                case 1: features
                case 2: stones
                case 3: tools
                default: faults
                }
            }
            .padding(.horizontal, Fell.gutter)
            .padding(.bottom, 28)
        }
        .background(Fell.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { Text("Register").font(Fell.title(17)).foregroundColor(Fell.ink) }
        }
        .onAppear { section = store.section("register") }
        .onChange(of: section) { value in store.remember("register", value) }
        .sheet(item: $openStyle) { entry in StyleSheet(entry: entry) { openStyle = nil }.environmentObject(store) }
        .sheet(item: $openFeature) { entry in FeatureSheet(entry: entry) { openFeature = nil }.environmentObject(store) }
        .sheet(item: $openStone) { entry in StoneSheet(entry: entry) { openStone = nil }.environmentObject(store) }
        .sheet(item: $openTool) { entry in ToolSheet(entry: entry) { openTool = nil }.environmentObject(store) }
        .sheet(item: $openFault) { entry in FaultSheetView(entry: entry) { openFault = nil }.environmentObject(store) }
    }

    private var readCount: String {
        let n = (store.ledger.readStyles ?? []).count + (store.ledger.readFeatures ?? []).count + (store.ledger.readStones ?? []).count + (store.ledger.readTools ?? []).count + (store.ledger.readFaults ?? []).count
        return "\(n)/55 read"
    }

    private var styles: some View {
        VStack(spacing: 12) {
            ForEach(StoneLore.styles) { entry in
                let read = store.hasRead("style", entry.id)
                Button(action: { Knock.light(); openStyle = entry }) {
                    SheetCard(padding: 11) {
                        VStack(alignment: .leading, spacing: 8) {
                            PlateBox(name: entry.facePlate, height: Fell.isPad ? 230 : 150)
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.style.name).font(Fell.title(14)).foregroundColor(Fell.ink)
                                    Text(entry.region).font(Fell.body(11.5)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 6)
                                if read { StampTag(text: "read", tone: Fell.good) }
                                if (store.ledger.stylesBuilt ?? []).contains(entry.style.rawValue) { StampTag(text: "built", tone: Fell.moss) }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var features: some View {
        VStack(spacing: 12) {
            ForEach(StoneLore.features) { entry in
                let read = store.hasRead("feature", entry.id)
                Button(action: { Knock.light(); openFeature = entry }) {
                    SheetCard(padding: 11) {
                        HStack(alignment: .top, spacing: 10) {
                            PlateBox(name: entry.plate, height: 86).frame(width: 126)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(entry.feature.name).font(Fell.title(13)).foregroundColor(Fell.ink)
                                    Spacer(minLength: 4)
                                    if read { TickGlyph(size: 14, color: Fell.good) }
                                }
                                Text(entry.why).font(Fell.body(11.5)).foregroundColor(Fell.inkSoft).lineLimit(3).fixedSize(horizontal: false, vertical: true)
                                if store.wall(for: entry.feature) != nil { StampTag(text: "in the field", tone: Fell.moss) }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var stones: some View {
        VStack(spacing: 12) {
            ForEach(StoneLore.stones) { entry in
                let read = store.hasRead("stone", entry.id)
                Button(action: { Knock.light(); openStone = entry }) {
                    SheetCard(padding: 11) {
                        HStack(alignment: .top, spacing: 10) {
                            PlateBox(name: entry.plate, height: 86).frame(width: 126)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(entry.name).font(Fell.title(13)).foregroundColor(Fell.ink)
                                    Spacer(minLength: 4)
                                    if read { TickGlyph(size: 14, color: Fell.good) }
                                }
                                Text(entry.region).font(Fell.note(11)).foregroundColor(Fell.inkFaint).fixedSize(horizontal: false, vertical: true)
                                Text("\(entry.kind.family.name), \(Int(entry.kind.density)) kg per cubic metre").font(Fell.body(11.5)).foregroundColor(Fell.inkSoft)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var tools: some View {
        VStack(spacing: 12) {
            ForEach(StoneLore.tools) { entry in
                let read = store.hasRead("tool", entry.id)
                Button(action: { Knock.light(); openTool = entry }) {
                    SheetCard(padding: 11) {
                        HStack(alignment: .top, spacing: 10) {
                            PlateBox(name: entry.plate, height: 86).frame(width: 126)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(entry.name).font(Fell.title(13)).foregroundColor(Fell.ink)
                                    Spacer(minLength: 4)
                                    if read { TickGlyph(size: 14, color: Fell.good) }
                                }
                                Text(entry.use).font(Fell.body(11.5)).foregroundColor(Fell.inkSoft).lineLimit(3).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var faults: some View {
        VStack(spacing: 12) {
            NoticeBar(text: "Every fault here is one the judge counts on the bank. The frame check draws them on your own wall.", tone: Fell.rubric)
            ForEach(StoneLore.faults) { entry in
                let read = store.hasRead("fault", entry.id)
                Button(action: { Knock.light(); openFault = entry }) {
                    SheetCard(padding: 11) {
                        VStack(alignment: .leading, spacing: 8) {
                            PlateBox(name: entry.plate, height: Fell.isPad ? 220 : 146)
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.kind.name).font(Fell.title(14)).foregroundColor(Fell.ink)
                                    Text(entry.what).font(Fell.body(11.5)).foregroundColor(Fell.inkSoft).lineLimit(2).fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: 6)
                                if read { StampTag(text: "read", tone: Fell.good) }
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
