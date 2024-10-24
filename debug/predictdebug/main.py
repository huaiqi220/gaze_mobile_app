import multiprocessing
import logging
import numpy as np
import pandas as pd
from ttool import ttool
import os

from multiprocessing import Lock
import dlib

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s [*] %(processName)s %(message)s")


def down_process(count, file_need, origin_path, output_path, log_path, lock):
    while count.value < 1000:
        current_index = count.value
        with count.get_lock():  # 仍然需要使用 get_lock 方法来获取锁对象
            count.value += 1

        user_index = file_need.iloc[current_index, 0]
        # print("正在处理: " + str(user_index) + " 号数据")

        detector = dlib.get_frontal_face_detector()
        predictor = dlib.shape_predictor(
            'shape_predictor_68_face_landmarks.dat')
        ttool.convertTheLabel(count.value, user_index, origin_path,
                              output_path, detector, predictor, log_path, lock)


def main_process(ctx, origin_path, output_path, file_need, log_path, lock):
    v = ctx.Value("i", 0)  # 使用 value 来标明全局进度
    # print("主进程开始")
    # 若value大于1000，进程停止

    # file_data = pd.read_table(record_path)

    # file_need = file_data[file_data['当前状态'] == "已回收"].copy()

    processList = [
        ctx.Process(target=down_process,
                    args=(
                        v,
                        file_need,
                        origin_path,
                        output_path,
                        log_path,
                        lock,
                    )) for _ in range(10)
    ]
    [task.start() for task in processList]
    [task.join() for task in processList]
    logging.info("主处理进程退出")


if __name__ == '__main__':
    # record_path = '/home/work/didonglin/GazeTR/new-code/video-download/final_data.txt'

    file_path = '/home/work/didonglin/Gaze-PrecClk/video-download/data'

    list = os.listdir(file_path)

    file_table_list = []

    for file in list:

        file_table_list.append(pd.read_table(os.path.join(file_path, file)))

    res = pd.concat(file_table_list, axis=0)

    file_need = res[res["当前状态"] == "不回收"]

    log_path = './Record-5000.label'
    origin_path = '/disk2/repository/DGaze-5000/data_origin/'
    output_path = '/disk2/repository/DGaze-5000/data_final/'
    outfile = open(log_path, 'w')
    outfile.write('数据集后续处理情况记录\n')
    outfile.close()
    multiprocessing.set_start_method('spawn')
    ctx = multiprocessing.get_context('spawn')
    lock = Lock()
    main_process(ctx, origin_path, output_path, file_need, log_path, lock)
