//
//  PeerConnection.swift
//  PlaygroundOS
//
//  Created by Tarek Radovan on 16/03/2023.
//

import Foundation
import Network
import SwiftUI
import Combine

// Create parameters for use in PeerConnection and PeerListener with app services.
func applicationServiceParameters() -> NWParameters {
  let parameters = NWParameters.applicationService
  return parameters
}

var sharedConnection: PeerConnection?

protocol PeerConnectionDelegate: AnyObject {
  func connectionReady()
  func connectionFailed()
  func receivedMessage(content: Data?, message: NWProtocolFramer.Message)
  func displayAdvertiseError(_ error: NWError)
}

class PeerConnection: ObservableObject {
  
  weak var delegate: PeerConnectionDelegate?
  var connection: NWConnection?
  let endpoint: NWEndpoint?
  let initiatedConnection: Bool

  // Create an outbound connection when the user initiates a connection.
  init(endpoint: NWEndpoint, interface: NWInterface?, delegate: PeerConnectionDelegate) {
    self.delegate = delegate
    self.endpoint = nil
    self.initiatedConnection = true

    let connection = NWConnection(to: endpoint, using: NWParameters())
    self.connection = connection

    startConnection()
  }
    
  // Create an outbound connection when the user initiates a connection via DeviceDiscoveryUI.
  init(endpoint: NWEndpoint, delegate: PeerConnectionDelegate) {
    self.delegate = delegate
    self.endpoint = endpoint
    self.initiatedConnection = true

    // Create the NWConnection to the supplied endpoint.
    let connection = NWConnection(
      to: endpoint,
      using: applicationServiceParameters()
    )
    self.connection = connection

    startConnection()
  }

  // Handle an inbound connection when the user receives a connection request.
  init(connection: NWConnection) {
    self.endpoint = nil
    self.connection = connection
    self.initiatedConnection = false

    startConnection()
  }

  // Handle the user exiting the connection.
  func cancel() {
    if let connection = self.connection {
      connection.cancel()
      self.connection = nil
    }
  }

  // Handle starting the peer-to-peer connection for both inbound and outbound connections.
  func startConnection() {
    guard let connection = connection else {
      return
    }

    connection.stateUpdateHandler = { [weak self] newState in
    switch newState {
    case .ready:
      print("\(connection) established")
      self?.delegate?.connectionReady()
      
    case .failed(let error):
      print("\(connection) failed with \(error)")
      // Cancel the connection upon a failure.
      connection.cancel()

      if
        let endpoint = self?.endpoint,
        let initiated = self?.initiatedConnection,
        initiated && error == NWError.posix(.ECONNABORTED) {
          // Reconnect if the user suspends the app on the nearby device.
          let connection = NWConnection(
            to: endpoint,
            using: applicationServiceParameters()
          )
          self?.connection = connection
          self?.startConnection()
      } else {
          // Notify the delegate when the connection fails.
        self?.delegate?.connectionFailed()
      }
  default:
      break
    }
  }

    // Start the connection establishment.
    connection.start(queue: .main)
  }
}
