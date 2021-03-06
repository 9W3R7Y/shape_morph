function [layer_img,layer_mask,morph_points] = obj2img(obj,use_GPU)
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
    morph_points = shape_points.*obj.param_value+mesh_points.*(1-obj.param_value);

    [W,H,Ch] = size(img);
    layer_img = single(zeros([W,H,Ch]));
    layer_mask = single(zeros([W,H]));

    [mesh_num,~] = size(meshes);

    for i = 1:mesh_num
        idxs = meshes(i,:);
        mesh_verts = mesh_points(idxs,:);
        morph_verts = morph_points(idxs,:);
        
        plot([mesh_verts(:,1); mesh_verts(1,1)],[mesh_verts(:,2); mesh_verts(1,2)],color=[0 1 0])
        
        xRange = round([min([mesh_verts(:,1);morph_verts(:,1)]),...
            max([mesh_verts(:,1);morph_verts(:,1)])]);
        yRange = round([min([mesh_verts(:,2);morph_verts(:,2)]),...
            max([mesh_verts(:,2);morph_verts(:,2)])]);
        
        
        mesh_W = xRange(2)-xRange(1)+1;
        mesh_H = yRange(2)-yRange(1)+1;
        
        disp('---')
        disp([xRange(1); xRange(2); mesh_verts(:,1); morph_verts(:,1)]);
        
        origin_corr = [xRange(1)-1,yRange(1)-1];
        
        mesh_verts = mesh_verts - [origin_corr;origin_corr;origin_corr];
        morph_verts = morph_verts - [origin_corr;origin_corr;origin_corr];
       
        disp([mesh_verts(:,1); morph_verts(:,1)]);
        
        mesh_mask_range = mask(yRange(1):yRange(2),xRange(1):xRange(2),:).* ...
            poly2mask(mesh_verts(:,1),mesh_verts(:,2), mesh_H, mesh_W);

        T = transCoeff(mesh_verts,morph_verts);
        tform = affine2d(T);
        outView = affineOutputView([mesh_H,mesh_W],tform,'BoundsStyle','sameAsInput');

        mesh_img = single(zeros([W,H,3]));
        mesh_mask = single(zeros([W,H,1]));
        
        mesh_img(yRange(1):yRange(2),xRange(1):xRange(2),:) = ...
            imwarp(img(yRange(1):yRange(2),xRange(1):xRange(2),:),tform,'OutputView',outView);
        mesh_mask(yRange(1):yRange(2),xRange(1):xRange(2)) = ...
            imwarp(mesh_mask_range,tform,'OutputView',outView);

        layer_img = blender(gather(layer_img),gather(mesh_img),gather(mesh_mask));
        layer_mask = gather(layer_mask+mesh_mask);
        
    end
                    
    layer_img = gather(layer_img);
    layer_mask = gather(layer_mask);
    morph_points = gather(morph_points);
end