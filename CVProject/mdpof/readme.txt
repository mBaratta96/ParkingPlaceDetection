========================================================
MDPOF - Motion Detail Preserving Optical Flow Estimation  
========================================================
Distributed Version 2.0
This software implements the following paper
Li Xu, Jiaya Jia, Yasuyuki Matsushita,"Motion Detail Preserving Optical Flow Estimation", IEEE Transactions on Pattern Analysis and Machine Intelligence (TPAMI), 34(9), 1744-1757, 2012.
The executable has been tested on 32-bit and 64-bit windows 7 and is for non-commercial use only.
Copyright 2012, The Chinese Uniersity of Hong Kong

========================================================
USAGE
========================================================
mdpof.exe imgdir [imgtype][smooth][largemotion][occlusion] [resultdir]
e.g. mdpof.exe ".\data\Bird" ".png" 8 1 0 ".\data\Bird"

imgdir - Specifies the directory containing at least two images for optical flow estimation.
imgtype - Specifies the image file extensions to be processed.  [Values: .png, .bmp, .jpg, .ppm][Default: .png]
smooth - Controls the regularization strength for flow estimation. [Values: 5-30, the larger the value, the smoother the flow field][Default:8]
largemotion - Indicates whether large motion (>50pixels) is presented. [Values: 0-small motion, 1-large motion][Default: 1] 
occlusion - Indicates whether occlusion handling is applied. [Values: 0-without occlusion handling, 1-with occlusion handling][Default:0]
resultdir - Specifies the directory to save the optical flow output. [Default:imgdir]

OUTPUT
filename_mdpof.flo - A standard optical flow format. (see http://vision.middlebury.edu/flow/)
filename_mdpof.ppm - An image visualizing the flow field using the color coding from Middlebury Optical Flow Benchmark
filename_mdpwarp.ppm - A backward warping result using the optical flow field (bilinear warpping.)

========================================================
MIDDLEBURY BENCHMARK
========================================================
We use the following parameters to generate the results on the Middlebury Benchmark dataset
-mdpof.exe imgdir ".png" 6 0 1

========================================================
CONTACT
========================================================
Please contact Li Xu (xuli@cse.cuhk.edu.hk) for reporting bugs.