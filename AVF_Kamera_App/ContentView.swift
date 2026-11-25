import SwiftUI
import AVFoundation

enum BottomBarSelectedTab: Int {
    case camera = 0
    case project = 1
    case textToSpeech = 2
}

struct ContentView: View {
    @State private var selectedTab: Int = BottomBarSelectedTab.project.rawValue
    // initialisiert mit Project

    @StateObject private var mediaStore: MediaStore
    @StateObject private var cameraManager: CameraManager

    init() {
        let store = MediaStore()
        _mediaStore = StateObject(wrappedValue: store)
        _cameraManager = StateObject(wrappedValue: CameraManager(mediaStore: store))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Horizontaler Swipe = View wechsel
            TabView(selection: $selectedTab) {

                CameraView(cameraManager: cameraManager)
                    .tag(BottomBarSelectedTab.camera.rawValue)

                ProjectView(mediaStore: mediaStore)
                    .tag(BottomBarSelectedTab.project.rawValue)

                TextToSpeechView()
                    .tag(BottomBarSelectedTab.textToSpeech.rawValue)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
            .ignoresSafeArea(
                edges: selectedTab == BottomBarSelectedTab.camera.rawValue
                    ? .all
                    : []
            )

            // BottomBar nicht in CameraView anzeigne
            if selectedTab != BottomBarSelectedTab.camera.rawValue {
                BottomBar(
                    selectedTab: Binding(
                        get: {
                            BottomBarSelectedTab(rawValue: selectedTab) ?? .project
                        },
                        set: {
                            selectedTab = $0.rawValue
                        }
                    )
                )
            }
        }
    }
}

struct BottomBar: View {
    @Binding var selectedTab: BottomBarSelectedTab

    // Navigation Elemente mit Funktion tabButton()
    var body: some View {
        HStack {
            tabButton(
                title: "Camera",
                image: "camera",
                tab: .camera
            )

            tabButton(
                title: "Project",
                image: "square.grid.2x2",
                tab: .project
            )

            tabButton(
                title: "Text to Speech",
                image: "speaker.wave.2",
                tab: .textToSpeech
            )
        }
        // Abstand & Hintergrund der Leiste
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.regularMaterial)
    }

    private func tabButton(
        title: String,
        image: String,
        tab: BottomBarSelectedTab
    ) -> some View {
        Button {
            selectedTab = tab
        } label: { // einzelne Button Design
            VStack(spacing: 5) {
                Image(systemName: image)
                    .font(.system(size: 22))

                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(
                selectedTab == tab ? .purple : .gray
            )
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
