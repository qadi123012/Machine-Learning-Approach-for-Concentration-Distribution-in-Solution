
% 本程序为蓝本，其他需处理的数据仅需要将本文本拷入，并修改公共路径以及比较范围，即可自动处理
% 增加的浓度计算，需要根据溶液变化K，变化背景浓度
% 初始化定义公共参数
pixequiwid=0.06;
F=750;
L=1.5;
K=2.7*10^-4;

% 选取图像的分析区域
comdir='E:\植物纹影\植物根部离子吸收处理程序\FeCl3对比吸收数据及处理\NaCl处理后FeCl3\';
roidir=strcat(comdir,'选区图像\1.bmp');
oriim=rgb2gray(imread(roidir));
[roi,rect]=imcrop(oriim);         
oriim=transpose(oriim);             
roiind=uint8(ones(size(oriim)));    
x=uint16(round(rect(1)));          
y=uint16(round(rect(2)));
dx=uint16(round(rect(3)));
dy=uint16(round(rect(4)));
roiind(x:x+dx,y:y+2)=0;        
roiind(x:x+dx,y+dy-2:y+dy)=0;
roiind(x:x+2,y:y+dy)=0;
roiind(x+dx-2:x+dx,y:y+dy)=0;

figure                             
imshow(transpose(oriim.*roiind))
saveas(gcf,strcat(comdir,'选区图像\','roi.png') )
figure
imagesc(transpose(oriim.*roiind))   
axis equal
axis off
saveas(gcf,strcat(comdir,'选区图像\','roisc.png') )
close all
figure
imagesc(roi)
axis equal
axis off

% 获取标定曲线
imgname=(0:200:4000);               %注意要根据实验更改
calidisp=imgname/1000;              
cirnum=length(imgname);
calimatrix=cell(dx,dy);            
califold=strcat(comdir,'标定\');
for i=1:cirnum
    fullpath=strcat(califold, num2str( imgname(i) ),'.bmp' );
    caliimgi=transpose( rgb2gray( imread(fullpath) ) );
    for j=1:dx
        for k=1:dy
            calimatrix{j,k}=[calimatrix{j,k},caliimgi(x+j,y+k)];
        end
    end
end

% 灰度值图像转化折射率图像
%计算位移矩阵
folderinfor=dir(strcat(comdir,'待处理图像\','*.bmp'));
for l=1:length(folderinfor)
        imgdir=strcat(comdir,'待处理图像\',folderinfor(l).name);
        anaimgi=transpose( rgb2gray( imread(imgdir) ) );
        anaroii=anaimgi(x+1:x+dx,y+1:y+dy);
        dispmatri=zeros(dx,dy);
        
        comstar=7;                                           %每一个程序都需要定制修改比较范围
        comend=cirnum-3;
        for i=1:dx
             for j=1:dy
                 if anaroii(i,j)>=calimatrix{i,j}(comstar)
                     dispmatri(i,j)=calidisp(comstar);
                 elseif anaroii(i,j)<=calimatrix{i,j}(comend)
                     dispmatri(i,j)=calidisp(comend);
                 else
                     k=comstar;
                     while k<comend                   
                        t1=anaroii(i,j)-calimatrix{i,j}(k);
                        t2=anaroii(i,j)-calimatrix{i,j}(k+1);
                        if t1<=0 && t2>0
                            dispmatri(i,j)=calidisp(k)+(calidisp(k+1)-calidisp(k))*(double(anaroii(i,j))-double(calimatrix{i,j}(k)))/( double( calimatrix{i,j}(k+1) )-double( calimatrix{i,j}(k) ) ); %图像转矩阵数据类型为uint,负数超出范围，因此在运算前都应换为double
                            break
                        else
                            k=k+1;
                        end
                     end           
                 end
             end
        end
        basedisp=mean(mean(dispmatri));
        dispmatri=-(dispmatri-basedisp);        
        figure
        imagesc(transpose(dispmatri))
        %计算折射率矩阵
        refind=zeros(dx,dy);
        for i=1:dx-1
             refind(i+1,:)=1/(F*L)*dispmatri(i,:)*pixequiwid+refind(i,:);
        end
%       figure
%       imagesc(transpose(refind))
        % 绘图，科研绘图
        figure
        imagesc([0,dx]*pixequiwid,[0,dy]*pixequiwid,transpose(refind))
%         axis equal
%         xlim([0,dx]*pixequiwid)
%         ylim([0,dy]*pixequiwid)
%         xlabel('x / mm','FontSize',18,'FontName','Times New Roman')
%         ylabel('y / mm','FontSize',18,'FontName','Times New Roman')
%         a=colorbar;
%         a.Label.String='refractive index change';
%         a.Label.FontName='Times New Roman';

%         a.Label.FontSize=18;
%         ax=gca;
%         ax.FontSize=18;
%         ax.FontName='Times New Roman';
%         saveas(gcf,strcat(comdir,'处理结果\',num2str(l),'.png') )
%       close
        %计算浓度
        concen=refind/K-max(max(refind/K))+5; %背景浓度5 g/L
        figure
        imagesc([0,dx]*pixequiwid,[0,dy]*pixequiwid,transpose(concen))
        axis equal
        xlim([0,dx]*pixequiwid)
        ylim([0,dy]*pixequiwid)
        xlabel('x / mm','FontSize',18,'FontName','Times New Roman')
        ylabel('y / mm','FontSize',18,'FontName','Times New Roman')
        a=colorbar;
        a.Label.String='concentration g/L';
        a.Label.FontName='Times New Roman';
        a.Label.FontSize=18;
        ax=gca;
        ax.FontSize=18;
        ax.FontName='Times New Roman';
        saveas(gcf,strcat(comdir,'处理结果\',num2str(l),'.png') )
end