//
//  MyTasksViewController.swift
//  ACROSSDataCollection
//

import UIKit

class MyTasksViewController: UIViewController {
    
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
        label.text = "我的任务"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["进行中", "已完成"])
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private lazy var taskList: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyTaskCell.self, forCellReuseIdentifier: "MyTaskCell")
        tableView.separatorStyle = .none
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isInProgress = true
    
    private var filteredTasks: [Task] {
        if isInProgress {
            return allTasks.filter { $0.status == .inProgress }
        } else {
            return allTasks.filter { $0.status == .completed }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserTaskList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserTaskList()
    }
    
    private func loadUserTaskList() {
        NetworkManager.shared.getTaskReceiveList(appUserId: "\(currentUser.id)") { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let receives):
                    self.updateUserTasks(with: receives)
                    self.updateEmptyState()
                    self.taskList.reloadData()
                case .failure:
                    self.updateEmptyState()
                    self.taskList.reloadData()
                }
            }
        }
    }
    
    private func updateUserTasks(with receives: [TaskReceive]) {
        for receive in receives {
            if let index = allTasks.firstIndex(where: { $0.id == "\(receive.taskId)" }) {
                allTasks[index].status = receive.status == "approved" ? .completed : .inProgress
                allTasks[index].reward = receive.reward
            } else {
                let newTask = Task(
                    id: "\(receive.taskId)",
                    title: receive.taskName,
                    description: receive.description ?? "",
                    industry: .health,
                    reward: receive.reward,
                    progress: receive.status == "approved" ? 100 : 50,
                    deadline: AppConfig.TaskDefaults.deadline,
                    status: receive.status == "approved" ? .completed : .inProgress,
                    steps: AppConfig.TaskDefaults.steps,
                    requirements: AppConfig.TaskDefaults.requirements,
                    videoUrl: receive.videoUrl ?? ""
                )
                allTasks.append(newTask)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(segmentControl)
        view.addSubview(taskList)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentControl.widthAnchor.constraint(equalToConstant: 160),
            
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
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func segmentChanged() {
        isInProgress = segmentControl.selectedSegmentIndex == 0
        updateEmptyState()
        taskList.reloadData()
    }
    
    private func updateEmptyState() {
        let hasTasks = filteredTasks.count > 0
        taskList.isHidden = !hasTasks
        emptyStateView.isHidden = hasTasks
        
        if !hasTasks {
            emptyStateLabel.text = isInProgress ? "暂时没有进行中的任务，快去接取新任务吧" : "暂时没有完成任何任务，快去完成任务吧"
        }
    }
}

extension MyTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTaskCell", for: indexPath) as! MyTaskCell
        cell.configure(with: filteredTasks[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
}

extension MyTasksViewController: MyTaskCellDelegate {
    func didTapTask(task: Task) {
        let vc = TaskDetailViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol MyTaskCellDelegate: AnyObject {
    func didTapTask(task: Task)
}

class MyTaskCell: UITableViewCell {
    weak var delegate: MyTaskCellDelegate?
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
    
    private lazy var titleLabel: UILabel = {
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
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("继续任务", for: .normal)
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
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(rewardLabel)
        containerView.addSubview(progressLabel)
        containerView.addSubview(deadlineLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(acceptButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: rewardLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            rewardLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            rewardLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            progressLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            progressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            deadlineLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 6),
            deadlineLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            statusLabel.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            acceptButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 14),
            acceptButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            acceptButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            acceptButton.heightAnchor.constraint(equalToConstant: 40),
            acceptButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -14)
        ])
    }
    
    func configure(with task: Task) {
        self.task = task
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        rewardLabel.text = String(format: "¥%.2f", task.reward)
        progressLabel.text = "\(task.progress)% (\(task.progress)/\(task.steps.count))"
        deadlineLabel.text = "截止: \(task.deadline)"
        statusLabel.text = "状态: \(task.status.rawValue)"
        
        if task.status == .completed {
            acceptButton.setTitle("已完成", for: .normal)
            acceptButton.backgroundColor = .gray
            acceptButton.isEnabled = false
        } else if task.status == .expired {
            acceptButton.setTitle("已过期", for: .normal)
            acceptButton.backgroundColor = .gray
            acceptButton.isEnabled = false
        } else {
            acceptButton.setTitle("进行中", for: .normal)
            acceptButton.backgroundColor = .acrossOrange
            acceptButton.isEnabled = true
        }
    }
    
    @objc private func cellTapped() {
        if let task = task {
            delegate?.didTapTask(task: task)
        }
    }
    
    @objc private func acceptTapped() {
        if let task = task {
            delegate?.didTapTask(task: task)
        }
    }
}
