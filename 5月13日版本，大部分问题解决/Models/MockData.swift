//
//  MockData.swift
//  ACROSSDataCollection
//

import Foundation

let userLevels: [UserLevel] = [
    UserLevel(level: AppConfig.LevelDefaults.level, name: AppConfig.LevelDefaults.name, minExperience: AppConfig.LevelDefaults.minExperience, maxExperience: AppConfig.LevelDefaults.maxExperience, benefits: AppConfig.LevelDefaults.benefits, requiredTasks: AppConfig.LevelDefaults.requiredTasks), // 此处将由接口数据填充
    UserLevel(level: 2, name: "初级采集员", minExperience: 100, maxExperience: 300, benefits: ["解锁健康行业任务", "1.1倍收益"], requiredTasks: 5), // 此处将由接口数据填充
    UserLevel(level: 3, name: "中级采集员", minExperience: 300, maxExperience: 600, benefits: ["解锁零售行业任务", "1.2倍收益"], requiredTasks: 15), // 此处将由接口数据填充
    UserLevel(level: 4, name: "高级采集员", minExperience: 600, maxExperience: 1000, benefits: ["解锁家政行业任务", "1.3倍收益"], requiredTasks: 30), // 此处将由接口数据填充
    UserLevel(level: 5, name: "资深专家", minExperience: 1000, maxExperience: 2000, benefits: ["全部任务权限", "1.5倍收益", "专属客服"], requiredTasks: 50), // 此处将由接口数据填充
    UserLevel(level: 6, name: "精英大师", minExperience: 2000, maxExperience: 5000, benefits: ["全部任务权限", "1.8倍收益", "专属客服", "优先审核"], requiredTasks: 100), // 此处将由接口数据填充
]

var allTasks: [Task] = [
    Task(
        id: AppConfig.TaskDefaults.id,
        title: AppConfig.TaskDefaults.title,
        description: AppConfig.TaskDefaults.description,
        industry: .health,
        reward: AppConfig.TaskDefaults.reward,
        progress: AppConfig.TaskDefaults.progress,
        deadline: AppConfig.TaskDefaults.deadline,
        status: .pending,
        steps: AppConfig.TaskDefaults.steps,
        requirements: AppConfig.TaskDefaults.requirements,
        videoUrl: ""
    ), // 此处将由接口数据填充
    Task(
        id: "2",
        title: "零售行业任务",
        description: "用手将收银台上商品扫码并打包完成",
        industry: .retail,
        reward: AppConfig.TaskDefaults.reward, // 此处将由接口数据填充
        progress: AppConfig.TaskDefaults.progress, // 此处将由接口数据填充
        deadline: AppConfig.TaskDefaults.deadline, // 此处将由接口数据填充
        status: .pending, // 改为待完成状态，显示立即接取按钮
        steps: ["前往指定零售门店", "扫描收银台商品", "将商品打包", "拍照上传凭证"],
        requirements: ["必须在收银台完成", "扫码准确无误", "打包整齐"],
        videoUrl: ""
    ), // 此处将由接口数据填充
    Task(
        id: "3",
        title: "家政行业任务",
        description: "用手整理橱柜",
        industry: .housekeeping,
        reward: AppConfig.TaskDefaults.reward, // 此处将由接口数据填充
        progress: AppConfig.TaskDefaults.progress, // 此处将由接口数据填充
        deadline: AppConfig.TaskDefaults.deadline, // 此处将由接口数据填充
        status: .pending,
        steps: ["前往指定地点", "整理橱柜物品", "分类摆放整齐", "拍照上传"],
        requirements: ["物品分类清晰", "摆放整齐美观", "照片清晰"],
        videoUrl: ""
    ), // 此处将由接口数据填充
    Task(
        id: "4",
        title: "健康行业任务",
        description: "医疗器械盘点记录",
        industry: .health,
        reward: 15.0, // 此处将由接口数据填充
        progress: 100, // 此处将由接口数据填充
        deadline: "2024-12-20 18:00", // 此处将由接口数据填充
        status: .completed,
        steps: ["前往医疗机构", "盘点医疗器械", "记录数量", "提交报告"],
        requirements: ["记录准确", "数据完整", "按时提交"],
        videoUrl: ""
    ), // 此处将由接口数据填充
    Task(
        id: "5",
        title: "零售行业任务",
        description: "货架商品补货",
        industry: .retail,
        reward: 12.0, // 此处将由接口数据填充
        progress: 0, // 此处将由接口数据填充
        deadline: "2024-12-10 18:00", // 此处将由接口数据填充
        status: .expired,
        steps: ["前往门店", "检查货架", "补充商品", "整理陈列"],
        requirements: ["商品摆放整齐", "价签对应"],
        videoUrl: ""
    ), // 此处将由接口数据填充
]

let earningsRecords: [EarningsRecord] = [
    EarningsRecord(id: AppConfig.EarningsDefaults.id, taskName: AppConfig.EarningsDefaults.taskName, amount: AppConfig.EarningsDefaults.amount, time: AppConfig.EarningsDefaults.time, type: AppConfig.EarningsDefaults.type), // 此处将由接口数据填充
    EarningsRecord(id: "2", taskName: "药品打包任务", amount: 11.0, time: "2024-12-19 10:20", type: "收入"), // 此处将由接口数据填充
    EarningsRecord(id: "3", taskName: "商品扫码打包", amount: 13.0, time: "2024-12-18 16:45", type: "收入"), // 此处将由接口数据填充
    EarningsRecord(id: "4", taskName: "橱柜整理", amount: 10.0, time: "2024-12-17 09:15", type: "收入"), // 此处将由接口数据填充
    EarningsRecord(id: "5", taskName: "提现", amount: -50.0, time: "2024-12-16 11:00", type: "支出"), // 此处将由接口数据填充
]

var currentUser = User(
    id: AppConfig.UserDefaults.id, // 此处将由接口数据填充
    name: AppConfig.UserDefaults.name, // 此处将由接口数据填充
    avatar: AppConfig.UserDefaults.avatar, // 此处将由接口数据填充
    totalEarnings: AppConfig.UserDefaults.totalEarnings, // 此处将由接口数据填充
    todayEarnings: AppConfig.UserDefaults.todayEarnings, // 此处将由接口数据填充
    completedTasks: AppConfig.UserDefaults.completedTasks, // 此处将由接口数据填充
    inviteCount: AppConfig.UserDefaults.inviteCount, // 此处将由接口数据填充
    currentLevel: userLevels[0], // 此处将由接口数据填充
    currentExperience: AppConfig.UserDefaults.currentExperience, // 此处将由接口数据填充
    withdrawableAmount: AppConfig.UserDefaults.withdrawableAmount, // 此处将由接口数据填充
    tasks: allTasks
)