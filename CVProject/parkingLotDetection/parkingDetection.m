function [] = parkingDetection()
addpath(genpath('parkingLotDetection'));
w = warning ('off','all');
source = 'output2.avi';

videoSource = vision.VideoFileReader(source,'ImageColorSpace','Intensity','VideoOutputDataType','uint8');
indexGood = [1:300,1430:1870,5400:5700,6400:6800,9600:9950,15500:16100,17050:17480,24960:25600,27490:27850,29400:30060]; % interesting frames
         
 % 1:300,1430:1870,5400:5700,6400:6800,9600:9950,15500:16100,17050:17480,24960:25600,27490:27850,29400:30060

 
jump = 1; %jump to interesting frames
skipvideo = 0; %visualize every frame (utile per computazione più veloce)
firstFrame = step(videoSource);

firstFrame = firstFrame(1:end-1,:);


frameSize = size(firstFrame);

textPosition = [85 8];
firstTextedFrame = insertText(firstFrame,textPosition,'Selezionare la zona da monitorare', ...
'FontSize',13,'TextColor','w','BoxOpacity',0);
scaleFactor = 1;


firstTextedFrame = imresize(firstTextedFrame, scaleFactor);
figure(1),
set(gcf,'numbertitle','off','name','Parking Lots Project','Visible','on'); % figure title
imshow(firstTextedFrame); % frame visualization



%% SELECT RECTANGLE TO MONITOR
inputValid = 0;
while(~inputValid)
    prompt = {'Inserisci il numero di aree da monitorare'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'2'};
    opts.WindowStyle = 'Normal';
    answer = inputdlg(prompt,dlgtitle,dims,definput, opts);
    user_val = str2num(answer{1});
    if(user_val>0)
        inputValid = 1;
    else
        f = errordlg('Input deve essere maggiore di 0','Input Error');
        uiwait(f);
    end
end
parkshapes = user_val;
% park area params

minimumArea = 2750;
maximumArea = 6500;

minimumSize = 60;

initXsize = 200;
initYsize = 50;
invalidRectTextPosition = [65 8];


%array of coordinates of parking areas
parkingAreaPoly = zeros(4,2,parkshapes);
parkingArea_rearranged = zeros([parkshapes 8]);
for i = 1:parkshapes
    %define initial polygon shape, user modifies it and confirm it with mouse double click
    parkShape = impoly(gca,[frameSize(2)/2-initXsize,frameSize(1)/2-initYsize; ...
                        frameSize(2)/2-initXsize,frameSize(1)/2+initYsize; ...
                        frameSize(2)/2+initXsize,frameSize(1)/2+initYsize; ...
                        frameSize(2)/2+initXsize,frameSize(1)/2-initYsize;]);
    api = iptgetapi(parkShape);
    fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),get(gca,'YLim'));
    api.setPositionConstraintFcn(fcn);
    api.setColor('yellow');
    parkShape.wait;
    props = regionprops(parkShape.createMask);
    validRegion = 0;
    while(~validRegion)
        if size(props,1) > 1
            tmp_textPos = [invalidRectTextPosition(1)-30 invalidRectTextPosition(2)];
            invalidRectTextedFrame = insertText(firstFrame,tmp_textPos,'Area selezionata non è un quadrilatero, riprovare', ...
             'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
        else
            if (props.Area) < minimumArea
              invalidRectTextedFrame = insertText(firstFrame,invalidRectTextPosition,'Area selezionata troppo piccola, riprovare', ...
               'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
            else
                if min(props.BoundingBox(3:4)) < minimumSize
                    invalidRectTextedFrame = insertText(firstFrame,invalidRectTextPosition,'Area selezionata troppo schiacciata, riprovare', ...
                        'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
                else
                    if (parkshapes == 1 || i == 1) %if there are multiple areas to draw, check if they don't overlap
                        validRegion = 1;
                    else
                        if i>1
                            pos = getPosition(parkShape);
                            pnew=polyshape(pos(:,1).', pos(:,2).');
                            overlapping = 0;
                            for j = 1:i-1
                                pold=polyshape(parkingAreaPoly(:,1,j).',parkingAreaPoly(:,2,j).');
                                TF = overlaps(pold, pnew);
                                if (TF == 1)
                                    overlapping = 1;
                                end
                            end
                            if overlapping==1
                                invalidRectTextedFrame = insertText(firstFrame,invalidRectTextPosition,'Aree sovrapposte, riprovare', ...
                                'FontSize',13,'TextColor','w','BoxOpacity',0);
                            else
                                validRegion = 1;
                            end
                        end
                    end
                end
            end
        end
        old_pos = getPosition(parkShape);
        if ~validRegion
            invalidRectTextedFrame = imresize(invalidRectTextedFrame, scaleFactor);
            figure(1);
            imshow(invalidRectTextedFrame);
            parkingArea_rearranged_temp = zeros([i 8]);
            % the previous impoly object has been torn down, I have to setup a
            % new one, equal to the old one
            for k=1:i-1
                for j = 1:4
                    parkingArea_rearranged_temp(k, 2*j-1) = parkingAreaPoly(k,1,i);
                    parkingArea_rearranged_temp(k, 2*j)   = parkingAreaPoly(k,2,i);
                end
                firstTextedFrame = insertShape(firstTextedFrame,'FilledPolygon',parkingArea_rearranged_temp(k,:),'Opacity',0.1);
                figure(1);
                imshow(firstTextedFrame);
            end
            parkShape = impoly(gca,old_pos);
            api = iptgetapi(parkShape);
            fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),get(gca,'YLim'));
            api.setPositionConstraintFcn(fcn);
            api.setColor('yellow');
            parkShape.wait;
            props = regionprops(parkShape.createMask);
        end
    end

    parkingAreaPolyTemp = getPosition(parkShape);
    [tmpX,tmpY]=poly2ccw(parkingAreaPolyTemp(:,1),parkingAreaPolyTemp(:,2));
    parkingAreaPoly(:,:,i) = [tmpX,tmpY];
    delete(parkShape);
    % parkingArea_rearranged contains the same values of parkingAreaPoly,
    % but rearranged to be compatible with insertShape function

    % rearrange values of the position
    % in order to fit insertShape() requirements
    for j = 1:4
        parkingArea_rearranged(i, 2*j-1) = parkingAreaPoly(j,1,i);
        parkingArea_rearranged(i, 2*j)   = parkingAreaPoly(j,2,i);
    end
    firstTextedFrame = insertShape(firstTextedFrame,'FilledPolygon',parkingArea_rearranged(i,:),'Opacity',0.1);
    figure(1);
    imshow(firstTextedFrame);
end
%% INIT:
%   FOREGROUND DETECTOR OBJECT 
%   BLOB ANALYZER
%   TRACKS

% Background Subtraction with GMM
foregroundDetector = vision.ForegroundDetector('NumGaussians', 2, 'NumTrainingFrames', ...
                     30, 'MinimumBackgroundRatio', 0.54, 'LearningRate',0.0145);

% blobAnalysys: outputs a bbox from a binary mask
% 'ExcludeBorderBlobs' is useful for excluding cars that are not completely in the image. Less tracks to consider
blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, 'AreaOutputPort', true, ...
               'CentroidOutputPort', true, 'MinimumBlobArea', minimumArea,'MaximumBlobArea',maximumArea,...
               'ExcludeBorderBlobs', true);


tracks = initializeTracks();     

nextId = 1; % next track
freePlaces = 0;
busyPlaces = 0;
places = initializePlaces();
frameCount = 0;
afterPanic = 0; %if too much foreground pixels, pause analysis for 3 frames
panic = 0; %flag if too much foreground pixels

%% MAIN LOOP: 1 ITERATION PER FRAME

while ~isDone(videoSource)
    
    nextFrame = step(videoSource);
    %videoSource adds one pixel pad to rectified video, we remove that
    nextFrame = nextFrame(1:end-1,:);

    debug = 74;
    debugFrame = 15577;
    if (any(frameCount == indexGood(:)) || jump==0)
        
        if(frameCount > debugFrame)
            debug;
        end
        
        % object detection with Background Subtraction (GMM)
        [centroids, bboxes, mask, panic, afterPanic] = detectObjects(nextFrame,foregroundDetector,blobAnalyser, panic, afterPanic);
        
        if(frameCount > debugFrame)
            debug;
        end
        
        %prediction of the new posizion of the tracks
        tracks = predictNewLocationsOfTracks(tracks);


        % assing detected objects to new predicted tracks
        [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids,bboxes);
        if (panic == 1 || afterPanic > 0)
           nTracks = length(tracks);
           unassignedTracks = [1:nTracks]';
           assignments = [];
        end
        
        if(frameCount > debugFrame)
            debug;
        end

        %upadate each track according to the category it belongs
        tracks = updateAssignedTracks(tracks,assignments,centroids,bboxes,parkingAreaPoly,scaleFactor);
        
        if(frameCount > debugFrame)
            debug;
        end
        

        tracks = updateUnassignedTracks(tracks,unassignedTracks);
        
        if(frameCount > debugFrame)
            debug;
        end
        

        [tracks,freePlaces,busyPlaces,places] = deleteLostTracks(tracks,freePlaces,busyPlaces,places);

        
        if(frameCount > debugFrame)
            debug;
        end
        

        [tracks, nextId] = createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId,parkingAreaPoly,scaleFactor,panic);
        
        if(frameCount > debugFrame)
            debug;
        end
        
        minVisibleCount = 8; % a track is reliable if it's been visible for more than a certain number of frames
        if ~isempty(tracks)
            reliableTrackInds = [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);
            reliableTrackInds = [reliableTracks(:).consecutiveInvisibleCount] == 0;
            reliableTracks = tracks(reliableTrackInds);
            

            bboxes = cat(1, reliableTracks.bbox);
        elseif (panic == 1)
            bboxes = double([]);
        end
        if (~skipvideo)
        %visualizaiotn
            nextFrame = insertShape(nextFrame,'rectangle',bboxes); % insert bbox aorund reliable tracks
            placesTextPosition = [30 8]; % free/occupied parking slots
            nextFrame = insertText(nextFrame,placesTextPosition,sprintf('Posti liberi: %d           Posti occupati: %d     Frame: %d',freePlaces,busyPlaces,frameCount), ...
            'FontSize',13,'TextColor','w','BoxOpacity',0);
            nextFrame = imresize(nextFrame, scaleFactor);
            
            for i=1:parkshapes
                nextFrame = insertShape(nextFrame,'FilledPolygon',parkingArea_rearranged(i,:),'Color','yellow','Opacity',0.1); % parking areas
            end
            freeCircles = circlesFromFreePlaces(places,scaleFactor); % centroids of free places
            nextFrame = insertShape(nextFrame,'FilledCircle',freeCircles,'Color','green'); % insert free places as green circles

            busyCircles = circlesFromBusyPlaces(places,scaleFactor); % centroids of occupied places
            nextFrame = insertShape(nextFrame,'FilledCircle',busyCircles,'Color','red'); % insert free places as red circles
           
            figure(1);
            imshow(nextFrame);
        end
    else
        foregroundDetector.reset();
        tracks = initializeTracks();  
    end
    frameCount = frameCount + 1;
    
end
%last frame
nextFrame = insertShape(nextFrame,'rectangle',bboxes);
placesTextPosition = [30 8];
nextFrame = insertText(nextFrame,placesTextPosition,sprintf('Posti liberi: %d           Posti occupati: %d     Frame: %d',freePlaces,busyPlaces,frameCount), ...
'FontSize',13,'TextColor','w','BoxOpacity',0);
nextFrame = imresize(nextFrame, scaleFactor);
for i=1:parkshapes
    nextFrame = insertShape(nextFrame,'FilledPolygon',parkingArea_rearranged(i,:),'Color','yellow','Opacity',0.1);
end
freeCircles = circlesFromFreePlaces(places,scaleFactor);
nextFrame = insertShape(nextFrame,'FilledCircle',freeCircles,'Color','green');
busyCircles = circlesFromBusyPlaces(places,scaleFactor);
nextFrame = insertShape(nextFrame,'FilledCircle',busyCircles,'Color','red');
figure(1);
imshow(nextFrame)
release(videoSource);
end

