//
//  FacilityController.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/11/20.
//

import UIKit

class FacilityController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBarUI()
        // Do any additional setup after loading the view.
    }
    
    func configureNavBarUI() {
        view.backgroundColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.7960784314, blue: 0.5568627451, alpha: 1)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = "Facility Info"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "delete.left"), style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "phone.circle"), style: .plain, target: self, action: #selector(handleContact))
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleContact() {
        
    }
}
