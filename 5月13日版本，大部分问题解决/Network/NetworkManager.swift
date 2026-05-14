//
//  NetworkManager.swift
//  ACROSSDataCollection
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://8.141.117.147:8088"
    
    private init() {}
    
    // POST 保存app用户
    func createAppUser(userName: String, phone: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/appUser") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let body: [String: Any] = [
            "userName": userName,
            "phone": phone
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // GET 根据手机号获取用户信息
    func getUserInfo(phone: String, completion: @escaping (Result<ApiUser, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/appUser?phone=\(phone)") else {
            print("URL无效: \(baseURL)/api/appUser?phone=\(phone)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        print("正在请求用户信息: \(url)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("网络请求失败: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("返回数据为空")
                completion(.failure(NetworkError.noData))
                return
            }
            
            // 打印原始响应数据
            if let responseString = String(data: data, encoding: .utf8) {
                print("接口返回数据: \(responseString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(ApiResponse<ApiUser>.self, from: data)
                
                // 检查接口返回的code
                if apiResponse.code == 200 {
                    if let user = apiResponse.data {
                        completion(.success(user))
                    } else {
                        print("接口返回成功但数据为空")
                        completion(.failure(NetworkError.userNotFound))
                    }
                } else {
                    print("接口返回错误码: \(apiResponse.code), 消息: \(apiResponse.message)")
                    completion(.failure(NetworkError.apiError(message: apiResponse.message)))
                }
            } catch {
                print("JSON解码失败: \(error.localizedDescription)")
                print("完整错误信息: \(error)")
                if let decodingError = error as? DecodingError {
                    print("解码错误详情: \(decodingError)")
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("类型不匹配: \(type)")
                        print("上下文: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("值不存在: \(type)")
                        print("上下文: \(context.debugDescription)")
                    case .keyNotFound(let key, let context):
                        print("键不存在: \(key)")
                        print("上下文: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("数据损坏")
                        print("上下文: \(context.debugDescription)")
                    @unknown default:
                        print("未知解码错误")
                    }
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    // POST 保存app用户接收任务
    func receiveTask(userId: String, taskId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/receives") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let body: [String: Any] = [
            "userId": userId,
            "taskId": taskId
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // GET 根据app用户id获取任务接单信息
    func getTaskReceiveList(appUserId: String, completion: @escaping (Result<[TaskReceive], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/receives/getTaskReceiveList?appUserId=\(appUserId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ApiResponse<[TaskReceive]>.self, from: data)
                if let tasks = response.data {
                    completion(.success(tasks))
                } else {
                    completion(.success([]))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // POST 上传任务视频
    func uploadTaskVideo(taskId: Int, videoUrl: URL, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/receives/submitTask") else {
            completion(false)
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let fileName = videoUrl.lastPathComponent
        let fileData = try? Data(contentsOf: videoUrl)
        
        guard let data = fileData else {
            completion(false)
            return
        }
        
        var body = Data()
        
        let taskIdData = "taskId=\(taskId)".data(using: .utf8)!
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"taskId\"\r\n\r\n".data(using: .utf8)!)
        body.append(taskIdData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("上传失败: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
    
    // GET 获取任务列表
    func getTaskList(completion: @escaping (Result<[ApiTask], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/tasks/taskListByStatus") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ApiResponse<[ApiTask]>.self, from: data)
                if let tasks = response.data {
                    completion(.success(tasks))
                } else {
                    completion(.success([]))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case userNotFound
    case apiError(message: String)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL地址"
        case .noData:
            return "服务器返回数据为空"
        case .invalidResponse:
            return "服务器响应格式错误"
        case .userNotFound:
            return "用户不存在"
        case .apiError(let message):
            return message
        }
    }
}

struct ApiResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
}

struct ApiUser: Codable {
    let id: Int
    let userName: String
    let phone: String
    let password: String?
    let totalReward: Int
    let status: String
    let createTime: String?
    let updateTime: String?
}

struct ApiTask: Codable {
    let id: Int
    let name: String
    let description: String
    let reward: Double
    let videoUrl: String
    let status: String
    let typeId: Int
    let typeName: String
    let createBy: Int
    let createTime: String?
    let updateTime: String?
}

struct TaskReceive: Codable {
    let id: Int
    let taskId: Int
    let userId: Int
    let receiveUrl: String?
    let status: String
    let content: String?
    let description: String?
    let reward: Double
    let videoUrl: String?
    let taskStatus: String
    let taskName: String
}
