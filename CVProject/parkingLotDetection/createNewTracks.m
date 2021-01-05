function [tr, ni] = createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId,rect,scaleFactor,panic)
     if (panic == 0)  
        centroids = centroids(unassignedDetections, :); % centroid of detected objects
        bboxes = bboxes(unassignedDetections, :); % bbox of detected objects

        for i = 1:size(centroids, 1)

            centroid = centroids(i,:);
            bbox = bboxes(i, :);
            % creating a new Kalman filter for the prediciotn of the centroid (position) of the track
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);

            % new TRack
            newTrack = struct(...
                'id', nextId, ...   % track Id
                'bbox', bbox, ...   % rectangle around the object that is assigned to the track
                'kalmanFilter', kalmanFilter, ...   % filter for centroid prediction
                'oneStepCentroid', [], ...   % centroid of the second-last frame
                'twoStepCentroid', centroid, ...   % centroid of the last frame
                'overlappingGrade', zeros(1,1,'double'), ...   % oerlapping grade between bbox and parking area
                'interestingCount', 0, ...   % n of frames in which an object has the "interesting" status
                'parkLot', bbox, ...   % bbox that has been detected
                'age', 1, ...   % number of frames of the track
                'totalVisibleCount', 1, ...   % frames in which the object has been visible
                'consecutiveInvisibleCount', 0);   % consecutive frames in which the object has been invisible

            % update overlapping grade array

            overlapGrade = 0;
            for j =1:size(rect, 3)
            overlapGradeTemp = overlappingGrade(bbox * scaleFactor,rect(:,:,j)); % overlapping grade of an object
                if overlapGradeTemp > overlapGrade
                    overlapGrade = overlapGradeTemp;

                end
            end
            newTrack.overlappingGrade(newTrack.age) = overlapGrade;


            % update of count of interest
            if (newTrack.overlappingGrade(newTrack.age) > 0.65)
                newTrack.interestingCount = ...
                    newTrack.interestingCount + 1;
            end

            % add new track to the array of tracks
            tracks(end + 1) = newTrack;

            % update id for the next track
            nextId = nextId + 1;
        end

        tr = tracks;
        ni = nextId;
     else
         tr = tracks;
         ni = nextId;
     end
end