//
//  HomeViewController.swift
//  ACROSSDataCollection
//

import UIKit

class HomeViewController: UIViewController {
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ACROSS数采赚币"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var myTasksButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("我的任务", for: .normal)
        button.setTitleColor(.acrossTextGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(myTasksTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var earningsCard: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 1, green: 0.588, blue: 0.275, alpha: 1).cgColor, UIColor(red: 1, green: 0.435, blue: 0.122, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 16
        view.layer.insertSublayer(gradientLayer, at: 0)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var totalEarningsLabel: UILabel = {
        let label = UILabel()
        label.text = "累计收益(元)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var totalEarningsAmount: UILabel = {
        let label = UILabel()
        label.text = String(format: "¥%.2f", currentUser.totalEarnings)
        label.font = UIFont.boldSystemFont(ofSize: 44)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dividerLine: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var todayEarningsView: UIView = createStatView(title: "今日收益", value: String(format: "¥%.2f", currentUser.todayEarnings))
    private lazy var completedTasksView: UIView = createStatView(title: "完成任务", value: "\(currentUser.completedTasks)个")
    private lazy var levelView: UIView = createStatView(title: "当前等级", value: "Lv.\(currentUser.currentLevel.level) \(currentUser.currentLevel.name)")
    
    private lazy var categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "任务分类"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var healthCategoryButton: UIButton = createCategoryButton(title: "健康", iconView: CategoryHealthIcon(), color: .healthCardBg, tag: 0)
    private lazy var retailCategoryButton: UIButton = createCategoryButton(title: "零售", iconView: CategoryRetailIcon(), color: .retailCardBg, tag: 1)
    private lazy var housekeepingCategoryButton: UIButton = createCategoryButton(title: "家政", iconView: CategoryHousekeepingIcon(), color: .housekeepingCardBg, tag: 2)
    
    private lazy var recommendedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "推荐任务"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("查看全部>", for: .normal)
        button.setTitleColor(.acrossTextGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var taskList: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = "暂时没有未完成的任务发布"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tasks: [Task] {
        return allTasks.filter { $0.status != .completed && $0.status != .expired }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
        loadUserData()
        loadTaskList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTaskList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradientLayer = earningsCard.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = earningsCard.bounds
        }
    }
    
    private func loadUserData() {
        // 根据开关决定是否使用真实接口
        if AppConfig.useRealAPI {
            NetworkManager.shared.getUserInfo(phone: "15211112222") { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        print("用户数据加载成功: \(user.userName), 收益: \(user.totalReward)")
                        currentUser.totalEarnings = Double(user.totalReward)
                        currentUser.name = user.userName
                        self.updateEarningsUI()
                    case .failure(let error):
                        print("用户数据加载失败: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // 使用默认数据
            print("使用默认用户数据")
            updateEarningsUI()
        }
    }
    
    private func loadTaskList() {
        // 根据开关决定是否使用真实接口
        if AppConfig.useRealAPI {
            NetworkManager.shared.getTaskList { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let apiTasks):
                        print("任务数据加载成功: \(apiTasks.count) 个任务")
                        self.updateTasks(with: apiTasks)
                        self.updateEmptyState()
                        self.taskList.reloadData()
                    case .failure(let error):
                        print("任务数据加载失败: \(error.localizedDescription)")
                        self.updateEmptyState()
                        self.taskList.reloadData()
                    }
                }
            }
        } else {
            // 使用默认任务数据
            print("使用默认任务数据")
            self.updateEmptyState()
            self.taskList.reloadData()
        }
    }
    
    private func updateEmptyState() {
        let hasTasks = tasks.count > 0
        taskList.isHidden = !hasTasks
        emptyStateView.isHidden = hasTasks
    }
    
    private func updateEarningsUI() {
        totalEarningsAmount.text = String(format: "¥%.2f", currentUser.totalEarnings)
        todayEarningsView.subviews.forEach { view in
            if let label = view as? UILabel, label.font.pointSize == 14 {
                label.text = String(format: "¥%.2f", currentUser.todayEarnings)
            }
        }
        completedTasksView.subviews.forEach { view in
            if let label = view as? UILabel, label.font.pointSize == 14 {
                label.text = "\(currentUser.completedTasks)个"
            }
        }
        levelView.subviews.forEach { view in
            if let label = view as? UILabel, label.font.pointSize == 14 {
                label.text = "Lv.\(currentUser.currentLevel.level) \(currentUser.currentLevel.name)"
            }
        }
    }
    
    private func updateTasks(with apiTasks: [ApiTask]) {
        // 创建临时数组存储更新后的任务
        var updatedTasks: [Task] = []
        
        for apiTask in apiTasks {
            let industry: IndustryType
            switch apiTask.typeName {
            case "健康":
                industry = .health
            case "零售":
                industry = .retail
            case "家政":
                industry = .housekeeping
            default:
                industry = .health
            }
            
            // 检查是否已存在相同ID的任务，保留其状态
            if let existingTask = allTasks.first(where: { $0.id == "\(apiTask.id)" }) {
                // 更新任务数据但保留状态
                let updatedTask = Task(
                    id: "\(apiTask.id)",
                    title: apiTask.name,
                    description: apiTask.description,
                    industry: industry,
                    reward: apiTask.reward,
                    progress: existingTask.progress,
                    deadline: AppConfig.TaskDefaults.deadline,
                    status: existingTask.status,
                    steps: AppConfig.TaskDefaults.steps,
                    requirements: AppConfig.TaskDefaults.requirements,
                    videoUrl: apiTask.videoUrl
                )
                updatedTasks.append(updatedTask)
            } else {
                // 创建新任务
                let newTask = Task(
                    id: "\(apiTask.id)",
                    title: apiTask.name,
                    description: apiTask.description,
                    industry: industry,
                    reward: apiTask.reward,
                    progress: 0,
                    deadline: AppConfig.TaskDefaults.deadline,
                    status: apiTask.status == "published" ? .pending : .completed,
                    steps: AppConfig.TaskDefaults.steps,
                    requirements: AppConfig.TaskDefaults.requirements,
                    videoUrl: apiTask.videoUrl
                )
                updatedTasks.append(newTask)
            }
        }
        
        // 更新全局任务数组
        allTasks = updatedTasks
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(myTasksButton)
        view.addSubview(earningsCard)
        view.addSubview(categoryTitleLabel)
        view.addSubview(categoryStackView)
        view.addSubview(recommendedTitleLabel)
        view.addSubview(seeAllButton)
        view.addSubview(taskList)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateLabel)
        
        earningsCard.addSubview(totalEarningsLabel)
        earningsCard.addSubview(totalEarningsAmount)
        earningsCard.addSubview(dividerLine)
        earningsCard.addSubview(statsStackView)
        
        statsStackView.addArrangedSubview(todayEarningsView)
        statsStackView.addArrangedSubview(completedTasksView)
        statsStackView.addArrangedSubview(levelView)
        
        categoryStackView.addArrangedSubview(healthCategoryButton)
        categoryStackView.addArrangedSubview(retailCategoryButton)
        categoryStackView.addArrangedSubview(housekeepingCategoryButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            myTasksButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            myTasksButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            earningsCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            earningsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            earningsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            earningsCard.heightAnchor.constraint(equalToConstant: 200),
            
            totalEarningsLabel.topAnchor.constraint(equalTo: earningsCard.topAnchor, constant: 20),
            totalEarningsLabel.leadingAnchor.constraint(equalTo: earningsCard.leadingAnchor, constant: 20),
            
            totalEarningsAmount.topAnchor.constraint(equalTo: totalEarningsLabel.bottomAnchor, constant: 12),
            totalEarningsAmount.leadingAnchor.constraint(equalTo: earningsCard.leadingAnchor, constant: 20),
            
            dividerLine.topAnchor.constraint(equalTo: totalEarningsAmount.bottomAnchor, constant: 16),
            dividerLine.leadingAnchor.constraint(equalTo: earningsCard.leadingAnchor, constant: 20),
            dividerLine.trailingAnchor.constraint(equalTo: earningsCard.trailingAnchor, constant: -20),
            dividerLine.heightAnchor.constraint(equalToConstant: 1),
            
            statsStackView.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: earningsCard.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: earningsCard.trailingAnchor, constant: -20),
            statsStackView.heightAnchor.constraint(equalToConstant: 56),
            
            categoryTitleLabel.topAnchor.constraint(equalTo: earningsCard.bottomAnchor, constant: 24),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            categoryStackView.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 12),
            categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryStackView.heightAnchor.constraint(equalToConstant: 100),
            
            recommendedTitleLabel.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 24),
            recommendedTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            seeAllButton.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 24),
            seeAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            taskList.topAnchor.constraint(equalTo: recommendedTitleLabel.bottomAnchor, constant: 12),
            taskList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskList.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: recommendedTitleLabel.bottomAnchor, constant: 50),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor)
        ])
        
        healthCategoryButton.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        retailCategoryButton.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        housekeepingCategoryButton.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(earningsCardTapped))
        earningsCard.addGestureRecognizer(tapGesture)
        
        let levelTapGesture = UITapGestureRecognizer(target: self, action: #selector(levelTapped))
        levelView.addGestureRecognizer(levelTapGesture)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        taskList.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.taskList.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func myTasksTapped() {
        let myTasksVC = MyTasksViewController()
        navigationController?.pushViewController(myTasksVC, animated: true)
    }
    
    @objc private func seeAllTapped() {
        let allTasksVC = AllTasksViewController()
        if let navController = navigationController {
            navController.pushViewController(allTasksVC, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: allTasksVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
    }
    
    @objc private func earningsCardTapped() {
        loadUserData()
        loadTaskList()
        showRefreshToast()
    }
    
    @objc private func levelTapped() {
        loadUserData()
        loadTaskList()
        showRefreshToast()
    }
    
    private func showRefreshToast() {
        let toastLabel = UILabel()
        toastLabel.text = "数据已刷新"
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 20
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            toastLabel.widthAnchor.constraint(equalToConstant: 120),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        toastLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.7, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        var industry: IndustryType
        switch sender.tag {
        case 0:
            industry = .health
        case 1:
            industry = .retail
        case 2:
            industry = .housekeeping
        default:
            return
        }
        let vc = TaskListViewController(industry: industry)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createStatView(title: String, value: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .white
        titleLabel.alpha = 0.8
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    private func createCategoryButton(title: String, iconView: UIView, color: UIColor, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = color
        button.tag = tag
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return button
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.configure(with: tasks[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

extension HomeViewController: TaskCellDelegate {
    func didTapCell(task: Task) {
        let vc = TaskDetailViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapAccept(task: Task) {
        let vc = TaskDetailViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol TaskCellDelegate: AnyObject {
    func didTapCell(task: Task)
    func didTapAccept(task: Task)
}

class TaskCell: UITableViewCell {
    weak var delegate: TaskCellDelegate?
    private var task: Task?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .acrossGray
        view.setCornerRadius(12)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var industryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var rewardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .acrossOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("立即接取", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .acrossOrange
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setCornerRadius(8)
        button.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        containerView.addSubview(industryLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(rewardLabel)
        containerView.addSubview(progressLabel)
        containerView.addSubview(deadlineLabel)
        containerView.addSubview(acceptButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            industryLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            industryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            industryLabel.trailingAnchor.constraint(lessThanOrEqualTo: rewardLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: industryLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            rewardLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            rewardLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            progressLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            deadlineLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 4),
            deadlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            acceptButton.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 12),
            acceptButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            acceptButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            acceptButton.heightAnchor.constraint(equalToConstant: 40),
            acceptButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with task: Task) {
        self.task = task
        industryLabel.text = task.title
        descriptionLabel.text = task.description
        rewardLabel.text = String(format: "¥%.2f", task.reward)
        progressLabel.text = "\(task.progress)% (\(task.progress)/\(task.steps.count))"
        deadlineLabel.text = "截止: \(task.deadline)"
        
        if task.status == .completed {
            acceptButton.setTitle("已完成", for: .normal)
            acceptButton.backgroundColor = .gray
            acceptButton.isEnabled = false
        } else if task.status == .expired {
            acceptButton.setTitle("已过期", for: .normal)
            acceptButton.backgroundColor = .gray
            acceptButton.isEnabled = false
        } else if task.status == .inProgress {
            acceptButton.setTitle("已接取", for: .normal)
            acceptButton.backgroundColor = .gray
            acceptButton.isEnabled = false
        } else {
            acceptButton.setTitle("立即接取", for: .normal)
            acceptButton.backgroundColor = .acrossOrange
            acceptButton.isEnabled = true
        }
    }
    
    @objc private func cellTapped() {
        if let task = task {
            delegate?.didTapCell(task: task)
        }
    }
    
    @objc private func acceptTapped() {
        if let task = task {
            acceptButton.isEnabled = false
            acceptButton.setTitle("接取中...", for: .normal)
            
            NetworkManager.shared.receiveTask(userId: "\(currentUser.id)", taskId: task.id) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.acceptButton.isEnabled = true
                    switch result {
                    case .success:
                        self.acceptButton.setTitle("已接取", for: .normal)
                        self.acceptButton.backgroundColor = .gray
                        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
                            allTasks[index].status = .inProgress
                        }
                        self.delegate?.didTapAccept(task: task)
                    case .failure:
                        self.acceptButton.setTitle("立即接取", for: .normal)
                        self.acceptButton.backgroundColor = .acrossOrange
                    }
                }
            }
        }
    }
}

class CategoryHealthIcon: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let iconSize: CGFloat = 32
        let centerX = rect.midX
        let centerY = rect.midY
        
        // 上半圆（开口向下）
        let halfCirclePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                                          radius: iconSize / 2,
                                          startAngle: .pi,
                                          endAngle: 0,
                                          clockwise: false)
        UIColor.healthTeal.setFill()
        halfCirclePath.fill()
        
        // 白色心形（位于半圆下方）
        let heartSize: CGFloat = 14
        let heartY = centerY + iconSize * 0.25
        
        let heartPath = UIBezierPath()
        heartPath.move(to: CGPoint(x: centerX, y: heartY - heartSize * 0.4))
        heartPath.addCurve(to: CGPoint(x: centerX - heartSize * 0.5, y: heartY + heartSize * 0.2),
                          controlPoint1: CGPoint(x: centerX - heartSize * 0.5, y: heartY),
                          controlPoint2: CGPoint(x: centerX - heartSize * 0.5, y: heartY))
        heartPath.addLine(to: CGPoint(x: centerX, y: heartY + heartSize * 0.4))
        heartPath.addLine(to: CGPoint(x: centerX + heartSize * 0.5, y: heartY + heartSize * 0.2))
        heartPath.addCurve(to: CGPoint(x: centerX, y: heartY - heartSize * 0.4),
                          controlPoint1: CGPoint(x: centerX + heartSize * 0.5, y: heartY),
                          controlPoint2: CGPoint(x: centerX + heartSize * 0.5, y: heartY))
        heartPath.close()
        
        UIColor.white.setFill()
        heartPath.fill()
    }
}

class CategoryRetailIcon: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let iconSize: CGFloat = 32
        let centerX = rect.midX
        let centerY = rect.midY
        
        // 上半圆（开口向下）
        let halfCirclePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                                          radius: iconSize / 2,
                                          startAngle: .pi,
                                          endAngle: 0,
                                          clockwise: false)
        UIColor.retailBlue.setFill()
        halfCirclePath.fill()
        
        // 白色房子（位于半圆下方）
        let houseWidth: CGFloat = 18
        let houseHeight: CGFloat = 12
        let houseX = centerX - houseWidth / 2
        let houseY = centerY + iconSize * 0.25
        
        let housePath = UIBezierPath()
        // 屋顶
        housePath.move(to: CGPoint(x: centerX, y: houseY))
        housePath.addLine(to: CGPoint(x: houseX + houseWidth, y: houseY + houseHeight * 0.45))
        housePath.addLine(to: CGPoint(x: houseX, y: houseY + houseHeight * 0.45))
        housePath.close()
        
        // 屋身
        housePath.move(to: CGPoint(x: houseX, y: houseY + houseHeight * 0.45))
        housePath.addLine(to: CGPoint(x: houseX, y: houseY + houseHeight))
        housePath.addLine(to: CGPoint(x: houseX + houseWidth, y: houseY + houseHeight))
        housePath.addLine(to: CGPoint(x: houseX + houseWidth, y: houseY + houseHeight * 0.45))
        
        UIColor.white.setFill()
        housePath.fill()
        
        // 门
        let doorWidth: CGFloat = 4
        let doorHeight: CGFloat = 6
        let doorX = centerX - doorWidth / 2
        let doorY = houseY + houseHeight * 0.5
        
        let doorPath = UIBezierPath(rect: CGRect(x: doorX, y: doorY, width: doorWidth, height: doorHeight))
        UIColor.retailBlue.setFill()
        doorPath.fill()
    }
}

class CategoryHousekeepingIcon: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let iconSize: CGFloat = 32
        let centerX = rect.midX
        let centerY = rect.midY
        
        // 上半圆（开口向下）
        let halfCirclePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                                          radius: iconSize / 2,
                                          startAngle: .pi,
                                          endAngle: 0,
                                          clockwise: false)
        UIColor.housekeepingOrange.setFill()
        halfCirclePath.fill()
        
        // 挂孔（半圆中间）
        let holePath = UIBezierPath(ovalIn: CGRect(x: centerX - iconSize * 0.15, y: centerY - iconSize * 0.1, width: iconSize * 0.3, height: iconSize * 0.1))
        UIColor.housekeepingCardBg.setFill()
        holePath.fill()
        
        // 白色购物袋（位于半圆下方）
        let bagWidth: CGFloat = 16
        let bagHeight: CGFloat = 12
        let bagX = centerX - bagWidth / 2
        let bagY = centerY + iconSize * 0.25
        
        let bagPath = UIBezierPath()
        bagPath.move(to: CGPoint(x: bagX, y: bagY))
        bagPath.addLine(to: CGPoint(x: bagX + bagWidth * 0.15, y: bagY + bagHeight * 0.2))
        bagPath.addLine(to: CGPoint(x: bagX + bagWidth * 0.85, y: bagY + bagHeight * 0.2))
        bagPath.addLine(to: CGPoint(x: bagX + bagWidth, y: bagY))
        bagPath.addLine(to: CGPoint(x: bagX + bagWidth * 0.95, y: bagY + bagHeight))
        bagPath.addLine(to: CGPoint(x: bagX + bagWidth * 0.05, y: bagY + bagHeight))
        bagPath.close()
        
        UIColor.white.setFill()
        bagPath.fill()
        
        // 五角星
        let starSize: CGFloat = 7
        let starX = centerX - starSize / 2
        let starY = bagY + bagHeight * 0.4
        
        let starPath = UIBezierPath()
        for i in 0..<5 {
            let angle = (CGFloat.pi * 2 * CGFloat(i)) / 5 - CGFloat.pi / 2
            let x = starX + starSize / 2 + cos(angle) * starSize / 2
            let y = starY + starSize / 2 + sin(angle) * starSize / 2
            if i == 0 {
                starPath.move(to: CGPoint(x: x, y: y))
            } else {
                starPath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        starPath.close()
        
        UIColor.housekeepingOrange.setFill()
        starPath.fill()
    }
}

class AllTasksViewController: UIViewController {
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "全部任务"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var taskList: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = "暂无任务"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var tasks: [Task] {
        return allTasks
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTaskList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTaskList()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(taskList)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            taskList.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            taskList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskList.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 100),
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor)
        ])
    }
    
    private func updateEmptyState() {
        let hasTasks = tasks.count > 0
        taskList.isHidden = !hasTasks
        emptyStateView.isHidden = hasTasks
    }
    
    @objc private func backTapped() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func loadTaskList() {
        if AppConfig.useRealAPI {
            NetworkManager.shared.getTaskList { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let apiTasks):
                        print("任务数据加载成功: \(apiTasks.count) 个任务")
                        // 创建临时数组存储更新后的任务
                        var updatedTasks: [Task] = []
                        for apiTask in apiTasks {
                            var industry: IndustryType = .health
                            switch apiTask.typeName {
                            case "健康":
                                industry = .health
                            case "零售":
                                industry = .retail
                            case "家政":
                                industry = .housekeeping
                            default:
                                industry = .health
                            }
                            
                            // 检查是否已存在相同ID的任务，保留其状态
                            if let existingTask = allTasks.first(where: { $0.id == "\(apiTask.id)" }) {
                                let updatedTask = Task(
                                    id: "\(apiTask.id)",
                                    title: apiTask.name,
                                    description: apiTask.description,
                                    industry: industry,
                                    reward: apiTask.reward,
                                    progress: existingTask.progress,
                                    deadline: AppConfig.TaskDefaults.deadline,
                                    status: existingTask.status,
                                    steps: AppConfig.TaskDefaults.steps,
                                    requirements: AppConfig.TaskDefaults.requirements,
                                    videoUrl: apiTask.videoUrl
                                )
                                updatedTasks.append(updatedTask)
                            } else {
                                let newTask = Task(
                                    id: "\(apiTask.id)",
                                    title: apiTask.name,
                                    description: apiTask.description,
                                    industry: industry,
                                    reward: apiTask.reward,
                                    progress: 0,
                                    deadline: AppConfig.TaskDefaults.deadline,
                                    status: apiTask.status == "published" ? .pending : .completed,
                                    steps: AppConfig.TaskDefaults.steps,
                                    requirements: AppConfig.TaskDefaults.requirements,
                                    videoUrl: apiTask.videoUrl
                                )
                                updatedTasks.append(newTask)
                            }
                        }
                        allTasks = updatedTasks
                        self.updateEmptyState()
                        self.taskList.reloadData()
                    case .failure(let error):
                        print("任务数据加载失败: \(error.localizedDescription)")
                        self.updateEmptyState()
                        self.taskList.reloadData()
                    }
                }
            }
        } else {
            print("使用默认任务数据")
            updateEmptyState()
            taskList.reloadData()
        }
    }
}

extension AllTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.delegate = self
        cell.configure(with: tasks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension AllTasksViewController: TaskCellDelegate {
    func didTapCell(task: Task) {
        let vc = TaskDetailViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapAccept(task: Task) {
        let vc = TaskDetailViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
}
