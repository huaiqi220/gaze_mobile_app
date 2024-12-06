import torch
import model
import getEyeAndFace3
import dlib
import os
import cv2
import numpy as np

import coremltools as ct
import numpy as np





detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor('./shape_predictor_68_face_landmarks.dat')
image_path_now = '/Users/zhuz1/Desktop/数据预处理检查'


ml_model_path = "../../VisionDetection/model/cges_decoder.mlpackage"
ml_model = ct.models.MLModel(ml_model_path)







# 2. 打印模型的输入和输出信息
print("Model inputs:", ml_model.input_description)
print("Model outputs:", ml_model.output_description)
# index = 0
# for image in os.listdir(image_path_now):
#     if image == ".DS_Store":
#         continue
#     img = cv2.imread(os.path.join(image_path_now,image))
#     height = img.shape[0]
#     index = index + 1

#     width = img.shape[1]
#     facial, left_eye, right_eye = getEyeAndFace3.getEyeAndFace(detector, predictor, img)
#     face = img[facial[1]:facial[3], facial[0]:facial[2]]
#     limg = img[left_eye[1]:left_eye[3], left_eye[0]:left_eye[2]]
#     rimg = img[right_eye[1]:right_eye[3], right_eye[0]:right_eye[2]]
#     # rimg = cv2.resize(rimg,(112,112))
#     # limg = cv2.resize(limg,(112,112))
#     # fimg = cv2.resize(face,(224,224))

#     cv2.imwrite("face_" + str(index) + "_.jpg",face)
#     cv2.imwrite("left_" + str(index) + "_.jpg",limg)
#     cv2.imwrite("right_" + str(index) + "_.jpg",rimg)


    
    # rect = [facial[0],facial[1],facial[2],facial[3],
    #         left_eye[0],left_eye[1],left_eye[2],left_eye[3],
    #         right_eye[0],right_eye[1],right_eye[2],right_eye[3]]
    # rect = np.array(rect).astype("float")

    # 定义 k = 12
k = 12
totalCalibrations = 1 << k  # 2^k = 4096

# 随机生成 fc1 的向量，大小为 [27, 512]（根据模型的要求调整形状）
fc1_shape = (27, 512)
fc1 = np.random.rand(*fc1_shape).astype(np.float32)

# 遍历 4096 种校准向量
for i in range(totalCalibrations):
    # 将整数 i 转换为 12 位二进制向量，并将其转为浮点数组
    cali_vector = np.array([int(bit) for bit in format(i, f'0{k}b')], dtype=np.float32)

    # 准备输入字典
    ml_feature = {
        "cali": cali_vector,
        "fc1": fc1,
    }

    # 进行预测
    try:
        ml_res = ml_model.predict(ml_feature)
    except Exception as e:
        print(f"模型推理失败，校准向量: {cali_vector}, 错误: {e}")
        continue

    # 输出检查
    output_values = ml_res["linear_2"]  # 假设模型输出为 'linear_2'
    print(i)
    if np.all(output_values == 0):
        print(f"输出全为 0，校准向量: {cali_vector}")
    else:
        print(f"推理成功，校准向量: {cali_vector}, 输出: {output_values}")
    

# mlfeature = {"faceImg":fimg,"leftEyeImg":limg,"rightEyeImg":rimg,"faceGridImg":rect}

    # rect = torch.from_numpy(rect).type(torch.FloatTensor)
    # fimg = torch.from_numpy(fimg).type(torch.FloatTensor)
    # limg = torch.from_numpy(limg).type(torch.FloatTensor)
    # rimg = torch.from_numpy(rimg).type(torch.FloatTensor)

# ml_res = ml_model.predict(mlfeature)
# print("这是ml output")
# print(ml_res)




    # # model.func(face_path=face,leye_path=left_eye,reye_path=right_eye,save_path="")
    # net = model.model()
    # statedict = torch.load("./Iter_16_AFF-Net.pt",
    #                         map_location=torch.device("cpu"))
    # new_state_dict = {}
    # for key, value in statedict.items():
    # # 如果 key 以 "module." 开头，则去掉这个前缀
    #     new_key = key[7:]
    #     new_state_dict[new_key] = value
    # net.load_state_dict(state_dict=new_state_dict)

    # res = net(limg,rimg,fimg,rect)
    # print(image)
    # print(res)