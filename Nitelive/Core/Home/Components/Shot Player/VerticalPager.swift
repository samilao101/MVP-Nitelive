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
    
    
    @StateObject var userManager: UserManager
    @StateObject var clubData: FirebaseData
    @ObservedObject var loader: ShotLoader
    @Binding var isGone: Bool
    
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
        var parent: VerticalPager
        init(_ parent: VerticalPager){
            self.parent = parent
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            parent.viewController(withOffset: 1, from: viewController)
        }
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            parent.viewController(withOffset: -1, from: viewController)
        }
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
    
    func viewController(withOffset offset: Int, from viewController: UIViewController)->ShotViewHostingController?{
        if let controller = viewController as? ShotViewHostingController, let index = loader.shots.firstIndex(where: {$0.id == controller.shot.id}), index + offset >= 0, index + offset < loader.shots.count
        {
            return ShotViewHostingController(shot: loader.shots[index + offset], club: loader.getClubById(clubId: loader.shots[index + offset].clubId), userManager: userManager, clubData: clubData)
        }else{
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
