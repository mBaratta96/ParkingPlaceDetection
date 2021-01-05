
function overlapGrade = overlappingGrade(rectOverlap,polygonBase)
% return overlapping grade (percentage) of rectOverlap rectangle with pogonBase polygon

    topLeftCornerOverlap = [rectOverlap(1), rectOverlap(2)];
    topRightCornerOverlap = [rectOverlap(1) + rectOverlap(3), rectOverlap(2)];
    bottomLeftCornerOverlap = [rectOverlap(1), rectOverlap(2) + rectOverlap(4)];
    bottomRightCornerOverlap = [rectOverlap(1) + rectOverlap(3), rectOverlap(2) + rectOverlap(4)];

    polygonRectX = [topLeftCornerOverlap(1),topRightCornerOverlap(1),bottomRightCornerOverlap(1),bottomLeftCornerOverlap(1)];
    polygonRectY = [topLeftCornerOverlap(2),topRightCornerOverlap(2),bottomRightCornerOverlap(2),bottomLeftCornerOverlap(2)];

    polygonRectX = double(polygonRectX);
    polygonRectY = double(polygonRectY);
    polygonBaseX = polygonBase(:,1);
    polygonBaseY = polygonBase(:,2);

    [overlappingPolygonX,overlappingPolygonY] = polybool('intersection',polygonRectX,polygonRectY,polygonBaseX,polygonBaseY);

    overlappingPolygonArea = polyarea(overlappingPolygonX,overlappingPolygonY);
    totalArea = rectOverlap(3) * rectOverlap(4);
    overlapGrade = (double(overlappingPolygonArea) / double(totalArea));



end