function [centroids, bboxes, mask,panic,afterPanic] = detectObjects(frame,detector,blobAnalyser,panic,afterPanic)
        % return centroids of foregorund objects
        % return bboxes of these objects
        % return binary mask background/foregorund

        % foregorund detection
        mask = detector.step(frame);
        
        figure(2)
        subplot(2,1,1)
        imshow(mask);
        %morphological operation for noise removal and hole filling

        mask = imopen(mask, strel('diamond', 1));
        mask = imclose(mask, strel('diamond',10));


       foregroundPixels = sum(mask(:));

       pixelThreshold = 20000; %maximum threshold of foregorund. This values depends on the video that is utilized

        
       if (foregroundPixels>0 && foregroundPixels < pixelThreshold)
           % blob detection
           [areas, centroids, bboxes] = blobAnalyser.step(mask);

          %show bboxes as rectangles
           maskBboxes = insertShape(im2uint8(mask),'rectangle',bboxes);
            for i =1:size(bboxes, 1)               
                if size(bboxes,1)>1                    
                    position = bboxes(i,1:2);
                else
                    position = bboxes(1:2);
                end
                %show area of bbox: very useful to set min/max area for blobAnalyser
                maskBboxes = insertText(maskBboxes, position, int2str(areas(i)));
            end
           if(panic == 1)
             afterPanic = 3;
           elseif (afterPanic >= 1)
             afterPanic = afterPanic - 1;
           end
           panic = 0;
       else
           [areas, centroids, bboxes] = blobAnalyser.step(mask);
           
           maskBboxes = insertShape(im2uint8(mask),'rectangle',bboxes);
            for i =1:size(bboxes,1)
                if size(bboxes,1)>1                    
                    position = bboxes(i,1:2);
                else
                    position = bboxes(1:2);
                end         
                maskBboxes = insertText(maskBboxes, position, int2str(areas(i)));
            end
           panic = 1;
           afterPanic = 0;
       end
       
        subplot(2,1,2)
        imshow(maskBboxes);
end