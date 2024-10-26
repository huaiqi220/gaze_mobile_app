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
image_path_now = './images'


ml_model_path = "../../VisionDetection/model/aff_net_ma.mlpackage"
ml_model = ct.models.MLModel(ml_model_path)

# 2. 打印模型的输入和输出信息
print("Model inputs:", ml_model.input_description)
print("Model outputs:", ml_model.output_description)

for image in os.listdir(image_path_now):
    if image == ".DS_Store":
        continue
    img = cv2.imread(os.path.join(image_path_now,image))
    height = img.shape[0]

    width = img.shape[1]
    facial, left_eye, right_eye = getEyeAndFace3.processFrame(detector, predictor, img)
    face = img[facial[1]:facial[3], facial[0]:facial[2]]
    limg = img[left_eye[1]:left_eye[3], left_eye[0]:left_eye[2]]
    rimg = img[right_eye[1]:right_eye[3], right_eye[0]:right_eye[2]]
    rimg = cv2.resize(rimg,(112,112))/255.0
    limg = cv2.resize(limg,(112,112))/255.0
    fimg = cv2.resize(face,(224,224))/255.0
    rect = [facial[0],facial[1],facial[2],facial[3],
            left_eye[0],left_eye[1],left_eye[2],left_eye[3],
            right_eye[0],right_eye[1],right_eye[2],right_eye[3]]
    rect = np.array(rect).astype("float")
    rect = torch.from_numpy(rect).type(torch.FloatTensor)

    mlfeature = {"faceImg":fimg,"leftEyeImg":limg,"rightEyeImg":rimg,"faceGridImg":rect}


    fimg = torch.from_numpy(fimg).type(torch.FloatTensor)
    limg = torch.from_numpy(limg).type(torch.FloatTensor)
    rimg = torch.from_numpy(rimg).type(torch.FloatTensor)

    ml_res = ml_model.predict(mlfeature)
    print("这是ml output")
    print(ml_res)




    # model.func(face_path=face,leye_path=left_eye,reye_path=right_eye,save_path="")
    net = model.model()
    statedict = torch.load("./Iter_16_AFF-Net.pt",
                            map_location=torch.device("cpu"))
    new_state_dict = {}
    for key, value in statedict.items():
    # 如果 key 以 "module." 开头，则去掉这个前缀
        new_key = key[7:]
        new_state_dict[new_key] = value
    net.load_state_dict(state_dict=new_state_dict)

    res = net(limg,rimg,fimg,rect)
    print(image)
    print(res)