import numpy as np
from PIL import Image, ImageDraw
import tkinter as tk
import cv2

# turn on cam
webcam = cv2.VideoCapture(0, cv2.CAP_DSHOW)
img_draw = Image.new("RGB", (1000, 1000)) 

root = tk.Tk()
canvas = tk.Canvas()
canvas.pack()

cubic_rate = 0.1

count = 0
count_limit = 1000

while (1):
    canvas.delete("all")
    count += 1
    if(count > count_limit):
        count = 0
    else:
        continue

    _, imageFrame = webcam.read()

    # # black color
    # res_black = cv2.bitwise_and(imageFrame, imageFrame, mask=black_mask)
    im_gray = cv2.cvtColor(imageFrame, cv2.COLOR_BGR2GRAY)

    im_bw = cv2.threshold(im_gray, 100, 255, cv2.THRESH_BINARY)[1]


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
            imageFrame = cv2.rectangle(imageFrame, (x, y),
                                       (x + w, y + h),
                                       (0, 0, 0), 2)

            cv2.putText(imageFrame, "Black Object", (x, y),
                        cv2.FONT_HERSHEY_SIMPLEX,
                        1.0, (0, 0, 0))
            
            # Check if it is a cube-ish
            if(w/h < 1 + cubic_rate and w/h > 1 - cubic_rate):
                if(y > 20 and x > 20 and y + h + 20 < height and x + w + 20 < width):
                    crop = img_gray[y-20:y+h+20, x-20:x+w+20]  
                    circles2 = cv2.HoughCircles(crop, cv2.HOUGH_GRADIENT, 1.8, 100, minRadius=1, maxRadius=1000)
                    if circles2 is not None: 
                        circles2 = np.uint16(np.around(circles2))
                        for i in circles2[0,:]:
                            canvas.create_oval(100,300-h,110,310-h,outline ="black",fill ="white",width =2)
    root.update()

    #circles = cv2.HoughCircles(img_circle, cv2.HOUGH_GRADIENT, 1.4, 100, minRadius=1, maxRadius=1000)
    # circles = cv2.HoughCircles(img, cv2.HOUGH_GRADIENT, 1.8, 500, minRadius=1, maxRadius=100)
    # #cv2.HoughCircles(gray, circles, cv2.HOUGH_GRADIENT,2,10,param1=50,param2=30,minRadius=0,maxRadius=0)
 
    # if circles is not None:
    #     circles = np.uint16(np.around(circles))
    #     for i in circles[0,:]:
    #         # draw the outer circle
    #         cv2.circle(imageFrame,(i[0],i[1]),i[2],(0,255,0),2)
    #         # draw the center of the circle
    #         cv2.circle(imageFrame,(i[0],i[1]),2,(0,0,255),3)

    cv2.imshow('detected circles',imageFrame)
    cv2.imshow('gray', img)
   

    #cv2.imshow('art', img_draw)

    # final run
    #cv2.imshow("Color Detection", res_black)
    #cv2.imshow("Color Detection", imageFrame)

    if cv2.waitKey(10) & 0xFF == ord('q'):
        webcam.release()
        cv2.destroyAllWindows()
        break