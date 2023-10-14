//
//  UICollectionViewExtension.swift
//  GlueTeam
//
//  Created by Bui Tan Sang on 14/10/2023.
//

import UIKit

extension UICollectionView {
    public func registerCell<T: Reusable>(reusable: T.Type) {
        self.register(reusable.nib, forCellWithReuseIdentifier: reusable.identifier)
    }
    
    public func dequeueCell<T>(at indexPath: IndexPath) -> T? where T: Reusable {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T
    }
}
