import numpy as np



def getGridInfo(width,height,x1,y1,x2,y2):

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

def getLocation(width,height,index):

    label_x = 0
    label_y = 0

    if index == 1 or index == 2 or index == 3:
        label_x = 0.1 * width
        label_y = 0.15 * height

    if index == 4 or index == 5 or index == 6:
        label_x = 0.5 * width
        label_y = 0.15 * height

    if index == 7 or index == 8 or index == 9:
        label_x = 0.9 * width
        label_y = 0.15 * height

    if index == 10 or index == 11 or index == 12:
        label_x = 0.1 * width
        label_y = 0.55 * height

    if index == 13 or index == 14 or index == 15:
        label_x = 0.9 * width
        label_y = 0.55 * height

    if index == 16 or index == 17 or index == 18:
        label_x = 0.1 * width
        label_y = 0.95 * height

    if index == 19 or index == 20 or index == 21:
        label_x = 0.5 * width
        label_y = 0.95 * height

    if index == 22 or index == 23 or index == 24:
        label_x =  0.95 * width
        label_y = 0.95 * height

    return label_x,label_y