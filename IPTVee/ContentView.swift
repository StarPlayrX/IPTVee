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
    @State var userName: String = "toddbruss90"
    @State var passWord: String = "zzeH7C0xdw"
    @State var service: String = "primestreams.tv"
    @State var https: Bool = false
    @State var port: String = "826"
    @State var showOneLevelIn: Bool = false
    
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
                        NavigationLink("Categories",destination: CategoriesView(), isActive: $obs.isAutoSwitchCat)
                            .foregroundColor(.blue)
                    }
                    .disabled(!obs.isLoggedIn)
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
            .navigationTitle("IPTVee")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
