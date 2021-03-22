function mesh = point2mesh(points,alpha)
    shp = alphaShape(points(:,1),points(:,2));
    shp.Alpha = alpha;
    mesh = alphaTriangulation(shp);
end