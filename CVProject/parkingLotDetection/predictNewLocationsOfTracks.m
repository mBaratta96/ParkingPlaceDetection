function tr = predictNewLocationsOfTracks(tracks)
        for i = 1:length(tracks)
            if (~isempty(tracks(i).twoStepCentroid) && ~isempty(tracks(i).oneStepCentroid))
                bbox = tracks(i).bbox;
                % prediction of the position of the tracks (centroid position)

                predictedCentroid = predict(tracks(i).kalmanFilter);
                predictedCentroid = [2*tracks(i).twoStepCentroid(1) - tracks(i).oneStepCentroid(1), ...
                                     2*tracks(i).twoStepCentroid(2) - tracks(i).oneStepCentroid(2)];

            else
                bbox = tracks(i).bbox;
                predictedCentroid = predict(tracks(i).kalmanFilter);
            end
            % bbox shifting in order to set the predicted centroid as the new one

                predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
                tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
        
        tr = tracks;
end