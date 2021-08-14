import Model
import SwiftUI

@main
struct GRDBValueObserverIssueApp: App {
    @StateObject var model = Model()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
