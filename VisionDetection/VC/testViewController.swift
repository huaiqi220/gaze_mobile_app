//
//  testViewController.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/17.
//  Copyright © 2024 Willjay. All rights reserved.
//

/**
这个VC专门用来测试其他的函数
 
 */

import Foundation
import UIKit
import Vision
import CoreML
import ImageIO


class testViewController: UIViewController{
    private let face_image_size = CGSize(width: 112, height: 112)
    private let eye_image_size = CGSize(width: 224, height: 224)
    private var face_renderer = UIGraphicsImageRenderer()
    private var eye_renderer = UIGraphicsImageRenderer()
    private var imageView: UIImageView!
    
    private var batchCache: [[String: MLMultiArray]] = [] // 缓存每张图片的结果
    private let batchSize = 9 // 批量大小
    
    override func viewDidLoad() {
        super.viewDidLoad()
        face_renderer = UIGraphicsImageRenderer(size: self.face_image_size)
        eye_renderer = UIGraphicsImageRenderer(size: self.eye_image_size)
        
        // 展示debug图片
        imageView = UIImageView(frame: self.view.bounds) // 使其填满整个屏幕
        imageView.contentMode = .scaleAspectFit // 使图像保持比例
        view.backgroundColor = .white
        
        // 获取选中目录的路径
        if let customDirectory = ModelCaliViewController.getCustomDirectory(caseID: "32") {
            // 遍历选中目录中的图片文件，执行人脸特征检测
            let imageFiles = ModelCaliViewController.getImageFiles(from: customDirectory)
            var index = 1
            for imageURL in imageFiles {
                if var image = UIImage(contentsOfFile: imageURL.path)?.fixedOrientation(){
                    
                    guard let cgImage = image.cgImage else { return }
                    image = UIImage(cgImage: cgImage,scale: image.scale, orientation: .upMirrored)
                    guard let quartzImage = image.cgImage else {return}
                    index = index + 1
                    

                    detectFaceLandmarks(in: image) { faceObservation in
                        if let faceObservation = faceObservation{
                            let newSize = CGSizeMake(112, 112); // 你希望调整的目标大小
                            let interpolation = 1; // 插值方法
                            
                            
                            let result = ImageProcessor.preprocess(image, with: faceObservation, with: newSize, interpolation: Int32(interpolation))
                            
                            guard var facema = result["face"] as? MLMultiArray,
                                  var lma = result["left"] as? MLMultiArray,
                                  var rma = result["right"] as? MLMultiArray,
                                  var may = result["rect"] as? MLMultiArray else{
                                print("返回来的图像有空")
                                return
                            }
                            
                            // 添加到缓存
                            let resultDict = ["face": facema, "left": lma, "right": rma, "rect": may]
                            self.batchCache.append(resultDict)
                            // 批量处理
                            if self.batchCache.count == self.batchSize {
                                self.processBatch()
                            }
                            
//                            let resultDictionary = getCaliDataFeature(image1: facema, image2: lma, image3: rma, multiArray: may)
//                            print("----")
//                            print("正在处理图片: \(imageURL.lastPathComponent)")
//                            print(resultDictionary)
//                            print("----")
  

                        }else{
                            print("未检测到人脸特征")
                        }

                    }

                } else {
                    print("无法加载图片: \(imageURL.lastPathComponent)")
                }

            }
            
        }
        
        
    }
    
    private func processBatch() {
        print("正在处理批量图片，数量: \(batchCache.count)")
        
        // 提取 face、left、right 的 NHWC 堆叠
        let faceArrays = batchCache.compactMap { $0["face"] }
        let leftArrays = batchCache.compactMap { $0["left"] }
        let rightArrays = batchCache.compactMap { $0["right"] }
        let rects = batchCache.compactMap { $0["rect"] }
        
        guard let stackedFace = stackMultiArray(faceArrays),
              let stackedLeft = stackMultiArray(leftArrays),
              let stackedRight = stackMultiArray(rightArrays),
              let stackedRects = stackMultiArray(rects) else {
            print("批量堆叠失败")
            return
        }
        
        // 批量推理逻辑（可以根据需求修改这里的代码）
        let resultDictionary = getCaliDataFeature(image1: stackedFace, image2: stackedLeft, image3: stackedRight, multiArray: stackedRects)
        print("----")
        print(resultDictionary?.count)
        print("----")
        
        // 清空缓存
        batchCache.removeAll()
    }
    
    // 工具方法：将多个 MLMultiArray 堆叠为一个 NHWC 的 MLMultiArray
    private func stackMultiArray(_ arrays: [MLMultiArray]) -> MLMultiArray? {
        guard let first = arrays.first else { return nil }
        
        // 确定新维度大小
        let shape = first.shape.map { $0.intValue }
        let batchSize = arrays.count
        let newShape = [batchSize] + shape // 添加批量维度
        
        // 创建新的 MLMultiArray
        let stackedArray = try? MLMultiArray(shape: newShape as [NSNumber], dataType: first.dataType)
        
        guard let result = stackedArray else { return nil }
        
        // 填充堆叠后的数据
        for (batchIndex, array) in arrays.enumerated() {
            let offset = batchIndex * shape.reduce(1, *)
            for i in 0..<array.count {
                result[offset + i] = array[i]
            }
        }
        
        return result
    }

}


func printMultiArray(_ multiArray: MLMultiArray) {
    let count = multiArray.count
    var elements: [Float] = []
    for i in 0..<count {
        elements.append(multiArray[i].floatValue)
    }
    print(elements)
}
