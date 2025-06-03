# YOLOv5 🚀 by Ultralytics, GPL-3.0 license
"""
Pipeline
1. BusPanelDetection: Input image --> DL Model --> Bus panel --> cropped bus panel image
2. BusNumberDetection: Cropped_bus_panel_image --> DL Model --> Bus number (Alpha Numeric)
3. ImproveTheAccuracy: Filtering detections within the AOI --> Sorting the bounding boxes 
  --> Text sequence matching with whitelist --> Voting to get the final prediction.
"""

from collections import Counter
from ultralytics import YOLO
import pandas as pd
import numpy as np
import torch
import yaml
import json
import cv2
import time
import traceback

dataJson = {
    'imageData': {
        'imageName': None,
        'imageDimension': None, 
        'imageResolution': None,
        'prediction': None,
        'timeStamp': None,
        'featureType': None
    },
    'processingData': {
        'ProcessingTime': None,
        'CPUResourceUti': None
    }, 
    'userData': {
        'geoLocation': None,
        'timeZone': None
    }}

with open('data/alphanumeric.yaml', 'r') as file:
    yaml_data = yaml.safe_load(file)
# Class names for busnumber model
category_dict = yaml_data['names']
# Loading the whitelist of all the buses in HK
df = pd.read_csv('data/whitelist.csv')
whitelist = df.Bus_Number.to_list()

def load_models():
    # Load model
    busPanel_model = torch.hub.load('ultralytics/yolov5', 'custom', path='weights/bus_panel.pt')
    busNumber_model = torch.hub.load('ultralytics/yolov5', 'custom', path='weights/bus_number.pt')
    busNumber_model_v8 = YOLO('weights/busNum_yolov8.pt')  # pretrained YOLOv8n model
    busNumber_model.amp = True
    busPanel_model.amp = True
    return busPanel_model, busNumber_model, busNumber_model_v8

def check_withinRange(half_image_bb, number_bb, text_list):
    """ We further crop the cropped_buspanel_image to reduce our search area (bus number are present on rightside of bus panel) 
        Filter the bounding box predictions that are within the AOI (cropped image range) """ 
    final_bblist = []
    new_text_list = []
    for idx, num_bb in enumerate(number_bb):
        if (num_bb[0] > half_image_bb[0]) & (num_bb[0] < half_image_bb[2]):
            final_bblist.append(num_bb)
            new_text_list.append(category_dict[text_list[idx]])
        else:
            continue
    return final_bblist, new_text_list

def sorting_boundingbox(bbox_list, text_list):
    """ Sorting the bounding boxes based on its location (x,y) (as the final prediction is jumbled) """
    n = len(bbox_list)     
    for i in range(n-1):
        for j in range(0, n-i-1):
            if bbox_list[j][0] > bbox_list[j+1][0]:
                bbox_list[j], bbox_list[j + 1] = bbox_list[j + 1], bbox_list[j]
                text_list[j], text_list[j+1] = text_list[j+1], text_list[j]
    text_list = ''.join(str(x) for x in text_list)
    return text_list, bbox_list

def busnumber_detection(img_list, busPanel_model, busNumber_model, start_time):
    """ Buspanel and Busnumber detection """
    text_list = []
    dataJson['imageData']['prediction'] = {'buspanel': [], 'busnumber': []}
    for idx, img in enumerate(img_list):
        # Detecting bus panel
        busPanel = busPanel_model(img)
        pred_busPanel = busPanel.pred[0].tolist()
        text_on_image = []
        # If bus panel is detected
        if pred_busPanel:
            for j in pred_busPanel:
                # Saving the metadata
                dict_1 = {'class_id': None, 'name': None, 'coords': None, 'conf': None }
                x1, y1, x2, y2, conf, class_id = j
                dict_1['class_id'], dict_1['name'], dict_1['coords'], dict_1['conf'] = class_id, 'buspanel', [x1, y1, x2, y2], conf
                dataJson['imageData']['prediction']['buspanel'].append(dict_1)
                if conf > 0.7:
                    cropped_image = img[int(y1):int(y2), int(x1):int(x2)]
                    # Detecting bus number
                    busNumber = busNumber_model(cropped_image)
                    pred_busNum = busNumber.pred[0]
                    dict_2 = {'class_id': None, 'name': None, 'coords': None}
                    boxes_number = pred_busNum[:, :4].tolist()
                    # Cropping to get the AOI
                    height, width = cropped_image.shape[0], cropped_image.shape[1]
                    crpd_bb = [int(width/2), 0, width, height]
                    cate_number = pred_busNum[:, 5].tolist()
                    # Filter the bbox within the AOI
                    list_bbox, list_text = check_withinRange(crpd_bb, boxes_number, cate_number)
                    # Sorting the bounding box
                    pred_text, bb_list = sorting_boundingbox(list_bbox, list_text)
                    dict_2['class_id'], dict_2['name'], dict_2['coords'] = cate_number, pred_text, bb_list
                    dataJson['imageData']['prediction']['busnumber'].append(dict_2)
                    if pred_text: text_list.append(pred_text)
                    # Getting the most common detected bus number (voting)
                    if True:  # ((idx+1)%3 == 0) or ((idx+1)%1  == 0):
                        if text_list:
                            text_new_list = [item for item in text_list if item]
                            vote = Counter(text_new_list)
                            final_text = vote.most_common()[0][0]
                            if not final_text:
                                text_on_image.append('No detection') 
                            else:
                                # Checking whether the predicted number is in whitelist or not
                                text_matching_list = ["Yes" if x in final_text else "No" for x in whitelist]
                                if all(x == "No" for x in text_matching_list):
                                    text_on_image.append("Bus number " + final_text+ " is approaching.") ### Changes made here ###
                                else:
                                    text_matching_index = [idx for idx, value in enumerate(text_matching_list) if value == 'Yes']
                                    text_on_image.append("Bus number " + whitelist[text_matching_index[-1]]+ " is approaching.")  
                            text_list.clear() 
                        else:
                            text_on_image.append('No detection') 
                    else:
                        text_on_image.append('No detection') 
        else:
            text_on_image.append('No bus is approaching')
        end_time = time.perf_counter()

        latency = end_time - start_time
        current_time = time.localtime()
        current_month = time.strftime('%Y-%m', current_time)
        current_date = time.strftime('%Y-%m-%d', current_time)
        pred_class = text_on_image[11:15]
        imageName = f'{current_month}/{current_date}/{str(start_time)}_{str(pred_class)}_{str(latency)}'

        dataJson['imageData']['imageName'] = imageName
        dataJson['imageData']['imageDimension'] = img_list[0].shape
        dataJson['imageData']['featureType'] = 'busnumber detection'
        dataJson['imageData']['timeStamp'] = str(start_time)
        dataJson['processingData']['ProcessingTime'] = str(latency)

        print("Processing time at the backend: ", latency)
        print("text_on_image: ", text_on_image)
    return json.dumps(text_on_image), dataJson

def busnumber_detection_batched(img_list, busPanel_model, busNumber_model, start_time):
    """ Buspanel and Busnumber detection, batched """
    text_on_image = []
    text_list = []
    busPanelsAll = busPanel_model(img_list)
    end_bus = time.perf_counter()
    dataJson['imageData']['prediction'] = {'buspanel': [], 'busnumber': []}
    start_buspanel = time.perf_counter()
    for idx, busPanel in enumerate(busPanelsAll.pred):
        # Detecting bus panel
        img = img_list[idx]
        # For all images in img_list, get x1, y1, x2, y2, conf, class_id
        pred_busPanel = busPanel.tolist()# busPanel.pred[0].tolist()
        # If bus panel is detected
        if pred_busPanel:
            for j in pred_busPanel:
                x1, y1, x2, y2, conf, class_id = j
                dict_1 = {'class_id': None, 'name': None, 'coords': None, 'conf': None }
                dict_1['class_id'], dict_1['name'], dict_1['coords'], dict_1['conf'] = class_id, 'buspanel', [x1, y1, x2, y2], conf
                dataJson['imageData']['prediction']['buspanel'].append(dict_1)
                if conf > 0.7:
                    cropped_image = img[int(y1):int(y2), int(x1):int(x2)]
                    # Detecting bus number
                    busNumber = busNumber_model(cropped_image)
                    dict_2 = {'class_id': None, 'name': None, 'coords': None}
                    for result in busNumber:
                        cate_number = result.boxes.cls.tolist()
                        boxes_number = result.boxes.xyxy.tolist()
                    # Cropping to get the AOI
                    height, width = cropped_image.shape[0], cropped_image.shape[1]
                    crpd_bb = [int(width/2), 0, width, height]
                    # Filter the bbox within the AOI
                    list_bbox, list_text = check_withinRange(crpd_bb, boxes_number, cate_number)
                    # Sorting the bounding box
                    pred_text, bb_list = sorting_boundingbox(list_bbox, list_text)
                    dict_2['class_id'], dict_2['name'], dict_2['coords'] = cate_number, pred_text, bb_list
                    dataJson['imageData']['prediction']['busnumber'].append(dict_2)
                    if pred_text: text_list.append(pred_text)
        else:
            text_on_image.append("No bus is approaching.")
    end_buspanel = time.perf_counter()
    start_text = time.perf_counter()
    if text_list:
        text_new_list = [item for item in text_list if item]
        vote = Counter(text_new_list)
        final_text = vote.most_common()[0][0]
        if not final_text:
            text_on_image.append('No detection') 
        else:
            text_matching_list = ["Yes" if x in final_text else "No" for x in whitelist]
            if all(x == "No" for x in text_matching_list):
                text_on_image.append("Bus number " + final_text+ " is approaching.") ### Changes made here ###
            else:
                text_matching_index = [idx for idx, value in enumerate(text_matching_list) if value == 'Yes']
                text_on_image.append("Bus number " + whitelist[text_matching_index[-1]]+ " is approaching.") 
    else:
        text_on_image.append('No detection') 

    end_time = time.perf_counter()
    latency = round(end_time - start_time, 3)
    current_time = time.localtime()
    current_month = time.strftime('%Y-%m', current_time)
    current_date = time.strftime('%Y-%m-%d', current_time)
    pred_class = text_on_image[11:15]
    imageName = f'{current_month}/{current_date}/{str(start_time)}_{str(pred_class)}_{str(latency)}'

    dataJson['imageData']['imageName'] = imageName
    dataJson['imageData']['imageDimension'] = img_list[0].shape
    dataJson['imageData']['featureType'] = 'busnumber detection'
    dataJson['imageData']['timeStamp'] = str(start_time)
    dataJson['processingData']['ProcessingTime'] = str(latency)
    
    print("Bus panel detection time: ", round(end_bus - start_time,3))
    print("Bus number detection time: ", round(end_buspanel - start_buspanel,3))
    print("Post porcessing the text time: ", round(end_time - start_text, 3))
    print("Overall processing time at the backend: ", latency)
    print("text_on_image: ", text_on_image)
    return json.dumps(text_on_image), dataJson
    
 