//
//  BoardViewController.swift
//  Wordle
//
//  Created by Palina Skakun on 12/26/24.
//

import UIKit

protocol BoardViewControllerDatasource: AnyObject {
    var currentGuesses: [[Character?]] {get}
    //retrieve the color for a given cell
    
    func boxColor(at indexPath: IndexPath) -> UIColor?
}

// Add this class to BoardViewController.swift
class BoardCell: KeyCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = UIFont(name: "Futura-Bold", size: 36)  // Much bigger font for board letters
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class BoardViewController: UIViewController,
                            UICollectionViewDelegateFlowLayout, UICollectionViewDelegate,
                            UICollectionViewDataSource{
    
    weak var datasource: BoardViewControllerDatasource?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .clear

        collectionView.register(BoardCell.self, forCellWithReuseIdentifier: KeyCell.identifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])

    }
    
    public func reloadData() {
        collectionView.reloadData()
    }

}

extension BoardViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return datasource?.currentGuesses.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let guesses = datasource?.currentGuesses ?? []
        return guesses[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyCell.identifier, for: indexPath) as? KeyCell else {
            fatalError()
        }

        cell.backgroundColor = .customBackground
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.customBorderColor.cgColor
        
        let guesses = datasource?.currentGuesses ?? []
        if let letter =
            guesses[indexPath.section][indexPath.row] {
            
            cell.configure(with: String(letter))
            
            if indexPath.section == (datasource as? ViewController)?.currentRow {
                cell.backgroundColor = .customBackground
                cell.layer.borderColor = UIColor.customBorderColor.cgColor
            }
            
        }
        // Now get color from the datasource
        if let color = (datasource as? ViewController)?.boxColor(at: indexPath) {
            cell.backgroundColor = color
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let margin: CGFloat = 20
        let size: CGFloat = (collectionView.frame.size.width-margin)/5
        
        
        return CGSize (width: size, height: size)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(
            top: 2, left: 2, bottom: 2, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        //
    }
}

