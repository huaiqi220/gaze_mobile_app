import json
import os.path
import cv2
from ttool import getGrid
from ttool import getEyeAndFace3
from multiprocessing import Lock
import dlib
# import skvideo.io
# import imutils


def convertTheLabel(v,user_index,origin_path,output_path_base,detector, predictor,log_path,lock):
# def convertTheLabel(v, user_index, origin_path, output_path_base, detector, predictor):
    try:
        labelPath = origin_path + str(user_index) + "/label.json"

        case_info = json.load(open(labelPath))

        ScreenSize_px = case_info[str(user_index)]['screen_size(px)']
        SizeList_px = ScreenSize_px[1:].split("]")[0].split(",")
        ScreenHeight_px = int(SizeList_px[0])
        ScreenWidth_px = int(SizeList_px[1])

        ScreenSize_cm = case_info[str(user_index)]['phone_size']
        SizeList_cm = ScreenSize_cm[1:].split("]")[0].split(",")
        ScreenWidth_cm = float(SizeList_cm[0])
        ScreenHeight_cm = float(SizeList_cm[1])

        CameraLocation_cm = case_info[str(user_index)]['camera_position']
        LocationList_cm = CameraLocation_cm[1:].split("]")[0].split(",")
        CameraX_cm = float(LocationList_cm[0])
        CameraY_cm = float(LocationList_cm[1])

        camera_path = origin_path + str(user_index)+ "/camera/"
        if not os.path.exists(camera_path):
            os.mkdir(camera_path)
        photo_path = origin_path + str(user_index) +  "/photo/"
        if not os.path.exists(photo_path):
            os.mkdir(photo_path)

        camera_name = 'camera_' + str(user_index) + '_.mp4'
        camera_video = os.path.join(camera_path, camera_name)
        print(camera_video)
        video_capture = cv2.VideoCapture(camera_video)
        # metadata = skvideo.io.ffprobe(camera_video)

        output_path = os.path.join(output_path_base, "Image", str(user_index))

        if v % 16 == 0 or v % 17 == 0:
            splited_set = "test"
        else:
            splited_set = "train"
        # splited_set = "train"


        if not os.path.exists(os.path.join(output_path, 'face')):
            os.makedirs(os.path.join(output_path, 'face'))

        if not os.path.exists(os.path.join(output_path, 'left')):
            os.makedirs(os.path.join(output_path, 'left'))

        if not os.path.exists(os.path.join(output_path, 'right')):
            os.makedirs(os.path.join(output_path, 'right'))

        if not os.path.exists(os.path.join(output_path, 'full')):
            os.makedirs(os.path.join(output_path, 'full'))

        if not os.path.exists(os.path.join(output_path, 'grid')):
            os.makedirs(os.path.join(output_path, 'grid'))

        if not os.path.exists(os.path.join(output_path_base, "Label", splited_set)):
            os.makedirs(os.path.join(output_path_base, "Label", splited_set))

        WordList = case_info[str(user_index)]['text']

        PhotoIdList = case_info[str(user_index)]['photo_id']

        PhotoList = []

        for i in range(0, len(PhotoIdList)):
            image_path_now = os.path.join(photo_path,   "photo_" +str(user_index) + "_"+ str(PhotoIdList[i]) + "_.png")
            # print(image_path_now)
            img = cv2.imread(image_path_now)
            # print(image_path_now)

            height = img.shape[0]
            width = img.shape[1]

            x, y = getGrid.getLocation(ScreenWidth_cm, ScreenHeight_cm, int(PhotoIdList[i]))

            # print(x, y)

            # 考虑摄像头位置的厘米长度
            label_x_final = x - CameraX_cm
            label_y_final = y - CameraY_cm

            centimeters_label = [str(label_x_final), str(label_y_final)]

            face, left_eye, right_eye = getEyeAndFace3.processFrame(detector, predictor, img)
            if face == [] or left_eye == [] or right_eye == []:
                continue

            total_rect = [str(face[0]), str(face[1]), str(face[2]), str(face[3]), str(left_eye[0]),
                          str(left_eye[1]), str(left_eye[2]),
                          str(left_eye[3]), str(right_eye[0]), str(right_eye[1]), str(right_eye[2]),
                          str(right_eye[3])]
            # print("开始输出坐标============")
            # print(face, left_eye, right_eye)
            # print(total_rect)

            '''
                    开始输出裁剪之后的图像,保存至文件并生成label
    
                    '''
            # 在此利用face和相片宽高算出grid
            grid = getGrid.getGridInfo(width, height, face[0], face[1], face[2], face[3])
            file_name = "point_" + str(PhotoIdList[i]) + ".jpg"

            save_full_path = os.path.join(str(user_index), 'full', file_name)
            save_face_path = os.path.join(str(user_index), 'face', file_name)
            save_left_path = os.path.join(str(user_index), 'left', file_name)
            save_right_path = os.path.join(str(user_index), 'right', file_name)
            save_grid_path = os.path.join(str(user_index), 'grid', file_name)

            label = " ".join([save_face_path, save_left_path, save_right_path, save_grid_path, save_full_path,
                              ",".join(centimeters_label), "Point", ",".join(total_rect)])

            PhotoList.append(label)

            cv2.imwrite(os.path.join(output_path, 'full', file_name),
                        img)
            cv2.imwrite(os.path.join(output_path, 'face', file_name),
                        img[face[1]:face[3], face[0]:face[2]])
            cv2.imwrite(os.path.join(output_path, 'left', file_name),
                        img[left_eye[1]:left_eye[3], left_eye[0]:left_eye[2]])
            cv2.imwrite(os.path.join(output_path, 'right', file_name),
                        img[right_eye[1]:right_eye[3], right_eye[0]:right_eye[2]])
            cv2.imwrite(os.path.join(output_path, 'grid', file_name), grid)

        number = 0

        count_word = 1

        for i in range(1, len(WordList)):

            # 此处逻辑为，每个成语生成一个label文件，命名格式为person + index

            label_outpath = os.path.join(output_path_base, "Label", splited_set,
                                         str(user_index) + "_" + str(i) + ".label")
            # label_outpath = output_path + "/Label/"+ str(splited_set), + "/"+ f"{person}.label"
            # print(label_outpath)

            outfile = open(label_outpath, 'w')
            outfile.write("Face Left Right Grid Full Xcam,Ycam Kind Rect\n")

            for j in range(0, len(PhotoList)):
                outfile.write(PhotoList[j] + "\n")

            bbox = WordList[str(i)]["text_bbox"]
            bbox_list = bbox[1:].split("]")[0].split(",")
            label_x_origin = (int(bbox_list[0]) + int(bbox_list[2])) / 2
            label_y_origin = (int(bbox_list[1]) + int(bbox_list[3])) / 2
            label_x = label_x_origin / ScreenWidth_px * ScreenWidth_cm
            label_y = label_y_origin / ScreenHeight_px * ScreenHeight_cm
            label_x = label_x - CameraX_cm
            label_y = label_y - CameraY_cm
            current_label = [str(label_x), str(label_y)]

            gaze_frame = WordList[str(i)]["gaze_frame"]
            result = gaze_frame[1:].split("]")[0].split(",")
            # number = 0
            count_pic = 0

            for i in range(4, 14):
                video_capture.set(cv2.CAP_PROP_POS_FRAMES, float(result[i]))
                if video_capture.isOpened():  # 判断是否正常打开
                    rval, frame = video_capture.read()

                    # 解决某些视频自动旋转90度的问题
                    # try:
                    #     d = metadata['video'].get('tag')[0]
                    #     if d.setdefault('@key') == 'rotate':  # 获取视频自选择角度
                    #         frame = imutils.rotate(frame, 360 - int(d.setdefault('@value')))
                    # except:
                    #     pass

                    width = frame.shape[0]
                    height = frame.shape[1]
                    # print(frame.shape)
                    face, left_eye, right_eye = getEyeAndFace3.processFrame(detector, predictor, frame)
                    if face == [] or left_eye == [] or right_eye == []:
                        continue
                    
                    count_pic = count_pic + 1
                    face_rect = [str(face[0]), str(face[1]), str(face[2]), str(face[3]), str(left_eye[0]),
                                 str(left_eye[1]), str(left_eye[2]),
                                 str(left_eye[3]), str(right_eye[0]), str(right_eye[1]), str(right_eye[2]),
                                 str(right_eye[3])]
                    grid = getGrid.getGridInfo(width, height, face[0], face[1], face[2], face[3])
                    file_name = "photo_" + str(number) + ".jpg"
                    number = number + 1

                    save_face_path = os.path.join(str(user_index), 'face', file_name)
                    save_left_path = os.path.join(str(user_index), 'left', file_name)
                    save_right_path = os.path.join(str(user_index), 'right', file_name)
                    save_full_path = os.path.join(str(user_index), 'full', file_name)
                    save_grid_path = os.path.join(str(user_index), 'grid', file_name)

                    label = " ".join(
                        [save_face_path, save_left_path, save_right_path, save_grid_path, save_full_path,
                         ",".join(current_label), "Photo", ",".join(face_rect)])
                    outfile.write(label + "\n")

                    cv2.imwrite(os.path.join(output_path, 'face', file_name),
                                frame[face[1]:face[3], face[0]:face[2]])
                    cv2.imwrite(os.path.join(output_path, 'left', file_name),
                                frame[left_eye[1]:left_eye[3], left_eye[0]:left_eye[2]])
                    cv2.imwrite(os.path.join(output_path, 'right', file_name),
                                frame[right_eye[1]:right_eye[3], right_eye[0]:right_eye[2]])
                    cv2.imwrite(os.path.join(output_path, 'full', file_name), frame)
                    cv2.imwrite(os.path.join(output_path, 'grid', file_name), grid)

            label = str(user_index) + " 号样本" + str(count_word) + "号成语处理完成,共获得" + str(count_pic) + "张图片和" + str(
                len(PhotoList)) + "张Point图片"
            print(label)
            with lock:
                f = open(log_path, 'a+')
                f.write(label + "\n")
                f.close()
            count_word = count_word + 1

        video_capture.release()
    except:
        label = str(user_index) + "处理错误"
        print(label)
        with lock:
            f = open(log_path, 'a+')
            f.write(label + "\n")
            f.close()







if __name__ == '__main__':

    origin_path = 'C:/Users/zhuziyang/Desktop/dataset_download/dataset_test/'

    output_path = 'C:/Users/zhuziyang/Desktop/dataset_download/dataset_output/'

    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor('shape_predictor_68_face_landmarks.dat')

    convertTheLabel(100,38158,origin_path,output_path, detector, predictor)


