import numpy as np
from PIL import Image, ImageDraw
import tkinter as tk
import cv2
import socket

def calculate_vector(p1, p2):
    return [p2[0] - p1[0], p2[1] - p1[1]]


if __name__ == '__main__':
    # internet set-up
    UDP_IP = "127.0.0.1"
    UDP_PORT = 5005
    MESSAGE = b"Hello, World!"

    print("UDP target IP: %s" % UDP_IP)
    print("UDP target port: %s" % UDP_PORT)
    print("message: %s" % MESSAGE)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    #sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))

    # turn on cam
    webcam = cv2.VideoCapture(0, cv2.CAP_DSHOW) 

    cubic_rate = 0.3

    no_ball_count = 0
    active_ball_count = 0
    no_ball_limit = 10
    active_ball_limit = 3

    active_ball = False

    active_ball_coords = []
    unactive_ball_coords = []
    added_balls = 0

    found_ball = False

    _, imageFrame = webcam.read()
    cam_height, cam_width = imageFrame.shape[:2]

    #ball = canvas.create_oval(100, 0, 130, 30, outline="red", fill="white", width=4)

    while (1):

        #if(len(active_ball_coords) > 2):
            #print("vector: ", calculate_vector(active_ball_coords[added_balls-1], active_ball_coords[added_balls-2]))

        # If not active ball, and found ball for a while
        if(not active_ball and active_ball_count > active_ball_limit):
            active_ball = True
        # If active ball, and no ball found for a while
        if(active_ball and no_ball_count > no_ball_limit):
            active_ball = False
            active_ball_coords = []
            unactive_ball_coords = []
            active_ball_count = 0
            added_balls = 0
        
        # Reset
        found_ball = False

        # Read webcam
        _, imageFrame = webcam.read()
        #height, width = imageFrame.shape[:2]
        #imageFrame = crop = imageFrame[50:height-50, 50:width-50]  
        # # black color
        # res_black = cv2.bitwise_and(imageFrame, imageFrame, mask=black_mask)
        im_gray = cv2.cvtColor(imageFrame, cv2.COLOR_BGR2GRAY)

        im_bw = cv2.threshold(im_gray, 40, 255, cv2.THRESH_BINARY)[1]


        img_gray = cv2.medianBlur(im_gray,5)
        img = cv2.medianBlur(im_bw,5)
        height, width = img.shape[:2]
        assert img is not None, "uuh failure"
        #gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY);
        
        #circles = cv2.HoughCircles(gray, cv2.HOUGH_GRADIENT, 2, 10)
        contours, hierarchy = cv2.findContours(img,
                                            cv2.RETR_TREE,
                                            cv2.CHAIN_APPROX_SIMPLE)
        
        for pic, contour in enumerate(contours):
            area = cv2.contourArea(contour)
            if (area > 100):
                x, y, w, h = cv2.boundingRect(contour)
                
                # Check if it is a cube-ish
                if(w/h < 1 + cubic_rate and w/h > 1 - cubic_rate):
                    if(y > 20 and x > 20 and y + h + 20 < height and x + w + 20 < width):
                        found_ball = True
                        cv2.putText(imageFrame, "Object", (x, y),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            1.0, (0, 0, 255))
                        imageFrame = cv2.rectangle(imageFrame, (x, y),
                                        (x + w, y + h),
                                        (0, 0, 255), 2)
                        #canvas.coords(ball, 100 - h, y * 2, 130 - h, y * 2 + 30)

                        
                        ball_x = x + w/2
                        ball_y = y + h/2
                        #crop = img_gray[y-20:y+h+20, x-20:x+w+20]  
                        #resized_crop = cv2.resize(crop, (500, 500))
                        if(active_ball):
                            active_ball_coords.append([ball_x,-ball_y])
                            added_balls += 1
                            if(active_ball_count == active_ball_limit + 1):
                                distance = ball_x-(cam_width/2)
                                msg = "x:" + str(distance)
                                #coord = calculate_vector(unactive_ball_coords[-3],[x,-y])
                                #msg = "x:" + str(coord[0]) + " y:" + str(coord[1])
                                b_msg = msg.encode("utf-8")
                                sock.sendto(b_msg, (UDP_IP, UDP_PORT))
                                #print(distance)

                        elif(active_ball_count > 0):
                            unactive_ball_coords.append([ball_x,-ball_y])
                        # circles2 = cv2.HoughCircles(resized_crop, cv2.HOUGH_GRADIENT, 1.4, 50, param1=30,param2=80,  minRadius=1, maxRadius=1000)
                        # if circles2 is not None: 
                        #     circles2 = np.uint16(np.around(circles2))
                        #     for i in circles2[0,:]:
                        #         circle_crop = resized_crop
                        #         # draw the outer circle
                        #         cv2.circle(resized_crop,(i[0],i[1]),i[2],(0,255,0),2)
                        #         # draw the center of the circle
                        #         cv2.circle(resized_crop,(i[0],i[1]),2,(0,0,255),3)
                        #         canvas.create_oval(100,100-h,110,110-h,outline ="black",fill ="white",width =2)
                    else:
                        imageFrame = cv2.rectangle(imageFrame, (x, y),
                                        (x + w, y + h),
                                        (0, 0, 0), 2)
                        cv2.putText(imageFrame, "Object", (x, y),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            1.0, (0, 0, 0))
                else:
                    imageFrame = cv2.rectangle(imageFrame, (x, y),
                                        (x + w, y + h),
                                        (0, 0, 0), 2)
                    cv2.putText(imageFrame, "Object", (x, y),
                            cv2.FONT_HERSHEY_SIMPLEX,
                            1.0, (0, 0, 0))

        #circles = cv2.HoughCircles(img_circle, cv2.HOUGH_GRADIENT, 1.4, 100, minRadius=1, maxRadius=1000)
        #circles = cv2.HoughCircles(im_gray, cv2.HOUGH_GRADIENT, 2.0, 100, minRadius=1, maxRadius=100)
        # #cv2.HoughCircles(gray, circles, cv2.HOUGH_GRADIENT,2,10,param1=50,param2=30,minRadius=0,maxRadius=0)
    
        # if circles is not None:
        #     circles = np.uint16(np.around(circles))
        #     for i in circles[0,:]:
        #         # draw the outer circle
        #         cv2.circle(imageFrame,(i[0],i[1]),i[2],(0,255,0),2)
        #         # draw the center of the circle
        #         cv2.circle(imageFrame,(i[0],i[1]),2,(0,0,255),3)

        cv2.imshow('detected circles',imageFrame)
        #cv2.imshow('crop', circle_crop)
        cv2.imshow('gray', img)
    

        #cv2.imshow('art', img_draw)

        # final run
        #cv2.imshow("Color Detection", res_black)
        #cv2.imshow("Color Detection", imageFrame)

        if cv2.waitKey(10) & 0xFF == ord('q'):
            webcam.release()
            cv2.destroyAllWindows()
            break

        if(found_ball):
            active_ball_count += 1;
            no_ball_count = 0
        else:
            no_ball_count += 1
        #root.update()