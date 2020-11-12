//
//  AQIController.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/12/20.
//

import UIKit
import WebKit
import BLTNBoard

class AQIController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    lazy var page: BLTNPageItem = {
        let page = BLTNPageItem(title: "Air Quality Index")
        page.image = UIImage(named: "aqipic")
        page.actionButtonTitle = "AQI Level Meaning"
        page.actionHandler = { (item: BLTNActionItem) in
            self.bulletinManager.push(item: self.secondPage)
        }
        return page
    }()
    
    lazy var secondPage: BLTNPageItem = {
        let secondPage = BLTNPageItem(title: "AQI Level Meaning")
        secondPage.image = UIImage(named: "aqilevel")
        secondPage.actionButtonTitle = "Go Back"
        secondPage.requiresCloseButton = false
        secondPage.actionHandler = { (item: BLTNActionItem) in
            self.bulletinManager.popItem()
        }
        return secondPage
    }()
    
    lazy var bulletinManager: BLTNItemManager = {
        return BLTNItemManager(rootItem: page)
    }()
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://www.airnow.gov/aqi")
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
        configureNavBarUI()
    }
    
    func configureNavBarUI() {
        //navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.06827291846, green: 0.363468945, blue: 0.6001564264, alpha: 1)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = "Air Quality Information"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)]
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.backward"), style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(handleInfo))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
    }
    
    @objc func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleInfo() {
        bulletinManager.showBulletin(above: self)
        
    }
}
