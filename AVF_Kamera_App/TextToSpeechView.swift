//
//  T2SView.swift
//  demo_iOS-app
//
//  Created by Duc Nguyen on 02.11.26.
//

import SwiftUI
import AVFoundation

struct TextToSpeechView: View {
    @State private var text = ""
    @FocusState private var isEditorFocused: Bool

    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        
        VStack{
            
            HStack{
                Text("Text to Speech")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.clear)
            
            ZStack{
                VStack(spacing: 20){
                    TextEditor(text: $text)
                        .focused($isEditorFocused)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scrollContentBackground(.hidden)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    
                    HStack{
                        
                        Button("Read out loud") {
                            let utterance = AVSpeechUtterance(
                                string: text
                            )
                            
                            // Einstellungen der Sprachausgabe
                            utterance.rate = 0.6
                            utterance.pitchMultiplier = 0.5
                            utterance.postUtteranceDelay = 0.1
                            utterance.volume = 0.7
                            
                            utterance.voice =
                            AVSpeechSynthesisVoice(language: "en-EN")
                            
                            // Sprachausgabe starten
                            synthesizer.speak(utterance)
                        }
                        
                        Button("Stop") {
                            synthesizer.stopSpeaking(at: .immediate)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Tastatur schließen, wenn außerhalb getippt wird
                if isEditorFocused {
                    Color.clear
                        .contentShape(Rectangle()) // berührbare Fläche (außerhalb)
                        .onTapGesture {
                            isEditorFocused = false
                        }
                        .allowsHitTesting(true)
                        .zIndex(1) // ebene 1 im zstack
                }
            }
        }
        .padding()
    }
}

#Preview {
    TextToSpeechView()
}
