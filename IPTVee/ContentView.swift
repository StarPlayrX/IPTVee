//
//  ContentView.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import SwiftUI

struct ContentView: View {

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
            TextField("Username", text: $userName)
            SecureField("Password", text: $passWord)
            TextField("iptvService.tv", text: $service)
            TextField("port #", text: $port)

            Button(action: { login(userName,passWord,service,port) }) {
                Text("Login")

            }
            .frame(maxWidth: .infinity, alignment: .center)

        }
        .disableAutocorrection(true)
        .autocapitalization(UITextAutocapitalizationType.none)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
