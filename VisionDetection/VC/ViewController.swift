//
//  ViewController.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/16.
//  Copyright © 2024 Willjay. All rights reserved.
//

import UIKit
import AVFoundation
import Vision


class ViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 创建按钮1
        let CaliVCButton = UIButton(type: .system)
        CaliVCButton.setTitle("采集校准数据", for: .normal)
        CaliVCButton.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        CaliVCButton.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
        view.addSubview(CaliVCButton)


        let showImages = UIButton(type: .system)
        showImages.setTitle("查看已采集的校准数据", for: .normal)
        showImages.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
        showImages.addTarget(self, action: #selector(showImagesTapped), for: .touchUpInside)
        view.addSubview(showImages)
        
        // 创建按钮2
        let startBasedPredict = UIButton(type: .system)
        startBasedPredict.setTitle("开始基准测试", for: .normal)
        startBasedPredict.frame = CGRect(x: 100, y: 400, width: 200, height: 50)
        startBasedPredict.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
        view.addSubview(startBasedPredict)
        
        
        let computeCaliParam = UIButton(type: .system)
        computeCaliParam.setTitle("计算校准向量", for: .normal)
        computeCaliParam.frame = CGRect(x: 100, y: 500, width: 200, height: 50)
        computeCaliParam.addTarget(self, action: #selector(showModelCaliVCTapped), for: .touchUpInside)
        view.addSubview(computeCaliParam)
        
        let startCaliPredict = UIButton(type: .system)
        startCaliPredict.setTitle("开始校准测试", for: .normal)
        startCaliPredict.frame = CGRect(x: 100, y: 600, width: 200, height: 50)
        startCaliPredict.addTarget(self, action: #selector(caliPredictTapped), for: .touchUpInside)
        view.addSubview(startCaliPredict)


        
        // 创建按钮2
        let buttonTest = UIButton(type: .system)
        buttonTest.setTitle("debug测试页面", for: .normal)
        buttonTest.frame = CGRect(x: 100, y: 700, width: 200, height: 50)
        buttonTest.addTarget(self, action: #selector(buttonTestTapped), for: .touchUpInside)
        view.addSubview(buttonTest)
    }
    
    // 校准数据采集按钮事件
    @objc func button1Tapped() {
        print("开始采集校准数据")
        let cameraVC = CaliHelperViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(cameraVC, animated: true)
    }


    @objc func showImagesTapped(){
        print("显示已采集的校准数据")
        let imagesVC = ImageGalleryViewController()
        imagesVC.modalPresentationStyle = .fullScreen
//        present(imagesVC, animated: true, completion: nil)
        navigationController?.pushViewController(imagesVC, animated: true)
    }
    
    
    @objc func showModelCaliVCTapped(){
        print("打开模型微调界面")
        let caliModelVC = ModelCaliViewController()
        caliModelVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(caliModelVC, animated: true)
        
    }

    // 按钮2的点击事件
    @objc func button2Tapped() {
        print("按钮2被点击")
        let predictVC = ModelPredictViewController()
        predictVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(predictVC, animated: true)
        
    }
    
    @objc func buttonTestTapped(){
        let testVC = testViewController()
        testVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(testVC, animated: true)
        print("打开了测试页面")
    }
    
    // 这次进行校准测试
    @objc func caliPredictTapped() {
        print("开始进行校准后测试")
//        let calipredictVC = CaliPredictViewController()
//        calipredictVC.modalPresentationStyle = .fullScreen
//        navigationController?.pushViewController(calipredictVC, animated: true)
        let cvsVC =  caliVecSelectViewController()
        cvsVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(cvsVC, animated: true)
    }
    
    
    
}


//class ViewController: UIViewController {
//    
//    
//    @IBOutlet weak var previewView: PreviewView!
//    
//    // VNRequest: Either Retangles or Landmarks
//    private var faceDetectionRequest: VNRequest!
//    
//    // TODO: Decide camera position --- front or back
//    // 决定用哪个摄像头拍照
//    private var devicePosition: AVCaptureDevice.Position = .front
//    
//    // Session Management
//    private enum SessionSetupResult {
//        case success
//        case notAuthorized
//        case configurationFailed
//    }
//    
//    private let session = AVCaptureSession()
//    private var isSessionRunning = false
//    
//    // Communicate with the session and other session objects on this queue.
//    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
//    
//    private var setupResult: SessionSetupResult = .success
//    private var videoDeviceInput:   AVCaptureDeviceInput!
//    private var videoDataOutput:    AVCaptureVideoDataOutput!
//    private var videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
//    private var requests = [VNRequest]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // 设置背景颜色
//        view.backgroundColor = .white
//        
//        // 创建按钮1
//        let button1 = UIButton(type: .system)
//        button1.setTitle("采集校准数据", for: .normal)
//        button1.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
//        button1.addTarget(self, action: #selector(button1Tapped), for: .touchUpInside)
//        view.addSubview(button1)
//        
//        
//        let showImages = UIButton(type: .system)
//        showImages.setTitle("查看已采集的校准数据", for: .normal)
//        showImages.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
//        showImages.addTarget(self, action: #selector(showImagesTapped), for: .touchUpInside)
//        view.addSubview(showImages)
//        
//        // 创建按钮2
//        let button2 = UIButton(type: .system)
//        button2.setTitle("开始正式推理", for: .normal)
//        button2.frame = CGRect(x: 100, y: 400, width: 200, height: 50)
//        button2.addTarget(self, action: #selector(button2Tapped), for: .touchUpInside)
//        view.addSubview(button2)
//        //        // Set up the video preview view.
//        //        previewView.session = session
//        //
//        //        // Set up Vision Request
//        //        faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleFaces) // Default
//        //        setupVision()
//        //
//        //        /*
//        //         Check video authorization status. Video access is required and audio
//        //         access is optional. If audio access is denied, audio is not recorded
//        //         during movie recording.
//        //         */
//        //        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video){
//        //        case .authorized:
//        //            // The user has previously granted access to the camera.
//        //            break
//        //
//        //        case .notDetermined:
//        //            /*
//        //             The user has not yet been presented with the option to grant
//        //             video access. We suspend the session queue to delay session
//        //             setup until the access request has completed.
//        //             */
//        //            sessionQueue.suspend()
//        //            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
//        //                if !granted {
//        //                    self.setupResult = .notAuthorized
//        //                }
//        //                self.sessionQueue.resume()
//        //            })
//        //
//        //
//        //        default:
//        //            // The user has previously denied access.
//        //            setupResult = .notAuthorized
//        //        }
//        //
//        //        /*
//        //         Setup the capture session.
//        //         In general it is not safe to mutate an AVCaptureSession or any of its
//        //         inputs, outputs, or connections from multiple threads at the same time.
//        //
//        //         Why not do all of this on the main queue?
//        //         Because AVCaptureSession.startRunning() is a blocking call which can
//        //         take a long time. We dispatch session setup to the sessionQueue so
//        //         that the main queue isn't blocked, which keeps the UI responsive.
//        //         */
//        //
//        //        sessionQueue.async { [unowned self] in
//        //            self.configureSession()
//        //        }
//        
//    }
//    
//    
//    
//    // 按钮1的点击事件
//    @objc func button1Tapped() {
//        print("开始采集校准数据")
//        let cameraVC = CaliHelperViewController()
//        cameraVC.modalPresentationStyle = .fullScreen
//        present(cameraVC, animated: true, completion: nil)
//    }
//    
//    
//    @objc func showImagesTapped(){
//        print("显示已采集的校准数据")
//        let imagesVC = ImageGalleryViewController()
//        imagesVC.modalPresentationStyle = .fullScreen
//        present(imagesVC, animated: true, completion: nil)
//    }
//
//    // 按钮2的点击事件
//    @objc func button2Tapped() {
//        print("按钮2被点击")
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        sessionQueue.async { [unowned self] in
//            switch self.setupResult {
//            case .success:
//                // Only setup observers and start the session running if setup succeeded.
//                self.addObservers()
//                self.session.startRunning()
//                self.isSessionRunning = self.session.isRunning
//                
//            case .notAuthorized:
//                DispatchQueue.main.async { [unowned self] in
//                    let message = NSLocalizedString("AVCamBarcode doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
//                    let    alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { action in
//                        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
//                    }))
//                    
//                    self.present(alertController, animated: true, completion: nil)
//                }
//                
//            case .configurationFailed:
//                DispatchQueue.main.async { [unowned self] in
//                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
//                    let alertController = UIAlertController(title: "AppleFaceDetection", message: message, preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
//                    
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        sessionQueue.async { [unowned self] in
//            if self.setupResult == .success {
//                self.session.stopRunning()
//                self.isSessionRunning = self.session.isRunning
//                self.removeObservers()
//            }
//        }
//        
//        super.viewWillDisappear(animated)
//    }
//    
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        
//        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
//            let deviceOrientation = UIDevice.current.orientation
//            guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
//                return
//            }
//            
//            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
//            
//        }
//    }
//    
//    // Segmente Control to switch over FaceOnly or FaceLandmark
//    @IBAction func UpdateDetectionType(_ sender: UISegmentedControl) {
//        faceDetectionRequest = sender.selectedSegmentIndex == 0 ? VNDetectFaceRectanglesRequest(completionHandler: handleFaces) : VNDetectFaceLandmarksRequest(completionHandler: handleFaceLandmarks)
//        
//        setupVision()
//    }
//
//    
//}
//
//// Video Sessions
//extension ViewController {
//    private func configureSession() {
//        if setupResult != .success { return }
//        
//        session.beginConfiguration()
//        session.sessionPreset = .high
//        
//        // Add video input.
//        addVideoDataInput()
//        
//        // Add video output.
//        addVideoDataOutput()
//        
//        session.commitConfiguration()
//        
//    }
//    
//    private func addVideoDataInput() {
//        do {
//            var defaultVideoDevice: AVCaptureDevice!
//            
//            if devicePosition == .front {
//                if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
//                    defaultVideoDevice = frontCameraDevice
//                }
//            }
//            else {
//                // Choose the back dual camera if available, otherwise default to a wide angle camera.
//                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
//                    defaultVideoDevice = dualCameraDevice
//                }
//                    
//                else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
//                    defaultVideoDevice = backCameraDevice
//                }
//            }
//            
//            
//            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
//            
//            if session.canAddInput(videoDeviceInput) {
//                session.addInput(videoDeviceInput)
//                self.videoDeviceInput = videoDeviceInput
//                DispatchQueue.main.async {
//                    /*
//                     Why are we dispatching this to the main queue?
//                     Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
//                     can only be manipulated on the main thread.
//                     Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
//                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
//                     
//                     Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
//                     handled by CameraViewController.viewWillTransition(to:with:).
//                     */
//                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
//                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
//                    if statusBarOrientation != .unknown {
//                        if let videoOrientation = statusBarOrientation.videoOrientation {
//                            initialVideoOrientation = videoOrientation
//                        }
//                    }
//                    self.previewView.videoPreviewLayer.connection!.videoOrientation = initialVideoOrientation
//                }
//            }
//            
//        }
//        catch {
//            print("Could not add video device input to the session")
//            setupResult = .configurationFailed
//            session.commitConfiguration()
//            return
//        }
//    }
//    
//    private func addVideoDataOutput() {
//        videoDataOutput = AVCaptureVideoDataOutput()
//        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
//        
//        
//        if session.canAddOutput(videoDataOutput) {
//            videoDataOutput.alwaysDiscardsLateVideoFrames = true
//            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
//            session.addOutput(videoDataOutput)
//        }
//        else {
//            print("Could not add metadata output to the session")
//            setupResult = .configurationFailed
//            session.commitConfiguration()
//            return
//        }
//    }
//}
//
//// MARK: -- Observers and Event Handlers
//extension ViewController {
//    private func addObservers() {
//        /*
//         Observe the previewView's regionOfInterest to update the AVCaptureMetadataOutput's
//         rectOfInterest when the user finishes resizing the region of interest.
//         */
//        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: Notification.Name("AVCaptureSessionRuntimeErrorNotification"), object: session)
//        
//        /*
//         A session can only run when the app is full screen. It will be interrupted
//         in a multi-app layout, introduced in iOS 9, see also the documentation of
//         AVCaptureSessionInterruptionReason. Add observers to handle these session
//         interruptions and show a preview is paused message. See the documentation
//         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
//         */
//        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: Notification.Name("AVCaptureSessionWasInterruptedNotification"), object: session)
//        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: Notification.Name("AVCaptureSessionInterruptionEndedNotification"), object: session)
//    }
//    
//    private func removeObservers() {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    @objc func sessionRuntimeError(_ notification: Notification) {
//        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else { return }
//        
//        let error = AVError(_nsError: errorValue)
//        print("Capture session runtime error: \(error)")
//        
//        /*
//         Automatically try to restart the session running if media services were
//         reset and the last start running succeeded. Otherwise, enable the user
//         to try to resume the session running.
//         */
//        if error.code == .mediaServicesWereReset {
//            sessionQueue.async { [unowned self] in
//                if self.isSessionRunning {
//                    self.session.startRunning()
//                    self.isSessionRunning = self.session.isRunning
//                }
//            }
//        }
//    }
//    
//    @objc func sessionWasInterrupted(_ notification: Notification) {
//        /*
//         In some scenarios we want to enable the user to resume the session running.
//         For example, if music playback is initiated via control center while
//         using AVCamBarcode, then the user can let AVCamBarcode resume
//         the session running, which will stop music playback. Note that stopping
//         music playback in control center will not automatically resume the session
//         running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
//         */
//        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?, let reasonIntegerValue = userInfoValue.integerValue, let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
//            print("Capture session was interrupted with reason \(reason)")
//        }
//    }
//    
//    @objc func sessionInterruptionEnded(_ notification: Notification) {
//        print("Capture session interruption ended")
//    }
//}
//
//// MARK: -- Helpers
//extension ViewController {
//    func setupVision() {
//        self.requests = [faceDetectionRequest]
//    }
//    
//    func handleFaces(request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
//            //perform all the UI updates on the main queue
//            guard let results = request.results as? [VNFaceObservation] else { return }
//            self.previewView.removeMask()
//            for face in results {
//                self.previewView.drawFaceboundingBox(face: face)
//            }
//        }
//    }
//    
//    func handleFaceLandmarks(request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
//            //perform all the UI updates on the main queue
//            guard let results = request.results as? [VNFaceObservation] else { return }
//            self.previewView.removeMask()
//            for face in results {
//                self.previewView.drawFaceWithLandmarks(face: face)
//            }
//        }
//    }
//
//}
//
//// Camera Settings & Orientation
//extension ViewController {
//    func availableSessionPresets() -> [String] {
//        let allSessionPresets = [AVCaptureSession.Preset.photo,
//                                 AVCaptureSession.Preset.low,
//                                 AVCaptureSession.Preset.medium,
//                                 AVCaptureSession.Preset.high,
//                                 AVCaptureSession.Preset.cif352x288,
//                                 AVCaptureSession.Preset.vga640x480,
//                                 AVCaptureSession.Preset.hd1280x720,
//                                 AVCaptureSession.Preset.iFrame960x540,
//                                 AVCaptureSession.Preset.iFrame1280x720,
//                                 AVCaptureSession.Preset.hd1920x1080,
//                                 AVCaptureSession.Preset.hd4K3840x2160]
//        
//        var availableSessionPresets = [String]()
//        for sessionPreset in allSessionPresets {
//            if session.canSetSessionPreset(sessionPreset) {
//                availableSessionPresets.append(sessionPreset.rawValue)
//            }
//        }
//        
//        return availableSessionPresets
//    }
//    
//    func exifOrientationFromDeviceOrientation() -> UInt32 {
//        enum DeviceOrientation: UInt32 {
//            case top0ColLeft = 1
//            case top0ColRight = 2
//            case bottom0ColRight = 3
//            case bottom0ColLeft = 4
//            case left0ColTop = 5
//            case right0ColTop = 6
//            case right0ColBottom = 7
//            case left0ColBottom = 8
//        }
//        var exifOrientation: DeviceOrientation
//        
//        switch UIDevice.current.orientation {
//        case .portraitUpsideDown:
//            exifOrientation = .left0ColBottom
//        case .landscapeLeft:
//            exifOrientation = devicePosition == .front ? .bottom0ColRight : .top0ColLeft
//        case .landscapeRight:
//            exifOrientation = devicePosition == .front ? .top0ColLeft : .bottom0ColRight
//        default:
//            exifOrientation = devicePosition == .front ? .left0ColTop : .right0ColTop
//        }
//        return exifOrientation.rawValue
//    }
//    
//    
//}
//
//// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
//extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
//        let exifOrientation = CGImagePropertyOrientation(rawValue: exifOrientationFromDeviceOrientation()) else { return }
//        var requestOptions: [VNImageOption : Any] = [:]
//        
//        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
//            requestOptions = [.cameraIntrinsics : cameraIntrinsicData]
//        }
//        
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: requestOptions)
//        
//        do {
//            try imageRequestHandler.perform(requests)
//        }
//            
//        catch {
//            print(error)
//        }
//        
//    }
//    
//}
//

