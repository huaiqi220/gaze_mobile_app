import coremltools as ct
import numpy as np



model_path = "../../VisionDetection/model/aff_net_ma.mlpackage"
model = ct.models.MLModel(model_path)

# 2. 打印模型的输入和输出信息
print("Model inputs:", model.input_description)
print("Model outputs:", model.output_description)