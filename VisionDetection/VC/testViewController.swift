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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // 获取选中目录的路径
        if let customDirectory = ModelCaliViewController.getCustomDirectory(caseID: "32") {
            // 遍历选中目录中的图片文件，执行人脸特征检测
            let imageFiles = ModelCaliViewController.getImageFiles(from: customDirectory)

            for imageURL in imageFiles {
                if let image = UIImage(contentsOfFile: imageURL.path) {
                    print("正在处理图片: \(imageURL.lastPathComponent)")

                    detectFaceLandmarks(in: image) { faceObservation in
                        if let faceObservation = faceObservation{
//                            let (leye,reye,fimg,landm) = cropImages(from: image, with: faceObservation)
//                            print("输出此人的Rect")
//                            print(image.size)
//                            print(landm)
                            print("首先输出图片的size")
                            print(image.size.width)
                            print(image.size.height)
                            print("再来输出这里的bbox rect")
                            let (l,f,r) = getFaceAndEyeBoundingBoxes(image: image, faceObservation: faceObservation) ?? (nil,nil,nil)
                            print(l,f,r)
                        }else{
                            print("未检测到人脸特征")
                        }

                        
                        // 直接操作faceObservation
//                        if let landmarks = faceObservation?.landmarks {
//                            // 这里检测到了人脸，开始裁剪处理得到MutiArray
//                            print("成功检测到人脸特征")
//                            if let leftEye = landmarks.leftEye {
//                                print("左眼特征点数量: \(leftEye)")
//                            }
//                            if let rightEye = landmarks.rightEye {
//                                print("右眼特征点数量: \(rightEye)")
//                            }
//                            if let mouth = landmarks.outerLips {
//                                print("嘴巴特征点数量: \(mouth)")
//                            }
//
//                        } else {
//                            print("未检测到人脸特征")
//                        }
                    }
                } else {
                    print("无法加载图片: \(imageURL.lastPathComponent)")
                }
            }
        }
    }

}
