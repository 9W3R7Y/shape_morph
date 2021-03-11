function mesh = point2mesh(points,alpha)
    shp = alphaShape(points(:,1),points(:,2));
    %a = criticalAlpha(shp,'one-region');
    shp.Alpha = alpha;
    mesh = alphaTriangulation(shp);
end