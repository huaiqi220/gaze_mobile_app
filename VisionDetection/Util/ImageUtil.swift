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
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

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


func getFaceAndEyeBoundingBoxes(image: UIImage, faceObservation: VNFaceObservation) -> (faceBoundingBox: CGRect, leftEye: CGRect, rightEye: CGRect)? {
    // 获取原图的尺寸
    let imageSize = image.size
    let width = imageSize.width
    let height = imageSize.height

    // 获取人脸的 bounding box
    let faceBoundingBox = faceObservation.boundingBox
    let faceRect = CGRect(
        x: faceBoundingBox.origin.x * width,
        y: faceBoundingBox.origin.y * height, // 使用相对于左上角的y坐标
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
            y: leftEyeBoundingBox.origin.y * height, // 使用相对于左上角的y坐标
            width: leftEyeBoundingBox.width * width,
            height: leftEyeBoundingBox.height * height
        )
    }

    if let rightEye = landmarks.rightEye {
        let rightEyePoints = rightEye.normalizedPoints
        let rightEyeBoundingBox = boundingBox(for: rightEyePoints, imageSize: imageSize)
        rightEyeRect = CGRect(
            x: rightEyeBoundingBox.origin.x * width,
            y: rightEyeBoundingBox.origin.y * height, // 使用相对于左上角的y坐标
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

    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}


