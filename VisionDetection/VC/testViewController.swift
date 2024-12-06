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

class testViewController: UIViewController {
    var featureModel: cges_encoder?
    var gazeModel: cges_decoder?
    var infModel: cges_inf?
    var case_id:String?
    
    private var batchCache: [[String: MLMultiArray]] = [] // 缓存每张图片的结果
    private var batchLabel: [[String: MLMultiArray]] = []

    private let progressView = UIProgressView(progressViewStyle: .default) // 进度条
    private let logTextView = UITextView() // 用于显示日志的文本框
    private let updateQueue = DispatchQueue(label: "com.testViewController.updateQueue", attributes: .concurrent)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
//        startCalibration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startCalibration()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 设置日志文本框
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.isEditable = false
        logTextView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        view.addSubview(logTextView)
        
        
        // 设置进度条
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        view.addSubview(progressView)
        
        // 布局
        NSLayoutConstraint.activate([
            // 日志文本框
            logTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logTextView.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -10),
            
            // 进度条
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func loadModels() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndGPU
            featureModel = try cges_encoder(configuration: config)
            gazeModel = try cges_decoder(configuration: config)
            updateUI(log: "Models loaded successfully")
        } catch {
            print("Feature model loading failed with error: \(error)")
            updateUI(log: "Feature model loading failed with error: \(error)")
        }
    }
    
    
    @objc private func startCalibration() {
        
        //取得目前选择的id
        
        loadModels()
        
        guard let caseId = case_id else {
            // 提示用户输入 Case ID
            print("样例id未设置")
            updateUI(log: "样例id未设置")
            return
        }
        
        // 获取选中目录的路径
        guard let customDirectory = ModelCaliViewController.getCustomDirectory(caseID: caseId) else {
            print("Custom directory not found")
            updateUI(log: "Custom directory not found")
            return
        }
        
        // 遍历选中目录中的图片文件，执行人脸特征检测
        let imageFiles = ModelCaliViewController.getImageFiles(from: customDirectory)
        progressView.progress = 0.0
        
        let dispatchGroup = DispatchGroup()
        var index = 1
        
        for imageURL in imageFiles {
            print("正在处理图片：")
            print(imageURL)
            self.updateUI(log: "正在处理图片: \(imageURL)")
            var location = extractSegments(from:imageURL.absoluteString)
            var label = createMLMultiArray(from:location.0, verticalSegment:location.1)
            if var image = UIImage(contentsOfFile: imageURL.path)?.fixedOrientation() {
                guard let cgImage = image.cgImage else {
                    dispatchGroup.leave()
                    return }
                image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .upMirrored)
                guard let quartzImage = image.cgImage else { 
                    dispatchGroup.leave()
                    return }
                
                dispatchGroup.enter()
                index += 1
                
                detectFaceLandmarks(in: image) { [self] faceObservation in
                    defer { dispatchGroup.leave() }
                    if let faceObservation = faceObservation {
                        let newSize = CGSize(width: 112, height: 112)
                        let interpolation = 1
                        
                        let result = ImageProcessor.preprocess(image, with: faceObservation, with: newSize, interpolation: Int32(interpolation))
                        
                        guard let facema = result["face"] as? MLMultiArray,
                              let lma = result["left"] as? MLMultiArray,
                              let rma = result["right"] as? MLMultiArray,
                              let may = result["rect"] as? MLMultiArray,
                              let cmlabel = label else {
                            print("Returned image data is nil")
                            self.updateUI(log: "Returned image data is nil")
                            return
                        }
                        
                        let resultDict = ["face": facema, "left": lma, "right": rma, "rect": may]
                        let pl = ["label": cmlabel]
                        DispatchQueue.main.async {
                            self.batchCache.append(resultDict)
                            self.batchLabel.append(pl)
                        }
                    } else {
                        print("No face landmarks detected")
                        self.updateUI(log: "No face landmarks detected")
                    }
                }
            } else {
                print("Unable to load image: \(imageURL.lastPathComponent)")
                self.updateUI(log: "Unable to load image: \(imageURL.lastPathComponent)")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.progressView.setProgress(1.0, animated: true)
//            print("All images processed")
            self.updateUI(progress: 1.0, log: "All images processed. Starting batch processing.")
            self.processBatch() // Process the batch after all images are processed
        }
    }
    
    private func processBatch() {
        guard !batchCache.isEmpty else {
            print("No processed images to work with")
            updateUI(log: "No processed images to work with")
            return
        }
        
        let faceArrays = batchCache.compactMap { $0["face"] }
        let leftArrays = batchCache.compactMap { $0["left"] }
        let rightArrays = batchCache.compactMap { $0["right"] }
        let rects = batchCache.compactMap { $0["rect"] }
        
        let mllabel = batchLabel.compactMap { $0["label"]}
        guard let stackedFace = stackMultiArray(faceArrays),
              let stackedLeft = stackMultiArray(leftArrays),
              let stackedRight = stackMultiArray(rightArrays),
              let stackedRects = stackMultiArray(rects),
              let stackedLabel = stackMultiArray(mllabel) else {
            print("Batch stacking failed")
            updateUI(log: "Batch stacking failed")
            return
        }
        
        print("All tensors stacked successfully, starting inference")
        updateUI(log: "All tensors stacked successfully, starting inference")
        
        let featureInput = cges_encoderInput(face: stackedFace, left_: stackedLeft, right_: stackedRight, rects: stackedRects)
        var feature: MLMultiArray?
        do {
            feature = try featureModel?.prediction(input: featureInput).linear_8
            print("Feature extraction successful")
            updateUI(log: "Feature extraction successful")
        } catch {
            print("Feature extraction failed")
            updateUI(log: "Feature extraction failed")
            return
        }
        
        guard let unwrappedFeature = feature else {
            print("Feature is nil")
            updateUI(log: "Feature is nil")
            return
        }
        
        computeCalibrationVectors(with: unwrappedFeature, label: stackedLabel)
    }
    
    private func computeCalibrationVectors(with feature: MLMultiArray, label : MLMultiArray) {
        let k = 12
        let totalCalibrations = 1 << k // 2^k
        var calibrationVectors: [MLMultiArray] = []
        var minError: Double = Double.greatestFiniteMagnitude
        var bestCalibrationVector: [Double] = []
        
        for i in 0..<totalCalibrations {
            var calibrationVector = [Int](repeating: 0, count: k)
            for j in 0..<k {
                calibrationVector[j] = (i >> j) & 1
            }
            
            if let mlArray = try? MLMultiArray(shape: [NSNumber(value: k)], dataType: .float32) {
                for index in 0..<k {
                    mlArray[index] = NSNumber(value: Float(calibrationVector[index]))
                }
                calibrationVectors.append(mlArray)
            } else {
                print("Failed to create MLMultiArray for calibration vector: \(calibrationVector)")
                updateUI(log: "Failed to create MLMultiArray for calibration vector: \(calibrationVector)")
            }
        }
        
        for (index, caliVec) in calibrationVectors.enumerated() {
            print("当前校准向量为")
            if index % 200 == 0 {
                updateUI(log:"这是第\(index)次校准")
                updateUI(log: "当前校准向量为: \(caliVec)")
            }
            print(caliVec)
            let gazeInput = cges_decoderInput(cali: caliVec, fc1: feature)
            do {
                let res = try gazeModel?.prediction(input: gazeInput).linear_2
                if let error = averageEuclideanDistance(gaze: res!,label: label){
                    if error < minError {
                        minError = error
                        bestCalibrationVector = (0..<k).map { Double(truncating: caliVec[$0]) }
                    }
                }else{
                    print("error类型不对")
                    updateUI(log: "Error type mismatch")
                }
                
            } catch {
                print("Gaze inference failed for calibration vector \(index + 1)")
                updateUI(log: "Gaze inference failed for calibration vector \(index + 1)")
            }
        }
        AppConfig.shared.setArray(key: case_id!, array: bestCalibrationVector)
        updateUI(log: "Best calibration vector: \(bestCalibrationVector)")
        updateUI(log: "Calibration vector has been saved to AppConfig")
        print("最佳校准向量为：")
        print(bestCalibrationVector)
        print("校准向量已经写到了Appconfig")
        
    }
    
    // 工具方法：将多个 MLMultiArray 堆叠为一个 NHWC 的 MLMultiArray
    private func stackMultiArray(_ arrays: [MLMultiArray]) -> MLMultiArray? {
        guard let first = arrays.first else { return nil }
        let shape = first.shape.map { $0.intValue }
        let batchSize = arrays.count
        let newShape = [batchSize] + shape
        
        guard let stackedArray = try? MLMultiArray(shape: newShape.map { NSNumber(value: $0) }, dataType: first.dataType) else {
            return nil
        }
        
        let totalElementsPerArray = shape.reduce(1, *)
        
        if first.dataType == .double {
            let stackedArrayPtr = stackedArray.dataPointer.bindMemory(to: Double.self, capacity: stackedArray.count)
            for (batchIndex, array) in arrays.enumerated() {
                let arrayPtr = array.dataPointer.bindMemory(to: Double.self, capacity: array.count)
                let destPtr = stackedArrayPtr.advanced(by: batchIndex * totalElementsPerArray)
                destPtr.assign(from: arrayPtr, count: totalElementsPerArray)
            }
        } else if first.dataType == .float32 {
            let stackedArrayPtr = stackedArray.dataPointer.bindMemory(to: Float32.self, capacity: stackedArray.count)
            for (batchIndex, array) in arrays.enumerated() {
                let arrayPtr = array.dataPointer.bindMemory(to: Float32.self, capacity: array.count)
                let destPtr = stackedArrayPtr.advanced(by: batchIndex * totalElementsPerArray)
                destPtr.assign(from: arrayPtr, count: totalElementsPerArray)
            }
        } else if first.dataType == .int32 {
            let stackedArrayPtr = stackedArray.dataPointer.bindMemory(to: Int32.self, capacity: stackedArray.count)
            for (batchIndex, array) in arrays.enumerated() {
                let arrayPtr = array.dataPointer.bindMemory(to: Int32.self, capacity: array.count)
                let destPtr = stackedArrayPtr.advanced(by: batchIndex * totalElementsPerArray)
                destPtr.assign(from: arrayPtr, count: totalElementsPerArray)
            }
        } else {
            print("Unsupported data type: \(first.dataType)")
            return nil
        }
        
        return stackedArray
    }
    
    func extractSegments(from urlString: String) -> (horizontal: String?, vertical: String?) {
        guard let url = URL(string: urlString) else {
            return (nil, nil)
        }
        let lastPathComponent = url.lastPathComponent
        let components = lastPathComponent.components(separatedBy: "_")
        guard components.count >= 4 else {
            return (nil, nil)
        }
        let horizontalSegment = components[1]
        let verticalSegment = components[2]
        return (horizontalSegment, verticalSegment)
    }
    
    private func updateUI(progress: Float? = nil, log: String? = nil) {
        updateQueue.async(flags: .barrier) {
            DispatchQueue.main.async {
                if let progress = progress {
                    self.progressView.setProgress(progress, animated: true)
                }
                if let log = log {
                    let currentText = self.logTextView.text ?? ""
                    self.logTextView.text = "\(currentText)\n\(log)"
                    let bottom = NSMakeRange(self.logTextView.text.count - 1, 1)
                    self.logTextView.scrollRangeToVisible(bottom)
                }
            }
        }
    }

}

