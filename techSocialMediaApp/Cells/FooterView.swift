//
//  FooterView.swift
//  techSocialMediaApp
//
//  Created by David Granger on 6/28/23.
//

import Foundation
import UIKit

class FooterView: UICollectionReusableView {
  static let identifier = "FooterView"

  private let activityIndicator = UIActivityIndicatorView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    layout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func layout() {
    addSubview(activityIndicator)
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
      ])
    activityIndicator.hidesWhenStopped = true
  }

  func toggleLoading(isEnabled: Bool) {
    if isEnabled {
      activityIndicator.startAnimating()
    } else {
      activityIndicator.stopAnimating()
    }
  }
}
