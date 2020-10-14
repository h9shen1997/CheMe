//
//  MenuPanelController.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/8/20.
//

import UIKit

class MenuPanelController: UIViewController {
    private let reuseIdentifier = "menuCell"
    
    var tableView: UITableView!
    var delegate: MapViewControllerDelegate?
    var footerView: UIView!
    var menuLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.8549019608, blue: 0.7176470588, alpha: 1)
        configureMenuLabel()
        configureTableView()
    }
    
    func configureMenuLabel() {
        menuLabel = UILabel()
        menuLabel.textAlignment = .center
        menuLabel.text = "Menu"
        menuLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        menuLabel.textColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        menuLabel.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.8549019608, blue: 0.7176470588, alpha: 1)
        
        view.addSubview(menuLabel)
        menuLabel.translatesAutoresizingMaskIntoConstraints = false
        menuLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        menuLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.8549019608, blue: 0.7176470588, alpha: 1)
        tableView.rowHeight = 70
        
        view.addSubview(tableView)
        
        tableView.register(MenuOptionCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 85).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        let footer = UIView()
        footer.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.8549019608, blue: 0.7176470588, alpha: 1)
        tableView.tableFooterView = footer
        
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        tableView.tableHeaderView = line
        line.backgroundColor = tableView.separatorColor
    }
}

extension MenuPanelController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MenuOptionCell
        let menuOption = MenuOption(rawValue: indexPath.row)
        cell.menuLabel.text = menuOption?.description
        cell.menuImage.image = menuOption?.image
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("this line is run")
        let menuOption = MenuOption(rawValue: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.toggleMenuPanel(forMenuOption: menuOption)
    }

}
