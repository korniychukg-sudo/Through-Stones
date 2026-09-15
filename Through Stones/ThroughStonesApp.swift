import SwiftUI

@main
struct ThroughStonesApp: App {
    @StateObject private var store = DykeStore()
    @StateObject private var session = WallSession()

    var body: some Scene {
        WindowGroup {
            Group {
                if store.ledger.seenIntro == true {
                    DykeRoot().environmentObject(store).environmentObject(session)
                } else {
                    DykeIntro { store.ledger.seenIntro = true }
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
