//
//  PredictHelperViewController.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/23.
//  Copyright © 2024 Willjay. All rights reserved.
//


import UIKit
import Foundation


class PredictHelperViewController: UIViewController {
    let caseIdTextField = UITextField()
    let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // 添加点击手势识别器以关闭键盘
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // 添加文本标签
        let helperLabel = UILabel()
        helperLabel.text = "即将进入模型测试界面，请在下拉框中选择"
        // 设置其他属性
        helperLabel.font = UIFont.systemFont(ofSize: 20)  // 设置字体大小
        helperLabel.textColor = .black  // 设置字体颜色
        helperLabel.numberOfLines = 0  // 设置为 0，表示无限行数
        helperLabel.lineBreakMode = .byWordWrapping  // 通过单词换行
        
        helperLabel.frame = CGRect(x: 50, y: 100, width: 300, height: 300)
        view.addSubview(helperLabel)
        
        let instructionLabel = UILabel()
        instructionLabel.text = "请输入 Case ID:"
        instructionLabel.frame = CGRect(x: 50, y: 400, width: 300, height: 50)
        view.addSubview(instructionLabel)
        
        // 添加文本框
        caseIdTextField.borderStyle = .roundedRect
        caseIdTextField.frame = CGRect(x: 50, y: 450, width: 300, height: 40)
        view.addSubview(caseIdTextField)
        
        // 添加下一步按钮
        nextButton.setTitle("下一步", for: .normal)
        nextButton.frame = CGRect(x: 100, y: 520, width: 200, height: 50)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    @objc func dismissKeyboard() {
        // 关闭键盘
        caseIdTextField.resignFirstResponder()
    }

    @objc func nextButtonTapped() {
        guard let caseId = caseIdTextField.text, !caseId.isEmpty else {
            // 提示用户输入 Case ID
            let alert = UIAlertController(title: "错误", message: "Case ID 不能为空", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }

        // 创建新的视图控制器并传递 case_id
        let newVC = CameraViewController()
        newVC.caseID = caseId // 假设 NewViewController 有一个 caseId 属性
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    func navigateToCameraViewController() {
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
}
