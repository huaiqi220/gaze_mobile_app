//
//  ModelPredictViewController.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/23.
//  Copyright © 2024 Willjay. All rights reserved.
//


import UIKit
import AVFoundation
import CoreML
import Vision

class ModelPredictViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoOutput: AVCaptureVideoDataOutput!
    var caliFeatureID: String?
    var model: aff_net_ma?
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
            model = try aff_net_ma(configuration: config)
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
                    let result = ImageProcessor.preprocess(image, with: faceObservation, with: newSize, interpolation: Int32(interpolation))
                    guard let facema = result["face"] as? MLMultiArray,
                          let lma = result["left"] as? MLMultiArray,
                          let rma = result["right"] as? MLMultiArray,
                          let may = result["rect"] as? MLMultiArray else{
                        print("返回来的图像有空")
                        return
                    }
                    let input = aff_net_maInput(leftEyeImg:lma,rightEyeImg: rma,faceImg: facema,faceGridImg: may)
                    do{
                        let res = try self.model?.prediction(input: input).linear_35
                        if let x = res?[0].doubleValue, let y = res?[1].doubleValue {
                            print(x,y)
                            let timestamp = Date().timeIntervalSince1970 * 1000
                            print("当前毫秒时间: \(timestamp)")
                            DispatchQueue.main.async {
                                // 更新主线程上的 UI
                                self.coordinateLabel.text = "x: \(x), y: \(y)"
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
extension ModelPredictViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
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


// 打印当前camera设备支持的格式
func printSupportedFormats(for device: AVCaptureDevice) {
    for format in device.formats {
        let description = format.formatDescription
        let dimensions = CMVideoFormatDescriptionGetDimensions(description)
        let frameRates = format.videoSupportedFrameRateRanges
        for range in frameRates {
            print("分辨率: \(dimensions.width)x\(dimensions.height), 支持的帧率范围: \(range.minFrameRate)-\(range.maxFrameRate)")
        }
    }
}


// 上面是原版，下面是想要使用人脸跟踪而不是检测来写的代码
// 但因为人脸跟踪不返回landmark所以只能放弃

//import UIKit
//import AVFoundation
//import CoreML
//import Vision
//
//class ModelPredictViewController: UIViewController {
//    var captureSession: AVCaptureSession!
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
//    var videoOutput: AVCaptureVideoDataOutput!
//    var caliFeatureID: String?
//    var model: aff_net_ma?
//    let sequenceHandler = VNSequenceRequestHandler()
//    var coordinateLabel: UILabel!
//    
//
//    // 持久化人脸检测请求
//    private lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
//        return VNDetectFaceRectanglesRequest()
//    }()
//
//    // 人脸跟踪请求
//    private var faceTrackingRequest: VNTrackObjectRequest?
//
//    // 帧计数器，用于控制检测频率
//    private var frameCounter = 0
//    private let detectionInterval = 5 // 每隔5帧进行一次人脸检测
//
//    // 当前人脸观察对象
//    private var currentFaceObservation: VNDetectedObjectObservation?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black
//
//        do {
//            let config = MLModelConfiguration()
//            config.computeUnits = .all
//            model = try aff_net_ma(configuration: config)
//        } catch {
//            print("模型加载抛出异常")
//            return
//        }
//
//        // 设置相机捕捉会话
//        captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
//
//        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
//            print("无法访问前置相机")
//            return
//        }
//
//        do {
//            let input = try AVCaptureDeviceInput(device: frontCamera)
//            if captureSession.canAddInput(input) {
//                captureSession.addInput(input)
//            }
//
//            // 配置视频输出
//            videoOutput = AVCaptureVideoDataOutput()
//            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//            if captureSession.canAddOutput(videoOutput) {
//                captureSession.addOutput(videoOutput)
//            }
//
//            // 显示相机的预览层
//            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            videoPreviewLayer.videoGravity = .resizeAspectFill
//            videoPreviewLayer.frame = view.layer.bounds
//            view.layer.addSublayer(videoPreviewLayer)
//
//            // 启动相机
//            DispatchQueue.global(qos: .background).async {
//                self.captureSession.startRunning()
//            }
//        } catch {
//            print("相机不可用: \(error)")
//        }
//
//        // 初始化 UILabel
//        coordinateLabel = UILabel()
//        coordinateLabel.translatesAutoresizingMaskIntoConstraints = false
//        coordinateLabel.text = "Ready for prediction"
//        coordinateLabel.textAlignment = .center
//        coordinateLabel.textColor = .green
//
//        self.view.addSubview(coordinateLabel)
//
//        NSLayoutConstraint.activate([
//            coordinateLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            coordinateLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
//            coordinateLabel.widthAnchor.constraint(equalToConstant: 200),
//            coordinateLabel.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//
//    // 停止会话以释放资源
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        captureSession.stopRunning()
//    }
//
//    // 处理捕获的帧
//    func processCapturedFrame(_ image: UIImage) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard let cgImage = image.cgImage else {
//                print("无法获取CGImage")
//                return
//            }
//
//            if let observation = self.currentFaceObservation {
//                let trackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
//                trackingRequest.trackingLevel = .fast
//
//                do {
//                    try self.sequenceHandler.perform([trackingRequest], on: cgImage)
//                    if let result = trackingRequest.results?.first as? VNDetectedObjectObservation {
//                        self.currentFaceObservation = result
//
//                        if result.confidence > 0.5 {
//                            let faceObservation = VNFaceObservation(boundingBox: result.boundingBox)
//                            DispatchQueue.main.async {
//                                self.handleFaceObservation(faceObservation, image: image)
//                            }
//                        } else {
//                            self.currentFaceObservation = nil
//                        }
//                    }
//                } catch {
//                    print("跟踪失败: \(error.localizedDescription)")
//                    self.currentFaceObservation = nil
//                }
//            }
//
//            if self.currentFaceObservation == nil {
//                if self.frameCounter % self.detectionInterval == 0 {
//                    let faceDetectionRequest = VNDetectFaceLandmarksRequest()
//                    do {
//                        try self.sequenceHandler.perform([faceDetectionRequest], on: cgImage)
//                        if let results = faceDetectionRequest.results as? [VNFaceObservation], let firstFace = results.first {
//                            self.currentFaceObservation = firstFace
//                            DispatchQueue.main.async {
//                                self.handleFaceObservation(firstFace, image: image)
//                            }
//                        }
//                    } catch {
//                        print("人脸检测失败: \(error.localizedDescription)")
//                    }
//                }
//                self.frameCounter += 1
//            }
//        }
//    }
//
//
//
//    // 处理人脸观察对象，进行特征点检测和模型预测
//    func handleFaceObservation(_ faceObservation: VNFaceObservation, image: UIImage) {
//        // 获取 CGImage
//        guard let cgImage = image.cgImage else {
//            print("无法获取CGImage")
//            return
//        }
//
//        // 进行人脸特征点检测
//        let faceLandmarksRequest = VNDetectFaceLandmarksRequest()
//        faceLandmarksRequest.inputFaceObservations = [faceObservation]
//
//        do {
//            try self.sequenceHandler.perform([faceLandmarksRequest], on: cgImage)
//            if let landmarksResults = faceLandmarksRequest.results as? [VNFaceObservation], let face = landmarksResults.first {
//                // 使用传入的 UIImage 进行预处理
//                let result = ImageProcessor.preprocess(image, with: face, with: CGSize(width: 112, height: 112), interpolation: 1)
//
//                guard let facema = result["face"] as? MLMultiArray,
//                      let lma = result["left"] as? MLMultiArray,
//                      let rma = result["right"] as? MLMultiArray,
//                      let may = result["rect"] as? MLMultiArray else {
//                    print("预处理结果为空")
//                    return
//                }
//
//                let input = aff_net_maInput(leftEyeImg: lma, rightEyeImg: rma, faceImg: facema, faceGridImg: may)
//
//                do {
//                    let res = try self.model?.prediction(input: input).linear_35
//                    if let x = res?[0].doubleValue, let y = res?[1].doubleValue {
//                        print(x, y)
//                        DispatchQueue.main.async {
//                            self.coordinateLabel.text = "x: \(x), y: \(y)"
//                        }
//                    }
//                } catch {
//                    print("模型推理失败")
//                }
//            }
//        } catch {
//            print("特征点检测失败: \(error.localizedDescription)")
//        }
//    }
//}
//
//extension ModelPredictViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(
//        _ output: AVCaptureOutput,
//        didOutput sampleBuffer: CMSampleBuffer,
//        from connection: AVCaptureConnection
//    ) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//        // 将 pixelBuffer 转换为 UIImage（如果需要 OpenCV 进行复杂预处理）
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let context = CIContext()
//        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
//            let capturedImage = UIImage(cgImage: cgImage)
//            // 处理捕获的帧
//            self.processCapturedFrame(capturedImage)
//        }
//    }
//}
//
