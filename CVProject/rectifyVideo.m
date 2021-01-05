clear;
clc;
close all;

% to speed up algorithm computation, rectify your video before applying parking lots detection algoritmh
workingDir = 'temp';
mkdir(workingDir)
mkdir(workingDir,'images')
videoSource = VideoReader('appa_park.mp4');
total_frames = videoSource.NumFrames;
y = linspace(1, total_frames, 10);

ii = 1;
while hasFrame(videoSource)
   img = readFrame(videoSource);
   img = rectifyFrame(img, 1); %0 or 1 if you want to visualize rectification method
   filename = [sprintf('%05d',ii) '.png'];
   fullname = fullfile(workingDir,'images',filename);
   imwrite(img,fullname)
   ii = ii+1;
   [Lia, Locb] = ismember(ii, y);
   if Lia(1)      
        fprintf('video_to_image: %d percentage\n', Locb(1)*10);
   end
end

imageNames = dir(fullfile(workingDir,'images','*.png'));
imageNames = {imageNames.name}';
outputVideo = VideoWriter(fullfile(workingDir,'output3.mp4'));
outputVideo.FrameRate = videoSource.FrameRate;
open(outputVideo)
for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,'images',imageNames{ii}));
   writeVideo(outputVideo,img);
   [Lia, Locb] = ismember(ii, y);
   if Lia(1)      
        fprintf('image_to_video: %d percentage\n', Locb(1)*10);
   end
end
close(outputVideo);


