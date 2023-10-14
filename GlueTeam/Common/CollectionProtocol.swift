//
//  CollectionProtocol.swift
//  GlueTeam
//
//  Created by Bui Tan Sang on 14/10/2023.
//

import UIKit

public protocol Reusable: AnyObject {
    static var identifier: String { get }
    static var nib: UINib? { get }
}

extension Reusable {
    public static var identifier: String { String(describing: Self.self) }
    public static var nib: UINib? { UINib(nibName: identifier, bundle: nil) }
}

public protocol Configurable: AnyObject {
    associatedtype Model
    func configure(model: Model?)
}
