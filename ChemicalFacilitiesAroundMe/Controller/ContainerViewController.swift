//
//  ContainerViewController.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/8/20.
//

import UIKit

class ContainerViewController: UIViewController {

    var menuPanelController: MenuPanelController!
    var centerController: UIViewController!
    var mapViewController: MapViewController!
    var isExpanded = false
    
    let centerPanelExpandedOffset: CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapViewController()
        configureMenuPanelController()
        
        let panGesturerecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        centerController.view.addGestureRecognizer(panGesturerecognizer)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    func configureMapViewController() {
        mapViewController = MapViewController()
        mapViewController.delegate = self
        centerController = UINavigationController(rootViewController: mapViewController)
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
    }
    
    func configureMenuPanelController() {
        if menuPanelController == nil {
            print("menu panel was created")
            menuPanelController = MenuPanelController()
            menuPanelController.delegate = self
            view.insertSubview(menuPanelController.view, at: 0)
            addChild(menuPanelController)
            menuPanelController.didMove(toParent: self)
        }
    }
}

extension ContainerViewController: MapViewControllerDelegate {
    func toggleMenuPanel(forMenuOption menuOptions: MenuOption?) {
        if !isExpanded {
            configureMenuPanelController()
        }
        isExpanded = !isExpanded
        animateMenuPanel(shouldExpand: isExpanded, menuOption: nil)
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func animateMenuPanel(shouldExpand: Bool, menuOption: MenuOption?) {
        if shouldExpand {
            animateCenterPanelXPosition(targetPosition: centerController.view.frame.width
             - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0)
            
            animateCenterPanelXPosition(targetPosition: 0) { (_) in
                guard let menuOption = menuOption else { return }
                self.didSelectMenuOption(menuOption: menuOption)
            }
        }
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    func didSelectMenuOption(menuOption: MenuOption) {
        switch menuOption {
        case .Map:
            print("show Profile")
        case .AirQualityIndex:
            print("air quality index")
        case .Education:
            print("Education")
        case .Complaint:
            print("Complaint")
        case .Explore:
            print("explore")
        }
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if shouldShowShadow {
            centerController.view.layer.shadowOpacity = 0.8
        } else {
            centerController.view.layer.shadowOpacity = 0
        }
    }
    
    
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        switch recognizer.state {
        case .began:
            if !isExpanded {
                if gestureIsDraggingFromLeftToRight {
                    configureMenuPanelController()
                }
            }
            showShadowForCenterViewController(true)
        case .changed:
            if let rview = recognizer.view {
                rview.center.x = rview.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
        case .ended:
            if let _ = menuPanelController, let rview = recognizer.view {
                let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
                animateMenuPanel(shouldExpand: hasMovedGreaterThanHalfway, menuOption: nil)
            }
        default:
            break
        }
    }
}