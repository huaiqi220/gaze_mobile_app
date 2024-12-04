//
//  OpenCVWrapper.m
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/21.
//  Copyright © 2024 Willjay. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import <iostream>
#import "OpenCVWrapper.h"

/*
 * add a method convertToMat to UIImage class
 */
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists {
    if (self.imageOrientation == UIImageOrientationRight) {
        /*
         * When taking picture in portrait orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        /*
         * When taking picture in portrait upside-down orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait upside-down orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        /*
         * When taking picture in landscape orientation,
         * convert UIImage to OpenCV Matrix directly,
         * and then ONLY rotate OpenCV Matrix for landscape left-side-up orientation
         */
        UIImageToMat(self, *pMat, alphaExists);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}
@end

@implementation OpenCVWrapper

+ (MLMultiArray *)createMat{
    // 创建大小为 112x112，通道数为 3，类型为 CV_32FC3 的 Mat
    cv::Mat mat(112, 112, CV_32FC3, cv::Scalar(0.5, 0.5, 0.5));
    

    return convertMatToMLMultiArray(mat);
}


+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)grayscaleImg:(UIImage *)image {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    cv::Mat gray;
    
    NSLog(@"channels = %d", mat.channels());

    if (mat.channels() > 1) {
        cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    } else {
        mat.copyTo(gray);
    }

    UIImage *grayImg = MatToUIImage(gray);
    return grayImg;
}

+ (UIImage *)resizeImg:(UIImage *)image :(int)width :(int)height :(int)interpolation {
    cv::Mat mat;
    [image convertToMat:&mat :false];
    
    if (mat.channels() == 4) {
        [image convertToMat:&mat :true];
    }
    
    NSLog(@"源图像形状 = (%d, %d)", mat.cols, mat.rows);
    
    cv::Mat resized;
    cv::Size size = {width, height};
    
    // 调整图像大小
    cv::resize(mat, resized, size, 0, 0, interpolation);
    
    // 归一化调整后的图像
//    resized.convertTo(resized, CV_32F, 1.0 / 255.0); // 转换为浮点型并进行归一化

    NSLog(@"目标图像形状 = (%d, %d)", resized.cols, resized.rows);
    
    UIImage *resizedImg = MatToUIImage(resized);
    
    return resizedImg;
}


@end

@implementation ImageProcessor

+ (NSDictionary *)preprocess:(UIImage *)image withFaceObservation:(VNFaceObservation *)faceObservation withSize:(CGSize)newSize interpolation:(int)interpolation {
    // 将 UIImage 转换为 cv::Mat
    std::cout << "oc1" << std::endl;
    cv::Mat mat;
    [image convertToMat:&mat :false];

    if (mat.channels() == 4) {
        cv::cvtColor(mat, mat, cv::COLOR_RGBA2BGR);
    } else if(mat.channels() == 3){
        cv::cvtColor(mat, mat, cv::COLOR_RGB2BGR);
    }

    CGSize imageSize = image.size;
    // 这里获得面部的bbox
    std::cout << "oc2" << std::endl;
    CGRect boundingBox = faceObservation.boundingBox;

    // 将边界框坐标转换为图像坐标系统
    CGFloat x = boundingBox.origin.x * imageSize.width;
    CGFloat y = boundingBox.origin.y * imageSize.height;
    CGFloat width = boundingBox.size.width * imageSize.width;
    CGFloat height = boundingBox.size.height * imageSize.height;
    std::cout << "oc3" << std::endl;
    // 裁剪面部区域
//    cv::Rect faceRect(static_cast<int>(x), static_cast<int>(imageSize.height - (y + height)), static_cast<int>(width), static_cast<int>(height));
    
    // 限制 faceRect 的范围在图像边界内
    // gpt写的，还没校对
    int x_start = std::max(0, std::min(static_cast<int>(x), mat.cols - 1));
    int y_start = std::max(0, std::min(static_cast<int>(imageSize.height - (y + height)), mat.rows - 1));
    int rect_width = std::max(1, std::min(static_cast<int>(width), mat.cols - x_start));
    int rect_height = std::max(1, std::min(static_cast<int>(height), mat.rows - y_start));

    // 创建裁剪区域
    cv::Rect faceRect(x_start, y_start, rect_width, rect_height);
    cv::Mat faceCrop = mat(faceRect);
    std::cout << "oc4" << std::endl;

    // 获取眼睛的地标并裁剪眼睛区域
    VNFaceLandmarks2D *landmarks = faceObservation.landmarks;
    MLMultiArray *leftMultiArray = nil;
    MLMultiArray *rightMultiArray = nil;
    MLMultiArray *faceMultiArray = nil;
    cv::Mat resizedFace, resizedLeftEye, resizedRightEye;
    
    float rects[12] = {0};
    if (landmarks) {
        VNFaceLandmarkRegion2D *leftEye = landmarks.leftEye;
        VNFaceLandmarkRegion2D *rightEye = landmarks.rightEye;
        if (leftEye && rightEye) {
            // 计算左眼边界框
            cv::Rect leftEyeRect = [self rectFromPointsInImage:[leftEye pointsInImageOfSize:imageSize] pointCount:leftEye.pointCount];
            leftEyeRect = cv::Rect(
                static_cast<int>(leftEyeRect.x),
                static_cast<int>(imageSize.height - (leftEyeRect.y + leftEyeRect.height)),
                static_cast<int>(leftEyeRect.width),
                static_cast<int>(leftEyeRect.height)
            );
            
            // 为左眼矩形上下各增加20像素，确保不超过边界
            leftEyeRect.y = std::max(leftEyeRect.y - 20, 0); // 确保y坐标不小于0
            leftEyeRect.height = std::min(leftEyeRect.height + 40, static_cast<int>(imageSize.height - leftEyeRect.y)); // 确保高度不超过图像边界
            leftEyeRect.width = std::min(leftEyeRect.width, static_cast<int>(imageSize.width - leftEyeRect.x)); // 确保宽度

            // 裁剪左眼图像
            cv::Mat leftEyeCrop = mat(leftEyeRect);
            cv::resize(leftEyeCrop, resizedLeftEye, cv::Size(224, 224), 0, 0, interpolation);
            resizedLeftEye.convertTo(resizedLeftEye, CV_32F, 1.0 / 255);
//            leftEyeImage = MatToUIImage(leftEyeCrop);
//            leftEyeImage = MatToUIImage(resizedLeftEye);
            leftMultiArray = convertMatToMLMultiArray(resizedLeftEye);
            
            // 存储左眼矩形信息
            rects[4] = leftEyeRect.x;
            rects[5] = leftEyeRect.y;
            rects[6] = leftEyeRect.width;
            rects[7] = leftEyeRect.height;
            // 计算右眼边界框
            cv::Rect rightEyeRect = [self rectFromPointsInImage:[rightEye pointsInImageOfSize:imageSize] pointCount:rightEye.pointCount];
            rightEyeRect = cv::Rect(
                static_cast<int>(rightEyeRect.x),
                static_cast<int>(imageSize.height - (rightEyeRect.y + rightEyeRect.height)),
                static_cast<int>(rightEyeRect.width),
                static_cast<int>(rightEyeRect.height)
            );
            
            // 为右眼矩形上下各增加20像素，确保不超过边界
            rightEyeRect.y = std::max(rightEyeRect.y - 20, 0); // 确保y坐标不小于0
            rightEyeRect.height = std::min(rightEyeRect.height + 40, static_cast<int>(imageSize.height - rightEyeRect.y)); // 确保高度不超过图像边界
            rightEyeRect.width = std::min(rightEyeRect.width, static_cast<int>(imageSize.width - rightEyeRect.x)); // 确保宽度不超过图像边界


            // 裁剪右眼图像
            cv::Mat rightEyeCrop = mat(rightEyeRect);
            cv::resize(rightEyeCrop, resizedRightEye, cv::Size(224, 224), 0, 0, interpolation);
//            rightEyeImage = MatToUIImage(rightEyeCrop);
            resizedRightEye.convertTo(resizedRightEye, CV_32F, 1.0/255);
            rightMultiArray = convertMatToMLMultiArray(resizedRightEye);
            // HWC转CHW
//            resizedRightEye = hwc_to_chw(resizedRightEye);
//            rightEyeImage = MatToUIImage(resizedRightEye);
            
            // 存储右眼矩形信息
            rects[8] = rightEyeRect.x;
            rects[9] = rightEyeRect.y;
            rects[10] = rightEyeRect.width;
            rects[11] = rightEyeRect.height;
        }
    }

    // 将面部裁剪转换为 UIImage
    cv::resize(faceCrop, resizedFace, cv::Size(112, 112), 0, 0, interpolation);
//    UIImage *faceImage = MatToUIImage(faceCrop);
    resizedFace.convertTo(resizedFace, CV_32F, 1.0/255);
//    std::cout << "Original type: " << mat.type() << std::endl;
//    std::cout << "Converted type: " << resizedFace.type() << std::endl;
//    std::cout << "Pixel value (0,0): " << resizedFace.at<float>(0, 0) << std::endl;
    faceMultiArray = convertMatToMLMultiArray(resizedFace);
    
    
//    UIImage *faceImage = MatToUIImage(resizedFace);
    
    // 存储面部矩形信息
    rects[0] = faceRect.x;
    rects[1] = faceRect.y;
    rects[2] = faceRect.width;
    rects[3] = faceRect.height;

    
    NSError *error = nil;
    // 创建一个长度为 12 的 1D MultiArray
    MLMultiArray *multiArray = [[MLMultiArray alloc] initWithShape:@[@12]
                                                         dataType:MLMultiArrayDataTypeFloat32
                                                            error:&error];

    if (error) {
        NSLog(@"创建 MLMultiArray 时出错: %@", error.localizedDescription);
        return nil;
    }

    // 设置一维数组的值
    for (NSInteger i = 0; i < 12; i++) {
        multiArray[i] = @(rects[i]);
    }

    
    NSDictionary *result = @{
        @"face": faceMultiArray,
        @"left": leftMultiArray,
        @"right": rightMultiArray,
        @"rect": multiArray
    };
    
    return result;
}

// 从 pointsInImage 中计算 cv::Rect
+ (cv::Rect)rectFromPointsInImage:(const CGPoint *)pointsInImage pointCount:(NSUInteger)pointCount {
    if (pointCount == 0) {
        return cv::Rect(0, 0, 0, 0);
    }

    CGFloat minX = CGFLOAT_MAX;
    CGFloat minY = CGFLOAT_MAX;
    CGFloat maxX = CGFLOAT_MIN;
    CGFloat maxY = CGFLOAT_MIN;

    // 遍历所有点并找到最小和最大 x, y 坐标
    for (NSUInteger i = 0; i < pointCount; i++) {
        CGPoint point = pointsInImage[i];
        minX = MIN(minX, point.x);
        minY = MIN(minY, point.y);
        maxX = MAX(maxX, point.x);
        maxY = MAX(maxY, point.y);
    }

    // 创建 cv::Rect，注意 OpenCV 的坐标系统
    return cv::Rect(static_cast<int>(minX), static_cast<int>(minY), static_cast<int>(maxX - minX), static_cast<int>(maxY - minY));
}

@end



MLMultiArray *convertMatToMLMultiArray(cv::Mat &mat) {
    NSError *error = nil;

    // 检查数据类型是否为 CV_32FC3（float32，3通道）
    if (mat.type() != CV_32FC3) {
        NSLog(@"不支持的 Mat 类型。仅支持 CV_32FC3（float32，3通道）类型。");
        return nil;
    }

    // 确保 Mat 在内存中是连续的
    if (!mat.isContinuous()) {
        mat = mat.clone();
    }

    // 定义 MLMultiArray 的形状，假设我们需要 [rows, cols, channels]
    NSArray<NSNumber *> *shape = @[@(mat.rows), @(mat.cols), @(mat.channels())];

    // 创建 MLMultiArray
    MLMultiArray *multiArray = [[MLMultiArray alloc] initWithShape:shape
                                                          dataType:MLMultiArrayDataTypeFloat32
                                                             error:&error];

    if (error) {
        NSLog(@"创建 MLMultiArray 时出错: %@", error.localizedDescription);
        return nil;
    }

    // 获取指向数据的指针
    float *matData = reinterpret_cast<float *>(mat.data);
    float *multiArrayData = (float *)multiArray.dataPointer;

    // 获取 MLMultiArray 的 strides（步长）
    NSInteger stride0 = multiArray.strides[0].integerValue; // rows
    NSInteger stride1 = multiArray.strides[1].integerValue; // cols
    NSInteger stride2 = multiArray.strides[2].integerValue; // channels

    // 确保 strides 是按 [rows, cols, channels] 的顺序
    if (multiArray.strides.count != 3 ||
        multiArray.shape.count != 3 ||
        stride0 <= 0 || stride1 <= 0 || stride2 <= 0) {
        NSLog(@"MLMultiArray 的 strides 或 shape 不正确。");
        return nil;
    }

    // 遍历所有元素，按正确的顺序复制数据
    for (int i = 0; i < mat.rows; ++i) {
        for (int j = 0; j < mat.cols; ++j) {
            cv::Vec3f pixel = mat.at<cv::Vec3f>(i, j);
            for (int c = 0; c < mat.channels(); ++c) {
                // 计算 MLMultiArray 中的索引
                NSInteger index = i * stride0 + j * stride1 + c * stride2;
                multiArrayData[index] = pixel[c];
            }
        }
    }

    return multiArray;
}


