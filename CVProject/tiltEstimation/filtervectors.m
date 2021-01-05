function [idxAboveTh]=filtervectors(speedsindices,speeds, th)
%find indices of elements above threshold
    incspeeds=speeds(speedsindices);
    idxAboveTh=find(incspeeds>th);
end