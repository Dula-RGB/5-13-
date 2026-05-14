//
//  TaskDetailViewController.swift
//  ACROSSDataCollection
//

import UIKit
import AVKit
import AVFoundation

class TaskDetailViewController: UIViewController {
    
    private let task: Task
    private var currentStatus: TaskStatus
    
    init(task: Task) {
        self.task = task
        self.currentStatus = task.status
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
        label.text = "任务详情"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 第一个卡片：任务名称、奖励、截止时间
    private lazy var infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(12)
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var taskNameLabel: UILabel = {
        let label = UILabel()
        label.text = task.title
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var rewardLabel: UILabel = {
        let label = UILabel()
        label.text = String(format: "¥%.2f", task.reward)
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .acrossOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "截止: \(task.deadline)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "\(task.progress)% (0/0)"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 第二个卡片：任务描述
    private lazy var descriptionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(12)
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "任务描述"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionContentLabel: UILabel = {
        let label = UILabel()
        label.text = task.description
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .acrossTextGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 第三个卡片：任务要求
    private lazy var requirementsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(12)
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var requirementsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "任务要求"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var requirementsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // 第四个卡片：操作视频
    private lazy var videoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadius(12)
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoCardTapped))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 28)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: imageConfig), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .acrossOrange
        button.setCornerRadius(20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(videoCardTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var videoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "查看操作视频"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var videoDescLabel: UILabel = {
        let label = UILabel()
        label.text = "点击观看任务操作演示"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .acrossTextGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .acrossTextGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 底部按钮
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(getButtonTitle(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .acrossOrange
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setCornerRadius(8)
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRequirements()
    }
    
    private func setupUI() {
        view.backgroundColor = .acrossLightGray
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(infoCardView)
        contentView.addSubview(descriptionCardView)
        contentView.addSubview(requirementsCardView)
        contentView.addSubview(videoCardView)
        contentView.addSubview(actionButton)
        
        // 第一个卡片内容
        infoCardView.addSubview(taskNameLabel)
        infoCardView.addSubview(rewardLabel)
        infoCardView.addSubview(deadlineLabel)
        infoCardView.addSubview(progressLabel)
        
        // 第二个卡片内容
        descriptionCardView.addSubview(descriptionTitleLabel)
        descriptionCardView.addSubview(descriptionContentLabel)
        
        // 第三个卡片内容
        requirementsCardView.addSubview(requirementsTitleLabel)
        requirementsCardView.addSubview(requirementsStackView)
        
        // 第四个卡片内容
        videoCardView.addSubview(playButton)
        videoCardView.addSubview(videoTitleLabel)
        videoCardView.addSubview(videoDescLabel)
        videoCardView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 第一个卡片
            infoCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            infoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            taskNameLabel.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 16),
            taskNameLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            
            rewardLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: 8),
            rewardLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            
            deadlineLabel.topAnchor.constraint(equalTo: rewardLabel.bottomAnchor, constant: 8),
            deadlineLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            
            progressLabel.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 4),
            progressLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -16),
            progressLabel.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -16),
            
            // 第二个卡片
            descriptionCardView.topAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: 16),
            descriptionCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: descriptionCardView.topAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: descriptionCardView.leadingAnchor, constant: 16),
            
            descriptionContentLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 12),
            descriptionContentLabel.leadingAnchor.constraint(equalTo: descriptionCardView.leadingAnchor, constant: 16),
            descriptionContentLabel.trailingAnchor.constraint(equalTo: descriptionCardView.trailingAnchor, constant: -16),
            descriptionContentLabel.bottomAnchor.constraint(equalTo: descriptionCardView.bottomAnchor, constant: -16),
            
            // 第三个卡片
            requirementsCardView.topAnchor.constraint(equalTo: descriptionCardView.bottomAnchor, constant: 16),
            requirementsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            requirementsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            requirementsTitleLabel.topAnchor.constraint(equalTo: requirementsCardView.topAnchor, constant: 16),
            requirementsTitleLabel.leadingAnchor.constraint(equalTo: requirementsCardView.leadingAnchor, constant: 16),
            
            requirementsStackView.topAnchor.constraint(equalTo: requirementsTitleLabel.bottomAnchor, constant: 12),
            requirementsStackView.leadingAnchor.constraint(equalTo: requirementsCardView.leadingAnchor, constant: 16),
            requirementsStackView.trailingAnchor.constraint(equalTo: requirementsCardView.trailingAnchor, constant: -16),
            requirementsStackView.bottomAnchor.constraint(equalTo: requirementsCardView.bottomAnchor, constant: -16),
            
            // 第四个卡片
            videoCardView.topAnchor.constraint(equalTo: requirementsCardView.bottomAnchor, constant: 16),
            videoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            videoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            videoCardView.heightAnchor.constraint(equalToConstant: 80),
            
            playButton.centerYAnchor.constraint(equalTo: videoCardView.centerYAnchor),
            playButton.leadingAnchor.constraint(equalTo: videoCardView.leadingAnchor, constant: 16),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalToConstant: 40),
            
            videoTitleLabel.topAnchor.constraint(equalTo: videoCardView.topAnchor, constant: 16),
            videoTitleLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            
            videoDescLabel.topAnchor.constraint(equalTo: videoTitleLabel.bottomAnchor, constant: 4),
            videoDescLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            
            arrowImageView.centerYAnchor.constraint(equalTo: videoCardView.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: videoCardView.trailingAnchor, constant: -16),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // 底部按钮
            actionButton.topAnchor.constraint(equalTo: videoCardView.bottomAnchor, constant: 24),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupRequirements() {
        for requirement in task.requirements {
            let label = UILabel()
            label.text = "• \(requirement)"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .black
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            requirementsStackView.addArrangedSubview(label)
        }
    }
    
    private func getButtonTitle() -> String {
        switch currentStatus {
        case .pending:
            return "立即接取任务"
        case .inProgress:
            return "去完成"
        case .completed:
            return "已完成"
        case .expired:
            return "已过期"
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionTapped() {
        switch currentStatus {
        case .pending:
            acceptTask()
        case .inProgress:
            submitTask()
        default:
            break
        }
    }
    
    @objc private func videoCardTapped() {
        guard let videoURL = URL(string: task.videoUrl), !task.videoUrl.isEmpty else {
            let alert = UIAlertController(title: "提示", message: "暂无操作视频", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    private func acceptTask() {
        currentStatus = .inProgress
        actionButton.setTitle(getButtonTitle(), for: .normal)
        
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[index].status = .inProgress
        }
        
        let alert = UIAlertController(title: "提示", message: "任务已接取，加油完成吧！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    private func submitTask() {
        let alert = UIAlertController(title: "完成任务", message: "请选择完成方式", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "选择本地视频", style: .default, handler: { [weak self] _ in
            self?.selectLocalVideo()
        }))
        
        alert.addAction(UIAlertAction(title: "拍摄视频", style: .default, handler: { [weak self] _ in
            self?.captureVideo()
        }))
        
        present(alert, animated: true)
    }
    
    private func selectLocalVideo() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func captureVideo() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func validateVideoDuration(url: URL) -> Bool {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        if durationInSeconds > 60 {
            showDurationAlert()
            return false
        }
        return true
    }
    
    private func showDurationAlert() {
        let alertLabel = UILabel()
        alertLabel.text = "时长超出1分钟"
        alertLabel.font = UIFont.systemFont(ofSize: 14)
        alertLabel.textColor = .white
        alertLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        alertLabel.textAlignment = .center
        alertLabel.layer.cornerRadius = 20
        alertLabel.clipsToBounds = true
        alertLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertLabel)
        
        NSLayoutConstraint.activate([
            alertLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            alertLabel.widthAnchor.constraint(equalToConstant: 140),
            alertLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        alertLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            alertLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.7, options: [], animations: {
                alertLabel.alpha = 0
            }) { _ in
                alertLabel.removeFromSuperview()
            }
        }
    }
    
    private func uploadVideo(url: URL) {
        guard let taskId = Int(task.id) else {
            let alert = UIAlertController(title: "提示", message: "任务ID无效", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }
        NetworkManager.shared.uploadTaskVideo(taskId: taskId, videoUrl: url) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.showReviewing()
                } else {
                    let alert = UIAlertController(title: "提示", message: "视频上传失败，请重试", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    private func showReviewing() {
        let alert = UIAlertController(title: "提交成功", message: "任务正在审核中，请耐心等待", preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            alert.dismiss(animated: true) {
                self?.showApproved()
            }
        }
    }
    
    private func showApproved() {
        currentStatus = .completed
        actionButton.setTitle(getButtonTitle(), for: .normal)
        actionButton.isEnabled = false
        
        if let index = allTasks.firstIndex(where: { $0.id == task.id }) {
            allTasks[index].status = .completed
        }
        
        let alert = UIAlertController(title: "审核通过", message: "恭喜！任务完成，收益¥\(task.reward)已到账", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}

extension TaskDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let videoURL = info[.mediaURL] as? URL else { return }
            
            if self?.validateVideoDuration(url: videoURL) == true {
                self?.uploadVideo(url: videoURL)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
