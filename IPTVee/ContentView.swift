//
//  ContentView.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import SwiftUI
import iptvKit

class LoginObservable: ObservableObject {
    static var lgo = LoginObservable()
    @Published var status: String = "test"
    @Published var loggedIn: Bool = false
}

class CategoriesObservable: ObservableObject {
    static var cto = CategoriesObservable()
    @Published var status: String = "test"
    @Published var loggedIn: Bool = false
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
    
    @ObservedObject var observable = LoginObservable.lgo
    @State var userName: String = "toddbruss90"
    @State var passWord: String = "zzeH7C0xdw"
    @State var service: String = "primestreams.tv"
    @State var port: String = "826"
    @State var https: Bool = false

    @State var showOneLevelIn: Bool = false
    
    var body: some View {

        NavigationView {

            Form {

               
                Section(header: Text("Credentials")) {
                    TextField("Username", text: $userName)
                    SecureField("Password", text: $passWord)
                    TextField("iptvService.tv", text: $service)
                    TextField("port #", text: $port)
                    Toggle(isOn: $https) {
                        Text("use https")
                    }
                    Button(action: {login(userName,passWord,service,port) }) {
                        Text("Login")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                Section(header: Text("UPDATE")) {
                    Text("Status")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(observable.status)
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section(header: Text("VIDEO")) {
                    
                    NavigationLink("Categories",destination: CategoriesView(), isActive: $showOneLevelIn)
                        .foregroundColor(.blue)
                    
                }
                
                Section(header: Text("COPYRIGHT")) {
                    Text("© 2021 Todd Bruss")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                
            }
            .disableAutocorrection(true)
            .autocapitalization(UITextAutocapitalizationType.none)
            .padding(.bottom, 0.0)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        //Image(systemName: "sun.min.fill")
                        Text("IPTVee").font(.largeTitle)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        
                    }
                }
            }

        }
        
        Spacer()

    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(observable: LoginObservable.lgo)
    }
}

