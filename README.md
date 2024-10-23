#  Gaze Estimation APP by CoreML IOS17 Vision

pipeline:

CVFundation -> Vision -> OpenCV -> CoreML


‘’‘
实现一个个性化注视估计模型的IOS端侧落地。
’‘’
- 项目文件目录及逻辑介绍

开发过程可能比较漫长，我怕后面搞忘记了



CameraViewController控制校准数据采集页面的逻辑，简单来说就是九个点，采集27张校准数据保存到本地

ViewController.swift
ViewController里面就是主界面

ImageUtil.swift
提供了图片保存、面部推理相关函数。

MLInferenceUtil.swift
提供了模型推理接口

dataUtil.swift
提供了数据持久化接口，将校准向量MLMultiArray持久化

testViewController.swift
测试VC

ModelCaliViewController.swift
执行校准的VC

CaliHelperViewController.swift
校准数据采集前的说明页面

CameraViewController.swift
实际校准数据采集页面

ImageGalleryViewController.swift
相册页面，查看采集好的校准数据


‘’‘
开发过程中的一些约定

校准数据使用FileManager存储在
/images/cali文件夹下，以jpg格式存储

推理后的校准向量存储在
/caliFeature文件夹下，以bin格式存储

’‘’
