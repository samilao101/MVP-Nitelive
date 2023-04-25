//
//  UploadManager .swift
//  Nitelive
//
//  Created by Sam Santos on 4/25/23.
//

import Foundation
import FirebaseStorage

class UploadManager {
    
    var uploadCount = 0
    
    func uploadVideo(storageRef: StorageReference, handler: @escaping (Result<URL,Error>) -> Void, videoURL: URL ) {
        
        func upload() {
            
            uploadCount += 1

            
            storageRef.putFile(from: videoURL, metadata: nil) { metadata, error in
                
                if let error = error {
                    
                    if self.uploadCount < 4 {
                        upload()
                    } else {
                        handler(.failure(error))
                    }
                    
                }
                
                
                var downloadCount = 0
                
                func downloadURL() {
                    
                    downloadCount += 1
                    
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            
                            if downloadCount < 3 {
                                
                                downloadURL()
                                return
                            } else {
                                handler(.failure(error!))
                                return
                            }
                           
                        }
                        
                        handler(.success(downloadURL))
                        
                    }
                }
                
                downloadURL()
                
            }

        }
        
        upload()
        
    }
    
    
}
