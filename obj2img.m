function [layer_img,layer_mask,morph_points] = obj2img(obj,morph,use_GPU)
    if ~exist('use_GPU','var'), use_GPU = false; end
    blender = vision.AlphaBlender('Operation','Binary mask','MaskSource','Input port');
    
    img = im2single(obj.img);
    mask = im2single(obj.mask);
    
    if use_GPU
        img = gpuArray(img);
        mask = gpuArray(mask);
    end
    
    mesh_points = obj.mesh_points;
    meshes = obj.meshes;
    shape_points = obj.shape_points;
    morph_points = shape_points.*morph+mesh_points.*(1-morph);

    [W,H,~] = size(img);
    layer_img = single(ones(size(img))).*0.5;
    layer_mask = single(zeros([W,H]));

    [mesh_num,~] = size(meshes);

    for i = 1:mesh_num
        idxs = meshes(i,:);
        mesh_verts = mesh_points(idxs,:);
        morph_verts = morph_points(idxs,:);
        
        mesh_mask = mask.*poly2mask(mesh_verts(:,1),mesh_verts(:,2), W, H);

        T = transCoeff(mesh_verts,morph_verts);
        tform = affine2d(T);
        outView = affineOutputView([W,H],tform,'BoundsStyle','sameAsInput');

        mesh_img = imwarp(img,tform,'OutputView',outView);
        mesh_mask = imwarp(mesh_mask,tform,'OutputView',outView);

        layer_img = blender(gather(layer_img),gather(mesh_img),gather(mesh_mask));
        layer_mask = gather(layer_mask+mesh_mask);
    end
    layer_img = gather(layer_img);
    layer_mask = gather(layer_mask);
    morph_points = gather(morph_points);
end