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




