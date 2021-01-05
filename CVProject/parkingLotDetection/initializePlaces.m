function places = initializePlaces()
    % empty array of places
    places = struct(...
        'bbox', {}, ...   % rectangle associated to a place
        'isFree', {});   % free/occupied place
end