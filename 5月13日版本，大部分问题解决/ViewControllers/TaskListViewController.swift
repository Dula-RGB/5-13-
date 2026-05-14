//
//  TaskListViewController.swift
//  ACROSSDataCollection
//

import UIKit

class TaskListViewController: UIViewController {
    
    private let industry: IndustryType
    
    init(industry: IndustryType) {
        self.industry = industry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        label.text = industry.rawValue
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var taskList: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskListCell.self, forCellReuseIdentifier: "TaskListCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var tasks: [Task] {
        return allTasks.filter { $0.industry == industry && $0.status != .completed && $0.status != .expired }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(taskList)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            taskList.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            taskList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath) as! TaskListCell
        cell.configure(with: tasks[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

extension TaskListViewController: TaskListCellDelegate {
    func didTapCell(task: Task) {
        let vc = TaskDetailViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapAccept(task: Task) {
        let vc = TaskDetailViewController(task: task)
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol TaskListCellDelegate: AnyObject {
    func didTapCell(task: Task)
    func didTapAccept(task: Task)
}

class TaskListCell: UITableViewCell {
    weak var delegate: TaskListCellDelegate?
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
            delegate?.didTapAccept(task: task)
        }
    }
}
