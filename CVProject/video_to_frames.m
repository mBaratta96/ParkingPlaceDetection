clear;
clc;
close all;

% utility for computing optical flow
% extract a certain number of frames from your video and then apply mdpof app
num_of_frames = 100;
dataFolder = 'data';
mkdir(dataFolder);
videoSource = vision.VideoFileReader('appa_park.mp4','ImageColorSpace','Intensity','VideoOutputDataType','uint8');
indexGood = 1:num_of_frames; % select desired frames
filename_count=1;
frame_count=1;
while ~isDone(videoSource)
    frame = step(videoSource);
    if any(frame_count == indexGood)
        filename = [sprintf('%03d',filename_count) '.jpg']; % modify %03d for a number of frams >=1000
        fullName = fullfile(dataFolder, filename);
        imwrite(frame,fullName);
        if ~mod(filename_count, 100)
            fprintf('%d images processed\n', filename_count);
        end
        filename_count = filename_count +1;
    end
    frame_count = frame_count+1;
end