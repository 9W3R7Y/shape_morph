imshow('cameraman.tif')
a = drawrectangle(gca,'Position', [10 10 100 100]);
b = drawrectangle(gca,'Position', [10 10 100 100]);
c = drawrectangle(gca,'Position', [10 10 100 100]);

addlistener(a,'MovingROI',@(src,evt) myCallback(evt));
addlistener(b,'MovingROI',@(src,evt) myCallback(evt));
addlistener(c,'MovingROI',@(src,evt) myCallback(evt));

function myCallback(evt)
    title(mat2str(evt.CurrentPosition,3));
end