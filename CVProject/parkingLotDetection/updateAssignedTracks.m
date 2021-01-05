function tr = updateAssignedTracks(tracks,assignments,centroids,bboxes,rect,scaleFactor)
    numAssignedTracks = size(assignments, 1); % number of assigned tracks
    
    for i = 1:numAssignedTracks
        trackIdx = assignments(i, 1); %track Id

        detectionIdx = assignments(i, 2); % object id
        centroid = centroids(detectionIdx, :); % object centroid
        bbox = bboxes(detectionIdx, :); % object bbox
        overlapGrade = 0;
        for j =1:size(rect, 3)
            overlapGradeTemp = overlappingGrade(bbox * scaleFactor,rect(:,:,j)); % overlapping grade of an object
            if overlapGradeTemp > overlapGrade
                overlapGrade = overlapGradeTemp;
            end
        end

        % correction of the estimete of the position of the track using the new detection
        correct(tracks(trackIdx).kalmanFilter, centroid);

        % substitute predicted bbox with the one that has been actually found
        tracks(trackIdx).bbox = bbox;

        % update track age
        tracks(trackIdx).age = tracks(trackIdx).age + 1;

        %update track visibility
        tracks(trackIdx).totalVisibleCount = ...
            tracks(trackIdx).totalVisibleCount + 1;
        tracks(trackIdx).consecutiveInvisibleCount = 0;
        
        % update overlapGrade of the track
        tracks(trackIdx).overlappingGrade(tracks(trackIdx).age) = overlapGrade;

        
        % update of count of interest
        if (tracks(trackIdx).interestingCount > 0) || (overlapGrade > 0.65)
            tracks(trackIdx).interestingCount = ...
                tracks(trackIdx).interestingCount + 1;
        end
        
        tracks(trackIdx).oneStepCentroid = tracks(trackIdx).twoStepCentroid;
        tracks(trackIdx).twoStepCentroid = centroid;
        
    end
    
    tr = tracks;
end