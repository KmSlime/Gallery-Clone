//
//  AppConfigurator.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import Foundation

final class AppConfigurator: NSObject {
    @objc static let shared = AppConfigurator()
    
    private override init() {}
    private let infoPlistDictionary = Bundle.main.infoDictionary

    var version: String {
        return readFromInfoPlist(withKey: "CFBundleShortVersionString") ?? "(unknown app version)"
    }
    var build: String {
        readFromInfoPlist(withKey: "CFBundleVersion") ?? "(unknown build number)"
    }
    var fullVersion: String {
        "\(version).\(build)"
    }

    private func readFromInfoPlist(withKey key: String) -> String? {
        return infoPlistDictionary?[key] as? String
    }
}
