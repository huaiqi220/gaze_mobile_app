//
//  AffPredictViewController.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/12/25.
//  Copyright © 2024 Willjay. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class AffPredictViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!
    var caliFeatureID: String?
    var model: aff_net_p30special?
    let sequenceHandler = VNSequenceRequestHandler()
    var coordinateLabel: UILabel!
    var frameCounter = 0
    var period = AppConfig.shared.get(key: "FaceDetectionPeriod", defaultValue: 5)
    
    
    // 持久化人脸检测请求
    private lazy var faceLandmarksRequest: VNDetectFaceLandmarksRequest = {
          return VNDetectFaceLandmarksRequest { [weak self] (request, error) in
              if let error = error {
                  print("人脸检测出错: \(error.localizedDescription)")
                  self?.currentCompletion?(nil)
                  return
              }

              // 提取第一个人脸检测结果
              guard let observations = request.results as? [VNFaceObservation], let firstFace = observations.first else {
                  print("没有检测到人脸")
                  self?.currentCompletion?(nil)
                  return
              }

              // 返回检测到的第一个人脸的特征
              self?.currentCompletion?(firstFace)
          }
      }()
    
    // 持久化当前的 completion 回调
    private var currentCompletion: ((VNFaceObservation?) -> Void)?
    
    
    func detectFaceLandmarks(in image: UIImage, completion: @escaping (VNFaceObservation?) -> Void) {
        guard let cgImage = image.cgImage else {
            print("无法获取CGImage")
            completion(nil)
            return
        }
        // 保存当前的 completion 回调以在请求结束时使用
        self.currentCompletion = completion

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                try self.sequenceHandler.perform([self.faceLandmarksRequest], on: cgImage)
            } catch {
                print("无法执行人脸检测请求: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
    
        do{
            let config = MLModelConfiguration()
            config.computeUnits = .all
            model = try aff_net_p30special(configuration: config)
        }catch{
            print("模型加载抛出异常")
            return
        }
        
        // 设置相机捕捉会话
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        let imageShape = AppConfig.shared.get(key: "ImageShape", defaultValue: "1280*720")
        // 逻辑可以多写点
        if imageShape == "1280*720"{
            captureSession.sessionPreset = .hd1280x720
        }else if imageShape == "640*480"{
            captureSession.sessionPreset = .vga640x480
        }else{
            captureSession.sessionPreset = .hd1920x1080
        }
        

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("无法访问相机")
            return
        }
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("无法访问前置相机")
            return
        }
        
//        printSupportedFormats(for: frontCamera)

        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }else{
                print("无法添加输入设备")
                return
            }
            
            // 配置帧率为 60 FPS
            try frontCamera.lockForConfiguration()
            frontCamera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 30) // 30 FPS
            frontCamera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30)
            frontCamera.unlockForConfiguration()
            
            
            // 配置视频输出
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true // 防止延迟
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                print("无法添加输出设备")
                return
            }
            
            // 提交配置
            captureSession.commitConfiguration()

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
        
        // 初始化 UILabel
          coordinateLabel = UILabel()
          coordinateLabel.translatesAutoresizingMaskIntoConstraints = false
          coordinateLabel.text = "Ready for prediction"
          coordinateLabel.textAlignment = .center
          coordinateLabel.textColor = .green

          // 将 UILabel 添加到视图中
          self.view.addSubview(coordinateLabel)

          // 设置约束以布局 UILabel
          NSLayoutConstraint.activate([
              coordinateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
              coordinateLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
              coordinateLabel.widthAnchor.constraint(equalToConstant: 200),
              coordinateLabel.heightAnchor.constraint(equalToConstant: 50)
          ])
        
    }

    // 停止会话以释放资源
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }

    // 将UIImage传递给自定义函数进行处理
    func processCapturedFrame(_ image: UIImage) {
        // 自定义逻辑
        self.detectFaceLandmarks(in: image){ faceObservation in
            if let faceObservation = faceObservation{
                // 在后台队列中执行耗时操作
                DispatchQueue.global(qos: .userInitiated).async {
                    let newSize = CGSizeMake(112, 112); // 你希望调整的目标大小
                    let interpolation = 1; // 插值方法
                    let result = ImageProcessor.preprocess(image, with: faceObservation, with: newSize, interpolation: Int32(interpolation),faceSize: 224,eyeSize: 112)
                    guard let facema = result["face"] as? MLMultiArray,
                          let lma = result["left"] as? MLMultiArray,
                          let rma = result["right"] as? MLMultiArray,
                          let may = result["rect"] as? MLMultiArray else{
                        print("返回来的图像有空")
                        return
                    }
                    let input = aff_net_p30specialInput(leftEyeImg:lma,rightEyeImg: rma,faceImg: facema,faceGridImg: may)
                    do{
                        let res = try self.model?.prediction(input: input).linear_35
                        if let x = res?[0].doubleValue, let y = res?[1].doubleValue {
                            print(x,y)
                            let pixelPoint = convertGazeToPixel(gazeX: x, gazeY: y)
                            print("Pixel Coordinates: \(pixelPoint)")
                            let timestamp = Date().timeIntervalSince1970 * 1000
                            print("当前毫秒时间: \(timestamp)")
                            DispatchQueue.main.async {
                                // 更新主线程上的 UI
                                print("5")
                                self.coordinateLabel.text = "x: \(x), y: \(y)"
                                self.drawGazePoint(at: pixelPoint)
                            }
                        }
                        
                    }catch{
                        print("推理报错")
                    }
                }
                
            }
        }
  
    }
}

// 扩展 AVCaptureVideoDataOutputSampleBufferDelegate
extension AffPredictViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        frameCounter += 1
        if frameCounter % period != 0 {
            return
        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let capturedImage = UIImage(cgImage: cgImage)
            
            
            // 在后台队列中处理帧
            DispatchQueue.global(qos: .userInitiated).async {
                self.processCapturedFrame(capturedImage)
            }
        }
    }
}

extension AffPredictViewController {
    func drawGazePoint(at point: CGPoint) {
        // 移除之前的标记
        view.layer.sublayers?.filter { $0.name == "gazePoint" }.forEach { $0.removeFromSuperlayer() }
        
        // 创建一个圆形图层作为标记
        let gazeLayer = CAShapeLayer()
        gazeLayer.name = "gazePoint"
        let radius: CGFloat = 10.0
        let path = UIBezierPath(ovalIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
        gazeLayer.path = path.cgPath
        gazeLayer.fillColor = UIColor.red.cgColor
        view.layer.addSublayer(gazeLayer)
    }
}


func convertGazeToPixel(gazeX: Double, gazeY: Double) -> CGPoint {
    // 屏幕的物理尺寸（厘米）
    let screenWidth_cm: Double = 6.5
    let screenHeight_cm: Double = 14.0
    
    // 摄像头相对于屏幕左上角的坐标（厘米）
    let cameraOriginX_cm: Double = 3.967
    let cameraOriginY_cm: Double = 0.473
    
    // 获取屏幕的像素分辨率
    let screenSize = UIScreen.main.bounds.size
    let screenScale = UIScreen.main.scale
    let screenWidth_pixels = screenSize.width * screenScale
    let screenHeight_pixels = screenSize.height * screenScale
    
    // 计算每厘米对应的像素数
    let pixelsPerCmX = screenWidth_pixels / CGFloat(screenWidth_cm)
    let pixelsPerCmY = screenHeight_pixels / CGFloat(screenHeight_cm)
    
    // 将注视点从摄像头坐标系转换到屏幕物理坐标系
    let screenX_cm = cameraOriginX_cm + gazeX
    let screenY_cm = cameraOriginY_cm + gazeY
    
    // 限制坐标在屏幕范围内
    let clampedX_cm = max(0, min(screenX_cm, screenWidth_cm))
    let clampedY_cm = max(0, min(screenY_cm, screenHeight_cm))
    
    // 将物理坐标转换为像素坐标
    let pixelX = CGFloat(clampedX_cm) * pixelsPerCmX
    let pixelY = CGFloat(clampedY_cm) * pixelsPerCmY
    
    return CGPoint(x: pixelX, y: pixelY)
}


