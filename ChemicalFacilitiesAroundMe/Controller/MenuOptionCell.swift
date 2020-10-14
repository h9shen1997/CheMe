//
//  MenuCell.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/8/20.
//

import UIKit

class MenuOptionCell: UITableViewCell {

    let menuImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let menuLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.2235294118, green: 0.231372549, blue: 0.2666666667, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = ""
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(menuImage)
        menuImage.translatesAutoresizingMaskIntoConstraints = false
        menuImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        menuImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        menuImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        addSubview(menuLabel)
        menuLabel.translatesAutoresizingMaskIntoConstraints = false
        menuLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        menuLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50).isActive = true
        backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.8549019608, blue: 0.7176470588, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
