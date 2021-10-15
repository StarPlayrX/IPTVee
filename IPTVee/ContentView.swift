//
//  ContentView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import iptvKit

struct ContentView: View {
    
    @ObservedObject var obs = LoginObservable.shared
    //MARK: - todo: Add in data store
    @State var userName: String = LoginObservable.shared.config?.userInfo.username ?? "takuachenvidia@gmail.com" //
    @State var passWord: String = LoginObservable.shared.config?.userInfo.password ?? "wBevDzfqb5" //
    @State var service: String = LoginObservable.shared.config?.serverInfo.url ?? ""
    @State var https: Bool = false
    @State var port: String = LoginObservable.shared.config?.serverInfo.port ?? ""
    @State var showOneLevelIn: Bool = false
    @State var title: String = "IPTVee"
    @State var isCatActive: Bool = false
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    HStack {
                        Text("IPTV")
                            .fontWeight(.bold)
                            .frame(alignment: .trailing)
                            .offset(x: 4.3)
                        
                        Text("ee")
                            .fontWeight(.light)
                            .frame(alignment: .leading)
                            .offset(x: -4.3)
                    }
                    .foregroundColor( Color(.displayP3, red: 63 / 255, green: 188 / 255, blue: 237 / 255)  )
                }
                
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

                        }.disabled(awaitDone)

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
                    title = "Login"
                })
                
                .disableAutocorrection(true)
                .autocapitalization(UITextAutocapitalizationType.none)
                .padding(0.0)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(title)
                .onAppear {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        AppDelegate.interfaceMask = UIInterfaceOrientationMask.portrait
                        
                    }   else {
                        AppDelegate.interfaceMask = UIInterfaceOrientationMask.landscape
                    }
                    
                }
                .onDisappear {
                    AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
                }
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
