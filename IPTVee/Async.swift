//
//  Async.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import Foundation
import iptvKit


enum Stepper {
    case start
    case config
    case categories
    case channels
    case CategoriesError
    case LoginError
    case ConfigurationError
    case unknown
}

var setCurrentStep: Stepper = .start {
    didSet {
        
        // MARK: - Step 1
        if setCurrentStep == .config {
            
            getConfig()
            LoginObservable.lgo.status = "Login"
            awaitDone = false
            
            // MARK: - Step 2
        } else if setCurrentStep == .categories {

            getCategories()
            LoginObservable.lgo.status = "Configuration"
            awaitDone = false
            
            // MARK: - Step 3
        } else if setCurrentStep == .channels {
            
           // getCategories()
            LoginObservable.lgo.status = "Categories"
            awaitDone = false
            
        }
    }
}

var awaitDone: Bool = false {
    didSet {
        if awaitDone {
            if setCurrentStep == .config {
                setCurrentStep = .categories
            } else if setCurrentStep == .categories {
                setCurrentStep = .channels
            }
        }
    }
}
