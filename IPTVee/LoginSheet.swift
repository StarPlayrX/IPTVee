//
//  ContentView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import iptvKit
import AVFoundation


struct LoginSheetView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var obs = LoginObservable.shared
    @State var userName: String = LoginObservable.shared.config?.userInfo.username ?? ""
    @State var passWord: String = LoginObservable.shared.config?.userInfo.password ?? ""
    @State var service: String = LoginObservable.shared.config?.serverInfo.url ?? "primestreams.tv"
    @State var https: Bool = false
    @State var port: String = LoginObservable.shared.config?.serverInfo.port ?? "826"
    @State var title: String = "IPTVee"
    
    var body: some View {
      
        
        Form {
            
            Button("Done") {
                presentationMode.wrappedValue.dismiss()

            }
            
            Section(header: Text("Credentials")) {
                TextField("Username", text: $userName)
                SecureField("Password", text: $passWord)
                TextField("iptvService.tv", text: $service)
                TextField("port #", text: $port)
                    .keyboardType(.numberPad)
                Button(action: {login(userName, passWord, service, port) }) {
                    Text("Login")
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                }
            }

            Section(header: Text("Status")) {
                Text(obs.status)
                    .font(.body)
                    .fontWeight(.regular)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
        }
        .onAppear {
            if !obs.isLoggedIn {
               // login(userName, passWord, service, port)
            }
        }
    }
}



struct LoginView: View {


    @ObservedObject var obs = LoginObservable.shared
    @State var userName: String = LoginObservable.shared.config?.userInfo.username ?? ""
    @State var passWord: String = LoginObservable.shared.config?.userInfo.password ?? ""
    @State var service: String = LoginObservable.shared.config?.serverInfo.url ?? "primestreams.tv"
    @State var https: Bool = false
    @State var port: String = LoginObservable.shared.config?.serverInfo.port ?? "826"
    @State var title: String = "IPTVee"
    @State var isLoggedin: Bool = LoginObservable.shared.isLoggedIn
    
    @State var showingLogin: Bool = LoginObservable.shared.showingLogin
    var body: some View {
            
       
        NavigationView {
           
            Group {
                Form {
                    
                    Button("Login") {
                        obs.showingLogin = true
                    }
                    .sheet(isPresented: $obs.showingLogin) {
                        LoginSheetView()
                    }
                    
                    Section(header: Text("Status")) {
                        Text(obs.status)
                            .font(.body)
                            .fontWeight(.regular)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Section(header: Text("Video")) {
                        HStack {
                            NavigationLink("Categories", destination: CategoriesView(), isActive: $obs.isAutoSwitchCat)
                                .isDetailLink(false)

                        }
                        .disabled(!obs.isLoggedIn)

                        HStack {
                            NavigationLink("Player Settings", destination: PlayerSettings())
                                .isDetailLink(true)

                        }
                    }
                    
                    Section(header: Text("Copyright")) {
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
                .padding()
                .disableAutocorrection(true)
                .autocapitalization(UITextAutocapitalizationType.none)
                
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("IPTVee")
                .onAppear {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        AppDelegate.interfaceMask = UIInterfaceOrientationMask.portrait
                    } else {
                        AppDelegate.interfaceMask = UIInterfaceOrientationMask.landscape
                    }
                    
                    
                    //Keeps view from not showing
                    DispatchQueue.main.async {
                        if userName.isEmpty || passWord.isEmpty || service.isEmpty || port.isEmpty {
                            obs.showingLogin.toggle()
                        } else if !obs.isLoggedIn {
                            login(userName, passWord, service, port)
                        }
                    }
            

                }
                .onDisappear {
                    AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
                    toggleSidebar()
                }
                .navigationViewStyle(.columns)
            }
        }
        .padding()

        
     
        

    }
    
    func toggleSidebar() {
#if os(iOS)
     #else
     NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
     #endif
    }
    
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}*/
