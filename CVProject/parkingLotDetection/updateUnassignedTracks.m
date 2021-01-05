function tr = updateUnassignedTracks(tracks,unassignedTracks)
    for i = 1:length(unassignedTracks)
        ind = unassignedTracks(i); % non-assigned track id
        if(tracks(ind).id==25)
            tracks(ind).id
        end
        tracks(ind).age = tracks(ind).age + 1; % update track age
        tracks(ind).consecutiveInvisibleCount = tracks(ind).consecutiveInvisibleCount + 1; % update track invisibility
        tracks(ind).overlappingGrade(tracks(ind).age) = tracks(ind).overlappingGrade(tracks(ind).age - 1); % update overlapGrade of the track
        
        % update of count of interest
        if (tracks(ind).interestingCount > 0)
            tracks(ind).interestingCount = tracks(ind).interestingCount + 1;
        end
        
        noGapRadiusInside = 15;
        noGapRadiusOutside = 9;
       
        if (~isempty(tracks(ind).twoStepCentroid) && ~isempty(tracks(ind).oneStepCentroid))
            if (tracks(ind).overlappingGrade(end-2) >= 0.33)
                close = areClose(tracks(ind).twoStepCentroid,tracks(ind).oneStepCentroid,noGapRadiusInside);
                if (close == 1)
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                else
                    predictedCentroid = [2*tracks(ind).twoStepCentroid(1) - tracks(ind).oneStepCentroid(1), ...
                                         2*tracks(ind).twoStepCentroid(2) - tracks(ind).oneStepCentroid(2)];
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                    tracks(ind).twoStepCentroid = predictedCentroid;
                end
            else
                close = areClose(tracks(ind).twoStepCentroid,tracks(ind).oneStepCentroid,noGapRadiusOutside);
                if (close == 1)
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                else
                    predictedCentroid = [2*tracks(ind).twoStepCentroid(1) - tracks(ind).oneStepCentroid(1), ...
                                         2*tracks(ind).twoStepCentroid(2) - tracks(ind).oneStepCentroid(2)];
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                    tracks(ind).twoStepCentroid = predictedCentroid;
                end
            end
            
        else
            tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
            tracks(ind).twoStepCentroid = (tracks(ind).kalmanFilter.State([1,3]))';
        end
        
    end
    
    tr = tracks;
end