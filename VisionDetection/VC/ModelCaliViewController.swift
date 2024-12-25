//
//  ModelCaliViewController.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/17.
//  Copyright © 2024 Willjay. All rights reserved.
//

//import Foundation
import UIKit
import Vision


class ModelCaliViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var folderPickerView: UIPickerView!
    var folderNames: [String] = []
    var selectedFolder: String?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // 添加描述标签
        let descriptionLabel = UILabel()
        descriptionLabel.text = "请在下拉框中选择需要校准的样本数据对应的 caseID"
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(descriptionLabel)
        
        // 设置描述标签约束
        descriptionLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150).isActive = true
        descriptionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
        
        // 创建下拉框 (UIPickerView)
        folderPickerView = UIPickerView()
        folderPickerView.delegate = self
        folderPickerView.dataSource = self
        folderPickerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(folderPickerView)
        
        // 添加约束 - 将下拉框与标签靠近
        folderPickerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10).isActive = true
        folderPickerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        // 获取images/cali中的文件夹
        loadFolderNames()
        
        // 创建校准页面跳转按钮
        let nextPageButton = UIButton(type: .system)
        nextPageButton.setTitle("下一步: 校准", for: .normal)
        nextPageButton.translatesAutoresizingMaskIntoConstraints = false
        nextPageButton.addTarget(self, action: #selector(nextPageButtonTapped), for: .touchUpInside)
        self.view.addSubview(nextPageButton)
        
        // 设置按钮约束
        nextPageButton.topAnchor.constraint(equalTo: folderPickerView.bottomAnchor, constant: 20).isActive = true
        nextPageButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
    }
    
    // 加载 images/cali 中的文件夹名称
    func loadFolderNames() {
        let fileManager = FileManager.default
        
        // 获取应用文档目录路径
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法获取文档目录")
            return
        }
        
        // 定位到 "images/cali" 目录
        let caliDir = documentsDirectory.appendingPathComponent("images/cali")
        
        do {
            // 获取cali目录中的文件夹
            let contents = try fileManager.contentsOfDirectory(at: caliDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for content in contents {
                if content.hasDirectoryPath {
                    folderNames.append(content.lastPathComponent)
                }
            }
        } catch {
            print("无法读取目录内容: \(error.localizedDescription)")
        }
        
        // 刷新下拉框数据
        folderPickerView.reloadAllComponents()
    }
    
    // UIPickerView - 数据源方法
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return folderNames.count
    }
    
    // UIPickerView - 委托方法
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return folderNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFolder = folderNames[row]
    }
    
    
    // 跳转到校准页面
    @objc func nextPageButtonTapped() {
        guard let selectedFolder = selectedFolder else {
            let alert = UIAlertController(title: "提示", message: "请选择一个文件夹", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let calVC = CalcuTheCaliVector()
        calVC.case_id = selectedFolder
        navigationController?.pushViewController(calVC, animated: true)
    }
    
    
    
    
    // 获取 "images/cali/{caseID}" 目录的路径
    static func getCustomDirectory(caseID: String) -> URL? {
        let fileManager = FileManager.default
        
        // 获取应用的文档目录
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法获取文档目录")
            return nil
        }
        
        // 拼接自定义目录路径 "images/cali/{caseID}"
        let customDir = documentsDirectory.appendingPathComponent("images/cali/\(caseID)")
        
        // 检查目录是否存在
        if fileManager.fileExists(atPath: customDir.path) {
            print("找到目录: \(customDir.path)")
            return customDir
        } else {
            print("目录不存在: \(customDir.path)")
            return nil
        }
    }

    // 遍历指定目录中的图片文件 (只包含 jpg 和 png 格式)
    static func getImageFiles(from directory: URL) -> [URL] {
        var imageFiles: [URL] = []
        let fileManager = FileManager.default
        
        do {
            // 获取目录中的文件列表
            let contents = try fileManager.contentsOfDirectory(atPath: directory.path)
            
            // 过滤只包含 jpg 和 png 图片文件
            for file in contents {
                let fileURL = directory.appendingPathComponent(file)
                if fileURL.pathExtension.lowercased() == "jpg" || fileURL.pathExtension.lowercased() == "png" {
                    imageFiles.append(fileURL)
                }
            }
        } catch {
            print("无法读取目录内容: \(error.localizedDescription)")
        }
        
        return imageFiles
    }
    
}
