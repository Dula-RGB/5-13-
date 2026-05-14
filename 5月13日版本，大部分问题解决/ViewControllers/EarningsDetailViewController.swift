//
//  EarningsDetailViewController.swift
//  ACROSSDataCollection
//

import UIKit

class EarningsDetailViewController: UIViewController {
    
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
        label.text = "收益明细"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var totalEarningsCard: UIView = {
        let view = UIView()
        view.backgroundColor = .acrossOrange
        view.setCornerRadius(12)
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.text = "累计收益(元)"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var totalAmount: UILabel = {
        let label = UILabel()
        label.text = String(format: "¥%.2f", currentUser.totalEarnings)
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var todayEarningsLabel: UILabel = {
        let label = UILabel()
        label.text = "今日收益: ¥\(currentUser.todayEarnings)"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var recordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "收益记录"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var recordList: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EarningsCell.self, forCellReuseIdentifier: "EarningsCell")
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let earningsRecords = [
        (date: AppConfig.EarningsDefaults.time, title: AppConfig.EarningsDefaults.taskName, amount: AppConfig.EarningsDefaults.amount, type: AppConfig.EarningsDefaults.type), // 此处将由接口数据填充
        (date: "2024-01-15", title: "零售门店巡检", amount: 25.00, type: "任务完成"), // 此处将由接口数据填充
        (date: "2024-01-14", title: "家政服务回访", amount: 20.00, type: "任务完成"), // 此处将由接口数据填充
        (date: "2024-01-14", title: "健康数据采集", amount: 18.00, type: "任务完成"), // 此处将由接口数据填充
        (date: "2024-01-13", title: "零售商品盘点", amount: 30.00, type: "任务完成"), // 此处将由接口数据填充
        (date: "2024-01-13", title: "邀请好友奖励", amount: 10.00, type: "邀请奖励"), // 此处将由接口数据填充
        (date: "2024-01-12", title: "家政保洁验收", amount: 22.00, type: "任务完成"), // 此处将由接口数据填充
        (date: "2024-01-12", title: "健康体检登记", amount: 16.00, type: "任务完成") // 此处将由接口数据填充
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(totalEarningsCard)
        view.addSubview(recordTitleLabel)
        view.addSubview(recordList)
        
        totalEarningsCard.addSubview(totalLabel)
        totalEarningsCard.addSubview(totalAmount)
        totalEarningsCard.addSubview(todayEarningsLabel)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            totalEarningsCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            totalEarningsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            totalEarningsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            totalEarningsCard.heightAnchor.constraint(equalToConstant: 120),
            
            totalLabel.topAnchor.constraint(equalTo: totalEarningsCard.topAnchor, constant: 16),
            totalLabel.leadingAnchor.constraint(equalTo: totalEarningsCard.leadingAnchor, constant: 16),
            
            totalAmount.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 8),
            totalAmount.leadingAnchor.constraint(equalTo: totalEarningsCard.leadingAnchor, constant: 16),
            
            todayEarningsLabel.topAnchor.constraint(equalTo: totalAmount.bottomAnchor, constant: 8),
            todayEarningsLabel.leadingAnchor.constraint(equalTo: totalEarningsCard.leadingAnchor, constant: 16),
            
            recordTitleLabel.topAnchor.constraint(equalTo: totalEarningsCard.bottomAnchor, constant: 24),
            recordTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            recordList.topAnchor.constraint(equalTo: recordTitleLabel.bottomAnchor, constant: 12),
            recordList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recordList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recordList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension EarningsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return earningsRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EarningsCell", for: indexPath) as! EarningsCell
        let record = earningsRecords[indexPath.row]
        cell.configure(date: record.date, title: record.title, amount: record.amount, type: record.type)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

class EarningsCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .acrossGray
        view.setCornerRadius(8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .acrossOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(typeLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(date: String, title: String, amount: Double, type: String) {
        titleLabel.text = title
        typeLabel.text = type
        dateLabel.text = date
        amountLabel.text = String(format: "+¥%.2f", amount)
    }
}
