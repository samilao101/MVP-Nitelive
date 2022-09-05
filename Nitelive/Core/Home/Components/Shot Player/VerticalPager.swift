//
//  VerticalPager.swift
//  Nitelive
//
//  Created by Sam Santos on 6/1/22.
//

import SwiftUI
import AVFoundation

struct VerticalPager: UIViewControllerRepresentable{
    typealias UIViewControllerType = UIPageViewController
    
     var nextController :ShotViewHostingController?
     var previousController :ShotViewHostingController?
    
    var controllers: [ShotViewHostingController] = []
    
    var numberOfControllersLoaded = 0
    
    @StateObject var userManager: UserManager
    @StateObject var clubData: FirebaseData
    @ObservedObject var loader: ShotLoader
    @Binding var isGone: Bool
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
        var parent: VerticalPager
        init(_ parent: VerticalPager){
            self.parent = parent
        }
        
        //Creates previous view
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            parent.viewController(withOffset: 1, from: viewController)
        }
        
        //creates next view
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            parent.viewController(withOffset: -1, from: viewController)
        }
        
       //pause all others
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed {
                previousViewControllers.forEach { previousController in
                    if let controller = previousController as? ShotViewHostingController {
                        controller.player.seek(to: .zero) { completed in
                            controller.player.pause()
                        }
                    }
                }
            }
        }
        
        //repeat plays
        
        func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
            pendingViewControllers.forEach { pendingController in
                if let controller = pendingController as? ShotViewHostingController {
                    controller.player.seek(to: .zero) { completed in
                        controller.player.play()
                    }
                }
            }
        }
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //creates view controller based on the offset
    mutating func viewController(withOffset offset: Int, from viewController: UIViewController)->ShotViewHostingController?{
        
        if let controller = viewController as? ShotViewHostingController, let index = loader.shots.firstIndex(where: {$0.id == controller.shot.id}), index + offset >= 0, index + offset < loader.shots.count
        
        {
            
            
        return ShotViewHostingController(shot: loader.shots[index + offset], club: loader.getClubById(clubId: loader.shots[index + offset].clubId), userManager: userManager, clubData: clubData)
            
            
            
//            let numberOfShots = loader.shots.count
//            let currentIndex = index + offset
//
//
//            if currentIndex == 1 {
//
//                let currentController = ShotViewHostingController(shot: loader.shots[currentIndex], club: loader.getClubById(clubId: loader.shots[currentIndex].clubId), userManager: userManager, clubData: clubData)
//
//
//                if currentIndex + 1 < numberOfShots {
//                    let previousController = controller
//                    controllers.append(previousController)
//                    controllers.append(currentController)
//                    let nextController = ShotViewHostingController(shot: loader.shots[currentIndex + 1], club: loader.getClubById(clubId: loader.shots[currentIndex + 1].clubId), userManager: userManager, clubData: clubData)
//                    controllers.append(nextController)
//                    numberOfControllersLoaded = 3
//                }
//                return currentController
//            } else {
//
//                if numberOfControllersLoaded - currentIndex > 2 {
//
//                    return controllers[currentIndex]
//
//                }
//
//                    if currentIndex + 1 < numberOfShots {
//                        let nextController = ShotViewHostingController(shot: loader.shots[currentIndex + 1], club: loader.getClubById(clubId: loader.shots[currentIndex + 1].clubId), userManager: userManager, clubData: clubData)
//                        nextController.viewDidLoad()
//                        controllers.append(nextController)
//                        print("adding")
//                        numberOfControllersLoaded += 1
//                    }
//
//
//                return controllers[currentIndex]
//            }
            
            
            
//            if index + offset + 1 < loader.shots.count {
//
//                nextController = ShotViewHostingController(shot: loader.shots[index + offset + 1], club: loader.getClubById(clubId: loader.shots[index + offset + 1].clubId), userManager: userManager, clubData: clubData)
//
//            }
//
//            if index + offset - 1 > 0 {
//
//                previousController = ShotViewHostingController(shot: loader.shots[index + offset - 1], club: loader.getClubById(clubId: loader.shots[index + offset - 1].clubId), userManager: userManager, clubData: clubData)
//
//            }
//
//
//            if index + offset == 1 {
//                nextController?.loadViewIfNeeded()
//                nextController?.view
//                print("loading next")
//                return currentController
//            }
//            if index + offset == 2 {
//                print("returning next")
//                return nextController
//            } else {
//                print("returning next")
//                return nextController
//            }
//
            
        }
        
        
        else
        {
            print("returning nil")
            return nil
        }
    }
    
    func makeUIViewController(context: Context) -> UIPageViewController {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.setViewControllers(
            [ShotViewHostingController(shot: loader.shots.first!, club: loader.getClubById(clubId: loader.shots.first!.clubId), userManager: userManager, clubData: clubData)],
            direction: .forward,
            animated: false
        )
        
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        if isGone {
            uiViewController.children.forEach { child in
            if let controller = child as? ShotViewHostingController {
                controller.player.pause()
            }
            }
        } else {
            uiViewController.children.forEach { child in
            if let controller = child as? ShotViewHostingController {
                controller.player.seek(to: .zero)
                controller.player.play()
            } 
            }
        }
    }
    
}

//uiViewController.parent?.children.forEach({ child in
//    if let controller = child as? ShotViewHostingController {
//        controller.shot.videoPlayer.seek(to: .zero) { completed in
//            print("pausing")
//            controller.shot.videoPlayer.play()
//        }
//    }
//})
