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
    // https://primestreams.tv:826/xmltv.php?username=Bobby2032&password=r1aBngmoW9
    @State var userName: String = LoginObservable.shared.config?.userInfo.username ?? "" //"Bobby2032" //"nicemac65"
    @State var passWord: String = LoginObservable.shared.config?.userInfo.password ?? "" //"r1aBngmoW9" //"pass65181"
    @State var service: String = LoginObservable.shared.config?.serverInfo.url ?? "ky-iptv.com" //"primestreams.tv" //
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
                    obs.isLoginButtonDisabled ? AnyView(ProgressView().frame(maxWidth: .infinity, alignment: .center)) : AnyView(EmptyView())
                }
                
                
                Button("Done") {
                    obs.isLoggedIn = true
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!obs.isLoggedIn)
                .frame(maxWidth: .infinity, alignment: .center)
                
                
                Section(header: Text("Need IPTV Access?")) {
                    Link("Get Xtreme HD IPTV", destination: URL(string: "https://xtremehdiptv.org/billing/aff.php?aff=251")!)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                

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
