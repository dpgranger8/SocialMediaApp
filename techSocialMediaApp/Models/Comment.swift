//
//  Comment.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/27/23.
//

import Foundation

struct Comment: Codable {
    var commentId: Int
    var userName: String
    var body: String
    var userId: UUID
    var createdDate: String
}
