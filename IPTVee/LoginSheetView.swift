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
//http://etv.wstreamzone.com/xmltv.php?username=U0YSV8YOCT&password=FU56KJYJJV
    @ObservedObject var obs = LoginObservable.shared
    
    //http://primestreams.tv:826/player_api.php?username=Bobby2032&password=r1aBngmoW9&action=
    @State var userName: String = LoginObservable.shared.config?.userInfo.username ?? "U0YSV8YOCT"
    @State var passWord: String = LoginObservable.shared.config?.userInfo.password ?? "FU56KJYJJV"
    @State var service: String = LoginObservable.shared.config?.serverInfo.url ?? "etv.wstreamzone.com"
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
