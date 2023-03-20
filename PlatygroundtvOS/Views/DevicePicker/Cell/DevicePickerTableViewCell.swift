//
//  DevicePickerTableViewCell.swift
//  PlatygroundtvOS
//
//  Created by Tarek Radovan on 17/03/2023.
//

import UIKit

final class DevicePickerTableViewCell: UITableViewCell {
  static let identifier = "DevicePickerTableViewCell"
  
  private lazy var deviceNameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    label.minimumScaleFactor = 0.5
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(
    style: UITableViewCell.CellStyle,
    reuseIdentifier: String?
  ) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(name: String) {
    deviceNameLabel.text = name
  }
}

private extension DevicePickerTableViewCell {
  
  func configureViews() {
    addViews()
    setConstraints()
    setStyles()
  }
  
  func addViews() {
    contentView.addSubview(deviceNameLabel)
  }
  
  func setConstraints() {
    NSLayoutConstraint.activate([
      deviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      deviceNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
      deviceNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      deviceNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
    ])
  }
  
  func setStyles() {
    contentView.backgroundColor = .cyan
  }
}

