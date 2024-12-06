//
//  CameraViewController.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/16.
//  Copyright © 2024 Willjay. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    
    // 按钮点击计数器
    var buttonClickCounts: [UIButton: Int] = [:]
    // 记录所有按钮
    var buttons: [UIButton] = []
    
    // 记录点击的当前按钮，用于在拍照时标识来源
    var currentButton: UIButton?
    
    // 存储用户输入的case_id
    var caseID: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // 弹出对话框要求用户输入 case_id

        
        // 设置相机捕捉会话
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("无法访问相机")
            return
        }
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("无法访问前置相机")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            // 配置输出
            photoOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }

            // 显示相机的预览层
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer)

            // 启动相机
            // 在后台线程启动相机捕获会话
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        } catch {
            print("相机不可用: \(error)")
        }
        
        createButtons()
    }
    
    
    func createButtons(){
        // 这里是屏幕九个校准点的位置数据
        let positions = [
            CGPoint(x: 50, y: 100),   // 左上
            CGPoint(x: 50, y: view.frame.height / 2),  // 左中
            CGPoint(x: 50, y: view.frame.height - 100),  // 左下
            CGPoint(x: view.frame.width - 50, y: 100),  // 右上
            CGPoint(x: view.frame.width - 50, y: view.frame.height / 2),  // 右中
            CGPoint(x: view.frame.width - 50, y: view.frame.height - 100),  // 右下
            CGPoint(x: view.frame.width / 2, y: 100),  // 中上
            CGPoint(x: view.frame.width / 2, y: view.frame.height - 100),  // 中下
            CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)  // 中中
        ]
        
        // 标签数组，标识按钮的位置
        let tags = ["left_top", "left_middle", "left_bottom", "right_top", "right_middle", "right_bottom", "center_top", "center_bottom", "center_middle"]
        
        for (index, position) in positions.enumerated() {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            button.layer.cornerRadius = 20
            button.backgroundColor = .white
            button.center = position
//            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            button.tag = index
            button.accessibilityLabel = tags[index]
            
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            // 初始化点击次数为 0
            buttonClickCounts[button] = 0
            
            view.addSubview(button)
            buttons.append(button)
        }
    }
    
    // 每次点击按钮
    @objc func buttonTapped(_ sender: UIButton) {
        // 记录按钮点击次数
        currentButton = sender
        
        if let count = buttonClickCounts[sender] {
            buttonClickCounts[sender] = count + 1
            print("按钮点击次数: \(buttonClickCounts[sender]!) 来自按钮: \(sender.accessibilityLabel!)")
            
            // 拍摄照片
            capturePhoto()

            // 如果按钮点击次数达到 3 次，移除按钮
            if buttonClickCounts[sender]! >= 3 {
                sender.removeFromSuperview()
                buttons.removeAll { $0 == sender }

                // 检查是否所有按钮都已消失
                if buttons.isEmpty {
                    showDataCollectionComplete()
                }
            }
        }
    }
    

    @objc func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // 所有按钮消失后提示并返回主界面
    func showDataCollectionComplete() {
        let alert = UIAlertController(title: "完成", message: "数据采集完成", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .default) { _ in
            // 返回主界面
            self.navigationController?.popToRootViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    // 停止会话以释放资源
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let capturedImage = UIImage(data: imageData)
        
        // 获取当前按钮的位置标识（如"left_top", "center_center"）
        let buttonTag = currentButton?.accessibilityLabel ?? "unknown"
        
        // 生成带有按钮位置信息的文件名
        let fileName = "photo_\(buttonTag)_\(UUID().uuidString).jpg"
        print("保存图片的文件名: \(fileName)")
        
        // 保存到自定义目录 "images/cali/{case_id}"
        if let caseID = caseID {
            saveImageToCustomDirectory(image: capturedImage!, fileName: fileName, caseID: caseID)
        } else {
            print("Case ID 为空，无法保存图片")
        }
    }    

}
