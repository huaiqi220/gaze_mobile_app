//
//  GazeUtil.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/12/6.
//  Copyright © 2024 Willjay. All rights reserved.
//

import Foundation


// 这个函数针对ipone14pro，别的设备要重新量
func createMLMultiArray(from horizontalSegment: String?, verticalSegment: String?) -> MLMultiArray? {
    guard let horizontal = horizontalSegment, let vertical = verticalSegment else {
        return nil
    }
    let horizontalValues: [String: Double] = ["left": -3.1483516483516483, "center": -0.7307692307692307, "right": 1.6923076923076923]
    let verticalValues: [String: Double] = ["top": -1.1758241758241759, "middle": -6.56043956043956, "bottom": -11.923076923076923]
    
    guard let horizontalValue = horizontalValues[horizontal], let verticalValue = verticalValues[vertical] else {
        return nil
    }
    
    do {
        let mlArray = try MLMultiArray(shape: [2], dataType: .double)
        mlArray[0] = NSNumber(value: horizontalValue)
        mlArray[1] = NSNumber(value: verticalValue)
        return mlArray
    } catch {
        print("Error creating MLMultiArray: \(error)")
        return nil
    }
}

func averageEuclideanDistance(gaze: MLMultiArray, label: MLMultiArray) -> Double? {
    guard gaze.count == 54, label.count == 54 else {
        print("Invalid input dimensions. Expected 27 * 2 for both gaze and label.")
        return nil
    }
    
    var totalDistance: Double = 0.0
    let numCoordinates = 27
    
    for i in 0..<numCoordinates {
        let gazeX = gaze[i * 2].doubleValue
        let gazeY = gaze[i * 2 + 1].doubleValue
        let labelX = label[i * 2].doubleValue
        let labelY = label[i * 2 + 1].doubleValue
        
        let distance = sqrt(pow(gazeX - labelX, 2) + pow(gazeY - labelY, 2))
        totalDistance += distance
    }
    
    let averageDistance = totalDistance / Double(numCoordinates)
    
    return averageDistance
}
