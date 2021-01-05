function [angle] = estimateTiltAngle(usedFrames)
    %% Initialize
    % algoritmh based on the paper Estimating Camera Tilt from Motion without Tracking by Nada Elassal and James H. Elder
    % returns the estimated tilt-angle of the camera
    addpath(genpath('tiltEstimation'));
    addpath(genpath('flow-code-matlab')); %.flo file analysis provided by http://vision.middlebury.edu/flow/code/flow-code-matlab.zip
    %param=parameters(num_of_frames, 3);
    dataFolder = 'data';
    imageFormat = '.jpg';
    knownFL = 200; %focal length assumed to be known
    opcentershift = [192, 144]; %paper assumes center of image coordinate system to be located at the principal point

    flowList = dir(fullfile(dataFolder, '*.flo'));
    picList = dir(fullfile(dataFolder, strcat('*.',imageFormat)));
    lb=pi/4;
    ub=pi/2;
    allmins=[];
    allang=[];
    objvals= [];
    allvals=[];


    %% noise reduction
    [perc, th] = choosePerc(dataFolder, flowList, usedFrames ,opcentershift);

    %% lower/upper bound
    % reference: point 5 of section 6.2 of the report
    for a=lb:pi/128:ub
        [res]=objfuncOnlyAngle(a, knownFL,flowList,usedFrames,dataFolder, th,opcentershift);
        allang=[allang,a];
        objvals=[objvals,res];
    end

    [~,id]=min(objvals);
    amin=allang(id);
    lb=amin - pi/128;
    ub=min([amin+pi/128, pi/2]);
    %compute minimization
    [angle,fval]= fmincon(@(a)objfuncOnlyAngle(a, knownFL,flowList,usedFrames,dataFolder, th,opcentershift),amin,[],[],[],[],lb,ub);



end