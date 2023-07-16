//
//  Post.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/26/23.
//

import Foundation
import UIKit

struct Post: Codable, Hashable {
    var postid: Int
    var authorUserName: String
    var title: String
    var body: String
    var createdDate: String
    var authorUserId: UUID
    var numComments: Int
    var likes: Int
    var userLiked: Bool

    // Define only the properties you want to encode/decode.
    enum CodingKeys: String, CodingKey {
        case postid, authorUserName, title, body, createdDate, authorUserId, numComments, likes, userLiked
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(postid)
    }
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.postid == rhs.postid
    }
}
