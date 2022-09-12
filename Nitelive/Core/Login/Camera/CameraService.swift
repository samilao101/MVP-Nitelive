//
//  CameraService.swift
//  Nitelive
//
//  Created by Sam Santos on 5/29/22.
//

import Foundation
import AVFoundation

class CameraService {
    
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    func start(newDelegate: AVCapturePhotoCaptureDelegate, completion: @escaping(Error?) -> ()) {
        print("putting delegate")
        
        self.delegate = newDelegate
        print(newDelegate.description)
        checkPermissions(completion: completion)

    }

    
    private func checkPermissions(completion: @escaping(Error?) -> ()){
        print("Checking permission")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return}
                
                DispatchQueue.main.async {
                    self?.setupCamera(completion: completion)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera(completion: completion)
        @unknown default:
            break
        }
    }
    
    private func setupCamera(completion: @escaping(Error?) -> ()) {
        
        print("setting camera")
        let session = AVCaptureSession()
        

        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
              
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
                
            } catch {
                
                completion(error)
                
            }
        }
            
            
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        print(delegate)
        output.capturePhoto(with: settings, delegate: self.delegate!)
    }
}

