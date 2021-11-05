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
            .onAppear {
                if !obs.isLoggedIn  {
                    //localLogin()
                    print(passWord)
                }
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
