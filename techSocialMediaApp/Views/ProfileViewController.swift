//
//  ProfileViewController.swift
//  techSocialMediaApp
//
//  Created by David Granger on 7/7/23.
//

import UIKit

class ProfileViewController: UIViewController, ModalDelegate {
    
    func modalDismissed() {
        fetchUserProfile()
    }
    
    var userBeingDisplayed: User? = User.current
    var profileBeingDisplayed: Profile? {
        didSet {
            nameLabel.text = (profileBeingDisplayed?.firstName ?? "") + " " + (profileBeingDisplayed?.lastName ?? "")
            userNameLabel.text = profileBeingDisplayed?.userName
            bioLabel.text = profileBeingDisplayed?.bio
            techInterestsLabel.text = profileBeingDisplayed?.techInterests
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var techInterestsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserProfile()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            let modalVC = segue.destination as! EditProfileViewController
            modalVC.delegate = self
        }
    }
    
    func fetchUserProfile() {
        guard let user = userBeingDisplayed else { return }
        Task {
            try await profileBeingDisplayed = APIController.shared.getProfile(for: user)
        }
    }
    
}
