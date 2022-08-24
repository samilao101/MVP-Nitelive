//
//  UserManager.swift
//  Nitelive
//
//  Created by Sam Santos on 5/12/22.
//
import Foundation
import Firebase
import MapKit

class UserManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    

    @Published var isUserCurrentlyLoggedOut = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    @Published var currentClub: Club? 
    @Published var alertItem: AlertItem?
    @Published var profileImage: UIImage? = nil
    
    @Published var gotUserLocation: Bool = false
    @Published var location: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    
    
    
    var locationManager: CLLocationManager?
    
  
    override init() {
        super.init()
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
        
        fetchCurrentClub()
        
        fetchUserLocation()
        
    }

    /// Fetchs the current user using the app information from Firebase if they are logged in and stores it in UserManager.
    /// ```
    /// If the user is logged into Firebase this functions downloads their information and stores
    /// it in UserManager as well as the FirebaseManager singleton.
    /// ```

    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data  = snapshot?.data() else {return}
                        
            self.currentUser = User(data: data)
            
            if self.currentUser != nil {
                FirebaseManager.shared.currentUser = self.currentUser
                self.getProfileImage(imageId: self.currentUser!.id)
            } else {
                self.isUserCurrentlyLoggedOut = true
            }
        }
    }
    
    /// Checks if the user is 'Checked In' into any of the clubs and if so downloads that clubs informaiton.
    /// ```
    /// The user is able to check in a club based on their proximity of the clubs location and if they
    ///  are checked in this functions downloads that  clubs information.
    /// ```
    
    func fetchCurrentClub() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        
        
        FirebaseManager.shared.firestore.collection("users").document(uid).collection(FirebaseConstants.checkedIn).document(FirebaseConstants.checkedInClub)
            .getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch current user: \(error)"
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                
                self.currentClub = Club(id: data["id"] as? String ?? "", data: data)
               
               
            }
        
    }
    
    /// Signs the current user out of Firebase
    /// ```
    /// This functions signs the current user out of Firebase and sets the current club that ther user is checked in to nil.
    /// ```
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        currentClub = nil
        currentUser = nil
    }
    
    
    /// Checks in the current user into a club.
    /// ```
    /// This function first checks if the current user is checked into any other club, and if it is, it checks them out and checks them
    /// into the current club. It also increments the number of users of user checked into the new club by 1.
    /// ```
    
    func checkInCurrentClub(club: Club) {
      
       
        guard let uid = currentUser?.uid else {return}
       
        if currentClub != nil {
            if currentClub!.id != club.id {
                
                alertItem = AlertContext.checkedOutOfOtherClub
                
                self.checkOutCurrentClub()
                
                FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(club.id).collection(FirebaseConstants.checkedInUsers)
                    .document(uid).setData(currentUser!.asDictionary) { err in

                        if let err = err {
                            print(err)
                           

                            return

                        }
                      

                        self.currentClub = club
                    }
                
                
                FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(currentUser!.uid).collection(FirebaseConstants.checkedIn)
                    .document(FirebaseConstants.checkedInClub).setData(club.asDictionary) { err in

                        if let err = err {
                            print(err)
                          

                            return
                        }
                      
                    
                    }
                
                
                FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(club.id).updateData([FirebaseConstants.checkedIN : FieldValue.increment(Int64(1))])
            }
               
            
        } else {
            FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(club.id).collection(FirebaseConstants.checkedInUsers)
                .document(uid).setData(currentUser!.asDictionary) { err in

                    if let err = err {
                        print(err)
                       

                        return

                    }
                  

                    self.currentClub = club
                }
            
            
            FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(currentUser!.uid).collection(FirebaseConstants.checkedIn)
                .document(FirebaseConstants.checkedInClub).setData(club.asDictionary) { err in

                    if let err = err {
                        print(err)
                      

                        return
                    }
                  
                
                }
            
            
            FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(club.id).updateData([FirebaseConstants.checkedIN : FieldValue.increment(Int64(1))])
        }

        
        
        
        
    }
    
    /// Checks the users out of current club.
    /// ```
    /// This functions checks the user out of any club they are checked in, decrements the number of users in that club by one.
    /// ```
    
    func checkOutCurrentClub() {
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(currentClub!.id).collection(FirebaseConstants.checkedInUsers).document(currentUser!.uid).delete()
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(currentUser!.uid).collection(FirebaseConstants.checkedIn).document(FirebaseConstants.checkedInClub).delete()
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(currentClub!.id).updateData([FirebaseConstants.checkedIN : FieldValue.increment(Int64(-1))])
        
        self.currentClub = nil
    }
    
    /// Uploads video to user's current club.
    /// ```
    /// This function uploads the video the user just created into the current club they are checked in at the moment. 
    /// ```
    
    func uploadVideo(videoUrl: URL?, handler: @escaping(Result<Bool, Error>)->Void) {
        
        guard let clubId = currentClub?.id else { return }
        guard let videoURL = videoUrl else {return}
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        let videoId = "\(UUID().uuidString)"
        
        let storageRef = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.locationVideos)/\(clubId)/\(videoId)")
        
        storageRef.putFile(from: videoURL, metadata: nil) { metadata, error in
//          guard let metadata = metadata else {
//            // Uh-oh, an error occurred!
//            return
//          }
          // Metadata contains file metadata such as size, content-type.
//          let size = metadata.size
          // You can also access to download URL after upload.
            
            if let error = error {
                handler(.failure(error))
            }
            
          storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                handler(.failure(error!))
              return
            }
              FirebaseManager.shared.firestore.collection(FirebaseConstants.locationVideos)
                  .addDocument(data: [FirebaseConstants.videoUrl: downloadURL.absoluteString,
                                      FirebaseConstants.timestamp: dateString,
                                      FirebaseConstants.fromId: self.currentUser!.uid,
                                      FirebaseConstants.email: self.currentUser!.email,
                                      FirebaseConstants.profileImageUrl: self.currentUser!.profileImageUrl,
                                      FirebaseConstants.id: videoId, FirebaseConstants.clubId: clubId])
              
              handler(.success(true))
              
          }
            
            
        }
        
        
    }
    
    
    func fetchUserLocation() {
        checkIfLocationServicesIsEnabled()
        
    }
    
    
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
        } else {
            print("show alert asking them to turn it on")
        }
        
        
        
    }
    
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
                gotUserLocation = false
        case .restricted:
            print("your location is restricted")
                gotUserLocation = false
        case .denied:
            print("you have denied this app location permission. go into authorizations to use it.")
                gotUserLocation = false
        case .authorizedAlways, .authorizedWhenInUse:
            if locationManager.location != nil {
                location = locationManager.location!.coordinate
                region = MKCoordinateRegion(center: location!, span: MapDetails.defaultSpan)
               
                   gotUserLocation = true
               
            }
             
          
        @unknown default:
            break
        }
        
        

    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func getProfileImage(imageId: String) {
        DispatchQueue.main.async {
            self.downloadImage(uid: imageId) { result in
                switch result {
                case .success(let downloadedImage):
                    self.profileImage = downloadedImage
                case .failure(_):
                    break
                }
            }
        }
        
    }
    
    func downloadImage(uid: String, handler: @escaping(Result<UIImage, Error>)->Void) {
        
        let logoStorage = FirebaseManager.shared.storage.reference().child("profileImages/\(uid)/\(uid)")

        
        logoStorage.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            print(error.localizedDescription)
              return
          } else {
            let image = UIImage(data: data!)
            guard let newimage = image else { return }
            print("got profile image")
            handler(.success(newimage))
          }

        }
        
    }
}
