import sys
import dlib
# from skimage import io
import cv2


def getEyeAndFace(detector,predictor,frame):
    # 加载并初始化检测器
    # 模型下载地址http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2
    # detector = dlib.get_frontal_face_detector()
    # predictor = dlib.shape_predictor('shape_predictor_68_face_landmarks.dat')
    face = []
    left_eye = []
    right_eye = []

    try:
        frame_new = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        # 检测脸部
        dets = detector(frame_new, 1)
        # print("Number of faces detected: {}".format(len(dets)))
        # 查找脸部位置

        for i, face in enumerate(dets):
            # print("Detection {}: Left: {} Top: {} Right: {} Bottom: {} ".format(
            #     i, face.left(), face.top(), face.right(), face.bottom()))
            # 绘制脸部位置
            # cv2.rectangle(frame, (face.left(), face.top()), (face.right(), face.bottom()), (0, 255, 0), 1)
            shape = predictor(frame_new, face)
            # print(shape.part(0),shape.part(1))
            # face = [face.left(), face.top(), face.right(), face.bottom()]
            face = [shape.part(0).x - 20, face.top() - 10, shape.part(16).x + 20, shape.part(8).y + 10]
            left_eye = [shape.part(43).x - 20, shape.part(44).y - 10, shape.part(46).x + 20, shape.part(47).y + 10]
            right_eye = [shape.part(37).x - 20, shape.part(38).y - 10, shape.part(40).x + 20, shape.part(42).y + 10]

    except:
        print("失败")

    return face, left_eye, right_eye
