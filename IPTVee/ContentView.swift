//
//  ContentView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import iptvKit

extension RangeReplaceableCollection where Self: StringProtocol {
    var digits: Self { filter(\.isWholeNumber) }
}

struct ContentView: View {
    
    @ObservedObject var obs = LoginObservable.shared
    
    //MARK: - todo: Add in data store
    @State var userName: String = "toddbruss90"
    @State var passWord: String = "zzeH7C0xdw"
    @State var service: String = "primestreams.tv"
    @State var https: Bool = false
    @State var port: String = "826"
    @State var showOneLevelIn: Bool = false
    @State var title: String = "IPTVee"
    @State var isCatActive: Bool = false
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section(header: Text("CREDENTIALS")) {
                    TextField("Username", text: $userName)
                    SecureField("Password", text: $passWord)
                    TextField("iptvService.tv", text: $service)
                    TextField("port #", text: $obs.port)
                        .keyboardType(.numberPad)
                    
                    //Toggle(isOn: $https) {
                    //    Text("use https")
                    //}
                    Button(action: {login(userName, passWord, service, obs.port) }) {
                        Text("Login")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                Section(header: Text("UPDATE")) {
                    Text("Status")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(obs.status)
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section(header: Text("VIDEO")) {
                    HStack {
                        
                        NavigationLink(destination: CategoriesView(), isActive: $obs.isAutoSwitchCat) {
                            Button(action: {
                                title = "Login"
                                obs.isAutoSwitchCat = true
                            }) {
                                Text("Categories")
                            }
                        } 
                    }
                    .disabled(!obs.isLoggedIn)
                }
                
                Section(header: Text("COPYRIGHT")) {
                    Text("© 2021 Todd Bruss")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onAppear(perform: {
                title = "IPTVee"
            })
            .onDisappear(perform: {
                title = "Login"
            })
            
            .disableAutocorrection(true)
            .autocapitalization(UITextAutocapitalizationType.none)
            .padding(0.0)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .onAppear {
                AppDelegate.interfaceMask = UIInterfaceOrientationMask.portrait
            }
            .onDisappear {
                AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
