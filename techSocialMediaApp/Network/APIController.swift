 //
//  APIController.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/26/23.
//

import Foundation

class APIController {
    
    //Initialize reusable decoder and session
    let decoder = JSONDecoder()
    let session = URLSession.shared
    static let shared = APIController()
    
    enum APIError: Error, LocalizedError {
        case noCurrentUserError
        case userHasNoProfileError
        case invalidResponse
        case wasNot200
    }
    
    func getProfile(for user: User) async throws -> Profile {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        //Initialize our request
        var request = URLRequest(url: URL(string: "\(API.url)/userProfile")!)
        
        //Set the query parameters
        let parameters = ["userUUID": "\(user.userUUID.uuidString)", "userSecret": "\(user.secret.uuidString)"]
        let queryParameters = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        //Set the query items
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.url?.append(queryItems: queryParameters)
        
        // Make the request
        let (data, response) = try await session.data(for: request)
        
        //Ensure a good response from the API
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse) //prints the response for debugging purposes if the request fails for any reason
            throw APIError.wasNot200
        }
        
        let profile = try decoder.decode(Profile.self, from: data)
        
        return profile
    }
    
    func updateProfile(bio: String, techInterests: String) async throws {
        guard let user = User.current else {throw APIError.userHasNoProfileError} //current user must have profile information saved to update their profile on the API
        
        var request = URLRequest(url: URL(string: "\(API.url)/updateProfile")!)
        
        let body: [String: Any] = ["userSecret": user.secret.uuidString, "profile": ["userName": user.userName, "bio": bio, "techInterests": techInterests]]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse)
            throw APIError.wasNot200
        }
    }
    
    func getPosts(for pageNumber: Int) async throws -> [Post] {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/posts")!)
        
        let parameters = ["userSecret": "\(user.secret.uuidString)", "pageNumber": "\(pageNumber)"]
        let queryParameters = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.url?.append(queryItems: queryParameters)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse)
            throw APIError.wasNot200
        }
        
        let posts = try decoder.decode([Post].self, from: data)
        
        return posts
    }
    
    func createPost(title: String, body: String) async throws {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/createPost")!)
        
        let body: [String: Any] = ["userSecret": user.secret.uuidString, "post": ["title": title, "body": body]]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse) //prints the response for debugging purposes if the request fails for any reason
            throw APIError.wasNot200
        }
    }
    
    func updateLikeOrUnlike(for post: Post) async throws -> Post {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/updateLikes")!)
        
        let body: [String: Any] = ["userSecret": user.secret.uuidString, "postid": post.postid.description]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse) //prints the response for debugging purposes if the request fails for any reason
            throw APIError.wasNot200
        }
        
        let post = try decoder.decode(Post.self, from: data)
        
        return post
    }
    
    func getComments(for post: Post) async throws -> [Comment] {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/comments")!)
        
        let parameters = ["userSecret": "\(user.secret.uuidString)", "postid": "\(post.postid)"]
        let queryParameters = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.url?.append(queryItems: queryParameters)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse)
            throw APIError.wasNot200
        }
        
        let comments = try decoder.decode([Comment].self, from: data)
        
        return comments
    }
    
    func createComment(for post: Post, body: String) async throws -> Comment {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/createComment")!)
        
        let body: [String: Any] = ["userSecret": user.secret.uuidString, "commentBody": body, "postID": post.postid]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse)
            throw APIError.wasNot200
        }
        
        let comment = try decoder.decode(Comment.self, from: data)
        
        return comment
    }
    
    func deletePost(for post: Post) async throws {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/post")!)
        
        let parameters = ["userSecret": "\(user.secret.uuidString)", "postID": "\(post.postid)"]
        let queryParameters = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.url?.append(queryItems: queryParameters)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse)
            throw APIError.wasNot200
        }
    }
    
    func editPost(for post: Post) async throws {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/editPost")!)
        
        let body: [String: Any] = ["userSecret": user.secret.uuidString, "post": ["postID": post.postid, "title": post.title, "body": post.body] as [String : Any]]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse) //prints the response for debugging purposes if the request fails for any reason
            throw APIError.wasNot200
        }
    }
    
    func getUserPosts(userUUID: UUID, pageNumber: Int) async throws -> [Post] {
        guard let user = User.current else {throw APIError.noCurrentUserError} //function cannot work without a current user
        
        var request = URLRequest(url: URL(string: "\(API.url)/userPosts")!)
        
        let parameters = ["userSecret": "\(user.secret.uuidString)", "userUUID": "\(userUUID)", "pageNumber": "\(pageNumber)"]
        let queryParameters = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.url?.append(queryItems: queryParameters)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            print(httpResponse)
            throw APIError.wasNot200
        }
        
        let posts = try decoder.decode([Post].self, from: data)
        
        return posts
    }
    
}
