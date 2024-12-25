import re
from collections import defaultdict

# Log data
log_data = """
模型加载 time: 57.747314453125 ms
面部检测 time: 17.5751953125 ms
图像处理 time: 4.953125 ms
模型推理 time: 4.837158203125 ms
面部检测 time: 13.088134765625 ms
图像处理 time: 3.9150390625 ms
模型推理 time: 2.52001953125 ms
面部检测 time: 10.90625 ms
图像处理 time: 4.039794921875 ms
模型推理 time: 1.925048828125 ms
面部检测 time: 13.962890625 ms
图像处理 time: 4.09912109375 ms
模型推理 time: 2.78271484375 ms
面部检测 time: 12.203125 ms
图像处理 time: 4.226318359375 ms
模型推理 time: 2.8310546875 ms
面部检测 time: 12.22509765625 ms
图像处理 time: 4.73291015625 ms
模型推理 time: 3.004150390625 ms
面部检测 time: 13.625732421875 ms
图像处理 time: 4.68310546875 ms
模型推理 time: 3.195068359375 ms
面部检测 time: 12.544189453125 ms
图像处理 time: 4.5859375 ms
模型推理 time: 2.988037109375 ms
面部检测 time: 12.76318359375 ms
图像处理 time: 4.43603515625 ms
模型推理 time: 3.5419921875 ms
面部检测 time: 13.9658203125 ms
图像处理 time: 4.90087890625 ms
模型推理 time: 3.321044921875 ms
面部检测 time: 13.701171875 ms
图像处理 time: 5.024169921875 ms
模型推理 time: 3.635986328125 ms
面部检测 time: 14.99609375 ms
图像处理 time: 5.177001953125 ms
模型推理 time: 3.90185546875 ms
面部检测 time: 15.052978515625 ms
图像处理 time: 5.14013671875 ms
模型推理 time: 3.872802734375 ms
面部检测 time: 16.612060546875 ms
图像处理 time: 4.850341796875 ms
模型推理 time: 3.985107421875 ms
面部检测 time: 13.7470703125 ms
图像处理 time: 4.636962890625 ms
模型推理 time: 3.130126953125 ms
面部检测 time: 12.989013671875 ms
图像处理 time: 4.525146484375 ms
模型推理 time: 3.652099609375 ms
面部检测 time: 14.035400390625 ms
图像处理 time: 4.39208984375 ms
模型推理 time: 3.287109375 ms
面部检测 time: 13.10791015625 ms
图像处理 time: 4.7587890625 ms
模型推理 time: 3.468017578125 ms
面部检测 time: 14.7353515625 ms
图像处理 time: 4.68115234375 ms
模型推理 time: 3.9189453125 ms
面部检测 time: 14.239990234375 ms
图像处理 time: 4.77587890625 ms
模型推理 time: 3.829833984375 ms
面部检测 time: 13.906005859375 ms
图像处理 time: 4.441162109375 ms
模型推理 time: 3.212890625 ms
面部检测 time: 13.112060546875 ms
图像处理 time: 4.3681640625 ms
模型推理 time: 3.38916015625 ms
面部检测 time: 13.175048828125 ms
图像处理 time: 4.41796875 ms
模型推理 time: 2.939208984375 ms
面部检测 time: 14.458984375 ms
图像处理 time: 4.53466796875 ms
模型推理 time: 3.259033203125 ms
面部检测 time: 13.644775390625 ms
图像处理 time: 4.3759765625 ms
模型推理 time: 3.444091796875 ms
面部检测 time: 13.52783203125 ms
图像处理 time: 4.590087890625 ms
模型推理 time: 3.18212890625 ms
面部检测 time: 12.364990234375 ms
图像处理 time: 4.56494140625 ms
模型推理 time: 3.2861328125 ms
面部检测 time: 14.885986328125 ms
图像处理 time: 4.9921875 ms
模型推理 time: 3.350830078125 ms
面部检测 time: 12.876953125 ms
图像处理 time: 4.34814453125 ms
模型推理 time: 2.558349609375 ms
面部检测 time: 13.523193359375 ms
图像处理 time: 4.572265625 ms
模型推理 time: 2.76904296875 ms
面部检测 time: 14.81787109375 ms
图像处理 time: 4.68310546875 ms
模型推理 time: 3.640869140625 ms
面部检测 time: 13.759033203125 ms
图像处理 time: 4.767822265625 ms
模型推理 time: 3.4951171875 ms
面部检测 time: 15.052001953125 ms
图像处理 time: 4.592041015625 ms
模型推理 time: 3.27001953125 ms
面部检测 time: 14.027099609375 ms
图像处理 time: 4.65087890625 ms
模型推理 time: 3.5791015625 ms
面部检测 time: 14.020263671875 ms
图像处理 time: 4.331787109375 ms
模型推理 time: 3.231201171875 ms
面部检测 time: 12.80224609375 ms
图像处理 time: 4.405029296875 ms
模型推理 time: 3.0458984375 ms
面部检测 time: 14.274169921875 ms
图像处理 time: 4.904052734375 ms
模型推理 time: 3.427001953125 ms
面部检测 time: 14.880126953125 ms
图像处理 time: 4.98828125 ms
模型推理 time: 3.796875 ms
面部检测 time: 14.763916015625 ms
图像处理 time: 4.831298828125 ms
模型推理 time: 3.865234375 ms
面部检测 time: 15.303955078125 ms
图像处理 time: 4.5302734375 ms
模型推理 time: 3.814208984375 ms
面部检测 time: 14.307861328125 ms
图像处理 time: 4.4541015625 ms
模型推理 time: 3.044921875 ms
面部检测 time: 14.125 ms
图像处理 time: 4.572021484375 ms
模型推理 time: 3.15283203125 ms
面部检测 time: 13.383056640625 ms
图像处理 time: 4.4892578125 ms
模型推理 time: 2.797119140625 ms
面部检测 time: 13.282958984375 ms
图像处理 time: 4.381103515625 ms
模型推理 time: 2.56103515625 ms
面部检测 time: 13.964111328125 ms
图像处理 time: 4.580078125 ms
模型推理 time: 3.383056640625 ms
面部检测 time: 14.170654296875 ms
图像处理 time: 4.44189453125 ms
模型推理 time: 3.1689453125 ms
面部检测 time: 13.65283203125 ms
图像处理 time: 4.56005859375 ms
模型推理 time: 2.52099609375 ms
面部检测 time: 13.59033203125 ms
图像处理 time: 4.362060546875 ms
模型推理 time: 3.019775390625 ms
面部检测 time: 12.281005859375 ms
图像处理 time: 4.381103515625 ms
模型推理 time: 3.0791015625 ms
面部检测 time: 12.863037109375 ms
图像处理 time: 4.3671875 ms
模型推理 time: 2.81005859375 ms
面部检测 time: 13.87890625 ms
图像处理 time: 4.7578125 ms
模型推理 time: 3.162109375 ms
面部检测 time: 13.740966796875 ms
图像处理 time: 4.546142578125 ms
模型推理 time: 2.791015625 ms
面部检测 time: 14.080078125 ms
图像处理 time: 4.81884765625 ms
模型推理 time: 2.7998046875 ms
面部检测 time: 13.822998046875 ms
图像处理 time: 4.758056640625 ms
模型推理 time: 3.47607421875 ms
面部检测 time: 14.7958984375 ms
图像处理 time: 4.899169921875 ms
模型推理 time: 3.475830078125 ms
面部检测 time: 14.617919921875 ms
图像处理 time: 4.907958984375 ms
模型推理 time: 3.55810546875 ms
面部检测 time: 14.91015625 ms
图像处理 time: 4.94189453125 ms
模型推理 time: 3.934814453125 ms
面部检测 time: 14.81689453125 ms
图像处理 time: 5.0078125 ms
模型推理 time: 3.97119140625 ms
面部检测 time: 14.35595703125 ms
图像处理 time: 4.48681640625 ms
模型推理 time: 2.924072265625 ms
面部检测 time: 12.9921875 ms
图像处理 time: 4.1201171875 ms
模型推理 time: 3.2490234375 ms
面部检测 time: 12.81884765625 ms
图像处理 time: 4.167724609375 ms
模型推理 time: 3.19287109375 ms
面部检测 time: 13.572265625 ms
图像处理 time: 4.169921875 ms
模型推理 time: 3.2392578125 ms
面部检测 time: 14.80810546875 ms
图像处理 time: 4.695068359375 ms
模型推理 time: 3.607421875 ms
面部检测 time: 13.565185546875 ms
图像处理 time: 4.403076171875 ms
模型推理 time: 3.76806640625 ms
面部检测 time: 13.342041015625 ms
图像处理 time: 4.385009765625 ms
模型推理 time: 3.660888671875 ms
面部检测 time: 14.203857421875 ms
图像处理 time: 4.7900390625 ms
模型推理 time: 3.929931640625 ms
面部检测 time: 13.988037109375 ms
图像处理 time: 4.369140625 ms
模型推理 time: 3.731201171875 ms
面部检测 time: 14.068115234375 ms
图像处理 time: 4.570068359375 ms
模型推理 time: 3.617919921875 ms
面部检测 time: 14.3271484375 ms
图像处理 time: 4.310791015625 ms
模型推理 time: 3.305908203125 ms
面部检测 time: 12.87158203125 ms
图像处理 time: 4.204345703125 ms
模型推理 time: 3.124267578125 ms
面部检测 time: 12.614990234375 ms
图像处理 time: 4.240234375 ms
模型推理 time: 2.968017578125 ms
面部检测 time: 12.259033203125 ms
图像处理 time: 4.39306640625 ms
模型推理 time: 3.23095703125 ms
面部检测 time: 13.114013671875 ms
图像处理 time: 4.72412109375 ms
模型推理 time: 3.233154296875 ms
面部检测 time: 12.1357421875 ms
图像处理 time: 4.4638671875 ms
模型推理 time: 2.9150390625 ms
面部检测 time: 13.06494140625 ms
图像处理 time: 4.552978515625 ms
模型推理 time: 3.05224609375 ms
面部检测 time: 12.26611328125 ms
图像处理 time: 4.4931640625 ms
模型推理 time: 2.85205078125 ms
面部检测 time: 14.38720703125 ms
图像处理 time: 4.5361328125 ms
模型推理 time: 3.340087890625 ms
面部检测 time: 14.30908203125 ms
图像处理 time: 4.448974609375 ms
模型推理 time: 3.3359375 ms
面部检测 time: 13.963623046875 ms
图像处理 time: 4.68505859375 ms
模型推理 time: 3.2509765625 ms
面部检测 time: 13.090087890625 ms
图像处理 time: 4.6728515625 ms
模型推理 time: 3.48095703125 ms
面部检测 time: 13.667236328125 ms
图像处理 time: 4.524658203125 ms
模型推理 time: 3.230712890625 ms
面部检测 time: 13.924072265625 ms
图像处理 time: 4.6162109375 ms
模型推理 time: 3.31396484375 ms
面部检测 time: 13.378662109375 ms
图像处理 time: 4.69091796875 ms
模型推理 time: 3.15087890625 ms
面部检测 time: 13.458740234375 ms
图像处理 time: 4.547119140625 ms
模型推理 time: 3.412109375 ms
面部检测 time: 13.44287109375 ms
图像处理 time: 4.386962890625 ms
模型推理 time: 2.9990234375 ms
面部检测 time: 13.665771484375 ms
图像处理 time: 4.355224609375 ms
模型推理 time: 2.957763671875 ms
面部检测 time: 14.59228515625 ms
图像处理 time: 4.4541015625 ms
模型推理 time: 3.343994140625 ms
面部检测 time: 15.21484375 ms
图像处理 time: 4.4169921875 ms
模型推理 time: 3.111083984375 ms
面部检测 time: 12.157958984375 ms
图像处理 time: 4.361328125 ms
模型推理 time: 3.045166015625 ms
面部检测 time: 13.43017578125 ms
图像处理 time: 4.47705078125 ms
模型推理 time: 2.35791015625 ms
面部检测 time: 14.85986328125 ms
图像处理 time: 4.672119140625 ms
模型推理 time: 2.83544921875 ms
面部检测 time: 14.64892578125 ms
图像处理 time: 4.68603515625 ms
模型推理 time: 3.9140625 ms
面部检测 time: 15.9296875 ms
图像处理 time: 4.64306640625 ms
模型推理 time: 2.93408203125 ms
面部检测 time: 15.228759765625 ms
图像处理 time: 4.757080078125 ms
模型推理 time: 3.5419921875 ms
面部检测 time: 13.498046875 ms
图像处理 time: 4.65185546875 ms
模型推理 time: 3.291259765625 ms
面部检测 time: 13.621826171875 ms
图像处理 time: 4.277099609375 ms
模型推理 time: 3.27099609375 ms
面部检测 time: 13.193115234375 ms
图像处理 time: 4.328125 ms
模型推理 time: 3.300048828125 ms
面部检测 time: 13.336181640625 ms
图像处理 time: 4.579833984375 ms
模型推理 time: 3.31103515625 ms
面部检测 time: 12.9638671875 ms
图像处理 time: 4.2412109375 ms
模型推理 time: 3.299560546875 ms
面部检测 time: 13.73583984375 ms
图像处理 time: 4.65087890625 ms
模型推理 time: 3.432861328125 ms
面部检测 time: 13.892822265625 ms
图像处理 time: 4.652099609375 ms
模型推理 time: 2.912841796875 ms
面部检测 time: 14.8720703125 ms
图像处理 time: 4.812255859375 ms
模型推理 time: 3.375 ms
面部检测 time: 13.4970703125 ms
图像处理 time: 4.659912109375 ms
模型推理 time: 3.401611328125 ms
面部检测 time: 13.8349609375 ms
图像处理 time: 4.73291015625 ms
模型推理 time: 3.386962890625 ms
面部检测 time: 15.61865234375 ms
图像处理 time: 4.358642578125 ms
模型推理 time: 3.67578125 ms
面部检测 time: 14.244140625 ms
图像处理 time: 4.442138671875 ms
模型推理 time: 3.345947265625 ms
面部检测 time: 15.521728515625 ms
图像处理 time: 4.4140625 ms
模型推理 time: 3.2470703125 ms
面部检测 time: 14.026123046875 ms
图像处理 time: 4.89794921875 ms
模型推理 time: 3.447021484375 ms
面部检测 time: 14.420166015625 ms
图像处理 time: 4.534912109375 ms
模型推理 time: 3.39697265625 ms
面部检测 time: 12.73095703125 ms
图像处理 time: 4.531005859375 ms
模型推理 time: 3.558837890625 ms
面部检测 time: 13.969970703125 ms
图像处理 time: 4.40966796875 ms
模型推理 time: 3.343994140625 ms
面部检测 time: 12.482177734375 ms
图像处理 time: 4.227783203125 ms
模型推理 time: 2.98291015625 ms
面部检测 time: 14.8408203125 ms
图像处理 time: 4.548095703125 ms
模型推理 time: 3.522705078125 ms
面部检测 time: 13.962890625 ms
图像处理 time: 4.23291015625 ms
模型推理 time: 3.195068359375 ms
面部检测 time: 14.5380859375 ms
图像处理 time: 4.52001953125 ms
模型推理 time: 3.43505859375 ms
面部检测 time: 13.336181640625 ms
图像处理 time: 4.501220703125 ms
模型推理 time: 3.30908203125 ms
面部检测 time: 14.329833984375 ms
图像处理 time: 4.539794921875 ms
模型推理 time: 3.1708984375 ms
面部检测 time: 13.796875 ms
图像处理 time: 4.41162109375 ms
模型推理 time: 3.4150390625 ms
面部检测 time: 13.69091796875 ms
图像处理 time: 4.4169921875 ms
模型推理 time: 2.65185546875 ms
面部检测 time: 13.156982421875 ms
图像处理 time: 4.284912109375 ms
模型推理 time: 2.979248046875 ms
面部检测 time: 12.93408203125 ms
图像处理 time: 4.701904296875 ms
模型推理 time: 2.8662109375 ms
面部检测 time: 13.854248046875 ms
图像处理 time: 4.673828125 ms
模型推理 time: 3.4853515625 ms
面部检测 time: 14.27880859375 ms
图像处理 time: 4.650146484375 ms
模型推理 time: 3.44091796875 ms
面部检测 time: 12.673828125 ms
图像处理 time: 4.561767578125 ms
模型推理 time: 3.710205078125 ms
面部检测 time: 14.4912109375 ms
图像处理 time: 4.755859375 ms
模型推理 time: 3.470947265625 ms
面部检测 time: 13.354736328125 ms
图像处理 time: 5.027099609375 ms
模型推理 time: 3.653076171875 ms
面部检测 time: 14.135009765625 ms
图像处理 time: 4.673095703125 ms
模型推理 time: 3.412841796875 ms
面部检测 time: 13.274658203125 ms
图像处理 time: 4.244873046875 ms
模型推理 time: 3.1328125 ms
面部检测 time: 13.802978515625 ms
图像处理 time: 4.398193359375 ms
模型推理 time: 3.267822265625 ms
面部检测 time: 13.005859375 ms
图像处理 time: 4.482177734375 ms
模型推理 time: 3.4921875 ms
面部检测 time: 14.389892578125 ms
图像处理 time: 4.565673828125 ms
模型推理 time: 3.227783203125 ms
面部检测 time: 13.105224609375 ms
图像处理 time: 4.470703125 ms
模型推理 time: 3.260986328125 ms
面部检测 time: 14.31396484375 ms
图像处理 time: 4.78125 ms
模型推理 time: 3.46630859375 ms
面部检测 time: 14.169921875 ms
图像处理 time: 4.772216796875 ms
模型推理 time: 3.752197265625 ms
面部检测 time: 15.84912109375 ms
图像处理 time: 4.933837890625 ms
模型推理 time: 3.85400390625 ms
面部检测 time: 15.199951171875 ms
图像处理 time: 4.9599609375 ms
模型推理 time: 3.51904296875 ms
面部检测 time: 13.712890625 ms
图像处理 time: 4.585205078125 ms
模型推理 time: 3.340087890625 ms
面部检测 time: 15.804931640625 ms
图像处理 time: 4.39404296875 ms
模型推理 time: 3.60498046875 ms
面部检测 time: 13.425048828125 ms
图像处理 time: 4.77294921875 ms
模型推理 time: 3.2421875 ms
面部检测 time: 13.46484375 ms
图像处理 time: 4.62109375 ms
模型推理 time: 3.305908203125 ms
面部检测 time: 13.61328125 ms
图像处理 time: 4.716064453125 ms
模型推理 time: 3.087890625 ms
面部检测 time: 14.868896484375 ms
图像处理 time: 4.372802734375 ms
模型推理 time: 3.536865234375 ms
面部检测 time: 13.68701171875 ms
图像处理 time: 4.305908203125 ms
模型推理 time: 3.2080078125 ms
面部检测 time: 11.940185546875 ms
图像处理 time: 4.293212890625 ms
模型推理 time: 2.827880859375 ms
面部检测 time: 13.576904296875 ms
图像处理 time: 4.359130859375 ms
模型推理 time: 3.0107421875 ms
面部检测 time: 15.303955078125 ms
图像处理 time: 4.339111328125 ms
模型推理 time: 2.826904296875 ms
面部检测 time: 12.703857421875 ms
图像处理 time: 4.335205078125 ms
模型推理 time: 2.6708984375 ms
面部检测 time: 12.37890625 ms
图像处理 time: 4.380615234375 ms
模型推理 time: 2.433837890625 ms
面部检测 time: 12.7021484375 ms
图像处理 time: 4.373046875 ms
模型推理 time: 2.898193359375 ms
面部检测 time: 15.355712890625 ms
图像处理 time: 4.758056640625 ms
模型推理 time: 3.4130859375 ms
面部检测 time: 15.278076171875 ms
图像处理 time: 4.89892578125 ms
模型推理 time: 3.731201171875 ms
面部检测 time: 15.106689453125 ms
图像处理 time: 5.12109375 ms
模型推理 time: 3.355224609375 ms
面部检测 time: 15.40283203125 ms
图像处理 time: 5.075927734375 ms
模型推理 time: 3.500244140625 ms
面部检测 time: 14.917724609375 ms
图像处理 time: 4.745849609375 ms
模型推理 time: 3.294189453125 ms
面部检测 time: 15.06689453125 ms
图像处理 time: 4.55908203125 ms
模型推理 time: 3.39501953125 ms
面部检测 time: 12.88818359375 ms
图像处理 time: 4.39599609375 ms
模型推理 time: 3.094970703125 ms
面部检测 time: 14.4169921875 ms
图像处理 time: 4.6298828125 ms
模型推理 time: 2.69482421875 ms
面部检测 time: 14.140869140625 ms
图像处理 time: 4.904296875 ms
模型推理 time: 2.97216796875 ms
面部检测 time: 14.491943359375 ms
图像处理 time: 4.390625 ms
模型推理 time: 3.21826171875 ms
面部检测 time: 14.902099609375 ms
图像处理 time: 4.35400390625 ms
模型推理 time: 3.033935546875 ms
面部检测 time: 14.581298828125 ms
图像处理 time: 4.35595703125 ms
模型推理 time: 3.61767578125 ms
面部检测 time: 15.982666015625 ms
图像处理 time: 4.829345703125 ms
模型推理 time: 3.51220703125 ms
面部检测 time: 13.41796875 ms
图像处理 time: 4.40380859375 ms
模型推理 time: 3.576171875 ms
面部检测 time: 13.524169921875 ms
图像处理 time: 4.299072265625 ms
模型推理 time: 3.462158203125 ms
面部检测 time: 15.56103515625 ms
图像处理 time: 4.76904296875 ms
模型推理 time: 3.940185546875 ms
面部检测 time: 15.31103515625 ms
图像处理 time: 4.8759765625 ms
模型推理 time: 3.364990234375 ms
面部检测 time: 13.590087890625 ms
图像处理 time: 4.572998046875 ms
模型推理 time: 3.409912109375 ms
面部检测 time: 15.52001953125 ms
图像处理 time: 4.59521484375 ms
模型推理 time: 3.677978515625 ms
面部检测 time: 14.90087890625 ms
图像处理 time: 4.448974609375 ms
模型推理 time: 3.134765625 ms
面部检测 time: 14.641845703125 ms
图像处理 time: 4.5751953125 ms
模型推理 time: 3.662841796875 ms
面部检测 time: 13.89208984375 ms
图像处理 time: 4.7197265625 ms
模型推理 time: 3.169921875 ms
面部检测 time: 14.931396484375 ms
图像处理 time: 4.51318359375 ms
模型推理 time: 3.278076171875 ms
面部检测 time: 14.707275390625 ms
图像处理 time: 4.406982421875 ms
模型推理 time: 3.2109375 ms
面部检测 time: 14.297119140625 ms
图像处理 time: 4.453125 ms
模型推理 time: 3.593017578125 ms
面部检测 time: 13.354248046875 ms
图像处理 time: 4.567626953125 ms
模型推理 time: 3.046142578125 ms
面部检测 time: 13.44677734375 ms
图像处理 time: 4.494873046875 ms
模型推理 time: 2.792724609375 ms
面部检测 time: 14.2060546875 ms
图像处理 time: 4.723876953125 ms
模型推理 time: 2.944091796875 ms
面部检测 time: 14.517822265625 ms
图像处理 time: 4.716064453125 ms
模型推理 time: 3.38134765625 ms
面部检测 time: 14.097900390625 ms
图像处理 time: 4.330078125 ms
模型推理 time: 3.2451171875 ms
面部检测 time: 15.30322265625 ms
图像处理 time: 4.743896484375 ms
模型推理 time: 3.43798828125 ms
面部检测 time: 14.019775390625 ms
图像处理 time: 4.499267578125 ms
模型推理 time: 2.619140625 ms
面部检测 time: 13.914794921875 ms
图像处理 time: 4.68505859375 ms
模型推理 time: 3.435791015625 ms
面部检测 time: 14.5712890625 ms
图像处理 time: 4.556884765625 ms
模型推理 time: 3.76904296875 ms
面部检测 time: 16.592041015625 ms
图像处理 time: 4.55419921875 ms
模型推理 time: 3.731201171875 ms
面部检测 time: 14.2158203125 ms
图像处理 time: 4.5361328125 ms
模型推理 time: 3.532958984375 ms
面部检测 time: 14.90087890625 ms
图像处理 time: 4.56103515625 ms
模型推理 time: 2.670166015625 ms
面部检测 time: 14.667236328125 ms
图像处理 time: 4.739990234375 ms
模型推理 time: 3.341796875 ms
面部检测 time: 12.383056640625 ms
图像处理 time: 4.366943359375 ms
模型推理 time: 3.543212890625 ms
面部检测 time: 13.761962890625 ms
图像处理 time: 4.834716796875 ms
模型推理 time: 3.682861328125 ms
面部检测 time: 12.8251953125 ms
图像处理 time: 4.605712890625 ms
模型推理 time: 3.546875 ms
面部检测 time: 13.666015625 ms
图像处理 time: 4.548828125 ms
模型推理 time: 3.856689453125 ms
面部检测 time: 13.179931640625 ms
图像处理 time: 4.592041015625 ms
模型推理 time: 3.419921875 ms
面部检测 time: 13.889892578125 ms
图像处理 time: 4.822998046875 ms
模型推理 time: 3.3271484375 ms
面部检测 time: 14.929931640625 ms
图像处理 time: 4.4990234375 ms
模型推理 time: 3.4609375 ms
面部检测 time: 12.183837890625 ms
图像处理 time: 4.373046875 ms
模型推理 time: 3.030029296875 ms
面部检测 time: 13.364990234375 ms
图像处理 time: 4.447021484375 ms
模型推理 time: 2.91796875 ms
面部检测 time: 14.576171875 ms
图像处理 time: 4.550048828125 ms
模型推理 time: 2.924072265625 ms
面部检测 time: 13.324951171875 ms
图像处理 time: 4.531005859375 ms
模型推理 time: 3.64794921875 ms
面部检测 time: 13.6357421875 ms
图像处理 time: 4.4931640625 ms
模型推理 time: 3.001953125 ms
面部检测 time: 13.908935546875 ms
图像处理 time: 4.494140625 ms
模型推理 time: 3.237060546875 ms
面部检测 time: 13.97705078125 ms
图像处理 time: 4.38671875 ms
模型推理 time: 3.06787109375 ms
面部检测 time: 13.4169921875 ms
图像处理 time: 4.3349609375 ms
模型推理 time: 2.38916015625 ms
面部检测 time: 13.83203125 ms
图像处理 time: 4.350830078125 ms
模型推理 time: 3.067138671875 ms
面部检测 time: 14.33203125 ms
图像处理 time: 4.3759765625 ms
模型推理 time: 3.639892578125 ms
面部检测 time: 15.213134765625 ms
图像处理 time: 4.959228515625 ms
模型推理 time: 3.72998046875 ms
面部检测 time: 15.22021484375 ms
图像处理 time: 4.7548828125 ms
模型推理 time: 3.85498046875 ms
面部检测 time: 15.97265625 ms
图像处理 time: 4.962890625 ms
模型推理 time: 3.673095703125 ms
面部检测 time: 14.69677734375 ms
图像处理 time: 4.46240234375 ms
模型推理 time: 3.153076171875 ms
面部检测 time: 12.538330078125 ms
图像处理 time: 4.345947265625 ms
模型推理 time: 2.9990234375 ms
面部检测 time: 13.802978515625 ms
图像处理 time: 4.250244140625 ms
模型推理 time: 2.477294921875 ms
面部检测 time: 12.607177734375 ms
图像处理 time: 4.23291015625 ms
模型推理 time: 2.573974609375 ms
面部检测 time: 12.444091796875 ms
图像处理 time: 4.34814453125 ms
模型推理 time: 2.567138671875 ms
面部检测 time: 14.427001953125 ms
图像处理 time: 4.5400390625 ms
模型推理 time: 2.93212890625 ms
面部检测 time: 12.92724609375 ms
图像处理 time: 4.501220703125 ms
模型推理 time: 3.306884765625 ms
面部检测 time: 12.722900390625 ms
图像处理 time: 4.361083984375 ms
模型推理 time: 2.717041015625 ms
面部检测 time: 13.269775390625 ms
图像处理 time: 4.7607421875 ms
模型推理 time: 3.572021484375 ms
面部检测 time: 13.2958984375 ms
图像处理 time: 4.7021484375 ms
模型推理 time: 2.847412109375 ms
面部检测 time: 12.77490234375 ms
图像处理 time: 4.43115234375 ms
模型推理 time: 3.30126953125 ms
面部检测 time: 12.2529296875 ms
图像处理 time: 4.31298828125 ms
模型推理 time: 2.911865234375 ms
面部检测 time: 13.030029296875 ms
图像处理 time: 4.52880859375 ms
模型推理 time: 2.977783203125 ms
面部检测 time: 12.47509765625 ms
图像处理 time: 4.68701171875 ms
模型推理 time: 2.927001953125 ms
面部检测 time: 13.68798828125 ms
图像处理 time: 4.890380859375 ms
模型推理 time: 3.1171875 ms
面部检测 time: 14.210205078125 ms
图像处理 time: 4.80712890625 ms
模型推理 time: 3.07275390625 ms
面部检测 time: 14.126953125 ms
图像处理 time: 4.766845703125 ms
模型推理 time: 2.86376953125 ms
面部检测 time: 14.1171875 ms
图像处理 time: 4.791015625 ms
模型推理 time: 3.2138671875 ms
面部检测 time: 14.55029296875 ms
图像处理 time: 4.73486328125 ms
模型推理 time: 3.036865234375 ms
面部检测 time: 14.7021484375 ms
图像处理 time: 4.72119140625 ms
模型推理 time: 3.448974609375 ms
面部检测 time: 14.651123046875 ms
图像处理 time: 4.852783203125 ms
模型推理 time: 3.11181640625 ms
面部检测 time: 15.593994140625 ms
图像处理 time: 4.9912109375 ms
模型推理 time: 2.945068359375 ms
面部检测 time: 15.11572265625 ms
图像处理 time: 4.820068359375 ms
模型推理 time: 3.14990234375 ms
面部检测 time: 12.97802734375 ms
图像处理 time: 4.638671875 ms
模型推理 time: 2.69287109375 ms
面部检测 time: 13.50927734375 ms
图像处理 time: 4.658203125 ms
模型推理 time: 3.065185546875 ms
面部检测 time: 15.60791015625 ms
图像处理 time: 4.914306640625 ms
模型推理 time: 3.242919921875 ms
面部检测 time: 14.890869140625 ms
图像处理 time: 4.8369140625 ms
模型推理 time: 3.31298828125 ms
面部检测 time: 14.06689453125 ms
图像处理 time: 4.688232421875 ms
模型推理 time: 3.202880859375 ms
面部检测 time: 12.81787109375 ms
图像处理 time: 4.601806640625 ms
模型推理 time: 3.195068359375 ms
面部检测 time: 13.474853515625 ms
图像处理 time: 4.48486328125 ms
模型推理 time: 3.251953125 ms
面部检测 time: 13.7958984375 ms
图像处理 time: 4.45263671875 ms
模型推理 time: 2.954833984375 ms
面部检测 time: 14.4248046875 ms
图像处理 time: 4.805908203125 ms
模型推理 time: 3.75 ms
面部检测 time: 14.9091796875 ms
图像处理 time: 5.073974609375 ms
模型推理 time: 3.6259765625 ms
面部检测 time: 15.76708984375 ms
图像处理 time: 4.668212890625 ms
模型推理 time: 3.451171875 ms
面部检测 time: 14.202880859375 ms
图像处理 time: 4.775146484375 ms
模型推理 time: 2.857666015625 ms
面部检测 time: 14.350830078125 ms
图像处理 time: 4.72802734375 ms
模型推理 time: 3.147216796875 ms
面部检测 time: 13.578857421875 ms
图像处理 time: 4.81982421875 ms
模型推理 time: 3.333984375 ms
面部检测 time: 13.215087890625 ms
图像处理 time: 4.3408203125 ms
模型推理 time: 3.224853515625 ms
面部检测 time: 12.572265625 ms
图像处理 time: 4.5400390625 ms
模型推理 time: 3.564697265625 ms
面部检测 time: 11.47021484375 ms
图像处理 time: 4.281982421875 ms
模型推理 time: 3.430908203125 ms
面部检测 time: 12.965087890625 ms
图像处理 time: 4.8681640625 ms
模型推理 time: 3.64208984375 ms
面部检测 time: 12.60986328125 ms
图像处理 time: 4.634033203125 ms
模型推理 time: 3.69287109375 ms
面部检测 time: 13.68212890625 ms
图像处理 time: 4.874267578125 ms
模型推理 time: 3.5927734375 ms
面部检测 time: 14.162109375 ms
图像处理 time: 4.615966796875 ms
模型推理 time: 3.44482421875 ms
面部检测 time: 13.625 ms
图像处理 time: 4.620849609375 ms
模型推理 time: 3.557373046875 ms
面部检测 time: 13.69189453125 ms
图像处理 time: 5.1279296875 ms
模型推理 time: 3.56298828125 ms
面部检测 time: 13.406005859375 ms
图像处理 time: 4.722900390625 ms
模型推理 time: 3.614013671875 ms
面部检测 time: 14.64208984375 ms
图像处理 time: 4.80810546875 ms
模型推理 time: 3.332763671875 ms
面部检测 time: 14.173828125 ms
图像处理 time: 4.994873046875 ms
模型推理 time: 3.18994140625 ms
面部检测 time: 13.968994140625 ms
图像处理 time: 4.64404296875 ms
模型推理 time: 3.406982421875 ms
面部检测 time: 13.404296875 ms
图像处理 time: 4.85205078125 ms
模型推理 time: 3.56884765625 ms
面部检测 time: 12.714111328125 ms
图像处理 time: 4.5400390625 ms
模型推理 time: 3.261962890625 ms
面部检测 time: 14.14990234375 ms
图像处理 time: 4.63525390625 ms
模型推理 time: 3.508056640625 ms
面部检测 time: 13.01318359375 ms
图像处理 time: 4.5 ms
模型推理 time: 3.046142578125 ms
面部检测 time: 12.01123046875 ms
图像处理 time: 4.57080078125 ms
模型推理 time: 3.263916015625 ms
面部检测 time: 12.546875 ms
图像处理 time: 4.573974609375 ms
模型推理 time: 3.788818359375 ms
面部检测 time: 135.3369140625 ms
面部检测 time: 104.14892578125 ms
面部检测 time: 38.718017578125 ms
面部检测 time: 73.0048828125 ms
图像处理 time: 4.7998046875 ms
图像处理 time: 6.068115234375 ms
模型推理 time: 1.981201171875 ms
图像处理 time: 5.75 ms
模型推理 time: 3.553955078125 ms
图像处理 time: 5.8447265625 ms
模型推理 time: 2.80908203125 ms
面部检测 time: 13.981689453125 ms
模型推理 time: 2.282958984375 ms
图像处理 time: 2.817138671875 ms
模型推理 time: 3.393798828125 ms
面部检测 time: 9.617431640625 ms
图像处理 time: 3.02783203125 ms
模型推理 time: 2.51904296875 ms
面部检测 time: 10.078857421875 ms
图像处理 time: 3.3271484375 ms
模型推理 time: 2.997802734375 ms
面部检测 time: 10.1728515625 ms
图像处理 time: 3.3291015625 ms
模型推理 time: 2.436767578125 ms
面部检测 time: 10.02880859375 ms
图像处理 time: 3.5390625 ms
模型推理 time: 2.87109375 ms
面部检测 time: 10.323974609375 ms
图像处理 time: 3.573974609375 ms
模型推理 time: 3.045166015625 ms
面部检测 time: 10.954833984375 ms
图像处理 time: 3.55712890625 ms
模型推理 time: 2.874755859375 ms
面部检测 time: 11.27783203125 ms
图像处理 time: 4.239990234375 ms
模型推理 time: 3.487060546875 ms
面部检测 time: 11.826904296875 ms
图像处理 time: 4.08984375 ms
模型推理 time: 2.822998046875 ms
面部检测 time: 12.14990234375 ms
图像处理 time: 4.137939453125 ms
模型推理 time: 3.556884765625 ms
面部检测 time: 11.656005859375 ms
图像处理 time: 4.766845703125 ms
模型推理 time: 3.0400390625 ms
面部检测 time: 13.450927734375 ms
图像处理 time: 4.328125 ms
模型推理 time: 3.329833984375 ms
面部检测 time: 12.63720703125 ms
图像处理 time: 4.426025390625 ms
模型推理 time: 3.6591796875 ms
面部检测 time: 13.255126953125 ms
图像处理 time: 4.56103515625 ms
模型推理 time: 3.386962890625 ms
面部检测 time: 13.1552734375 ms
图像处理 time: 4.509033203125 ms
模型推理 time: 3.360107421875 ms
面部检测 time: 14.226806640625 ms
图像处理 time: 4.567138671875 ms
模型推理 time: 3.2431640625 ms
面部检测 time: 12.317138671875 ms
图像处理 time: 4.7490234375 ms
模型推理 time: 3.124755859375 ms
面部检测 time: 13.084228515625 ms
图像处理 time: 4.48291015625 ms
模型推理 time: 3.370849609375 ms
面部检测 time: 12.58935546875 ms
图像处理 time: 4.855224609375 ms
模型推理 time: 3.7177734375 ms
面部检测 time: 13.55419921875 ms
图像处理 time: 4.673095703125 ms
模型推理 time: 3.093994140625 ms
面部检测 time: 12.76611328125 ms
图像处理 time: 4.670166015625 ms
模型推理 time: 3.366943359375 ms
面部检测 time: 12.526123046875 ms
图像处理 time: 4.68310546875 ms
模型推理 time: 3.251953125 ms
面部检测 time: 13.807861328125 ms
图像处理 time: 4.707763671875 ms
模型推理 time: 3.6318359375 ms
面部检测 time: 12.73291015625 ms
图像处理 time: 4.9130859375 ms
模型推理 time: 3.17578125 ms
面部检测 time: 13.39404296875 ms
图像处理 time: 4.505859375 ms
模型推理 time: 3.802978515625 ms
面部检测 time: 13.46484375 ms
图像处理 time: 4.676025390625 ms
模型推理 time: 3.305908203125 ms
面部检测 time: 12.81201171875 ms
图像处理 time: 4.406982421875 ms
模型推理 time: 3.465087890625 ms
面部检测 time: 14.501953125 ms
图像处理 time: 4.468994140625 ms
模型推理 time: 3.42822265625 ms
面部检测 time: 12.591796875 ms
图像处理 time: 4.610107421875 ms
模型推理 time: 3.22998046875 ms
面部检测 time: 14.429931640625 ms
图像处理 time: 4.8671875 ms
模型推理 time: 3.65478515625 ms
面部检测 time: 14.3037109375 ms
图像处理 time: 4.4580078125 ms
模型推理 time: 3.362060546875 ms
面部检测 time: 13.009033203125 ms
图像处理 time: 4.52099609375 ms
模型推理 time: 3.173095703125 ms
面部检测 time: 13.39501953125 ms
图像处理 time: 4.656982421875 ms
模型推理 time: 2.7021484375 ms
面部检测 time: 13.678955078125 ms
图像处理 time: 4.522705078125 ms
模型推理 time: 3.50439453125 ms
面部检测 time: 13.573974609375 ms
图像处理 time: 4.572021484375 ms
模型推理 time: 3.58984375 ms
面部检测 time: 13.946044921875 ms
图像处理 time: 4.556884765625 ms
模型推理 time: 3.468017578125 ms
面部检测 time: 13.337890625 ms
图像处理 time: 5.112060546875 ms
模型推理 time: 3.706787109375 ms
面部检测 time: 15.27392578125 ms
图像处理 time: 4.93505859375 ms
模型推理 time: 3.390869140625 ms
面部检测 time: 14.006103515625 ms
图像处理 time: 4.668701171875 ms
模型推理 time: 3.412841796875 ms
面部检测 time: 15.451904296875 ms
图像处理 time: 4.59814453125 ms
模型推理 time: 3.2998046875 ms
面部检测 time: 13.822998046875 ms
图像处理 time: 4.751953125 ms
模型推理 time: 2.540283203125 ms
面部检测 time: 13.11181640625 ms
图像处理 time: 5.050048828125 ms
模型推理 time: 3.27294921875 ms
面部检测 time: 14.746826171875 ms
图像处理 time: 4.81591796875 ms
模型推理 time: 3.18115234375 ms
面部检测 time: 13.560791015625 ms
图像处理 time: 4.644287109375 ms
模型推理 time: 3.156005859375 ms
面部检测 time: 13.317138671875 ms
图像处理 time: 4.60791015625 ms
模型推理 time: 3.341064453125 ms
面部检测 time: 14.142822265625 ms
图像处理 time: 4.766845703125 ms
模型推理 time: 3.202880859375 ms
面部检测 time: 12.668212890625 ms
图像处理 time: 4.677001953125 ms
模型推理 time: 3.24609375 ms
面部检测 time: 14.807861328125 ms
图像处理 time: 4.808837890625 ms
模型推理 time: 3.31494140625 ms
面部检测 time: 14.456787109375 ms
图像处理 time: 4.94189453125 ms
模型推理 time: 3.576171875 ms
面部检测 time: 13.72998046875 ms
图像处理 time: 4.61669921875 ms
模型推理 time: 3.35498046875 ms
面部检测 time: 15.331298828125 ms
图像处理 time: 4.883056640625 ms
模型推理 time: 3.544921875 ms
面部检测 time: 14.311767578125 ms
图像处理 time: 4.627685546875 ms
模型推理 time: 3.347900390625 ms
面部检测 time: 13.6259765625 ms
图像处理 time: 4.51416015625 ms
模型推理 time: 3.48388671875 ms
面部检测 time: 12.828369140625 ms
图像处理 time: 4.4677734375 ms
模型推理 time: 3.601806640625 ms
面部检测 time: 12.26318359375 ms
图像处理 time: 4.580078125 ms
模型推理 time: 3.09521484375 ms
面部检测 time: 13.270263671875 ms
图像处理 time: 4.641845703125 ms
模型推理 time: 3.6572265625 ms
面部检测 time: 12.837890625 ms
图像处理 time: 4.8740234375 ms
模型推理 time: 3.60302734375 ms
面部检测 time: 13.251953125 ms
图像处理 time: 4.690185546875 ms
模型推理 time: 3.697021484375 ms
面部检测 time: 13.428955078125 ms
图像处理 time: 4.759765625 ms
模型推理 time: 3.19091796875 ms
面部检测 time: 14.553955078125 ms
图像处理 time: 4.5810546875 ms
模型推理 time: 3.35400390625 ms
面部检测 time: 12.881103515625 ms
图像处理 time: 4.607177734375 ms
模型推理 time: 3.341064453125 ms
面部检测 time: 13.419921875 ms
图像处理 time: 4.68408203125 ms
模型推理 time: 3.834228515625 ms
面部检测 time: 14.2861328125 ms
图像处理 time: 4.55712890625 ms
模型推理 time: 3.424072265625 ms
面部检测 time: 13.4619140625 ms
图像处理 time: 4.47998046875 ms
模型推理 time: 3.734130859375 ms
面部检测 time: 13.52880859375 ms
图像处理 time: 4.537109375 ms
模型推理 time: 3.14794921875 ms
面部检测 time: 14.369140625 ms
图像处理 time: 4.547119140625 ms
模型推理 time: 3.509033203125 ms
面部检测 time: 14.59912109375 ms
图像处理 time: 4.256103515625 ms
模型推理 time: 3.257080078125 ms
面部检测 time: 13.22119140625 ms
图像处理 time: 4.488037109375 ms
模型推理 time: 3.552734375 ms
面部检测 time: 13.47705078125 ms
图像处理 time: 4.502685546875 ms
模型推理 time: 3.43408203125 ms
面部检测 time: 13.23779296875 ms
图像处理 time: 4.5458984375 ms
模型推理 time: 3.29296875 ms
面部检测 time: 14.23681640625 ms
图像处理 time: 4.435791015625 ms
模型推理 time: 3.4189453125 ms
面部检测 time: 14.77197265625 ms
图像处理 time: 4.88671875 ms
模型推理 time: 3.379638671875 ms
面部检测 time: 12.0390625 ms
图像处理 time: 4.405029296875 ms
模型推理 time: 3.51806640625 ms
面部检测 time: 12.66796875 ms
图像处理 time: 4.548095703125 ms
模型推理 time: 3.406982421875 ms
面部检测 time: 12.802001953125 ms
图像处理 time: 4.572021484375 ms
模型推理 time: 3.553955078125 ms
面部检测 time: 14.669921875 ms
图像处理 time: 4.942138671875 ms
模型推理 time: 3.163818359375 ms
面部检测 time: 13.75927734375 ms
图像处理 time: 4.64794921875 ms
模型推理 time: 3.537109375 ms
面部检测 time: 13.869140625 ms
图像处理 time: 4.625 ms
模型推理 time: 3.43310546875 ms
面部检测 time: 13.051025390625 ms
图像处理 time: 4.653076171875 ms
模型推理 time: 3.698974609375 ms
面部检测 time: 13.80078125 ms
图像处理 time: 4.76611328125 ms
模型推理 time: 3.4580078125 ms
面部检测 time: 14.96484375 ms
图像处理 time: 4.950927734375 ms
模型推理 time: 3.699951171875 ms
面部检测 time: 15.122802734375 ms
图像处理 time: 4.939208984375 ms
模型推理 time: 3.410888671875 ms
面部检测 time: 14.81103515625 ms
图像处理 time: 4.501953125 ms
模型推理 time: 3.55615234375 ms
面部检测 time: 13.314697265625 ms
图像处理 time: 4.38427734375 ms
模型推理 time: 3.405029296875 ms
面部检测 time: 12.714111328125 ms
图像处理 time: 4.097900390625 ms
模型推理 time: 3.55419921875 ms
面部检测 time: 12.77294921875 ms
图像处理 time: 4.382080078125 ms
模型推理 time: 3.187255859375 ms
面部检测 time: 13.294921875 ms
图像处理 time: 4.55517578125 ms
模型推理 time: 3.171142578125 ms
面部检测 time: 12.43408203125 ms
图像处理 time: 4.52587890625 ms
模型推理 time: 2.72802734375 ms
面部检测 time: 12.780029296875 ms
图像处理 time: 4.43505859375 ms
模型推理 time: 2.951904296875 ms
面部检测 time: 13.30419921875 ms
图像处理 time: 4.6298828125 ms
模型推理 time: 2.875 ms
面部检测 time: 12.35888671875 ms
图像处理 time: 4.421875 ms
模型推理 time: 2.900146484375 ms
面部检测 time: 12.1943359375 ms
图像处理 time: 4.507080078125 ms
模型推理 time: 2.537841796875 ms
面部检测 time: 14.48388671875 ms
图像处理 time: 4.85693359375 ms
模型推理 time: 2.932861328125 ms
面部检测 time: 12.71728515625 ms
图像处理 time: 4.6279296875 ms
模型推理 time: 2.51904296875 ms
面部检测 time: 13.964111328125 ms
图像处理 time: 4.75830078125 ms
模型推理 time: 2.912109375 ms
面部检测 time: 13.655517578125 ms
图像处理 time: 4.86181640625 ms
模型推理 time: 2.851806640625 ms
面部检测 time: 13.776611328125 ms
图像处理 time: 5.126953125 ms
模型推理 time: 3.10498046875 ms
面部检测 time: 13.05517578125 ms
图像处理 time: 4.26611328125 ms
模型推理 time: 2.953125 ms
面部检测 time: 13.301025390625 ms
图像处理 time: 4.46142578125 ms
模型推理 time: 2.959228515625 ms
面部检测 time: 12.266845703125 ms
图像处理 time: 4.376953125 ms
模型推理 time: 3.06884765625 ms
面部检测 time: 13.59716796875 ms
图像处理 time: 4.479736328125 ms
模型推理 time: 3.311279296875 ms
面部检测 time: 13.504150390625 ms
图像处理 time: 4.71728515625 ms
模型推理 time: 3.60693359375 ms
面部检测 time: 13.6708984375 ms
图像处理 time: 4.5146484375 ms
模型推理 time: 3.296875 ms
面部检测 time: 12.984130859375 ms
图像处理 time: 4.48291015625 ms
模型推理 time: 3.2509765625 ms
面部检测 time: 13.512939453125 ms
图像处理 time: 4.3818359375 ms
模型推理 time: 2.953857421875 ms
面部检测 time: 12.4912109375 ms
图像处理 time: 4.580810546875 ms
模型推理 time: 2.403076171875 ms
"""

# 定义正则表达式模式以匹配每种时间类型
pattern = re.compile(r"(模型加载 time|面部检测 time|图像处理 time|模型推理 time): ([\d.]+) ms")

# 存储每种时间的值
times = defaultdict(list)

# 匹配日志数据并分类存储时间
for match in pattern.findall(log_data):
    category, time = match
    times[category].append(float(time))

# 计算每种时间的平均值
averages = {category: sum(values) / len(values) for category, values in times.items()}

# 打印结果
for category, avg_time in averages.items():
    print(f"{category}: {avg_time:.3f} ms")