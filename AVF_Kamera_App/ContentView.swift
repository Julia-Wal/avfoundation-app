<<<<<<< HEAD
import SwiftUI
import AVFoundation

enum BottomBarSelectedTab {
    case camera
    case project
    case textToSpeech
}

struct ContentView: View {
    @State var selectedTab: BottomBarSelectedTab = .project
    // initialisiert mit Project

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .camera: CameraView()
                case .project: ProjectView()
                case .textToSpeech: TextToSpeechView()
                }
            }

            Spacer(minLength: 0)

            BottomBar(selectedTab: $selectedTab)
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

=======
//
//  ContentView.swift
//  AVF_Kamera_App
//
//  Created by Thies Josten on 06.11.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

>>>>>>> bedb41c (Initial Commit)
#Preview {
    ContentView()
}
