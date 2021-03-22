load('testmesh.mat','OBJS')
obj = OBJS(1);
[img,mask,morph] = obj2img(obj);