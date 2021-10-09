//
//  Login.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import Foundation
import iptvKit
import UIKit

class LoginObservable: ObservableObject {
    static var shared = LoginObservable()
    @Published var status: String = "Update"
    @Published var port: String = "826"
    @Published var isLoggedIn: Bool = false
    @Published var isAutoSwitchCat: Bool = false
    @Published var isCatActive: Bool = false

    @Published var config: Config? = nil
   
}

func login(_ user: String,_ pass: String,_ host: String,_ port: String) {
    LoginObservable.shared.status = ""
    LoginObservable.shared.port = port.digits
    
    guard let port = Int(LoginObservable.shared.port) else { return }
    
    awaitDone = false
    LoginObservable.shared.status = "Logging In..."
    
    creds.username = user
    creds.password = pass
    iptv.host = host
    iptv.port = port
    
    setCurrentStep = .config
}

enum Stepper {
    case start
    case config
    case categories
    case channels
    case CategoriesError
    case ChannelsError
    case LoginError
    case ConfigurationError
    case finish
    case unknown
}

enum Status: String {
    case Login = "Login"
    case Configuration = "Configuration"
    case Categories = "Categories"
    case Channels = "Channels"
}

var setCurrentStep: Stepper = .start {
    didSet {
        switch setCurrentStep {
        case .config:
            getConfig()
            LoginObservable.shared.status = Status.Login.rawValue
            
        case .categories:
            getCategories()
            LoginObservable.shared.status = Status.Configuration.rawValue
            
        case .channels:
            getChannels()
            LoginObservable.shared.status = Status.Categories.rawValue
            
        case .finish:
            //done
            LoginObservable.shared.status = Status.Channels.rawValue
            LoginObservable.shared.isAutoSwitchCat = true
            LoginObservable.shared.isLoggedIn = true
        default:
            ()
        }
        
        awaitDone = false
    }
}

var awaitDone: Bool = false {
    didSet {
        if awaitDone {
            switch setCurrentStep {
            case .config:
                setCurrentStep = .categories
            case .categories:
                setCurrentStep = .channels
            case .channels:
                setCurrentStep = .finish
            default:
                ()
            }
        }
    }
}
