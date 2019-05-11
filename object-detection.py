import numpy as np
import os
import six.moves.urllib as urllib
import sys
import tarfile
import tensorflow as tf
import zipfile
 
from collections import defaultdict
from io import StringIO
from matplotlib import pyplot as plt
from PIL import Image
 
import cv2
cap = cv2.VideoCapture("rtsp://192.168.1.191:8554/unicast")

## Limiting 
cap.set(3, 640)
cap.set(4, 480)
cap.set(cv2.CAP_PROP_FPS, 1)

sys.path.append("..")
 
from object_detection.utils import label_map_util
 
from object_detection.utils import visualization_utils as vis_util
 
MODEL_NAME = 'ssd_mobilenet_v1_coco_11_06_2017'
MODEL_FILE = MODEL_NAME + '.tar.gz'
DOWNLOAD_BASE = 'http://download.tensorflow.org/models/object_detection/'
 
# Path to frozen detection graph. This is the actual model that is used for the object detection.
PATH_TO_CKPT = 'data/ssd_inception_v2_coco_trt.pb'
 
# List of the strings that is used to add correct label for each box.
PATH_TO_LABELS = os.path.join('data', 'mscoco_label_map.pbtxt')
 
NUM_CLASSES = 90
 
# opener = urllib.request.URLopener()
# opener.retrieve(DOWNLOAD_BASE + MODEL_FILE, MODEL_FILE)
# tar_file = tarfile.open(MODEL_FILE)
# for file in tar_file.getmembers():
# 	file_name = os.path.basename(file.name)
# 	if 'frozen_inference_graph.pb' in file_name:
# 		tar_file.extract(file, os.getcwd())
 
trt_graph = tf.GraphDef()
with tf.gfile.GFile(PATH_TO_CKPT, 'rb') as fid:
	serialized_graph = fid.read()
	trt_graph.ParseFromString(serialized_graph)
	tf.import_graph_def(trt_graph, name='')
 
label_map = label_map_util.load_labelmap(PATH_TO_LABELS)
categories = label_map_util.convert_label_map_to_categories(label_map, max_num_classes=NUM_CLASSES, use_display_name=True)
category_index = label_map_util.create_category_index(categories)
 
config = tf.ConfigProto()
config.gpu_options.allow_growth = True
config.gpu_options.per_process_gpu_memory_fraction = 0.4


with detection_graph.as_default():
	with tf.Session(graph=detection_graph, config=config) as sess:
		tf.import_graph_def(trt_graph, name='')
		image_tensor = detection_graph.get_tensor_by_name('image_tensor:0')
		# Each box represents a part of the image where a particular object was detected.
		boxes = detection_graph.get_tensor_by_name('detection_boxes:0')
		# Each score represent how level of confidence for each of the objects.
		# Score is shown on the result image, together with the class label.
		scores = detection_graph.get_tensor_by_name('detection_scores:0')
		classes = detection_graph.get_tensor_by_name('detection_classes:0')
		num_detections = detection_graph.get_tensor_by_name('num_detections:0')

		while True:
			ret, image_np = cap.read()
			image_np = cv2.flip(image_np, -1)
			# Expand dimensions since the model expects images to have shape: [1, None, None, 3]
			image_np_expanded = np.array(image_np.resize((300, 300)))

			# Actual detection.
			(boxes, scores, classes, num_detections) = sess.run(
			[boxes, scores, classes, num_detections],
			feed_dict={image_tensor: image_np_expanded})
			# Visualization of the results of a detection.
			print(classes[0])
			# vis_util.visualize_boxes_and_labels_on_image_array(
			# 	image_np,
			# 	np.squeeze(boxes),
			# 	np.squeeze(classes).astype(np.int32),
			# 	np.squeeze(scores),
			# 	category_index,
			# 	use_normalized_coordinates=True,
			# 	line_thickness=8)

			cv2.imshow('object detection', cv2.resize(image_np, (800,600)))
			if cv2.waitKey(25) & 0xFF == ord('q'):
				cv2.destroyAllWindows()
				break