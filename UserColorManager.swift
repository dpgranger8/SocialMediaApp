//
//  UserColorManager.swift
//  techSocialMediaApp
//
//  Created by David Granger on 7/3/23.
//

import Foundation
import UIKit

class UserColorManager {
    static let shared = UserColorManager()
    
    private let userDefaultsKey = "UserColorAssociations6"
    private var userColorAssociations: [String: String] = [:]  // We save colors as hex strings and also convert UUID to String
    
    private init() {
        loadUserColorAssociations()
    }
    
    // Get the color associated with a user. If a user does not have a color associated with them yet, a unique one is created.
    func color(for user: UUID) -> UIColor {
        let userID = user.uuidString
        if let colorString = userColorAssociations[userID], let color = UIColor(rgbHexString: colorString) {
            return color
        } else {
            let newColor = generateUniqueColor()
            userColorAssociations[userID] = newColor.rgbHexString
            saveUserColorAssociations()
            return newColor
        }
    }
    
    // Generates a unique color that no other user has.
    private func generateUniqueColor() -> UIColor {
        var newColor: UIColor
        repeat {
            newColor = UIColor(hue: CGFloat.random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
        } while userColorAssociations.values.contains(newColor.rgbHexString ?? "")
        return newColor
    }
    
    private func saveUserColorAssociations() {
        UserDefaults.standard.set(userColorAssociations, forKey: userDefaultsKey)
    }
    
    private func loadUserColorAssociations() {
        if let loadedAssociations = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] {
            self.userColorAssociations = loadedAssociations
        }
    }
}

extension UIColor {
    var rgbHexString: String? {
        guard let components = cgColor.components, components.count >= 3 else { return nil }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
    
    convenience init?(rgbHexString: String) {
        var chars = Array(rgbHexString.hasPrefix("#") ? rgbHexString.dropFirst() : rgbHexString[...])
        let r, g, b: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F","F","F"] + chars
            fallthrough
        case 8:
            r = .init(strtoul(String(chars[0...1]), nil, 16)) / 255
            g = .init(strtoul(String(chars[2...3]), nil, 16)) / 255
            b = .init(strtoul(String(chars[4...5]), nil, 16)) / 255
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
