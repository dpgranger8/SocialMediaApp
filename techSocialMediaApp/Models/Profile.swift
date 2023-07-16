//
//  Profile.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/26/23.
//

import Foundation

struct Profile: Codable {
    var firstName: String
    var lastName: String
    var userName: String
    var userUUID: String
    var bio: String
    var techInterests: String
    var posts: [Post]
}
