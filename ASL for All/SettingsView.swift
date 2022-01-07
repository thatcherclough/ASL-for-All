//
//  SettingsView.swift
//  ASL for All
//
//  Created by Thatcher Clough on 8/22/21.
//

import SwiftUI

struct SettingsView: View {
    @State var mainViewModel: MainViewModel?
    @State var followASLWordOrder: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? UIColor.systemBackground : UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            
            VStack() {
                ZStack {
                    Text("Settings")
                        .font(.system(size: 23, weight: .semibold))
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .buttonStyle(CircularButtonStyle(size: 20, height: 35))
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
                
                List {
                    Section(header: Text("Settings")) {
                        HStack {
                            Toggle("Follow ASL word order (beta)", isOn: $followASLWordOrder)
                                .onChange(of: followASLWordOrder) { value in
                                    mainViewModel?.followASLWordOrder = value
                                }
                        }
                    }
                    
                    Section(header: Text("Other")) {
                        HStack{
                            Image(systemName: "ant.fill")
                            
                            Button {
                                if let url = URL(string: "https://github.com/thatcherclough/ASL-for-All/issues/new") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("Submit a bug report!")
                                    .foregroundColor(Color(UIColor.label))
                            }
                        }
                    }
                    
                    Section(header: Text("Credit")) {
                        HStack{
                            Image(systemName: "link")
                            
                            Button {
                                if let url = URL(string: "https://www.signingsavvy.com") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text("SigningSavvy.com")
                                    .foregroundColor(Color(UIColor.label))
                            }
                        }
                    }
                }
            }
        }
        .animation(defaultAnimation)
    }
}
