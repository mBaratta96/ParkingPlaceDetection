function [tr,freePl,busyPl,pl] = deleteLostTracks(tracks,freePlaces,busyPlaces,places)
    isnewplace = 0;
    if isempty(tracks)
        tr = tracks;
        freePl = freePlaces;
        busyPl = busyPlaces;
        pl = places;
        return;
    end

    invisibleForTooLong = 30; % maximum invisibily threshold
    ageThreshold = 18; % minimum age threshold

    % fraction of frames in which the track has been visible
    ages = [tracks(:).age];
    totalVisibleCounts = [tracks(:).totalVisibleCount];
    visibility = totalVisibleCounts ./ ages;

    % index of tracks that are either noise or stationary cars
    lostInds = (ages < ageThreshold & visibility < 0.6) | ...
        [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
    
    % index of stationary cars
    lostVisTracks = [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

    % tracks to delete
    lostTracks = tracks(lostVisTracks);
    
    % analisys of the history of the track, using overlapping grade array
    % checking if a place is free or occupied

    for i = 1:length(lostTracks)
        if lostTracks(i).id==8 
           lostTracks(i).id;
        end
        lostTracks(i).overlappingGrade(end)
         if (lostTracks(i).interestingCount == lostTracks(i).age) && ...
            (lostTracks(i).overlappingGrade(lostTracks(i).age) < 0.65)
            freePlaces = freePlaces + 1;
 
            % check if parking slot is already present in the array of slots
            presenceIndex = isAlreadyKnown(lostTracks(i).parkLot,places);
            if(presenceIndex == 0) % NOT present = add to the array of slots
                newPlace = struct(...
                'bbox', lostTracks(i).parkLot, ...
                'isFree', 1);
                places(end + 1) = newPlace;

            else % present = change the status
                busyPlaces = busyPlaces - 1;
                places(presenceIndex).isFree = 1;
            end
         end
         if (lostTracks(i).interestingCount >0) && (lostTracks(i).overlappingGrade(lostTracks(i).age) > 0.70) ...
            && (lostTracks(i).overlappingGrade(1) < 0.70)
            % check if parking slot is already present in the array of slots
            presenceIndex = isAlreadyKnown(lostTracks(i).bbox,places);
            
            if (presenceIndex == 0) || (places(presenceIndex).isFree==1)
                busyPlaces = busyPlaces + 1;

                if(presenceIndex == 0) % NOT present = add to the array of slots
                    newPlace = struct(...
                    'bbox', lostTracks(i).bbox, ...
                    'isFree', 0);
                    places(end + 1) = newPlace;

                else % present = change the status
                    freePlaces = freePlaces - 1;
                    places(presenceIndex).isFree = 0;
                end
            end
        end
    end
    
    % eliminate lost tracks
    tracks = tracks(~lostInds);
    
    tr = tracks;
    freePl = freePlaces;
    busyPl = busyPlaces;
    pl = places;
    
end