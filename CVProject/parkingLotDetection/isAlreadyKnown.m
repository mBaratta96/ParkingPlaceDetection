function index = isAlreadyKnown(parkLot,places)
    % 1 if a place (indentified by its bbox) is present in the array of places
    % 0 otherwise

    maxOverlap = 0;
    
    for i = 1:length(places)
        topLeftCorner = [places(i).bbox(1),places(i).bbox(2)];
        topRightCorner = [places(i).bbox(1)+places(i).bbox(3),places(i).bbox(2)];
        bottomRightCorner = [places(i).bbox(1)+places(i).bbox(3),places(i).bbox(2)+places(i).bbox(4)];
        bottomLeftCorner = [places(i).bbox(1),places(i).bbox(2)+places(i).bbox(4)];
        polyX = [topLeftCorner(1),topRightCorner(1),bottomRightCorner(1),bottomLeftCorner(1)];
        polyY = [topLeftCorner(2),topRightCorner(2),bottomRightCorner(2),bottomLeftCorner(2)];
        polyPlace = [double(polyX'),double(polyY')];
        overlap = overlappingGrade(parkLot,polyPlace);
        if(overlap > maxOverlap)
            maxOverlap = overlap;
            index = i;
        end
    end

    if(maxOverlap < 0.55)
        index = 0;
    end

end