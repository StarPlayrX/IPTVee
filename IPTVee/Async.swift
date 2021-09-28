//
//  Async.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import Foundation
import iptvKit

class Async {
    func await(action: String) {
        DispatchQueue.global().async {
            while !awaitDone {}
            if action == Actions.getLiveCategoriesAction.rawValue {
                //1
                getCategories()
                //2
                awaitDone = false
                self.await(action: "")
                
            } else if action.isEmpty {
                
                //3
                print(cats as Any)
            }
        }
    }

}
