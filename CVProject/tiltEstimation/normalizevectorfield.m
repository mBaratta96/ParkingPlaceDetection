
function [allxComponents , allyComponents,allyLocation]= normalizevectorfield(directory, estFL, estAngle, usedfiles,opcentershift,th, filelist)
    % returns the values computed by equation (2) and (3) of section 6.2 of the report
    temp_size = 100000;

    yh = estFL/tan(estAngle);
    yhorig = max(opcentershift(2)-yh,1);

    %to save memory: istead of preallocate three array of length width*heigth*usedfiles, allocate temporal array
    allxComponents= [];
    allxComponentsTemp = zeros(temp_size, 1);
    x_count=1;
    allyComponents= [];
    allyComponentsTemp = zeros(temp_size, 1);
    y_count=1;
    allyLocation = [];
    allyLocationTemp = zeros(temp_size, 1);
    y_loc_count=1;

    for file = 1:(usedfiles-1)
        fileName = filelist(file).name;
        Flow = readFlowFile(fullfile(directory, fileName));
        [ii,jj]=ndgrid(1:size(Flow,2),round(yhorig):size(Flow,1));
        origcoord=[ii(:) jj(:)];
        speeds = sqrt((Flow(:,:,1).^2+Flow(:,:,2).^2));

        denoisedspeeds = speeds;
        denoisedspeeds( denoisedspeeds<th) = 0;
        %paper assumes center of image coordinate at the principal point. Must shift the coordinates
        origcoordTrans(:,1) = (origcoord(:,1))-opcentershift(1);    % x increasing to the right
        origcoordTrans(:,2) = (-origcoord(:,2))+opcentershift(2);   % Y increasing upwards
        % Eq2 in report
        rectx=  (estFL./(estFL*cos(estAngle)- origcoordTrans(:,2).*sin(estAngle))) .* origcoordTrans(:,1);
        recty= (estFL./(estFL*cos(estAngle)- origcoordTrans(:,2).*sin(estAngle))) .* ( origcoordTrans(:,2)*cos(estAngle)+ estFL* sin(estAngle));

        rectxOrig= opcentershift(1)+ rectx;
        rectyOrig= opcentershift(2) - recty;
        % linear indexing
        xComponentloc=sub2ind(size(Flow), origcoord(:,2)', origcoord(:,1)',ones(1,size(origcoord,1)));
        yComponentloc=sub2ind(size(Flow), origcoord(:,2)', origcoord(:,1)',2*ones(1,size(origcoord,1)));
        % filter vectors
        [idxAboveTh]=filtervectors(xComponentloc,speeds, th);
        % Original vector
        xComponent = Flow((xComponentloc));
        yComponent = Flow((yComponentloc));

        % Eq3 in report
        RectxComponent = (estFL./(estFL*cos(estAngle)- origcoordTrans(:,2).*sin(estAngle)).^2).* ( estFL* xComponent'.* cos(estAngle)+ (origcoordTrans(:,1).*yComponent' - xComponent'.*origcoordTrans(:,2)).* sin(estAngle) );
        RectyComponent = (estFL./(estFL*cos(estAngle)- origcoordTrans(:,2).*sin(estAngle)).^2).* ( estFL * -yComponent' );
        %noise filter
        denoisedrectxOrig=rectxOrig(idxAboveTh);
        denoisedrectyOrig= rectyOrig(idxAboveTh);
        denoisedRectxComponent=RectxComponent(idxAboveTh);
        denoisedRectyComponent=RectyComponent(idxAboveTh);

        %preallocated arrays are filled with components. If temporal array is full,
        %move elements to final array and allocate a new one

        if size(denoisedRectxComponent,1)>0
            if size(denoisedRectxComponent,1)<temp_size-x_count+1
                allxComponentsTemp(x_count:x_count+size(denoisedRectxComponent,1)-1)=denoisedRectxComponent;
                x_count=x_count+size(denoisedRectxComponent,1)-1;
            else
                allxComponents=[allxComponents; allxComponentsTemp(1:x_count); denoisedRectxComponent];
                allxComponentsTemp=zeros(temp_size,1);
                x_count=1;
            end
        end
        
        if size(denoisedRectyComponent,1)>0
            if size(denoisedRectyComponent,1)<temp_size-y_count+1
                allyComponentsTemp(y_count:y_count+size(denoisedRectyComponent,1)-1)=denoisedRectyComponent;
                y_count=y_count+size(denoisedRectyComponent,1)-1;
            else
                allyComponents=[allyComponents; allyComponentsTemp(1:y_count); denoisedRectyComponent];
                allyComponentsTemp=zeros(temp_size,1);
                y_count=1;
            end
        end
        
        if size(denoisedrectyOrig,1)>0
            if size(denoisedrectyOrig,1)<temp_size-y_loc_count+1
                allyLocationTemp(y_loc_count:y_loc_count+size(denoisedrectyOrig,1)-1)=denoisedrectyOrig;
                y_loc_count=y_loc_count+size(denoisedrectyOrig,1)-1;
            else
                allyLocation=[allyLocation; allyLocationTemp(1:y_loc_count); denoisedrectyOrig];
                allyLocationTemp=zeros(temp_size,1);
                y_loc_count=1;
            end
        end
    end
    allxComponents = [allxComponents; allxComponentsTemp(1:x_count)];
    allyComponents = [allyComponents; allyComponentsTemp(1:y_count)];
    allyLocation = [allyLocation; allyLocationTemp(1:y_loc_count)];
end

