//
//  LevelRulesViewController.swift
//  ACROSSDataCollection
//

import UIKit

class LevelRulesViewController: UIViewController {
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "等级规则"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var currentLevelCard: UIView = {
        let view = UIView()
        view.backgroundColor = .acrossOrange
        view.setCornerRadius(12)
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var currentLevelTitle: UILabel = {
        let label = UILabel()
        label.text = "当前等级"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var currentLevelName: UILabel = {
        let label = UILabel()
        label.text = "Lv.\(currentUser.currentLevel.level) \(currentUser.currentLevel.name)"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var levelProgressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .white
        progress.progressTintColor = .yellow
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "再完成 \(currentUser.currentLevel.requiredTasks - currentUser.completedTasks) 个任务升级"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var rulesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "等级说明"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var rulesScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView = UIView()
    
    private lazy var rulesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLevelCards()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(currentLevelCard)
        view.addSubview(rulesTitleLabel)
        view.addSubview(rulesScrollView)
        
        currentLevelCard.addSubview(currentLevelTitle)
        currentLevelCard.addSubview(currentLevelName)
        currentLevelCard.addSubview(levelProgressView)
        currentLevelCard.addSubview(progressLabel)
        
        rulesScrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(rulesStackView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            currentLevelCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            currentLevelCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            currentLevelCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            currentLevelCard.heightAnchor.constraint(equalToConstant: 140),
            
            currentLevelTitle.topAnchor.constraint(equalTo: currentLevelCard.topAnchor, constant: 16),
            currentLevelTitle.leadingAnchor.constraint(equalTo: currentLevelCard.leadingAnchor, constant: 16),
            
            currentLevelName.topAnchor.constraint(equalTo: currentLevelTitle.bottomAnchor, constant: 8),
            currentLevelName.leadingAnchor.constraint(equalTo: currentLevelCard.leadingAnchor, constant: 16),
            
            levelProgressView.topAnchor.constraint(equalTo: currentLevelName.bottomAnchor, constant: 16),
            levelProgressView.leadingAnchor.constraint(equalTo: currentLevelCard.leadingAnchor, constant: 16),
            levelProgressView.trailingAnchor.constraint(equalTo: currentLevelCard.trailingAnchor, constant: -16),
            levelProgressView.heightAnchor.constraint(equalToConstant: 8),
            
            progressLabel.topAnchor.constraint(equalTo: levelProgressView.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: currentLevelCard.leadingAnchor, constant: 16),
            
            rulesTitleLabel.topAnchor.constraint(equalTo: currentLevelCard.bottomAnchor, constant: 24),
            rulesTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            rulesScrollView.topAnchor.constraint(equalTo: rulesTitleLabel.bottomAnchor, constant: 16),
            rulesScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rulesScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rulesScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: rulesScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: rulesScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: rulesScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: rulesScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: rulesScrollView.widthAnchor),
            
            rulesStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rulesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rulesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rulesStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        let progress = Float(currentUser.completedTasks) / Float(currentUser.currentLevel.requiredTasks)
        levelProgressView.progress = min(progress, 1.0)
    }
    
    private func setupLevelCards() {
        let levels = [
            (level: AppConfig.LevelDefaults.level, name: AppConfig.LevelDefaults.name, color: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), required: AppConfig.LevelDefaults.requiredTasks, benefits: AppConfig.LevelDefaults.benefits), // 此处将由接口数据填充
            (level: 2, name: "初级采集员", color: UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1), required: 5, benefits: ["基础奖励+10%", "每日5次任务机会", "专属新手任务"]), // 此处将由接口数据填充
            (level: 3, name: "中级采集员", color: UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1), required: 15, benefits: ["基础奖励+20%", "每日8次任务机会", "优先任务推送"]), // 此处将由接口数据填充
            (level: 4, name: "高级采集员", color: UIColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 1), required: 30, benefits: ["基础奖励+35%", "每日12次任务机会", "专属高价值任务"]), // 此处将由接口数据填充
            (level: 5, name: "采集专家", color: UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1), required: 50, benefits: ["基础奖励+50%", "每日15次任务机会", "专属客服支持", "月度额外奖励"]) // 此处将由接口数据填充
        ]
        
        for item in levels {
            let card = createLevelCard(level: item.level, name: item.name, color: item.color, required: item.required, benefits: item.benefits)
            rulesStackView.addArrangedSubview(card)
        }
    }
    
    private func createLevelCard(level: Int, name: String, color: UIColor, required: Int, benefits: [String]) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = color.cgColor
        view.setCornerRadius(12)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let levelLabel = UILabel()
        levelLabel.text = "Lv.\(level)"
        levelLabel.font = UIFont.boldSystemFont(ofSize: 20)
        levelLabel.textColor = color
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let requiredLabel = UILabel()
        if required == 0 {
            requiredLabel.text = "初始等级"
        } else {
            requiredLabel.text = "需要完成 \(required) 个任务"
        }
        requiredLabel.font = UIFont.systemFont(ofSize: 12)
        requiredLabel.textColor = .acrossTextGray
        requiredLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let benefitsTitle = UILabel()
        benefitsTitle.text = "专属权益:"
        benefitsTitle.font = UIFont.systemFont(ofSize: 12)
        benefitsTitle.textColor = .acrossTextGray
        benefitsTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let benefitsStack = UIStackView()
        benefitsStack.axis = .vertical
        benefitsStack.spacing = 4
        benefitsStack.translatesAutoresizingMaskIntoConstraints = false
        
        for benefit in benefits {
            let label = UILabel()
            label.text = "• \(benefit)"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            benefitsStack.addArrangedSubview(label)
        }
        
        view.addSubview(levelLabel)
        view.addSubview(nameLabel)
        view.addSubview(requiredLabel)
        view.addSubview(benefitsTitle)
        view.addSubview(benefitsStack)
        
        NSLayoutConstraint.activate([
            levelLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            levelLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            requiredLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            requiredLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            benefitsTitle.topAnchor.constraint(equalTo: requiredLabel.bottomAnchor, constant: 12),
            benefitsTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            benefitsStack.topAnchor.constraint(equalTo: benefitsTitle.bottomAnchor, constant: 4),
            benefitsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            benefitsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            benefitsStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
        
        return view
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
