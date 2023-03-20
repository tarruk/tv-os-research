//
//  DevicePickerController.swift
//  PlatygroundtvOS
//
//  Created by Tarek Radovan on 17/03/2023.
//

import UIKit
import DeviceDiscoveryUI

final class DevicePickerController: UIViewController {

  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(
      DevicePickerTableViewCell.self,
      forCellReuseIdentifier: DevicePickerTableViewCell.identifier
    )
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViews()
  }
  
  func searchForDevices() async {
    // Check to see whether the device supports DDDevicePickerViewController.
    guard DDDevicePickerViewController.isSupported(
      .applicationService(name: "PlaygroundOS"),
      using: NWParameters.applicationService
    ) else {
      print("This device does not support DDDevicePickerViewController.")
      return
    }

    // Create the view controller for the device picker.
    guard let devicePicker = DDDevicePickerViewController(
      browseDescriptor: .applicationService(name: "PlaygroundOS"),
      parameters: NWParameters.applicationService
    ) else {
      print("Could not create device picker.")
      return
    }
    
    // Show the network device picker as a full-screen, modal view.
    self.present(devicePicker, animated: true)
    
    do {
      // Receive an endpoint asynchronously.
      let endpoint = try await devicePicker.endpoint
      sharedConnection = PeerConnection(endpoint: endpoint, delegate: self)
    } catch let error {
     // Handle any errors.
     print("There was an error with the endpointPicker: \(error)")
    }
  }
}

extension DevicePickerController: PeerConnectionDelegate {
  func connectionReady() {
    //
  }
  
  func connectionFailed() {
    //
  }
  
  func receivedMessage(content: Data?, message: NWProtocolFramer.Message) {
    //
  }
  
  func displayAdvertiseError(_ error: NWError) {
    //
  }
}

private extension DevicePickerController {
  
  func configureViews() {
    addViews()
    setConstraints()
    setStyles()
    tableView.reloadData()
  }
  
  func addViews() {
    view.addSubview(tableView)
  }
  
  func setConstraints() {
    NSLayoutConstraint.activate([
      tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
      tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
      tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
  
  func setStyles() {
    
  }
  
}

extension DevicePickerController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    Task {
      await searchForDevices()
    }
  }
}

extension DevicePickerController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: DevicePickerTableViewCell.identifier, for: indexPath) as? DevicePickerTableViewCell else {
      return UITableViewCell()
    }
    cell.configure(name: "Search for devices...")
    return cell
  }
}


import SwiftUI

struct DevicePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DevicePickerController
    
    func makeUIViewController(context: Context) -> DevicePickerController {
      DevicePickerController()
    }
    
    func updateUIViewController(_ uiViewController: DevicePickerController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}
