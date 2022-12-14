//
//  VideoCameraView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import SwiftUI
import AVFoundation

struct VideoCameraView: UIViewControllerRepresentable {
    ////
    
    @Binding var videoURL: URL?
    @Binding var startStop: Bool
    @Binding var flipCamera: Bool
    @State var isCameraFlipping: Bool = false
    @State var isItRecording: Bool = false
    
    func makeUIViewController(context: Context) -> VideoCameraViewController {
        
      
        let viewController = VideoCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, videoURL: $videoURL)
    }
    
    
    class Coordinator: NSObject, AVCaptureFileOutputRecordingDelegate {
        
        let parent: VideoCameraView
        @Binding var videoURL: URL?
        
        init(_ parent: VideoCameraView, videoURL: Binding<URL?>){
            self.parent = parent
            self._videoURL = videoURL
        }
        
        func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
            print("Trying to get file")
            if (error != nil) {
            
                print("Error recording movie: \(error!.localizedDescription)")
            
            } else {
            
              
                self.videoURL = outputFileURL
                
            }
        
        }
    }
    
    
    
    func updateUIViewController(_ uiViewController: VideoCameraViewController, context: Context) {
        
        if isCameraFlipping != flipCamera {
            uiViewController.updateCameraPosition(flipCamera: flipCamera)
            DispatchQueue.main.async {
                isCameraFlipping = flipCamera
            }
        }
        
      
        
        if isItRecording != startStop {
            uiViewController.startRecording()
            DispatchQueue.main.async {
                isItRecording = startStop
            }
        }
    }
    
}
