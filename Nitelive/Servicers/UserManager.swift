//
//  UserManager.swift
//  Nitelive
//
//  Created by Sam Santos on 5/12/22.
//
import Foundation
import Firebase
import MapKit
import GoogleSignIn

class UserManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    

    static let instance = UserManager()
    

    
    @Published var isUserCurrentlyLoggedOut = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    @Published var currentClub: Club? {
        didSet {
            if let currentClub = currentClub {
                print("about to create notification")
                self.createNotificationForNextEntryToClub(clubId: currentClub.id, clubLocation: currentClub.location)
            }
        }
    }
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
        fetchUserLocation()
        listenToCheckCurrentUserIsSignedIn()
    }

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
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
        checkOutCurrentClub()
    }
    
    
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
                            print("Error setting user data when checking in")
                            return
                        }
                        self.currentClub = club
                    }
                
                
                FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(currentUser!.uid).collection(FirebaseConstants.checkedIn)
                    .document(FirebaseConstants.checkedInClub).setData(club.asDictionary) { err in

                        if let err = err {
                            print(err)
                          
                            print("error setting club data in user when checking in")
                            return
                        }
                    }
   
                FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(club.id).updateData([FirebaseConstants.checkedIN : FieldValue.increment(Int64(1))]) { err in
                    if let err = err {
                        print(err)
                      
                        print("error when incrementing club number")
                        return
                    }
                }
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
        print("Checking out....")

        if currentUser != nil {
           
            FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(currentClub!.id).collection(FirebaseConstants.checkedInUsers).document(currentUser!.uid).delete()
            
            
            FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(currentUser!.uid).collection(FirebaseConstants.checkedIn).document(FirebaseConstants.checkedInClub).delete()
            
            FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(currentClub!.id).updateData([FirebaseConstants.checkedIN : FieldValue.increment(Int64(-1))])
            
            self.currentClub = nil
            self.currentUser = nil

            
        }
        
       
    }
    
    /// Uploads video to user's current club.
    /// ```
    /// This function uploads the video the user just created into the current club they are checked in at the moment. 
    /// ```
    
    func uploadVideo(videoUrl: URL?, handler: @escaping(Result<Bool, Error>)->Void) {
        
        guard let clubId = currentClub?.id else { return }
        guard let videoURL = videoUrl else {return}
        guard let clubName = currentClub?.name else {return}
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        let videoId = "\(UUID().uuidString)"
        
        let storageRef = FirebaseManager.shared.storage.reference(withPath: "\(FirebaseConstants.locationVideos)/\(clubId)/\(videoId)")
        
        storageRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            
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
                                      FirebaseConstants.id: videoId,
                                      FirebaseConstants.clubId: clubId,
                                      FirebaseConstants.clubName: clubName
                                     ])
              
              handler(.success(true))
              
            }
        }
        
    }
    
    
    func fetchUserLocation() {
        checkIfLocationServicesIsEnabled()
    }
   
    func createNotificationForNextEntryToClub(clubId: String, clubLocation: CLLocation) {
        NotificationManager.instance.scheduleLocationNotification(clubId: clubId, clubLocation: clubLocation)
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
    
    func listenToCheckCurrentUserIsSignedIn() {
        let _ = FirebaseManager.shared.auth.addStateDidChangeListener { auth, user in
            
            if user == nil {
                self.checkOutCurrentClub()
            }
            
            
          }
    }
}
