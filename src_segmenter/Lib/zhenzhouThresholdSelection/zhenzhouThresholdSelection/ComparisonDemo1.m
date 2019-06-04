%%%This program is written by Zhenzhou Wang, for more information please
%%%contact: zzwangsia@yahoo.com or wangzhenzhou@sia.cn
%%%This program is free for academic use only.
%%%Please reference and acknowledge the following paper:
%%%%%%[1]Z.Z. Wang, "A new approach for Segmentation and Quantification of Cells or Nanoparticles," IEEE T IND INFORM, 2016



%%%% This code is used to compare zhenzhou threshold selection method
%%%% with others. This code should be run many times since the synthesized
%%%% images vary a little bit every time
close all;
clear all;


%%%%%%%%%%%Synthesizing the image
S=30;
C1=50+S*randn(128,128);
Center1=80+S*randn(64,64);
Center2=150+S*randn(64,64);
C1(13:76,13:76)=Center1;
C1(53:116,53:116)=Center2;
C=(C1);
figure,imagesc(C);colormap gray;


IS=size(C1);
Seg1=double(C1);
S=size(Seg1);
    for l=1:10
        for i=2:IS(1)-1
            for j=2:IS(2)-1
                meanc=(Seg1(i+1,j+1)+Seg1(i+1,j-1)+Seg1(i-1,j+1)+Seg1(i-1,j-1)+Seg1(i+1,j)+Seg1(i,j+1)+Seg1(i-1,j)+Seg1(i,j-1)+Seg1(i,j))/9;
                Seg1(i,j)=round(meanc);
            end;
        end;
    end;
    Seg1(1:2,:)=Seg1(3:4,:);
    Seg1((IS(1)-1):IS(1),:)=Seg1((IS(1)-3):(IS(1)-2),:);
    Seg1(:,1:2)=Seg1(:,3:4);
    Seg1(:,(IS(2)-1):IS(2))=Seg1(:,(IS(2)-3):(IS(2)-2));

Seg=Seg1;
figure,imagesc(Seg);colormap gray;
%%%%%%%%%%%End of Synthesizing the image



%%%Zhenzhou threshold selection method
T=zhenzhou_threshold_selection_updated(double(Seg),2,15,1);
bSeg=Seg>T;
figure,imagesc(bSeg);colormap gray;


 
%%%%EM Results
[Segs,mu,v,p]=EMSeg(Seg,2);
figure,imagesc(Segs);colormap gray;



%%%%%%%%%%%%%%kmeans results 

[mu,Segs]=kmeans(uint8(Seg),2);
figure,imagesc(Segs);colormap gray;






%  C. Li, C. Xu, C. Gui, M. D. Fox, "Distance Regularized Level Set Evolution and Its Application to Image Segmentation", 
%     IEEE Trans. Image Processing, vol. 19 (12), pp. 3243-3254, 2010.
% clear all;
% close all;

    tic;
    Img=double(Seg);
    %% parameter setting
    timestep=5;  % time step
    mu=0.2/timestep;  % coefficient of the distance regularization term R(phi)
%     iter_inner=5;
%     iter_outer=40;
    iter_inner=20;
    iter_outer=80;
    lambda=5; % coefficient of the weighted length term L(phi)
    alfa=1.5;  % coefficient of the weighted area term A(phi)
    epsilon=1.5; % papramater that specifies the width of the DiracDelta function
    
    sigma=1.5;     % scale parameter in Gaussian kernel
    G=fspecial('gaussian',15,sigma);
    Img_smooth=conv2(Img,G,'same');  % smooth image by Gaussiin convolution
    [Ix,Iy]=gradient(Img_smooth);
    f=Ix.^2+Iy.^2;
    g=1./(1+f);  % edge indicator function.
    
    % initialize LSF as binary step function
    c0=2;
    initialLSF=c0*ones(size(Img));
    % generate the initial region R0 as a rectangle
    NS=size(Img);
    % initialLSF(10:55, 10:75)=-c0;
    initialLSF(10:NS(1)-10,10:NS(2)-10)=-c0;
%     initialLSF(round(NS(1)/2-10):round(NS(1)/2+10),round(NS(2)/2-10):round(NS(2)/2+10))=-c0;
    phi=initialLSF;
    
    figure(1);
    mesh(-phi);   % for a better view, the LSF is displayed upside down
    hold on;  contour(phi, [0,0], 'r','LineWidth',2);
    title('Initial level set function');
    view([-80 35]);
    
    figure(2);
    imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
    title('Initial zero level contour');
    pause(0.5);
    
    potential=2;
    if potential ==1
        potentialFunction = 'single-well';  % use single well potential p1(s)=0.5*(s-1)^2, which is good for region-based model
    elseif potential == 2
        potentialFunction = 'double-well';  % use double-well potential in Eq. (16), which is good for both edge and region based models
    else
        potentialFunction = 'double-well';  % default choice of potential function
    end
    
    
    % start level set evolution
    for n=1:iter_outer
        phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);
        if mod(n,2)==0
            figure(2);
            imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r','LineWidth',3);
        end
    end
    
    % refine the zero level contour by further level set evolution with alfa=0
    alfa=0;
    iter_refine = 10;
    phi = drlse_edge(phi, g, lambda, mu, alfa, epsilon, timestep, iter_inner, potentialFunction);
    
    finalLSF=phi;
    figure(2);
    imagesc(Img,[0, 255]); axis off; axis equal; colormap(gray); hold on;  contour(phi, [0,0], 'r');
    hold on;  contour(phi, [0,0], 'r','LineWidth',3);
    str=['Final zero level contour, ', num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
    title(str);
    
    pause(1);
    figure;
    mesh(-finalLSF); % for a better view, the LSF is displayed upside down
    hold on;  contour(phi, [0,0], 'r-','LineWidth',3);
%     legend('Dis-LS');
%     str=['Final level set function, ', num2str(iter_outer*iter_inner+iter_refine), ' iterations'];
%     title(str);
    axis on;
    
    toc;









% Description: This code implements the paper: "Active Contours Without
% Edges" By Chan Vese.

I=uint8(Seg);
tic;
%     figure,imagesc(I);colormap gray;
m = zeros(size(I,1),size(I,2));          %-- create initial mask
NS=size(I);
 m(30:NS(1)-10,2:NS(2)-10) = 1;
seg = region_seg(I, m, 1200); %-- Run segmentation
figure,imagesc(seg);colormap gray;
toc;





% Shawn Lankton's IEEE TIP 2008 paper 'Localizing Region-Based Active
% Contours'.

% clc;clear all;close all;
imgID = 1; % 1,2,3  % choose one of the five test images
    
%     path='Images\test\100007.jpg';
%     path='Images\test\8068.jpg';%%C(:,:,1)
%     
%     path='Images\test\388067.jpg';%%C(:,:,1)
%     path='Images\val\3096.jpg';%%C(:,:,1)
%     path='Images\val\86016.jpg';%%C(:,:,3)
%     Seg=im2double(imread(path));
%     C=Seg(:,:,3)*255;
Img=(Seg);
NS=size(Img);
 
imgID = 3;
tic;
epsilon = 1;
switch imgID

    case 1
        num_it =1000;
        rad = 8;
        alpha = 0.3;% coefficient of the length term
        mask_init  = zeros(size(Img(:,:,1)));
        mask_init(10:NS(1)-10,10:NS(2)-10) = 1;
        seg = local_AC_MS(Img,mask_init,rad,alpha,num_it,epsilon);
    case 2
        num_it =1800;
        rad = 9;
        alpha = 0.003;% coefficient of the length term
        mask_init = zeros(size(Img(:,:,1)));
        mask_init(20:NS(1)-20,20:NS(2)-20) = 1;
        seg = local_AC_UM(Img,mask_init,rad,alpha,num_it,epsilon);
    case 3
        num_it = 2000;
        rad = 5;
        alpha = 0.001;% coefficient of the length term
        mask_init  = zeros(size(Img(:,:,1)));
        mask_init(10:NS(1)-10,10:NS(2)-10) = 1;
        seg = local_AC_UM(Img,mask_init,rad,alpha,num_it,epsilon);
end
toc;





%%%%%%%%%%%Otsu
X=(Seg);

tic;
for n = 2:2
    IDX = otsu(X,n);   
end
toc;
figure,imagesc(IDX);colormap gray;


 


%%%%%%%%%%%%ISO data
% Reference :T.W. Ridler, S. Calvard, Picture thresholding using an iterative selection method, 
%    IEEE Trans. System, Man and Cybernetics, SMC-8 (1978) 630-632.
    
 C=Seg;   
level = isodata(uint8(C));
 BW = im2bw(uint8(C),level);
 figure,imagesc(BW);colormap gray;
      
 

 
 %%%%maximum entropy    

 C=Seg;   
    
[threshold_max I1]=maxentropie(uint8(C));
figure,imagesc(I1);colormap gray;

 


 %%%cross entropy

C=Seg;

[threshold_cross I1]=minCE(uint8(C));
figure,imagesc(I1);colormap gray;


 

 %%%fuzzy entropy
C=Seg;   
    
NS=size(C);
T_fuzzy= entropy_fuzzy_threshold(C)
BC=zeros(NS(1),NS(2));
for i=1:NS(1)
    for j=1:NS(2)
        if C(i,j)>T_fuzzy
            BC(i,j)=1;
        end;
    end;
end;
figure,imagesc(BC);colormap gray;





%%%%%%%%%%%2015 thresholding
C=Seg;   
MG=fth(C,2,1,1.5);  
figure,imagesc(MG);colormap gray;
% MG1=MG<2;
% figure,imagesc(MG1);colormap gray;
% I1=MG-1;




%%%fuzzy Cmeans
C=Seg;    
fim=mat2gray(C);
level=graythresh(fim);
bwfim=im2bw(fim,level);


[bwfim0,level0]=fcmthresh(fim,0);
[bwfim1,level1]=fcmthresh(fim,1);
figure,imagesc(fim);colormap gray;
figure,imagesc(bwfim);colormap gray;


