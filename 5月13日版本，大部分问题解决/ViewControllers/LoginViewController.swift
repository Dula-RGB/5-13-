//
//  LoginViewController.swift
//  ACROSSDataCollection
//
//  Created by Developer on 2026/05/10.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ACROSS数采赚币"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "欢迎回来，请登录您的账号"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入手机号"
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .acrossOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加子视图
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(phoneTextField)
        view.addSubview(loginButton)
        loginButton.addSubview(activityIndicator)
        
        // 添加约束
        NSLayoutConstraint.activate([
            // 标题
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            // 副标题
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            // 手机号输入框
            phoneTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            phoneTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            phoneTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            phoneTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // 登录按钮
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 30),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 加载指示器
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
        ])
    }
    
    private func setupKeyboard() {
        // 点击空白处收起键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func loginTapped() {
        dismissKeyboard()
        validateAndLogin()
    }
    
    // MARK: - Login Logic
    private func validateAndLogin() {
        guard let phone = phoneTextField.text?.trimmingCharacters(in: .whitespaces), !phone.isEmpty else {
            showAlert(message: "请输入手机号")
            return
        }
        
        // 验证手机号格式（11位数字）
        let phoneRegex = "^1[3-9]\\d{9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !phonePredicate.evaluate(with: phone) {
            showAlert(message: "请输入正确的手机号格式")
            return
        }
        
        // 开始登录
        startLoading()
        performLogin(phone: phone)
    }
    
    private func performLogin(phone: String) {
        // 根据开关决定是否使用真实接口
        if AppConfig.useRealAPI {
            // 使用真实接口登录
            NetworkManager.shared.getUserInfo(phone: phone) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.stopLoading()
                    
                    switch result {
                    case .success(let user):
                        // 登录成功，保存用户信息
                        self.saveUserInfo(user: user)
                        // 跳转到首页
                        self.navigateToHome()
                        
                    case .failure(let error):
                        print("登录失败: \(error.localizedDescription)")
                        self.showAlert(message: "账号不存在，请重新输入")
                    }
                }
            }
        } else {
            // 使用模拟数据登录（测试模式）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.stopLoading()
                
                // 模拟登录成功，使用默认用户数据
                print("使用模拟数据登录，手机号: \(phone)")
                self.saveMockUserInfo()
                self.navigateToHome()
            }
        }
    }
    
    // 保存模拟用户信息（测试模式使用）
    private func saveMockUserInfo() {
        currentUser.id = AppConfig.UserDefaults.id
        currentUser.name = AppConfig.UserDefaults.name
        currentUser.totalEarnings = AppConfig.UserDefaults.totalEarnings
        currentUser.todayEarnings = AppConfig.UserDefaults.todayEarnings
        currentUser.completedTasks = AppConfig.UserDefaults.completedTasks
        currentUser.inviteCount = AppConfig.UserDefaults.inviteCount
        currentUser.currentExperience = AppConfig.UserDefaults.currentExperience
        currentUser.withdrawableAmount = AppConfig.UserDefaults.withdrawableAmount
    }
    
    private func saveUserInfo(user: ApiUser) {
        // 更新全局用户信息
        currentUser.id = "\(user.id)"
        currentUser.name = user.userName
        currentUser.totalEarnings = Double(user.totalReward)
        
        // 保存到UserDefaults（可选）
        UserDefaults.standard.set("\(user.id)", forKey: "userId")
        UserDefaults.standard.set(user.userName, forKey: "userName")
        UserDefaults.standard.set(user.phone, forKey: "userPhone")
        UserDefaults.standard.set(Double(user.totalReward), forKey: "totalReward")
        UserDefaults.standard.synchronize()
    }
    
    private func navigateToHome() {
        // 优先使用SceneDelegate（iOS 13+）
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.navigateToHomeTabBar()
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // 兼容iOS 12及以下版本
            appDelegate.navigateToHomeTabBar()
        }
    }
    
    // MARK: - Loading
    private func startLoading() {
        loginButton.isEnabled = false
        loginButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }
    
    private func stopLoading() {
        loginButton.isEnabled = true
        loginButton.setTitle("登录", for: .normal)
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
