//
//  AppConfig.swift
//  ACROSSDataCollection
//

import Foundation

struct AppConfig {
    // 是否使用真实接口数据（true=使用接口，false=使用默认数据）
    static var useRealAPI: Bool = true // 当前使用真实接口数据
    
    // 用户默认值
    struct UserDefaults {
        static let id: String = "0" // 此处将由接口数据填充
        static let name: String = "用户" // 此处将由接口数据填充
        static let avatar: String = "" // 此处将由接口数据填充
        static let totalEarnings: Double = 0.00 // 此处将由接口数据填充
        static let todayEarnings: Double = 0.00 // 此处将由接口数据填充
        static let completedTasks: Int = 0 // 此处将由接口数据填充
        static let inviteCount: Int = 0 // 此处将由接口数据填充
        static let currentExperience: Int = 0 // 此处将由接口数据填充
        static let withdrawableAmount: Double = 0.00 // 此处将由接口数据填充
    }
    
    // 等级默认值
    struct LevelDefaults {
        static let level: Int = 1 // 此处将由接口数据填充
        static let name: String = "新手入门" // 此处将由接口数据填充
        static let minExperience: Int = 0 // 此处将由接口数据填充
        static let maxExperience: Int = 100 // 此处将由接口数据填充
        static let benefits: [String] = ["基础任务权限"] // 此处将由接口数据填充
        static let requiredTasks: Int = 0 // 此处将由接口数据填充
    }
    
    // 任务默认值
    struct TaskDefaults {
        static let id: String = "0" // 此处将由接口数据填充
        static let title: String = "任务名称" // 此处将由接口数据填充
        static let description: String = "任务描述" // 此处将由接口数据填充
        static let reward: Double = 0.00 // 此处将由接口数据填充
        static let progress: Int = 0 // 此处将由接口数据填充
        static let deadline: String = "暂无截止时间" // 此处将由接口数据填充
        static let steps: [String] = ["步骤1", "步骤2"] // 此处将由接口数据填充
        static let requirements: [String] = ["要求1", "要求2"] // 此处将由接口数据填充
    }
    
    // 收益记录默认值
    struct EarningsDefaults {
        static let id: String = "0" // 此处将由接口数据填充
        static let taskName: String = "任务名称" // 此处将由接口数据填充
        static let amount: Double = 0.00 // 此处将由接口数据填充
        static let time: String = "暂无时间" // 此处将由接口数据填充
        static let type: String = "收入" // 此处将由接口数据填充
    }
}