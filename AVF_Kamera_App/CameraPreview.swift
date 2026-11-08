//
//  CameraPreview.swift
//  AVF_Kamera_App
//
//  Created by Thies Josten on 03.11.26.
//

import SwiftUI
import AVFoundation

struct CameraPreview : UIViewRepresentable {
    let session: AVCaptureSession
    var onTap: (CGPoint) -> Void
    
    class VideoPreviewView: UIView {
        var onTap: ((CGPoint) -> Void)?
        
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupTapGesture()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupTapGesture()
        }
        
        private func setupTapGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            addGestureRecognizer(tapGesture)
        }
        
        // TODO: Schauen, ob die Funktion broken ist, bzw was genau nicht funktioniert.
        @objc private func handleTap(_ sender: UITapGestureRecognizer) {
            let touchPoint = sender.location(in: self)
            let devicePoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
            onTap?(devicePoint)
        }
    }
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        view.onTap = { point in
            onTap(point)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
    }
}//
//  CameraPreview.swift
//  AVF_Kamera_App
//
//  Created by Thies Josten on 06.11.26.
//

