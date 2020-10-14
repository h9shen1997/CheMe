//
//  SubtitleTableViewCell.swift
//  ChemicalFacilitiesAroundMe
//
//  Created by Haotian Shen on 10/7/20.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = #colorLiteral(red: 1, green: 0.8352941176, blue: 0.4941176471, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
