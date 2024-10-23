//
//  LandmarkUtil.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/17.
//  Copyright © 2024 Willjay. All rights reserved.
//

import Vision
import UIKit
import CoreML
import CoreImage
import Photos



/// 根据UIImage使用Vision框架进行人脸检测，返回人脸的landmark
/// - Parameters:
///   - image: 人脸图像输入，UIImage格式
///   - completion: 返回的landmark，异步闭包格式返回
func detectFaceLandmarks(in image: UIImage, completion: @escaping (VNFaceObservation?) -> Void) {
    // 将UIImage转换为CGImage
    guard let cgImage = image.cgImage else {
        print("无法获取CGImage")
        completion(nil)
        return
    }

    // 创建请求来检测人脸
    let faceLandmarksRequest = VNDetectFaceLandmarksRequest { (request, error) in
        if let error = error {
            print("人脸检测出错: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // 提取第一个人脸检测结果
        guard let observations = request.results as? [VNFaceObservation], let firstFace = observations.first else {
            print("没有检测到人脸")
            completion(nil)
            return
        }

        // 返回检测到的第一个人脸的特征
        completion(firstFace)
    }

    // 创建图像处理处理程序
//    let orientation = image.imageOrientation.toCGImagePropertyOrientation()
    let handler = VNImageRequestHandler(cgImage: image.cgImage!,options: [:])

    // 异步执行人脸检测请求
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([faceLandmarksRequest])
        } catch {
            print("无法执行人脸检测请求: \(error.localizedDescription)")
            completion(nil)
        }
    }
}


/// 根据UImage和FaceObservation计算得到面部，眼部的boundingbox
/// 这个函数经过测试，基本正确
/// - Parameters:
///   - image: 输入图像
///   - faceObservation: Vision框架返回的人脸识别结果
/// - Returns: Bundingbox，12维，类似AFF-Net
func getFaceAndEyeBoundingBoxes(image: UIImage, faceObservation: VNFaceObservation) -> (faceBoundingBox: CGRect, leftEye: CGRect, rightEye: CGRect)? {
    // 获取原图的尺寸
    let imageSize = image.size
    let width = imageSize.width
    let height = imageSize.height

    // 获取人脸的 bounding box
    let faceBoundingBox = faceObservation.boundingBox
    let faceRect = CGRect(
        x: faceBoundingBox.origin.x * width,
        y: (1 - faceBoundingBox.origin.y - faceBoundingBox.height) * height,
        width: faceBoundingBox.width * width,
        height: faceBoundingBox.height * height
    )

    // 获取人脸特征点
    guard let landmarks = faceObservation.landmarks else {
        return (faceBoundingBox: faceRect, leftEye: .zero, rightEye: .zero)
    }

    // 获取左眼和右眼的坐标
    var leftEyeRect = CGRect.zero
    var rightEyeRect = CGRect.zero

    if let leftEye = landmarks.leftEye {
        let leftEyePoints = leftEye.normalizedPoints
        let leftEyeBoundingBox = boundingBox(for: leftEyePoints, imageSize: imageSize)
        leftEyeRect = CGRect(
            x: leftEyeBoundingBox.origin.x * width,
            y: (1 - leftEyeBoundingBox.origin.y - leftEyeBoundingBox.height) * height,
            width: leftEyeBoundingBox.width * width,
            height: leftEyeBoundingBox.height * height
        )
    }

    if let rightEye = landmarks.rightEye {
        let rightEyePoints = rightEye.normalizedPoints
        let rightEyeBoundingBox = boundingBox(for: rightEyePoints, imageSize: imageSize)
        rightEyeRect = CGRect(
            x: rightEyeBoundingBox.origin.x * width,
            y: (1 - rightEyeBoundingBox.origin.y - rightEyeBoundingBox.height) * height,
            width: rightEyeBoundingBox.width * width,
            height: rightEyeBoundingBox.height * height
        )
    }

    return (faceBoundingBox: faceRect, leftEye: leftEyeRect, rightEye: rightEyeRect)
}

func boundingBox(for points: [CGPoint], imageSize: CGSize) -> CGRect {
    let xValues = points.map { $0.x }
    let yValues = points.map { $0.y }

    let minX = xValues.min() ?? 0
    let maxX = xValues.max() ?? 0
    let minY = yValues.min() ?? 0
    let maxY = yValues.max() ?? 0

    // 这里依然返回的是归一化的值
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

func CropByBbox(image: UIImage, faceRect: CGRect, leyeRect: CGRect, reyeRect: CGRect)
->(UIImage,UIImage,UIImage){
    // 打印裁剪的区域
    print("Face Rect: \(faceRect)")
    print("Left Eye Rect: \(leyeRect)")
    print("Right Eye Rect: \(reyeRect)")
    
    // 裁剪图像的函数
    func cropImage(rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage?.cropping(to: rect) else {
            print("Failed to crop image with rect: \(rect)")
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    // 裁剪面部、左眼和右眼图像
    let faceImage = cropImage(rect: faceRect) ?? UIImage()
    let leyeImage = cropImage(rect: leyeRect) ?? UIImage()
    let reyeImage = cropImage(rect: reyeRect) ?? UIImage()

    return (faceImage, leyeImage, reyeImage)
}


// 保存图片到自定义目录
func saveImageToCustomDirectory(image: UIImage, fileName: String, caseID: String) {
    // 获取沙盒中的 Document 目录
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("无法访问文档目录")
        return
    }
    
    // 创建自定义目录 "images/cali/{case_id}"
    let customDir = documentsDirectory.appendingPathComponent("images/cali/\(caseID)")
    if !fileManager.fileExists(atPath: customDir.path) {
        do {
            try fileManager.createDirectory(at: customDir, withIntermediateDirectories: true, attributes: nil)
            print("创建目录: \(customDir.path)")
        } catch {
            print("创建目录失败: \(error)")
        }
    }

    // 保存文件到自定义目录
    let fileURL = customDir.appendingPathComponent(fileName)
    if let imageData = UIImageJPEGRepresentation(image, 1.0) {
        do {
            try imageData.write(to: fileURL)
            print("图片已保存到: \(fileURL.path)")
        } catch {
            print("保存图片失败: \(error)")
        }
    }
}



// MARK: Drawing Vision Observations
// copy from imon project
// 从landmark转换成rect
func getRectFromPointArray(pointArray points:[CGPoint], parentImage image:CGImage) -> CGRect{
    var Xs:[Float] = [], Ys:[Float] = []
    for landmark in points{
        Xs.append(Float(landmark.x))
        Ys.append(Float(landmark.y))
    }
    let width = Xs.max()! - Xs.min()!
    let height = Ys.max()! - Ys.min()!
    let rect = CGRect(x: Int((Xs.min()!-0.25*width)*Float(image.width)),
                      y: Int((Ys.min()!-1.5*height)*Float(image.height)),
                             width: Int(1.5*width*Float(image.width)),
                             height: Int(4*height*Float(image.height)))
    return rect
}



func processImage(_ image: UIImage, width: Int, height: Int) -> UIImage? {
    // 将 UIImage 转换为 CIImage
    guard let ciImage = CIImage(image: image) else { return nil }
    
    // 获取图像的宽和高
    let originalWidth = ciImage.extent.width
    let originalHeight = ciImage.extent.height

    // 创建一个转换矩阵，用于转置图像
    let transform = CGAffineTransform(scaleX: 1, y: -1)
                          .translatedBy(x: 0, y: -originalHeight)

    // 转置图像
    let transposedImage = ciImage.transformed(by: transform)

    // 创建一个 CIContext 用于渲染图像
    let context = CIContext()

    // 生成归一化后的图像
    guard let outputImage = context.createCGImage(transposedImage, from: transposedImage.extent) else { return nil }

    // 将 CGImage 转换为 UIImage
    let normalizedImage = UIImage(cgImage: outputImage)

    // 调整图像大小
    let resizedImage = normalizedImage.resized(to: CGSize(width: width, height: height))
    
    return resizedImage
}

func saveImageToPhotoLibrary(image: UIImage) {
    // 请求访问相册权限
    PHPhotoLibrary.requestAuthorization { status in
        switch status {
        case .authorized:
            // 开始保存图片
            saveImage(image)
        case .denied, .restricted:
            print("没有权限访问相册")
        case .notDetermined:
            print("权限未确定")
        default:
            break
        }
    }
}

func saveImage(_ image: UIImage) {
    // 使用 PHPhotoLibrary 保存图片
    PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAsset(from: image)
    }) { success, error in
        if success {
            print("图片已成功保存到相册")
        } else if let error = error {
            print("保存图片到相册失败: \(error)")
        }
    }
}

func mirrorImage(_ image: UIImage) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }
    return UIImage(cgImage: cgImage, scale: image.scale, orientation: .upMirrored)
}
