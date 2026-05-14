//
//  User.swift
//  ACROSSDataCollection
//
//  Created by ACROSS on 2024/1/1.
//

import Foundation

struct UserLevel {
    let level: Int
    let name: String
    let minExperience: Int
    let maxExperience: Int
    let benefits: [String]
    let requiredTasks: Int
}

struct User {
    var id: String
    var name: String
    let avatar: String
    var totalEarnings: Double
    var todayEarnings: Double
    var completedTasks: Int
    var inviteCount: Int
    var currentLevel: UserLevel
    var currentExperience: Int
    var withdrawableAmount: Double
    var tasks: [Task]
}
