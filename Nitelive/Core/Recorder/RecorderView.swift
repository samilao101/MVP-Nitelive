//
//  RecorderView.swift
//  Nitelive
//
//  Created by Sam Santos on 5/14/22.
//

import SwiftUI
import AVKit


struct RecorderView: View {
    
    @State var videoURL : URL? = nil
    @State var startStop: Bool = false
    @State var animationAmount = 1.0
    @Binding var showRecorder: Bool
    @EnvironmentObject var vm : UserManager
    @State var uploadingVideo = false
    @State var errorUploadingVideo = false
    @State var flipCamera: Bool = false

    
    var body: some View {
        ZStack {
            if videoURL != nil {
                ZStack{
                    Player(player: AVPlayer(url: videoURL!))
                         .ignoresSafeArea()
                    if uploadingVideo {
                        ProgressView("Uploading")
                            .frame(width: 100, height: 100, alignment: .center)
                            .scaleEffect(2)
                    }
                    
                    if errorUploadingVideo {
                        VStack {
                            Button {
                                errorUploadingVideo = false
                                vm.uploadVideo(videoUrl: videoURL){ res in dealWithResult(result: res)}
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Retry")
                                }
                            }
                            .font(.system(size: 24))
                            .foregroundColor(.white)

                        }
                    }
                    
                    VStack {
                        HStack{
                            VStack{
                                Button {
                                    videoURL = nil
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                Text("Cancel")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                          
                            .padding(.leading)
                            Spacer()
                            VStack{
                                Button {
                                    uploadingVideo = true
                                    vm.uploadVideo(videoUrl: videoURL){ res in dealWithResult(result: res)}
                                    
                                } label: {
                                    Image(systemName: "arrow.up.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                Text("Upload")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing)
                        }
                        .padding(40)
                        Spacer()

                    }
                }
            
            } else {
                ZStack{
                    VideoCameraView(videoURL: $videoURL, startStop: $startStop, flipCamera: $flipCamera)
                        .ignoresSafeArea()
                VStack {
                    HStack{
                        VStack{
                            Button {
                                
                                showRecorder.toggle()

                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            Text("Cancel")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }.padding(24)
                    Spacer()
                        
                        if !startStop {
                            VStack{
                                Button {
                                    
                                    flipCamera.toggle()
                             
                                } label: {
                                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                Text("Flip")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                
                            }.padding(24)
                        }
                        
                    }
                    Spacer()
                    Button {
                        startStop.toggle()
                        
                    } label: {
                        ZStack{
                            
                            if startStop {
                                Image(systemName: "circle")
                                    .font(.system(size: 72))
                                    .foregroundColor(.white)
                            } else {
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 72))
                                        .foregroundColor(.red)
                                    Image(systemName: "circle")
                                        .font(.system(size: 72))
                                        .foregroundColor(.white)
                                }
                              
                            }
                          
                            RecordingTimer(startStop: $startStop) {
                                startStop.toggle()
                            }
                        }.animation(.easeInOut(duration: 1).repeatForever(), value: startStop)
                   
                          
                    }
                    .padding(42)
                }
                }
            }
        }
    }
    
    func dealWithResult(result: Result<Bool, Error> ) {
        switch result {
        case .success(_):
            videoURL = nil
            showRecorder = false
            uploadingVideo = false 
        case .failure(let error):
            uploadingVideo = false
            errorUploadingVideo = true
            print(error.localizedDescription)
        }
    }
    
  
    
}
