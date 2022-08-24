//
//  VideoCameraController.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import UIKit

import AVFoundation

class VideoCameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    weak var camPreview: UIView!
    

    let captureSession = AVCaptureSession()

    let movieOutput = AVCaptureMovieFileOutput()

    var previewLayer: AVCaptureVideoPreviewLayer!

    var activeInput: AVCaptureDeviceInput!

    var outputURL: URL!
    
    var delegate: AVCaptureFileOutputRecordingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if setupSession() {
            setupPreview()
            startSession()
        }
    
      
    
    
   
    

    
    }

    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        camPreview.layer.addSublayer(previewLayer)
        self.view.layer.addSublayer(previewLayer)
    }

    //MARK:- Setup Camera

    func setupSession() -> Bool {
    
        captureSession.sessionPreset = AVCaptureSession.Preset.high
    
        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
    
        do {
        
            let input = try AVCaptureDeviceInput(device: camera)
        
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
    
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
    
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
    
    
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
    
        return true
    }

    func setupCaptureMode(_ mode: Int) {
        // Video Mode
    
    }

    //MARK:- Camera Session
    func startSession() {
    
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }

    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
    
        switch UIDevice.current.orientation {
            case .portrait:
                orientation = AVCaptureVideoOrientation.portrait
            case .landscapeRight:
                orientation = AVCaptureVideoOrientation.landscapeLeft
            case .portraitUpsideDown:
                orientation = AVCaptureVideoOrientation.portraitUpsideDown
            default:
                 orientation = AVCaptureVideoOrientation.landscapeRight
         }
    
         return orientation
     }

    @objc func startCapture() {
    
        startRecording()
    
    }

    //EDIT 1: I FORGOT THIS AT FIRST

    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
    
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
    
        return nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let vc = segue.destination as! VideoPlayback
    
        vc.videoURL = sender as? URL
    
    }

    func startRecording() {
    
        if movieOutput.isRecording == false {
        
            let connection = movieOutput.connection(with: AVMediaType.video)
        
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = .portrait
            }
        
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
        
            let device = activeInput.device
        
            if (device.isSmoothAutoFocusSupported) {
            
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                   print("Error setting configuration: \(error)")
                }
            
            }
        
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        
            }
            else {
                stopRecording()
            }
    
       }

   func stopRecording() {
    
       if movieOutput.isRecording == true {
           movieOutput.stopRecording()
        }
   }

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    
    }

//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//
//
//            let videoRecorded = outputURL! as URL
//            self.delegate?.fileOutput(output, didFinishRecordingTo: videoRecorded, from: connections, error: error)
////            performSegue(withIdentifier: "showVideo", sender: videoRecorded)
//
//
//
//    }

    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    
        
             guard let data = try? Data(contentsOf: outputFileURL) else {
                   return
               }

               print("File size before compression: \(Double(data.count / 1048576)) mb")

               let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
              
                compressVideo(inputURL: outputFileURL as URL,
                             outputURL: compressedURL) { exportSession in
                 
                    guard let session = exportSession else {
                       return
                   }

                   switch session.status {
                   case .unknown:
                       break
                   case .waiting:
                       break
                   case .exporting:
                       break
                   case .completed:
                       guard let compressedData = try? Data(contentsOf: compressedURL) else {
                           return
                       }

                       print("File size after compression: \(Double(compressedData.count / 1048576)) mb")
                       
                       self.delegate?.fileOutput(output, didFinishRecordingTo: compressedURL, from: connections, error: error)
                       
                   case .failed:
                       break
                   case .cancelled:
                       break
                   }
               }
     
    
    }
    
    
    func compressVideo(inputURL: URL,
                          outputURL: URL,
                          handler:@escaping (_ exportSession: AVAssetExportSession?) -> Void) {
           let urlAsset = AVURLAsset(url: inputURL, options: nil)
           guard let exportSession = AVAssetExportSession(asset: urlAsset,
                                                          presetName: AVAssetExportPresetMediumQuality) else {
               handler(nil)

               return
           }

           exportSession.outputURL = outputURL
           exportSession.outputFileType = .mp4
           exportSession.exportAsynchronously {
               handler(exportSession)
           }
       }

}


