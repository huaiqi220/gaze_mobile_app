//
//  MLInferenceUtil.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/17.
//  Copyright © 2024 Willjay. All rights reserved.
//

/**
 
 这个文件中的函数功能还没进行测试，先弄个简单的ResNet调通整个pipeline
 最后再换成我计算cali的gaze模型
 
 也要考虑我转换时候能不能直接接受Image而不是mlpackage
 总之，10月18日再搞
 sleep！的
 
 */

import CoreML
import UIKit
import Foundation





// 推理函数
func predictUsingMLPackage(image1: MLMultiArray, image2: MLMultiArray, image3: MLMultiArray, multiArray: MLMultiArray) -> (Double, Double)? {

    do{
        // 初始化模型
         let model = try aff_net_ma(configuration: .init())

        let input = aff_net_maInput(leftEyeImg:image2,rightEyeImg: image3,faceImg: image1,faceGridImg: multiArray)
        let res = try model.prediction(input: input)
        // 获取返回的 1x2 的 MLMultiArray
        
        let resultArray = res.linear_35
        
        // 提取结果值
        let x = resultArray[0].doubleValue
        let y = resultArray[1].doubleValue

        return (x, y)
        
    }catch{
        print("模型加载推理过程出错")
        return nil
    }
    

}


// 处理获得校准数据的feature
func getCaliDataFeature(image1: MLMultiArray, image2: MLMultiArray, image3: MLMultiArray, multiArray: MLMultiArray) -> MLMultiArray? {

    do{
        // 初始化模型
        let model = try cges_getfeature(configuration: .init())
        print("1")
        let input = cges_getfeatureInput(faceImg: image1,leftEyeImg:image2,rightEyeImg: image3,faceGridImg: multiArray)
        print("2")
        let res = try model.prediction(input: input)
        // 获取返回的 1x2 的 MLMultiArray
        print("3")
        let resultArray = res.linear_8
        print("4")
        return resultArray
        
    }catch{
        print("模型加载推理过程出错")
        return nil
    }
    

}


func addBatchDimension(to array: MLMultiArray, batchSize: Int, shape: Int) -> MLMultiArray? {
    // Ensure the original shape is [112, 112, 3]
    guard array.shape.count == 3,
          array.shape == [shape, shape, 3] as [NSNumber] else {
        print("Input MLMultiArray does not have the expected shape of [112, 112, 3].")
        return nil
    }
    
    // Create a new MLMultiArray with shape [batchSize, 112, 112, 3]
    let newShape = [batchSize, shape, shape, 3].map { NSNumber(value: $0) }
    guard let newArray = try? MLMultiArray(shape: newShape, dataType: array.dataType) else {
        print("Failed to create new MLMultiArray.")
        return nil
    }
    
    // Copy the data into the new array for each batch
    let totalElements = array.count
    for batch in 0..<batchSize {
        for index in 0..<totalElements {
            newArray[batch * totalElements + index] = array[index]
        }
    }
    return newArray
}


func create1DZeroArray(size: Int) -> MLMultiArray? {
    // 期望模型输入是一维数组，大小为 size
    let shape: [NSNumber] = [NSNumber(value: size)]
    
    // 尝试创建一维 MLMultiArray
    do {
        let multiArray = try MLMultiArray(shape: shape, dataType: .float32)
        
        // 初始化为全零
        for i in 0..<multiArray.count {
            multiArray[i] = 0
        }
        
        return multiArray
    } catch {
        print("Error creating MLMultiArray: \(error)")
        return nil
    }
}







