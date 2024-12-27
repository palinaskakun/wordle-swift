//
//  KeyboardViewController.swift
//  Wordle
//
//  Created by Palina Skakun on 12/26/24.
//

import UIKit

protocol KeyboardViewControllerDelegate: AnyObject {
    func keyboardViewController(
        _ vc: KeyboardViewController, didTapKey key: String
    )
}

class KeyboardViewController: UIViewController,
                              UICollectionViewDelegateFlowLayout,
                              UICollectionViewDelegate,
                              UICollectionViewDataSource{
    
    weak var delegate: KeyboardViewControllerDelegate?
    
    var letterColorDict: [String: UIColor] = [:]

    
    /// Each row is now an array of strings.
        private let rows: [[String]] = [
            Array("qwertyuiop").map { String($0) },
            Array("asdfghjkl").map { String($0) },
            ["ENT"] + Array("zxcvbnm").map { String($0) } + ["DEL"]
        ]
    
    private let collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .clear

        collectionView.register(KeyCell.self, forCellWithReuseIdentifier: KeyCell.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
        
    }
    
    // KeyboardViewController.swift
    func reloadKeys() {
        collectionView.reloadData()
    }

    
}

extension KeyboardViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return rows[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: KeyCell.identifier,
                for: indexPath
            ) as? KeyCell else {
            fatalError()
        }
        let key = rows[indexPath.section][indexPath.row]
        cell.configure(with: key)
        
        // Lookup the color (if any) from letterColorDict
                let lower = key.lowercased()
                
                // If it's ENT or DEL, skip color logic (or do as you like)
                if lower == "ent" || lower == "del" {
                    cell.backgroundColor = .customBorderColor
                } else {
                    // For normal letters:
                    if let color = letterColorDict[lower] {
                        cell.backgroundColor = color
                    } else {
                        // Default background
                        cell.backgroundColor = .customBackground
                    }
                }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let margin: CGFloat = 20
        let size: CGFloat = (collectionView.frame.size.width-margin)/10
        
        
        return CGSize (width: size, height: size*1.5)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let margin: CGFloat = 20
        let size: CGFloat = (collectionView.frame.size.width - margin)/10
        let count = CGFloat(collectionView.numberOfItems(inSection: section))
        let totalWidth = count * size + (2 * count)
        let leftover = collectionView.frame.size.width - totalWidth
        let inset: CGFloat = leftover/2
        
        return UIEdgeInsets(top: 2, left: inset, bottom: 2, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        //
        let key = rows[indexPath.section][indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: true)
        
        delegate?.keyboardViewController(self, didTapKey: key)
    }
}
