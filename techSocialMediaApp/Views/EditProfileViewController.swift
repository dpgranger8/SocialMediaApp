//
//  EditProfileViewController.swift
//  techSocialMediaApp
//
//  Created by David Granger on 7/7/23.
//

import UIKit

class EditProfileViewController: UIViewController, UITextViewDelegate {

    let defaults = UserDefaults.standard
    var delegate: ModalDelegate?
    
    let bioPlaceholderLabel = UILabel()
    let techInterestsPlaceholderLabel = UILabel()
    
    @IBOutlet weak var techInterestsTV: UITextView!
    @IBOutlet weak var bioTV: UITextView!
    
    @IBAction func saveButton(_ sender: Any) {
        let alert = UIAlertController(title: "Save", message: "Are you sure you want to edit your profile?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            Task {
                try await APIController.shared.updateProfile(bio: self.bioTV.text ?? "", techInterests: self.techInterestsTV.text ?? "")
                self.bioTV.text = ""
                self.techInterestsTV.text = ""
                self.dismiss(animated: true)
                self.delegate?.modalDismissed()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bioTV.delegate = self
        techInterestsTV.delegate = self
    }
    
    func setupPlaceholders() {
        bioPlaceholderLabel.text = "Bio"
        bioPlaceholderLabel.sizeToFit()
        bioTV.addSubview(bioPlaceholderLabel)
        bioPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (bioTV.font?.pointSize)! / 2)
        bioPlaceholderLabel.textColor = UIColor.lightGray
        bioPlaceholderLabel.isHidden = !bioTV.text.isEmpty
        
        techInterestsPlaceholderLabel.text = "Tech Interests"
        techInterestsPlaceholderLabel.sizeToFit()
        techInterestsTV.addSubview(techInterestsPlaceholderLabel)
        techInterestsPlaceholderLabel.frame.origin = CGPoint(x: 5, y: (techInterestsTV.font?.pointSize)! / 2)
        techInterestsPlaceholderLabel.textColor = UIColor.lightGray
        techInterestsPlaceholderLabel.isHidden = !techInterestsTV.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholderLabel.isHidden = !bioTV.text.isEmpty
    }

    override func viewWillAppear(_ animated: Bool) {
        bioTV.text = defaults.object(forKey: "Bio Field") as? String
        techInterestsTV.text = defaults.object(forKey: "Tech Interests Field") as? String
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if bioTV.text != "" || techInterestsTV.text != "" {
            defaults.set(bioTV.text, forKey: "Bio Field")
            defaults.set(techInterestsTV.text, forKey: "Tech Interests Field")
        }
    }

}
