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
            model = try aff_net_ma(configuration: .init())
        }catch{
            print("模型加载抛出异常")
            return
        }
        
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
            
            // 配置视频输出
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
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

extension ModelPredictViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let capturedImage = UIImage(cgImage: cgImage)
            // 传递每一帧图像给自定义函数进行处理
            DispatchQueue.main.async {
                self.processCapturedFrame(capturedImage)
            }
        }
    }
}
