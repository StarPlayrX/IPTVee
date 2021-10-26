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
    @State var userName: String = LoginObservable.shared.config?.userInfo.username ?? ""
    @State var passWord: String =  LoginObservable.shared.config?.userInfo.password ?? ""
    @State var service: String = LoginObservable.shared.config?.serverInfo.url ?? "primestreams.tv"
    @State var https: Bool = false
    @State var port: String = LoginObservable.shared.config?.serverInfo.port ?? "826"
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
                    TextField("port #", text: $port)
                        .keyboardType(.numberPad)
                    Button(action: {login(userName, passWord, service, port) }) {
                        Text("Login")
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                    }.disabled(awaitDone)
                }
                
                Section(header: Text("UPDATE")) {
                    Text("Status")
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(obs.status)
                        .font(.body)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section(header: Text("VIDEO")) {
                    HStack {
                        
                        NavigationLink("Categories", destination: CategoriesView(), isActive: $obs.isAutoSwitchCat)
                    }
                    .disabled(!obs.isLoggedIn)
                }
                
                Section(header: Text("COPYRIGHT")) {
                    HStack {
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
                        
                        Text("© 2021 Todd Bruss")
                            .offset(x: -4.3)
                        
                    }.frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onAppear(perform: {
                title = "Login"
                
            })
            
            .disableAutocorrection(true)
            .autocapitalization(UITextAutocapitalizationType.none)
            .padding(0.0)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(title)
            .onAppear {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    AppDelegate.interfaceMask = UIInterfaceOrientationMask.portrait
                } else {
                    AppDelegate.interfaceMask = UIInterfaceOrientationMask.landscape
                }
                getNowPlayingEpg(channelz: ChannelsObservable.shared.chan)
            }
            .onDisappear {
                AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
