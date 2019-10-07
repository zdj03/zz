//
//  LiBottomCollectionView.swift
//  LiJinPinTu
//
//  Created by 周登杰 on 2019/10/3.
//  Copyright © 2019 zdj. All rights reserved.
//

import UIKit

class LiBottomCollectionView: UICollectionView {
    var longTapBegan: ((Puzzle, CGPoint) -> ())?
    var longTapChange: ((CGPoint) -> ())?
    var longTapEnded: (() -> ())?
    
    let cellIdentifier = "ZzLineCollectionViewCell"
    var viewModels = [Puzzle]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initView(){
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        dataSource = self
        
        register(LiBottomCollectionViewCell.self, forCellWithReuseIdentifier: "ZzLineCollectionViewCell")
    }
    
}


extension LiBottomCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ZzLineCollectionViewCell", for: indexPath) as! LiBottomCollectionViewCell
        cell.cellIndex = indexPath.row
        cell.gameIndex = viewModels[indexPath.row].tag
        cell.viewModel = viewModels[indexPath.row]

        cell.longTapBegan = { [weak self] index in
            guard let self = self else {
                return
            }
            guard self.viewModels.count != 0 else {
                return
            }
            self.longTapBegan?(self.viewModels[index], cell.center)
        }
        cell.longTapChange = {
            self.longTapChange?($0)
        }
        cell.longTapEnded = {
            self.viewModels.remove(at: $0)
            self.reloadData()
            self.longTapEnded?()
        }
        return cell
    }
}
