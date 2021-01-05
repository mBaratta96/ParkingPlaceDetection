function [res] = objfuncOnlyAngle(tiltangle, knownFL,flowList,usedfiles,dir, th,opcentershift)
    %objective function to minimize. Equation 4 of the report
    if tiltangle >=pi/2
        res = nan;

    else
        [denoisedRectxComponent,denoisedRectyComponent,denoisedrectyOrig] = normalizevectorfield(dir, knownFL, tiltangle,usedfiles,opcentershift,th,flowList);
        newvel = [denoisedRectxComponent denoisedRectyComponent];

        speeds = sqrt(sum(newvel.^2,2));
        y = denoisedrectyOrig;
        coeff = polyfit(y,speeds,1);

        vhat = coeff(2) + coeff(1)*y;
        num = mean((speeds-vhat).^2);
        den = var(speeds);
        res = 1-num/den; %equation 4 of report
    end


end