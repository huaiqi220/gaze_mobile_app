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
func predictUsingMLPackage(image1: UIImage, image2: UIImage, image3: UIImage, multiArray: MLMultiArray) -> (Double, Double)? {

//    guard let img1 = image1 as? UIImage,
//          let img2 = image2 as? UIImage,
//          let img3 = image3 as? UIImage,
//          let mary = multiArray as? MLMultiArray else{
//        print("推理函数获取的三个image有nil,请检查人脸检测部分")
//        return nil
//    }
    
    do{
        // 初始化模型
         let model = try aff_net(configuration: .init())

         // 将 UIImage 转换为 CVPixelBuffer
         guard let fpb = image1.toCVPixelBuffer(),
               let lpb = image2.toCVPixelBuffer(),
               let rpb = image3.toCVPixelBuffer() else {
             print("没有成功把 UIImage 转成 PixelBuffer")
             return nil
         }
        
        
        let input = aff_netInput(leftEyeImg:lpb,rightEyeImg: rpb,faceImg: fpb,faceGridImg: multiArray)
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




