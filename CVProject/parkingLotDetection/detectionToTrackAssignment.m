function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids,bboxes)
    % return object->track assignment
    % return tracks with no assignment
    % return objects that have't been assignet to any track


    nTracks = length(tracks); % total number of tracks
    nDetections = size(centroids, 1); % number of detected objects

    % computation of assignment cost of each object to each track
    cost = zeros(nTracks, nDetections);
    
        for i = 1:nTracks
            if (~isempty(tracks(i).twoStepCentroid) && ~isempty(tracks(i).oneStepCentroid))
                predictedCentroid = [2*tracks(i).twoStepCentroid(1) - tracks(i).oneStepCentroid(1), ...
                                     2*tracks(i).twoStepCentroid(2) - tracks(i).oneStepCentroid(2)];
                cost(i, :) = distance(predictedCentroid, centroids);
            else
                predictedCentroid = tracks(i).kalmanFilter.State([1,3]);
                cost(i, :) = distance(predictedCentroid', centroids);
            end
        end
   
    %13
    costOfNonAssignment = 13; % computation of NON-assignment cost of each object to each track

    %assignment problem solved as minimization of the total cost
    [assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end
