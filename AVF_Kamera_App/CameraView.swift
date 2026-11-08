//
//  ContentView.swift
//  AVF_Kamera_App
//
//  Created by Thies Josten on 03.11.26.
//

import SwiftUI
import AVFoundation

enum CameraMode: String, CaseIterable {
    case photo = "Foto"
    case video = "Video"
}

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var mode: CameraMode = .photo
    
    var body: some View {
        ZStack {
            CameraBackgroundView(
                isAuthorized: cameraManager.isAuthorized,
                session: cameraManager.session,
                cameraManager: cameraManager
            )
            VStack {
                TopThumbnailView(image: cameraManager.lastCapturedImage)
                Spacer()
                ShutterButton(cameraManager: cameraManager, mode: $mode)
                    .padding(.bottom, 20)
                HStack {
                    Spacer()
                    HStack(spacing: 15) {
                        ModePickerView(mode: $mode, isRecording: cameraManager.isRecording)
                            .frame(width: 180)
                        CameraSwitchButton(cameraManager: cameraManager)
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Layout & Container Subviews

struct CameraBackgroundView: View {
    let isAuthorized: Bool
    let session: AVCaptureSession
    let cameraManager: CameraManager // <--- Neu übergeben
    
    var body: some View {
        if isAuthorized {
            CameraPreview(session: session) { point in
                // Da kriege ich iwie nen Fehler, muss ich mir nochmal angucken. Licht auf das Objekt fokussieren funktioniert
                cameraManager.focus(at: point)
            }
            .ignoresSafeArea()
        } else {
            Color.black
                .ignoresSafeArea()
                .overlay(
                    Text("Camera access is required to use this app.")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                )
        }
    }
}

// Funktioniert aktuell nur im .photo mode, macht dann oben links eine Preview von dem zuletzt gemachten Foto, im Ipad Format
//TODO: Das Bildformat vom Bild an das Foto/Gerät anpassen, Thumbnail für video erstellen, wenn das da auch funktionieren soll.
struct TopThumbnailView: View {
    let image: UIImage?
    
    var body: some View {
        HStack {
            if let capturedImage = image {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 286)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 2))
                    .padding(.leading, 20)
                    .padding(.top, 50)
            }
            Spacer()
        }
    }
}


// Toggelt .photo und .video, geht also auch davon aus, dass Beides klappt.
struct ModePickerView: View {
    @Binding var mode: CameraMode
    let isRecording: Bool
    
    var body: some View {
        Picker("Modus", selection: $mode) {
            ForEach(CameraMode.allCases, id: \.self) { currentMode in
                Text(currentMode.rawValue).tag(currentMode)
            }
        }
        .pickerStyle(.segmented)
        // Animation und Ausblenden während der Aufnahme direkt hier geregelt
        .opacity(isRecording ? 0.0 : 1.0)
        .animation(.easeInOut, value: isRecording)
    }
}

// Ab hier beginnen die structs fuer die einzelnen Elemente des View


// ShutterButton -> Wenn mode .photo macht Foto, wenn .video macht der Video und wird dann rot
//TODO: Das Bildformat ist noch ziemlich abgefuckt, ich muss nochmal schauen, wie ich quasi Gerät native Bild/Video Formate erkenne und da gute Sachen mache
struct ShutterButton: View {
    @ObservedObject var cameraManager: CameraManager
    @Binding var mode: CameraMode
    
    var body: some View {
        Button(action: {
            if mode == .photo {
                cameraManager.capturePhoto()
            } else {
                if cameraManager.isRecording {
                    cameraManager.stopRecording()
                } else {
                    cameraManager.startRecording()
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(mode == .photo || !cameraManager.isRecording ? Color.white : Color.red)
                    .frame(width: 70, height: 70)
               
                if mode == .video && cameraManager.isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                } else {
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
        }
    }
}

// Ist der Button um zwischen Front und Back Kamera zu wechseln, geht davon aus, dass es auf dem gerät Beides gibt und toggelt .front zu .back -> Siehe cameraManager.switchCamera
struct CameraSwitchButton: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        Button(action: {
            cameraManager.switchCamera()
        }) {
            Image(systemName: "camera.rotate.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.4))
                .clipShape(Circle())
        }
        .opacity(cameraManager.isRecording ? 0.3 : 1.0)
        .disabled(cameraManager.isRecording)
    }
}

#Preview {
    ContentView()
}

//TODO: Mehr Features aus AVfoundations einbauen. Also Blitzlicht aktivieren, Bildformate, Iso/Blende/Belichtungszeit etc.
// Swipen nach rechts, um wieder in die andere Ansicht von Duc zum kommen
