import numpy as np
import cv2
# import torch


def func(face_path,leye_path, reye_path,save_path):
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
    cv2.imwrite("face.jpg",fimg)
    cv2.imwrite("leye.jpg",limg)
    cv2.imwrite("reye.jpg",rimg)


if __name__ == "__main__":
    face_path = "images/IMG_1118.JPG"
    leye_path = "images/IMG_1119.JPG"
    reye_path = "images/IMG_1120.JPG"

    func(face_path=face_path,leye_path=leye_path,reye_path=reye_path,save_path="")