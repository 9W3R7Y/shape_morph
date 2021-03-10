%画像読み込み
[bk]  = im2single(imread("imgs\bk.png"));
[mouth,~,mask] = imread("imgs\mouth.png");
mouth = im2single(mouth);

mesh = [[209 208];[274 208];[246 263]];
open = mesh;
close = [[209 226];[274 226];[246 226]];

param = 0.1;

morph = open.*param+close.*(1-param);

T = transCoeff(mesh,morph);
tform = affine2d(T);
outView = affineOutputView(size(mouth),tform,'BoundsStyle','sameAsInput');
mouth = imwarp(mouth,tform,'OutputView',outView);
mask = imwarp(mask,tform,'OutputView',outView);

blender = vision.AlphaBlender('Operation','Binary mask','MaskSource','Input port');
face = blender(bk,mouth,mask);

image(face);