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
                if let image = UIImage(contentsOfFile: imageURL.path)?.fixedOrientation(){
                    
                    guard let quartzImage = image.cgImage else {return}
                    index = index + 1
                    print("正在处理图片: \(imageURL.lastPathComponent)")

                    detectFaceLandmarks(in: image) { faceObservation in
                        if let faceObservation = faceObservation{
                            print("\(OpenCVWrapper.getOpenCVVersion())")
//                            let (faceimg, leftimg, rightimg) = ImageProcessor.cropAndResize(image, fromFaceObservation: faceObservation, with: image.size, interpolation: 0)
                            
//                            let landmark = faceObservation.landmarks
//                            let el = landmark?.leftEye
//                            let er = landmark?.rightEye
//                            let ap = landmark?.allPoints
//                            print(ap?.pointCount)
//                            print(ap?.normalizedPoints)
 
                            
                            let newSize = CGSizeMake(112, 112); // 你希望调整的目标大小
                            let interpolation = 1; // 插值方法
                            let croppedImages = ImageProcessor.preprocess(image, with: faceObservation, with: newSize, interpolation: Int32(interpolation))
                            
                            // 处理返回的裁剪图像
                            
                            saveImageToCustomDirectory(image: image, fileName: "\(index)_origin.jpg", caseID: "test_resize_all8")
                            if let faceImage = croppedImages[0] as? UIImage {
                                // 使用 faceImage，例如在 UIImageView 中显示
                                saveImageToCustomDirectory(image: faceImage, fileName: "\(index)_face.jpg", caseID: "test_resize_all8")
                                saveImageToPhotoLibrary(image: faceImage)
                            }
                            if croppedImages.count > 1, let leftEyeImage = croppedImages[1] as? UIImage {
                                saveImageToCustomDirectory(image: leftEyeImage, fileName: "\(index)_left.jpg", caseID: "test_resize_all8")
                                saveImageToPhotoLibrary(image: leftEyeImage)
                                // 使用 leftEyeImage
                            }
                            if croppedImages.count > 2, let rightEyeImage = croppedImages[2] as? UIImage {
                                saveImageToCustomDirectory(image: rightEyeImage, fileName: "\(index)_right.jpg", caseID: "test_resize_all8")
                                saveImageToPhotoLibrary(image: rightEyeImage)
                                // 使用 rightEyeImage
                            }
                            
                            saveImageToPhotoLibrary(image: image)
                            
//                            let resize_img  = OpenCVWrapper.resizeImg(image, 112, 112, 0)
//                            print(resize_img.size)
//                            saveImageToCustomDirectory(image: resize_img, fileName: "resize112_\(index).jpg", caseID: "test_resize1")
                            
//                            let resizedAndTransposedImage = OpenCVWrapper.processImage(image, withWidth: 112, andHeight: 112)
//                            let imageView = UIImageView(image: resizedAndTransposedImage)
//                            imageView.frame = CGRect(x: 20, y: 50, width: 224, height: 224)
//                            self.view.addSubview(imageView)
                            
                            
//                            var faceRect = faceObservation.boundingBox
//                            faceRect = CGRect(x: Int(faceRect.origin.x*CGFloat(quartzImage.width)), y: Int(faceRect.origin.y*CGFloat(quartzImage.height)),
//                                                  width: Int(faceRect.width*CGFloat(quartzImage.width)), height: Int(faceRect.height*CGFloat(quartzImage.height)))
//                            let faceImage = quartzImage.cropping(to: faceRect)!
//                            let leftEyeLandmarks = faceObservation.landmarks?.leftEye?.normalizedPoints
//                            let rightEyeLandmarks = faceObservation.landmarks?.rightEye?.normalizedPoints
//                            let leftEyeRect = getRectFromPointArray(pointArray: leftEyeLandmarks!, parentImage: faceImage)
//                            let rightEyeRect = getRectFromPointArray(pointArray: rightEyeLandmarks!, parentImage: faceImage)
//                            
//                            print(faceRect)
//                            print(leftEyeLandmarks)
//                            print(rightEyeLandmarks)
//                            
//                            // Crop eye images and resize
//                            let leftEyeImage = faceImage.cropping(to: leftEyeRect)!
//                            let rightEyeImage = faceImage.cropping(to: rightEyeRect)!
//                            
//                            var faceUIImage = UIImage(cgImage: faceImage)
//                            faceUIImage = self.face_renderer.image { (context) in
//                                faceUIImage.draw(in: CGRect(origin: .zero, size: CGSize(width: 224, height: 224)))
//                            }
//                            
//                            var leftEyeUIImage = UIImage(cgImage: leftEyeImage)
//                            var rightEyeUIImage = UIImage(cgImage: rightEyeImage)
//                            leftEyeUIImage = self.eye_renderer.image { (context) in
//                                leftEyeUIImage.draw(in: CGRect(origin: .zero, size: self.eye_image_size))
//                            }
//                            rightEyeUIImage = self.eye_renderer.image { (context) in
//                                rightEyeUIImage.draw(in: CGRect(origin: .zero, size: self.eye_image_size))
//                            }
//                        
//            
//                            let caseID = "test2"
//                            saveImageToCustomDirectory(image: faceUIImage,fileName: "face_\(index)_.jpg",caseID: caseID)
//                            saveImageToCustomDirectory(image: leftEyeUIImage,fileName: "left_\(index)_.jpg", caseID: caseID)
//                            saveImageToCustomDirectory(image: rightEyeUIImage,fileName: "right_\(index)_.jpg",caseID: caseID)

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

}
