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

class UserManager: ObservableObject {
    
    
    var clubs : [Club]?
    var userLocation: CLLocationCoordinate2D?
    @Published var nearClub: Bool = false
    @Published var clubThatIsNear: Club?
    private var timer: Timer? = nil

    static let instance = UserManager()
    
    private var storedUID: String?
    
    private var locationManagerClass = LocationManger()
    @Published var isUserCurrentlyLoggedOut = false
    @Published var errorMessage = ""
    @Published var currentUser: User? {
        didSet {
            
            guard let tempUID = currentUser?.uid else {return}
            storedUID = tempUID
        }
    }
    
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
    @Published var showLogin = false
    @Published var showListView = false
    var uploadManager = UploadManager()

    var locationManager: CLLocationManager?
  
    init(){
        
        
        
        fetchCurrentUser()
//        fetchUserLocation()
        self.gotUserLocation = locationManagerClass.gotUserLocation
        self.location = locationManagerClass.location
        listenToCheckCurrentUserIsSignedIn()
        startTimer()
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
        isUserCurrentlyLoggedOut = true
        try? FirebaseManager.shared.auth.signOut()
        currentUser = nil
        showLogin.toggle()
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
        
        }

        
        
        
        
    }
    
    /// Checks the users out of current club.
    /// ```
    /// This functions checks the user out of any club they are checked in, decrements the number of users in that club by one.
    /// ```
    
    func checkOutCurrentClub() {
        print("Checking out....")

        if storedUID != nil {
           
            print("Trying to check out with functions")
    
//            FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(storedUID!).collection(FirebaseConstants.checkedInUsers).document(storedUID!).delete()
//
//
//            FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(storedUID!).collection(FirebaseConstants.checkedIn).document(FirebaseConstants.checkedInClub).delete()
//
//            FirebaseManager.shared.firestore.collection(FirebaseConstants.locations).document(storedUID!).updateData([FirebaseConstants.checkedIN : FieldValue.increment(Int64(-1))])
//
            
            
            let userId = storedUID!
            let clubId = currentClub!.id
            
            let url = URL(string: "https://us-central1-tonight-2081c.cloudfunctions.net/logOutUser?userId=\(userId)&clubId=\(clubId)")!

            print("starting task")
            URLSession.shared.dataTask(with: url).resume()
            
          
            
            
            self.currentClub = nil

            
            
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
                
        uploadManager.uploadVideo(storageRef: storageRef, videoURL: videoURL) { result in
            switch result {
            case .success(let downloadURL):
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
            case .failure(let error):
                handler(.failure(error))
            }
        }
            
        
    }
    

   
    func createNotificationForNextEntryToClub(clubId: String, clubLocation: CLLocation) {
        NotificationManager.instance.scheduleLocationNotification(clubId: clubId, clubLocation: clubLocation)
    }


    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            print("location services not determined")
            locationManager.requestWhenInUseAuthorization()
                gotUserLocation = false
        case .restricted:
            print("your location is restricted")
                gotUserLocation = false
        case .denied:
            print("you have denied this app location permission. go into authorizations to use it.")
                gotUserLocation = false
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized to use location services")
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
    
    func checkIfNearAnyClub() {
        if clubs != nil {
            print("Checking if near club..")
            location = locationManagerClass.location
            gotUserLocation = locationManagerClass.gotUserLocation
            
            if let userLocation = location {
                print("Checking per location")
                clubs?.forEach { club in
                    let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    let distance = userLoc.distance(from: club.location)
                    if distance <  1609/16.09 //1609*102
                    {
                        print("checked in club")
                        clubThatIsNear = club
                        nearClub = true
                       checkInCurrentClub(club: club)
                    }
                }
                
                if !nearClub {
                       print("Not near any club")
                       clubThatIsNear = nil
                       nearClub = false
                       if currentClub != nil {
                           checkOutCurrentClub()
                        }
                }
                
            } else {
                print("no location services")
                clubThatIsNear = nil
                nearClub = false
                if currentClub != nil {
                    checkOutCurrentClub()
                }
                
               
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (timer) in
            print("Timer Fired")
            self.checkIfNearAnyClub()
        })
    }
}
