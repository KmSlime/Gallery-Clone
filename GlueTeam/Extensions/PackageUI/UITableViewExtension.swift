//
//  UITableViewExtension.swift
//  GlueTeam
//
//  Created by Bui Tan Sang on 14/10/2023.
//

import UIKit

extension UITableView  {
    public func registerCell<T: Reusable>(reusable: T.Type) {
        self.register(reusable.nib, forCellReuseIdentifier: reusable.identifier)
    }
    
    public func dequeueCell<T>(at indexPath: IndexPath) -> T? where T: Reusable {
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T
    }
}
