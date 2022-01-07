//
//  ASL_for_AllApp.swift
//  ASL for All
//
//  Created by Thatcher Clough on 8/8/21.
//

import SwiftUI
import AVFoundation

@main
struct ASL_for_AllApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear() {
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: .mixWithOthers)
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if UserDefaults.standard.object(forKey: "showHint") != nil {
            UserDefaults.standard.set(false, forKey: "showHint")
        }
    }
}
