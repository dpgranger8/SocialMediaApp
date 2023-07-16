//
//  NewPostViewController.swift
//  techSocialMediaApp
//
//  Created by David Granger on 7/5/23.
//

import UIKit

class NewPostViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    var delegate: ModalDelegate?
    
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var bodyTF: UITextField!
    
    @IBAction func doneButton(_ sender: Any) {
        let alert = UIAlertController(title: "Create Post", message: "Are you sure you want to make this post?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Post", style: .default, handler: { action in
            Task {
                try await APIController.shared.createPost(title: self.titleTF.text ?? "", body: self.bodyTF.text ?? "")
                self.titleTF.text = ""
                self.bodyTF.text = ""
                self.dismiss(animated: true)
                //self.delegate?.modalDismissed()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTF.delegate = self
        bodyTF.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTF.resignFirstResponder()
        bodyTF.resignFirstResponder()
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        titleTF.text = defaults.object(forKey: "Title Field") as? String
        bodyTF.text = defaults.object(forKey: "Body Field") as? String
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        defaults.set(titleTF.text, forKey: "Title Field")
        defaults.set(bodyTF.text, forKey: "Body Field")
    }
}
