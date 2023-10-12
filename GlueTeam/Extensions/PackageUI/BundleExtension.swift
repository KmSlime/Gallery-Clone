//
//  BundleExtension.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import Foundation

extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}
