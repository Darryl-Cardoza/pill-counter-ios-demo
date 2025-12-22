//
//  ConfigurationManager.swift
//  PillCounter
//
//  Created by HC on 04/11/25.
//

import Foundation

//
// ConfigurationManager.swift
// PillCounter
//

final class ConfigurationManager {
    static let shared = ConfigurationManager()
    private var config: [String: Any] = [:]

    private init() {
        loadFromBundle()
    }

    /// Loads the Config.plist from the app bundle
    private func loadFromBundle() {
        guard
            let url = Bundle.main.url(
                forResource: "Config", withExtension: "plist"),
            let data = try? Data(contentsOf: url)
        else {
            return
        }

        do {
            if let dict = try PropertyListSerialization.propertyList(
                from: data, options: [], format: nil) as? [String: Any]
            {
                config = dict
            }
        } catch {
            print("❌ Failed to load plist:", error.localizedDescription)
        }
    }

    // MARK: - Public Accessors
    func getValue(forKey key: String) -> Any? {
        config[key]
    }

    var apiBaseURL: String {
        config["BASE_URL"] as? String ?? ""
    }

    var xServerKey: String {
        config["X_SERVER_KEY"] as? String ?? ""
    }
}
