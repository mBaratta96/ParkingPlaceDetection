function [circles] = circlesFromFreePlaces(places,scaleFactor)
    %
    % from the array of slots, return the centroid of free slots
    cir = [];

    k = 1;
    for i = 1:length(places)
    
        if (places(i).isFree == 1)
            cir(k,:) = [places(i).bbox(1) + places(i).bbox(3) / 2, ...
                            places(i).bbox(2) + places(i).bbox(4) / 2, ...
                            10] * scaleFactor;

            k = k + 1;
        end
        
    end

    circles = cir;
    
end