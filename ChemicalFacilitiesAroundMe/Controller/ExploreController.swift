//
//  ExploreController.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/20/20.
//

import UIKit
import WebKit

class ExploreController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var contact: [String] = ["+18002414113","+14046564713","+14043637000"]
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://epd.georgia.gov/air-protection-branch")
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
        configureNavBarUI()
    }
    
    func configureNavBarUI() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.0006859748974, green: 0.1958666146, blue: 0.2296158075, alpha: 1)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = "EPD Official Website"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.backward"), style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "phone.circle"), style: .plain, target: self, action: #selector(handleContact))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
    }
    
    @objc func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleContact() {
        let emergencyURL = URL(string: "tel://\(contact[0])")
        let generalURL = URL(string: "tel://\(contact[1])")
        let airURL = URL(string: "tel://\(contact[2])")
        let alert = UIAlertController(title: ("Contact Georgia Environmental Protection Division"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Environmental Emergencies", style: .default, handler: { (action) in
            UIApplication.shared.open(emergencyURL!)
        }))
        alert.addAction(UIAlertAction(title: "General Questions", style: .default, handler: { (action) in
            UIApplication.shared.open(generalURL!)
        }))
        alert.addAction(UIAlertAction(title: "Air Protection Branch", style: .default, handler: { (action) in
            UIApplication.shared.open(airURL!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
