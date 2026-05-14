//
//  AppDelegate.swift
//  ACROSSDataCollection
//
//  Created by ACROSS on 2024/1/1.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        // 启动时默认展示登录页面
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        
        return true
    }
    
    // 登录成功后跳转到首页
    func navigateToHomeTabBar() {
        let homeVC = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeVC)
        navigationController.navigationBar.isHidden = true
        
        window?.rootViewController = navigationController
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
