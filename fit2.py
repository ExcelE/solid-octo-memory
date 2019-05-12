from PIL import Image
import sys, cv2
import os
import urllib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import tensorflow as tf
import numpy as np
import time

from imutils.video import FileVideoStream
from imutils.video import FPS
import imutils

import tensorflow.contrib.tensorrt as trt
###


PATH_TO_CKPT = 'data/frozen_inference_graph.pb'
trt_graph = tf.GraphDef()
with tf.gfile.GFile(PATH_TO_CKPT, 'rb') as fid:
	serialized_graph = fid.read()
	trt_graph.ParseFromString(serialized_graph)

tf_config = tf.ConfigProto()
tf_config.gpu_options.allow_growth = True
# tf_config.gpu_options.per_process_gpu_memory_fraction = 0.4

tf_sess = tf.Session(config=tf_config)

tf.import_graph_def(trt_graph, name='')

tf_input = tf_sess.graph.get_tensor_by_name('image_tensor:0')
tf_scores = tf_sess.graph.get_tensor_by_name('detection_scores:0')
tf_boxes = tf_sess.graph.get_tensor_by_name('detection_boxes:0')
tf_classes = tf_sess.graph.get_tensor_by_name('detection_classes:0')
tf_num_detections = tf_sess.graph.get_tensor_by_name('num_detections:0')

## RTSP Stream

# fvs = FileVideoStream('rtsp://192.168.1.191:8554/unicast').start()

fvs = cv2.VideoCapture('rtsp://192.168.1.191:8554/unicast')

while fvs.isOpened():
	ret, frame = fvs.read()
	# frame = imutils.resize(frame, width=450)
	# frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	# frame = np.dstack([frame, frame, frame])

	image_np_expanded = np.expand_dims(frame, axis=0)

	# image_resized = cv2.resize(frame, (300, 300), interpolation = cv2.INTER_LINEAR)
	scores, boxes, classes, num_detections = tf_sess.run([tf_scores, tf_boxes, tf_classes, tf_num_detections], feed_dict={
		tf_input: image_np_expanded
		# tf_input: image_resized[None, ...]
	})

	boxes = boxes[0] # index by 0 to remove batch dimension
	scores = scores[0]
	classes = classes[0]
	num_detections = num_detections[0]

	print(classes[0])

	# cv2.imshow('object detection', cv2.resize(frame, (800,600)))
	cv2.imshow('object detection', frame)
	if cv2.waitKey(1) & 0xFF == ord('q'):
		break

# fvs.stop()
fvs.release()
cv2.destroyAllWindows()
tf_sess.close()
print("Cleaning up done")
