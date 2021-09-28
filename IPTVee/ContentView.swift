//
//  ContentView.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import SwiftUI
import iptvKit

class LoginViewObservable: ObservableObject {
    static var lvo = LoginViewObservable()
    @Published var status: String = "test"
}

extension ContentView {
    func login(_ user: String,_ pass: String,_ host: String,_ port: String) {
        awaitDone = false
        observable.status = "Logged in"

        guard let port = Int(port) else { return }
        creds.username = user
        creds.password = pass
        iptv.host = host
        iptv.port = port
        getConfig()
        Async().await(action: Actions.getLiveCategoriesAction.rawValue)
        
    }
}

struct ContentView: View {
    
    @ObservedObject var observable = LoginViewObservable.lvo
    @State var userName: String = "toddbruss90"
    @State var passWord: String = "zzeH7C0xdw"
    @State var service: String = ""
    @State var port: String = ""

    var body: some View {
        Text("IPTVee")
            .font(.largeTitle)
            .fontWeight(.heavy)
            .foregroundColor(Color.blue)
        
        
        Form {
            
            Section {
              Text("Login Info")
                    .foregroundColor(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Section {
                TextField("Username", text: $userName)
                SecureField("Password", text: $passWord)
                TextField("iptvService.tv", text: $service)
                TextField("port #", text: $port)

                Button(action: {login(userName,passWord,service,port) }) {
                    Text("Login")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
            }
           
            Section {
                Text("Status")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(observable.status)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Section {
                Text("Copyright © 2021 Todd Bruss")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            } 
        }
        .disableAutocorrection(true)
        .autocapitalization(UITextAutocapitalizationType.none)
        .padding(.bottom, 0.0)

       

      
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(observable: LoginViewObservable())
    }
}
