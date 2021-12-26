//
//  ContentView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import iptvKit
import AVFoundation

// http://ky-iptv.com:80/player_api.php?username=iantuc&password=pass8224&action=

struct LoginSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var obs = LoginObservable.shared
    
    @State var userName: String = LoginObservable.shared.config?.userInfo.username ?? "nicemac65"
    @State var passWord: String = LoginObservable.shared.config?.userInfo.password ?? "pass65181"
    @State var service: String = LoginObservable.shared.config?.serverInfo.url ?? "ky-iptv.com"
    @State var https: Bool = false
    @State var port: String = LoginObservable.shared.config?.serverInfo.port ?? "80"
    @State var title: String = "IPTVee"
    
    var body: some View {
      
        NavigationView {
            List {
                Section(header: Text("Credentials")) {
                    TextField("Username", text: $userName)
                    SecureField("Password", text: $passWord)
                    TextField("iptvService.tv", text: $service)
                    TextField("port #", text: $port)
                        .keyboardType(.numberPad)
                    Button(action: localLogin) {
                        Text("Login")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(obs.isLoginButtonDisabled)
                }
                Section(header: Text("Status")) {
                    Text(obs.status)
                        .font(.body)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Button("Done") {
                    obs.isLoggedIn = true
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!obs.isLoggedIn)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("IPTVee Login")
            .toolbar {
                Button(action: {obs.showingLogin = false}) {
                        Text("Done")
                }.frame(alignment: .topTrailing)
                
            }
        } 
    }
    
    func localLogin() {
        DispatchQueue.global().async {
            if !userName.isEmpty && !passWord.isEmpty && !service.isEmpty && !port.isEmpty {
                login(userName, passWord, service, port)
            }
        }
    }
}
