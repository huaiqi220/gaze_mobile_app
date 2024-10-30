import numpy as np
import cv2
# import torch
import os

index = 0
def func(face_path,leye_path, reye_path,save_path):
    index = index + 1
    rimg = cv2.imread(reye_path)
    # rimg = cv2.resize(rimg,  (224, 224))/255.0
    rimg = cv2.resize(rimg,  (112, 112))
    # rimg = rimg.transpose(2, 0, 1)

    limg = cv2.imread(leye_path)
    # limg = cv2.resize(limg,  (224, 224))/255.0
    limg = cv2.resize(limg,  (112, 112))
    # limg = limg.transpose(2, 0, 1)
    
    fimg = cv2.imread(face_path)
    # fimg = cv2.resize(fimg, (112, 112))/255.0
    fimg = cv2.resize(fimg, (224, 224))
    # fimg = fimg.transpose(2, 0, 1)


    print(rimg.shape)
    cv2.imwrite("face" + "_" + index + ".jpg",fimg)
    cv2.imwrite("leye" + "_" + index + ".jpg",limg)
    cv2.imwrite("reye" + "_" + index + ".jpg",rimg)


# if __name__ == "__main__":
#     folder = "/Users/zhuz1/Desktop/数据预处理检查"
#     for image in os.listdir(folder):
#         cur = os.path.join(folder,image)



#     func(face_path=face_path,leye_path=leye_path,reye_path=reye_path,save_path="")