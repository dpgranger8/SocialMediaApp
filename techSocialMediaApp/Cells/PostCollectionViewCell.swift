//
//  PostCollectionViewCell.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/27/23.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PostCell"
    
    var item: Post?
    
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var SpaceView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postIDLabel: UILabel!
    @IBOutlet weak var numCommentsLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    func configure(item: Post) {
        self.item = item
        
        //custom color
        self.backgroundColor = generateDeterministicColor(from: item.authorUserId)
        self.layer.cornerRadius = 15
        self.SpaceView.backgroundColor = .white
        self.SpaceView.layer.cornerRadius = 10
        
        //shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.45
        self.layer.masksToBounds = false
        
        //configure like button state
        let imageName = item.userLiked ? "hand.thumbsup.fill" : "hand.thumbsup"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.setTitle(item.likes.description, for: .normal)
        
        //configure the rest of cell
        usernameLabel.text = item.authorUserName
        titleLabel.text = item.title
        numCommentsLabel.text = item.numComments.description + " comments >"
        createdDateLabel.text = convertDateFormat(inputDate: item.createdDate)
        postIDLabel.text = "# " + item.postid.description
    }
    
    func convertDateFormat(inputDate: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: inputDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy"
            
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .ordinal
            let dayString = numberFormatter.string(from: NSNumber(value: day))
            
            return outputFormatter.string(from: date).replacingOccurrences(of: "\(day)", with: "\(dayString ?? "")")
        }
        
        return nil
    }
    
    func generateDeterministicColor(from uuid: UUID) -> UIColor {
        // Convert UUID to data
        var uuidBytes = [UInt8](repeating: 0, count: 16)
        (uuid as NSUUID).getBytes(&uuidBytes)
        
        // Get the first three bytes and normalize them to [0,1]
        let red = CGFloat(uuidBytes[0]) / 255.0
        let green = CGFloat(uuidBytes[1]) / 255.0
        let blue = CGFloat(uuidBytes[2]) / 255.0
        
        // Create a UIColor from the RGB values
        return UIColor(red: red, green: green, blue: blue, alpha: 0.85)
    }
    
}

