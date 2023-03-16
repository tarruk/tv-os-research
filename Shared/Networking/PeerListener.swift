//
//  PeerListener.swift
//  PlaygroundOS
//
//  Created by Tarek Radovan on 16/03/2023.
//

import Foundation

import Network

var bonjourListener: PeerListener?
var applicationServiceListener: PeerListener?

class PeerListener {
  enum ServiceType {
      case applicationService
  }

  weak var delegate: PeerConnectionDelegate?
  var listener: NWListener?
  var name: String?
  let type: ServiceType

  // Create a listener that advertises the game's app service
  // and has a delegate to handle inbound connections.
  init(delegate: PeerConnectionDelegate) {
    self.type = .applicationService
    self.delegate = delegate
    self.name = nil
    setupApplicationServiceListener()
  }

  func setupApplicationServiceListener() {
    do {
      // Create the listener object.
      let listener = try NWListener(using: applicationServiceParameters())
      self.listener = listener

      // Set the service to advertise.
      listener.service = NWListener.Service(applicationService: "RickAndMorty")

      startListening()
    } catch {
      print("Failed to create application service listener")
      abort()
    }
  }
    
  func applicationServiceListenerStateChanged(newState: NWListener.State) {
    switch newState {
    case .ready:
      print("Listener ready for nearby devices")
    case .failed(let error):
      print("Listener failed with \(error), stopping")
      self.delegate?.displayAdvertiseError(error)
      self.listener?.cancel()
    case .cancelled:
      applicationServiceListener = nil
    default:
      break
    }
  }
    
  func listenerStateChanged(newState: NWListener.State) {
    switch self.type {
    case .applicationService:
      applicationServiceListenerStateChanged(newState: newState)
    }
  }

  func startListening() {
    self.listener?.stateUpdateHandler = listenerStateChanged

    // The system calls this when a new connection arrives at the listener.
    // Start the connection to accept it, cancel to reject it.
    self.listener?.newConnectionHandler = { newConnection in
      if sharedConnection == nil {
        // Accept a new connection.
        sharedConnection = PeerConnection(connection: newConnection)
      } else {
        // If a game is already in progress, reject it.
        newConnection.cancel()
      }
    }

    // Start listening, and request updates on the main queue.
    self.listener?.start(queue: .main)
  }

  // Stop listening.
  func stopListening() {
    if let listener = listener {
      listener.cancel()
      switch self.type {
      case .applicationService:
        applicationServiceListener = nil
      }
    }
  }
}
