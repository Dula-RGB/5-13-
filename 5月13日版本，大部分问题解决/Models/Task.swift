//
//  Task.swift
//  ACROSSDataCollection
//
//  Created by ACROSS on 2024/1/1.
//

import Foundation

enum TaskStatus: String, Codable {
    case pending = "待完成"
    case inProgress = "进行中"
    case completed = "已完成"
    case expired = "已过期"
}

enum IndustryType: String, Codable {
    case health = "健康"
    case retail = "零售"
    case housekeeping = "家政"
}

struct Task: Codable {
    let id: String
    var title: String
    var description: String
    let industry: IndustryType
    var reward: Double
    var progress: Int
    let deadline: String
    var status: TaskStatus
    let steps: [String]
    let requirements: [String]
    let videoUrl: String
}

struct EarningsRecord: Codable {
    let id: String
    let taskName: String
    let amount: Double
    let time: String
    let type: String
}
