import SwiftUI

@main
struct HapticsLabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(testAppearance)
        }
    }

    private var testAppearance: ColorScheme? {
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-uiTestAppearance"),
           arguments.indices.contains(index + 1) {
            return arguments[index + 1] == "dark" ? .dark : .light
        }
#endif
        return nil
    }
}
