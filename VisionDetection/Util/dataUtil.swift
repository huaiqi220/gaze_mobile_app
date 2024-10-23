//
//  dataUtil.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/23.
//  Copyright © 2024 Willjay. All rights reserved.
//

/**
 
 模型执行个性化校准之后输出的就是MLMultiArray，这个MLMultiArray作为校准参数后续将在推理中进行加载。
 因此校准后把它持久化存储下来，推理时候根据case ID 作为key进行加载
 
 */

import Foundation
import CoreML

func saveMLMultiArray(array: MLMultiArray, withKey key: Int) throws {
    // 获取文件路径
    let fileManager = FileManager.default
    let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filePath = directory.appendingPathComponent("array_\(key).bin")
    
    // 转换为Data
    let arrayPointer = array.dataPointer
    let data = Data(bytes: arrayPointer, count: array.count * MemoryLayout<Double>.size)

    // 将Data写入文件
    try data.write(to: filePath)
    print("MLMultiArray saved to: \(filePath)")
}

func loadMLMultiArray(withKey key: Int, shape: [NSNumber], dataType: MLMultiArrayDataType) throws -> MLMultiArray {
    // Get the file path
    let fileManager = FileManager.default
    let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filePath = directory.appendingPathComponent("array_\(key).bin")
    
    // Read the data from the file
    let data = try Data(contentsOf: filePath)

    // Create an MLMultiArray to hold the loaded data
    let array = try MLMultiArray(shape: shape, dataType: dataType)

    // Ensure the data fits the MLMultiArray size
    guard data.count == array.count * MemoryLayout<Double>.size else {
        throw NSError(domain: "Data size mismatch", code: 1, userInfo: nil)
    }

    // Copy the data into MLMultiArray’s memory
    data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
        guard let baseAddress = bytes.baseAddress else { return }
        memcpy(array.dataPointer, baseAddress, data.count)
    }
    
    return array
}
