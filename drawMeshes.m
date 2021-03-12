blender = vision.AlphaBlender('Operation','Binary mask','MaskSource','Input port');

obj = imgs{1};
img = im2single(obj{2});
mask = im2single(obj{3});
vert = obj{5};
meshes = obj{6};

[W,H,~] = size(img);
layer_img = single(ones(size(img))).*0.5;
layer_mask = single(zeros([W,H]));

[mesh_num,~] = size(meshes);

for i = 1:mesh_num-1
    idxs = meshes(i,:);
    mesh = vert(idxs,:);
    mesh_mask = mask.*poly2mask(mesh(:,1),mesh(:,2), W, H);
    
    T = transCoeff(mesh,mesh);
    tform = affine2d(T);
    outView = affineOutputView([W,H],tform,'BoundsStyle','sameAsInput');
    
    mesh_img = imwarp(img,tform,'OutputView',outView);
    mesh_mask = imwarp(mesh_mask,tform,'OutputView',outView);
   
    layer_img = blender(layer_img,mesh_img,mesh_mask);
    layer_mask = layer_mask+mesh_mask;
end

image(layer_img,AlphaData=layer_mask);
hold on;
pbaspect([1 1 1]);
for i = 1:mesh_num
    idxs = meshes(i,:);
    mesh = vert(idxs,:);
    plot([mesh(:,1);mesh(1,1)],[mesh(:,2);mesh(1,2)],color=[0 1 0]);
end
hold off