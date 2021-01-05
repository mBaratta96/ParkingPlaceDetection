========================================================
Project 04 - Parking Lots Detection
========================================================
Main functionalities are in the project.m script.
-- parkingDetection(): performs parking detection with new modification (multiple parking area and rectified video)
-- estimateTileAngle(n_of_frames): perform tilt angle estimation of n frames
========================================================
Rectification
========================================================
In order to speed-up the computation of parkingDetection, it's advisable to transform the experimental video before the analysis.
Use rectifyVideo.m script for this purpose.
Rectification direct method is in rectifyFrame.m function: change the points if you want to use a new video
========================================================
Optical Flow computation for tilt angle estimation
========================================================
Tilt angle estimation requires the computation of the optical flow of a certain number of video frames.
-- prepare frames with video_to_frames.m
-- use command line and get into the working directory, then follow the instruction inside the readme.txt file of the mdpof folder
-- remember to change the dataDirectory in tiltEstimation/estimateTiltAngle.m. The script reads and processes the .flo files automatically
