function [maxp, th]=choosePerc(dataFolder, flowList, usedFrames,opcenter)
    %noise reduction
    %maxp is the threshold index that is computed maximizing R^2(0)
    %look point 4 in section 6.2 of the report for reference
    fileName = flowList(1).name;
    flow = readFlowFile(fullfile(dataFolder, fileName));
    flowFrames = [];
    speedsframes = zeros(size(flow,1), size(flow,2), usedFrames);
    for file = 1:(usedFrames-1)
        fileName = flowList(file).name;
        flow = readFlowFile(fullfile(dataFolder, fileName));
        speedsframes(:,:,file) = sqrt((flow(:,:,1).^2+flow(:,:,2).^2));
    end
    speeds = speedsframes(:);
    ycoordscol = [1:size(speedsframes,1)]';
    ycoordscol_shifted = ycoordscol-opcenter(2); %paper assumes center of image coordinate at the principal point. Must shift the coordinates
    ycoordoneFrame = repmat(ycoordscol_shifted,size(speedsframes,2),1);
    ycoords = repmat(ycoordoneFrame,size(speedsframes,3),1);

    th = prctile(speeds,0);
    idxaboveth = find(speeds>th);
    coeff = polyfit(ycoords(idxaboveth),speeds(idxaboveth),1);
    vhat = coeff(2) + coeff(1)*ycoords(idxaboveth);
    num = mean((speeds(idxaboveth)-vhat).^2);
    den = var(speeds(idxaboveth));
    maxslope = 1-num/den;
    maxp = 0;

    for p = [5:99,99.2,99.4,99.6]
        th = prctile(speeds,p);
        idxaboveth = find(speeds>th);
        coeff = polyfit(ycoords(idxaboveth),speeds(idxaboveth),1);
        vhat = coeff(2) + coeff(1)*ycoords(idxaboveth);
        num = mean((speeds(idxaboveth)-vhat).^2);
        den = var(speeds(idxaboveth));
        if 1-num/den>maxslope && coeff(1)<0
            maxslope = 1-num/den;
            maxp = p;
        end
    end
    th = prctile(speeds,maxp);
end