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

import UIKit
import CoreML
import Vision

func performInferenceOnImages() {
    // 1. 加载ML Model
    guard let modelURL = Bundle.main.url(forResource: "YourMLModel", withExtension: "mlpackage"),
          let model = try? MLModel(contentsOf: modelURL) else {
        print("模型加载失败")
        return
    }

    // 2. 获取文件夹中的图片
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("无法访问文档目录")
        return
    }
    
    let imagesDirectory = documentsDirectory.appendingPathComponent("images/cali")
    
    var results: [[Float]] = []
    
    do {
        let fileNames = try fileManager.contentsOfDirectory(atPath: imagesDirectory.path)
        
        for fileName in fileNames {
            let fileURL = imagesDirectory.appendingPathComponent(fileName)
            
            // 3. 加载图片并进行预处理
            if let image = UIImage(contentsOfFile: fileURL.path) {
                guard let processedImage = preprocessImage(image) else {
                    print("图片预处理失败：\(fileName)")
                    continue
                }
                
                // 4. 将图片转换为MLMultiArray
                guard let mlMultiArray = convertToMultiArray(image: processedImage) else {
                    print("图片转换为 MultiArray 失败：\(fileName)")
                    continue
                }
                
                // 5. 进行推理
                if let result = runInference(with: model, input: mlMultiArray) {
                    results.append(result)
                }
            }
        }
        
        // 6. 计算推理结果的平均值
        if let averageResult = calculateAverageResult(results: results) {
            print("推理结果平均值：\(averageResult)")
        }
        
    } catch {
        print("读取文件夹失败：\(error)")
    }
}

// 图片预处理函数，将图片转换为适合模型输入的格式
func preprocessImage(_ image: UIImage) -> UIImage? {
    // 根据模型需求调整图片的大小和颜色空间等
    let targetSize = CGSize(width: 224, height: 224) // 假设模型要求的输入尺寸为224x224
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
    image.draw(in: CGRect(origin: .zero, size: targetSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
}

// 将UIImage转换为MLMultiArray
func convertToMultiArray(image: UIImage) -> MLMultiArray? {
    guard let pixelBuffer = image.pixelBuffer(width: 224, height: 224) else { // 转换为CVPixelBuffer
        return nil
    }
    
    let mlMultiArray = try? MLMultiArray(shape: [1, 224, 224, 3], dataType: .float32)
    
    // 把pixelBuffer的内容复制到MultiArray
    // 这里你需要根据具体的模型要求来进行转换，例如归一化、色彩通道等
    return mlMultiArray
}

// 使用模型进行推理
func runInference(with model: MLModel, input: MLMultiArray) -> [Float]? {
    let inputDictionary: [String: Any] = ["image_input": input]
    guard let output = try? model.prediction(from: MLDictionaryFeatureProvider(dictionary: inputDictionary)) else {
        print("推理失败")
        return nil
    }
    
    // 假设输出为一个 MultiArray
    guard let outputArray = output.featureValue(for: "output_key")?.multiArrayValue else {
        print("无法获取输出结果")
        return nil
    }
    
    return outputArray.toFloatArray() // 将 MLMultiArray 转换为 [Float]
}

// 计算所有推理结果的平均值
func calculateAverageResult(results: [[Float]]) -> [Float]? {
    guard results.count > 0 else {
        return nil
    }
    
    let resultCount = results.first!.count
    var sum = [Float](repeating: 0, count: resultCount)
    
    for result in results {
        for i in 0..<resultCount {
            sum[i] += result[i]
        }
    }
    
    let average = sum.map { $0 / Float(results.count) }
    return average
}

// Extension 将UIImage转换为CVPixelBuffer
extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess, let pb = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pb, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pb)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pb), space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        guard let cgImage = self.cgImage else {
            return nil
        }

        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        CVPixelBufferUnlockBaseAddress(pb, CVPixelBufferLockFlags(rawValue: 0))

        return pb
    }
}

// Extension 将MLMultiArray转换为Float数组
extension MLMultiArray {
    func toFloatArray() -> [Float] {
        let pointer = UnsafeMutablePointer<Float>(OpaquePointer(self.dataPointer))
        return Array(UnsafeBufferPointer(start: pointer, count: self.count))
    }
}
