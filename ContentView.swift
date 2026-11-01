import SwiftUI
import Playgrounds

struct ContentView: View {
    @StateObject private var model = FrameHandler()
    var body: some View {
        FrameView(image: model.frame)
            .ignoresSafeArea()
    }
}

