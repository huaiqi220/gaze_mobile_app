//
//  AppConfig.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/30.
//  Copyright © 2024 Willjay. All rights reserved.
//

import Foundation


class AppConfig {
    static let shared = AppConfig()
    private var config: [String: Any] = [:]
    
    // 初始化时读取配置文件
    private init() {
        if let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist"),
           let data = NSDictionary(contentsOfFile: path) as? [String: Any] {
            config = data
        } else {
            print("Failed to load AppConfig.plist")
        }
    }

    // 根据 key 获取配置参数
    func get<T>(key: String, defaultValue: T) -> T {
        return config[key] as? T ?? defaultValue
    }
    
    // 根据 key 存储数组
    func setArray<T>(key: String, array: [T]) {
        config[key] = array
    }
    
    // 根据 key 获取数组
    func getArray<T>(key: String, defaultValue: [T]) -> [T] {
        return config[key] as? [T] ?? defaultValue
    }
    
}
