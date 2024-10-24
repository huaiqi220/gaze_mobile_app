import cv2
import dlib
import numpy as np
# import torchvision.transforms as transforms
# import torch
# from PIL import Image

# detector = dlib.get_frontal_face_detector()
# predictor = dlib.shape_predictor('/home/work/didonglin/GazeTR/new-code/newModelDataset/ttool/shape_predictor_68_face_landmarks.dat')
# image_path_now = '/home/work/didonglin/GazeTR/new-code/newModelDataset/ttool/test_pic.jpg'
# img = cv2.imread(image_path_now)
# height = img.shape[0]
# width = img.shape[1]

def getGridInfo(width, height, x1, y1, x2, y2):

    grid = np.zeros((25, 25))
    wid = x2 - x1
    hi = y2 - y1

    W = int(wid / width * 25)
    H = int(hi / height * 25)

    X = int(x1 / width * 25)
    Y = int(y1 / height * 25)

    grid[Y:(Y + H), X:(X + W)] = np.ones_like(grid[Y:(Y + H), X:(X + W)])
    # print(X,Y,W,H)

    return grid

def processFrame(detector, predictor, img):
    frame = img
    dets = detector(img, 1)
    height = img.shape[0]
    width = img.shape[1]
    facial = []
    left_eye = []
    right_eye = []
    for k, d in enumerate(dets):

        shape = predictor(frame, d)  # 68 keypoints

        # --------- 按照面部和眼睛的比例(3.35)截取眼部图像 -------------
        leftEyeCornerY = (shape.part(41).y + shape.part(37).y) // 2
        leftEyeCornerX = (shape.part(39).x + shape.part(36).x) // 2
        rightEyeCornerY = (shape.part(47).y + shape.part(43).y) // 2
        rightEyeCornerX = (shape.part(45).x + shape.part(42).x) // 2
        EyeSize = (d.right() - d.left()) / 3.35

        facial = [max(d.left(),1),
                  max(d.top(),1),
                  min(d.right(),width),
                  min(d.bottom(),height)]
        left_eye = [max(leftEyeCornerX - int(EyeSize / 2),1),
                    max(leftEyeCornerY - int(EyeSize / 2),1),
                    min(leftEyeCornerX + int(EyeSize / 2), width),
                    min(leftEyeCornerY + int(EyeSize / 2),height)]
        right_eye = [max(rightEyeCornerX - int(EyeSize / 2),1),
                     max(rightEyeCornerY - int(EyeSize / 2),1),
                     min(rightEyeCornerX + int(EyeSize / 2),width),
                     min(rightEyeCornerY + int(EyeSize / 2),height)]

    return facial, left_eye, right_eye

# if __name__ == "__main__":
#     f, l, r = processFrame(detector, predictor, img)
#     grid = getGridInfo(width, height, f[0], f[1], f[2], f[3])
#     print('sxy')