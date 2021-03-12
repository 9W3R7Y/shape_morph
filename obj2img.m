function [layer_img,layer_mask] = obj2img(obj,morph)
    blender = vision.AlphaBlender('Operation','Binary mask','MaskSource','Input port');
    
    img = im2single(obj{2});
    mask = im2single(obj{3});
    mesh_points = obj{5};
    meshes = obj{6};
    shape_points = obj{7};

    [W,H,~] = size(img);
    layer_img = single(ones(size(img))).*0.5;
    layer_mask = single(zeros([W,H]));

    [mesh_num,~] = size(meshes);

    for i = 1:mesh_num
        idxs = meshes(i,:);
        mesh_verts = mesh_points(idxs,:);
        shape_verts = shape_points(idxs,:);
        
        mesh_mask = mask.*poly2mask(mesh_verts(:,1),mesh_verts(:,2), W, H);

        morph_verts = shape_verts.*morph+mesh_verts.*(1-morph);
        T = transCoeff(mesh_verts,morph_verts);
        tform = affine2d(T);
        outView = affineOutputView([W,H],tform,'BoundsStyle','sameAsInput');

        mesh_img = imwarp(img,tform,'OutputView',outView);
        mesh_mask = imwarp(mesh_mask,tform,'OutputView',outView);

        layer_img = blender(layer_img,mesh_img,mesh_mask);
        layer_mask = layer_mask+mesh_mask;
    end
end