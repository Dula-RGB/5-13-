//
//  SceneDelegate.swift
//  ACROSSDataCollection
//
//  Created by ACROSS on 2024/1/1.
//


import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        // 启动时默认展示登录页面
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
    }
    
    // 登录成功后跳转到首页
    func navigateToHomeTabBar() {
        let homeVC = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeVC)
        navigationController.navigationBar.isHidden = true
        
        window?.rootViewController = navigationController
    }
}
