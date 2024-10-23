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
                if var image = UIImage(contentsOfFile: imageURL.path)?.fixedOrientation(){
                    
                    guard let cgImage = image.cgImage else { return }
                    image = UIImage(cgImage: cgImage,scale: image.scale, orientation: .upMirrored)
                    guard let quartzImage = image.cgImage else {return}
                    index = index + 1
                    print("正在处理图片: \(imageURL.lastPathComponent)")

                    detectFaceLandmarks(in: image) { faceObservation in
                        if let faceObservation = faceObservation{
                            let newSize = CGSizeMake(112, 112); // 你希望调整的目标大小
                            let interpolation = 1; // 插值方法
                            
                            
                            let result = ImageProcessor.preprocess(image, with: faceObservation, with: newSize, interpolation: Int32(interpolation))
                            
                            guard let faceimg = result["face"] as? UIImage,
                                  let limg = result["left"] as? UIImage,
                                  let rimg = result["right"] as? UIImage,
                                  let may = result["rect"] as? MLMultiArray else{
                                print("返回来的图像有空")
                                return
                            }
                            
                            saveImageToPhotoLibrary(image: faceimg)
                            saveImageToPhotoLibrary(image: limg)
                            saveImageToPhotoLibrary(image: rimg)
                            saveImageToPhotoLibrary(image: image)
                            
                            let resultDictionary = predictUsingMLPackage(image1: faceimg, image2: limg, image3: rimg, multiArray: may)
                            print(resultDictionary)
                            
                            
                            
                                
                                       
                                

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
