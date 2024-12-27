//
//  KeyCell.swift
//  Wordle
//
//  Created by Palina Skakun
//

import UIKit

// Add this extension to hold all custom colors
extension UIColor {
    static let customBackground = UIColor(red: 18/255.0, green: 18/255.0, blue: 19/255.0, alpha: 1.0)
    static let customBorderColor = UIColor(red: 58/255.0, green: 58/255.0, blue: 60/255.0, alpha: 1.0)
    static let customGreen = UIColor(red: 97/255.0, green: 139/255.0, blue: 85/255.0, alpha: 1.0)
    static let customYellow = UIColor(red: 178/255.0, green: 159/255.0, blue: 76/255.0, alpha: 1.0)
}


class KeyCell: UICollectionViewCell {
    static let identifier = "KeyCell"

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Futura", size: 18)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .customBackground
        layer.borderWidth = 1
        layer.borderColor = UIColor.customBorderColor.cgColor
                
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        backgroundColor = .customBackground  // Changed from customBorderColor
        layer.borderWidth = 1
        layer.borderColor = UIColor.customBorderColor.cgColor
    }

    func configure(with key: String) {
        label.text = key.uppercased()
    }
    
}
