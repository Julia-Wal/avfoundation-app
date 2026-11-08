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
            .background(.white)
            
            VStack(spacing: 20){
                TextEditor(text: $text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                
                HStack{
                    
                    Button("Vorlesen") {
                        let utterance = AVSpeechUtterance(
                            string: text
                        )
                        
                        // Einstellungen der Sprachausgabe
                        utterance.rate = 0.57
                        utterance.pitchMultiplier = 0.8
                        utterance.postUtteranceDelay = 0.2
                        utterance.volume = 0.8
                        
                        utterance.voice =
                        AVSpeechSynthesisVoice(language: "de-DE")
                        
                        // Sprachausgabe starten
                        synthesizer.speak(utterance)
                    }
                    
                    Button("Stop") {
                        synthesizer.stopSpeaking(at: .immediate)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    TextToSpeechView()
}
