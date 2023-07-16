//
//  ContainerViewController.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/30/23.
//

import UIKit

class ContainerViewController: UIViewController {

    
    @IBOutlet weak var PrettyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PrettyView.layer.cornerRadius = 15
        PrettyView.backgroundColor = UIColor(red: 118/255.0, green: 214/255.0, blue: 255/255.0, alpha: 1)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
