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

+ (NSArray<UIImage *> *)preprocess:(UIImage *)image withFaceObservation:(VNFaceObservation *)faceObservation withSize:(CGSize)newSize interpolation:(int)interpolation {
    // 将 UIImage 转换为 cv::Mat
    cv::Mat mat;
    [image convertToMat:&mat :false];
    
    if (mat.channels() == 4) {
        cv::cvtColor(mat, mat, cv::COLOR_RGBA2RGB);
    }

    CGSize imageSize = image.size;

    // 从 VNFaceObservation 中获取边界框
    CGRect boundingBox = faceObservation.boundingBox;

    // 将边界框坐标转换为图像坐标系统
    CGFloat x = boundingBox.origin.x * imageSize.width;
    CGFloat y = boundingBox.origin.y * imageSize.height;
    CGFloat width = boundingBox.size.width * imageSize.width;
    CGFloat height = boundingBox.size.height * imageSize.height;

    // 裁剪面部区域
    cv::Rect faceRect(static_cast<int>(x), static_cast<int>(imageSize.height - (y + height)), static_cast<int>(width), static_cast<int>(height));
    cv::Mat faceCrop = mat(faceRect);

    // 获取眼睛的地标并裁剪眼睛区域
    VNFaceLandmarks2D *landmarks = faceObservation.landmarks;
    UIImage *leftEyeImage = nil;
    UIImage *rightEyeImage = nil;
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
            
            // 为左眼矩形上下各增加20像素
            leftEyeRect.y = std::max(leftEyeRect.y - 20, 0); // 确保y坐标不小于0
            leftEyeRect.height = leftEyeRect.height + 40;     // 增加40像素高度（上下各20）

            // 裁剪左眼图像
            cv::Mat leftEyeCrop = mat(leftEyeRect);
            leftEyeImage = MatToUIImage(leftEyeCrop);

            // 计算右眼边界框
            cv::Rect rightEyeRect = [self rectFromPointsInImage:[rightEye pointsInImageOfSize:imageSize] pointCount:rightEye.pointCount];
            rightEyeRect = cv::Rect(
                static_cast<int>(rightEyeRect.x),
                static_cast<int>(imageSize.height - (rightEyeRect.y + rightEyeRect.height)),
                static_cast<int>(rightEyeRect.width),
                static_cast<int>(rightEyeRect.height)
            );
            
            // 为右眼矩形上下各增加20像素
            rightEyeRect.y = std::max(rightEyeRect.y - 20, 0); // 确保y坐标不小于0
            rightEyeRect.height = rightEyeRect.height + 40;     // 增加40像素高度（上下各20）

            // 裁剪右眼图像
            cv::Mat rightEyeCrop = mat(rightEyeRect);
            rightEyeImage = MatToUIImage(rightEyeCrop);
        }
    }

    // 将面部裁剪转换为 UIImage
//    UIImage *faceImage = [self matToUIImage:faceCrop];
    UIImage *faceImage = MatToUIImage(faceCrop);

    // 返回裁剪后的 UIImage 数组
    NSMutableArray<UIImage *> *resultImages = [NSMutableArray arrayWithObject:faceImage];
    if (leftEyeImage) {
        [resultImages addObject:leftEyeImage];
    }
    if (rightEyeImage) {
        [resultImages addObject:rightEyeImage];
    }

    return resultImages;
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
