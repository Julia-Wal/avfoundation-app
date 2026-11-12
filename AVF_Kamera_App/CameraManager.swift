//
//  CameraManager.swift
//  AVF_Kamera_App
//
//  Created by Thies Josten on 03.11.26.
//

import AVFoundation
import UIKit
import Photos

// Basically das Backend, wo die AVCaptureSession liegt, die unsere Inputs und Outputs verwaltet sowie Berechtigungen einholt
class CameraManager : NSObject, ObservableObject {
    
    
    let session = AVCaptureSession()
    
    let photoOutput = AVCapturePhotoOutput()
    let movieOutput = AVCaptureMovieFileOutput()
    
    @Published var isAuthorized: Bool = false
    @Published var isRunning: Bool = false
    @Published var lastCapturedImage: UIImage?
    @Published var isRecording: Bool = false
    
    @Published var cameraPosition: AVCaptureDevice.Position = .back
    
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted {
                        self.setupSession()
                    }
                }
            }
        default:
            self.isAuthorized = false
        }
    }
    
    private func getBestCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: position,
        )

        let availableCameras = discoverySession.devices

        let preferredOrder: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]

        for cameraType in preferredOrder {
            if let camera = availableCameras.first(where: {
                $0.deviceType == cameraType
            }) {
                return camera
            }
        }

        return nil
    }
    
    private func setupSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            if self.session.canSetSessionPreset(.high) {
                self.session.sessionPreset = .high
            }
            
            do {
                guard let videoDevice = self.getBestCamera(
                    position: self.cameraPosition
                ) else {
                    print("No suitable camera available.")
                    self.session.commitConfiguration()
                    return
                }
                
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }
                
                if let audioDevice = AVCaptureDevice.default(for: .audio) {
                    let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                    if self.session.canAddInput(audioInput) {
                        self.session.addInput(audioInput)
                    }
                }
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                if self.session.canAddOutput(self.movieOutput) {
                    self.session.addOutput(self.movieOutput)
                }
                
            } catch {
                print("Error setting up camera input: \(error.localizedDescription)")
            }
            
            self.session.commitConfiguration()
            self.startSession()
        }
    }
    
    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            let newPosition: AVCaptureDevice.Position = (self.cameraPosition == .back) ? .front : .back
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                
                self.session.beginConfiguration()
                
                if let currentInput = self.session.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) == true }) {
                    self.session.removeInput(currentInput)
                }
                
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                    
                    DispatchQueue.main.async {
                        self.cameraPosition = newPosition
                    }
                }
                
                self.session.commitConfiguration()
                
            } catch {
                print("Fehler beim Kamera-Wechsel: \(error.localizedDescription)")
                self.session.commitConfiguration()
            }
        }
    }
    
    func focus(at point: CGPoint) {
            sessionQueue.async { [weak self] in
                guard let self = self else { return }
                
                guard let videoDevice = (self.session.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) == true }) as? AVCaptureDeviceInput)?.device else { return }
                
                do {
                    try videoDevice.lockForConfiguration()
                    
                    if videoDevice.isFocusPointOfInterestSupported && videoDevice.isFocusModeSupported(.autoFocus) {
                        videoDevice.focusPointOfInterest = point
                        videoDevice.focusMode = .autoFocus
                    }
                    
                    if videoDevice.isExposurePointOfInterestSupported && videoDevice.isExposureModeSupported(.continuousAutoExposure) {
                        videoDevice.exposurePointOfInterest = point
                        videoDevice.exposureMode = .continuousAutoExposure
                    }
                    
                    videoDevice.unlockForConfiguration()
                } catch {
                    print("Fehler beim Einstellen des Fokus: \(error.localizedDescription)")
                }
            }
        }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startRecording() {
            guard !movieOutput.isRecording else { return }
            
            let outputFileName = "video_\(UUID().uuidString).mov"
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName)
            
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
        
    func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
        }
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.isRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.isRunning = false
                }
            }
        }
    }
}
    
    extension CameraManager: AVCapturePhotoCaptureDelegate {
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            if let error = error {
                print("Error capturing photo: \(error.localizedDescription)")
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else {
                print("Failed to convert photo data to UIImage.")
                return
            }
            
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized else {
                    print("Keine Berechtigung zum Speichern in der Mediathek.")
                    return
                }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    if success {
                        print("Erfolgreich in der Mediathek gespeichert!")
                    } else if let error = error {
                        print("Fehler beim Speichern: \(error.localizedDescription)")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.lastCapturedImage = image
                print("Successfully captured a photo!")
            }
        }
    }
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Fehler bei der Videoaufnahme: \(error.localizedDescription)")
            return
        }
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { success, error in
                if success {
                    print("Video erfolgreich in der Mediathek gespeichert!")
                } else if let error = error {
                    print("Fehler beim Speichern des Videos: \(error.localizedDescription)")
                }
            }
        }
    }
}
    
    
    //
//  CameraManager.swift
//  AVF_Kamera_App
//
//  Created by Thies Josten on 06.11.26.
//

