function tracks = initializeTracks()
    % creazione di un array vuoto di tracce
    tracks = struct(...
        'id', {}, ...   % track Id
        'bbox', {}, ...   % rectangle around the object that is assigned to the track
        'kalmanFilter', {}, ...      % filter for centroid prediction
        'oneStepCentroid', {}, ...   % centroid of the second-last frame
        'twoStepCentroid', {}, ...   % centroid of the last frame
        'overlappingGrade', {}, ...   % overlapping grade between bbox and parking area
        'interestingCount', {}, ...   %  n of frames in which an object has the "interesting" status
        'parkLot', {}, ...   % bbox that has been detected
        'age', {}, ...   % number of frames of the track
        'totalVisibleCount', {}, ...   % frames in which the object has been visible
        'consecutiveInvisibleCount', {});   % consecutive frames in which the object has been invisible
end