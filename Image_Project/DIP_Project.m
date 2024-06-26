clear all
clc
close all

%C:\Users\ahmet\Desktop\4.sınıf\image\image proje\test1.jpg
%C:\Users\ahmet\Desktop\4.sınıf\image\proje deneme\deneme3.jpg'
Group4=imread('C:\Users\ahmet\Desktop\4.sınıf\image\proje deneme\deneme3.jpg');
[row,column] = size(Group4);


Group4_1 = rgb2gray(Group4);
% eşik değeri kullanarak pikselleri 0 veya 1 değerlerine dönüştürerek bir eşikleme işlemi gerçekleştirir
Group4_1 = imbinarize(Group4_1);
% görüntüyü tersine çevir, siyah pikseller beyaz, beyaz pikseller siyah 
Group4_1 = ~Group4_1;

% Canny kenar tespiti algoritması ile ikili görüntü üzerinde kenarları
% belirledik
BW=edge(Group4_1,'canny',[0.04 0.1],4);
%BW=edge(Group4_1,'canny',[0.04 0.1],15);
%disp(BW);
% Hough dönüşümü uygularak kenarların bulunduğu çizgileri tespit ettik
[H,theta,rho] = hough(BW);

% Hough dönüşümü sonucunda elde edilen matristeki tepe noktalarını belirler.
P = houghpeaks(H,7);
x = theta(P(:,2)); 
y = rho(P(:,1));




% Belirli bir boşluk ve uzunluktaki çizgileri çıkarır.
LinesIm = houghlines(BW,theta,rho,P,'FillGap',3000,'MinLength',100);
%disp(length(LinesIm));

% Input1 : tum noktalari iceresinde tutan degisken
% PointsGroup : Noktaları eslestirmek icin gerekli olan degisken

% noktalari grupla

% Çizgi segmentlerinin uç noktalarını ve nokta gruplarını saklamak için boş matrisler oluşturur.
Input1 = [];
PointsGroup = [];


% Çizgi segmentlerinin uç noktalarını alır ve Input1 ve PointsGroup matrislerini oluşturur.
for f = 1:length(LinesIm)
        
    
        xy = [LinesIm(f).point1; LinesIm(f).point2];
        ab = [xy(1,1) xy(1,2)]; % baslangic noktasi
        cd = [xy(2,1) xy(2,2)]; % bitis noktasi
        Input1 = [Input1 ;ab ;cd]; 
        PointsGroup = [PointsGroup ;ab,2*f;cd,2*f-1]; 
      
              
end


%Houghline sonucu olusan cizgileri cizer
[row,col] = size(Input1);
%disp(row);
% Noktalar arasindaki farklari bulan algoritma :

%Noktalar arasındaki farkları saklamak için gerekli değişkenleri oluşturur.
pad = zeros(row-1,1);

% Noktalar arasındaki farkları hesaplar ve DifferenceArray matrisine kaydeder.
for Index = 1:row
    
    ColIndex = 1;
    
    for increase = 1:row-Index
        
            difference = sqrt(abs(Input1(Index,1)-Input1(Index+increase,1))^2 + abs(Input1(Index,2)-Input1(Index+increase,2))^2); %%öklid uzaklık hesabı
            DifferenceArray(Index,ColIndex+Index-1) = difference;
            ColIndex = ColIndex + 1;
            
    end
    
end
DifferenceArray = [pad DifferenceArray];


% Ayni oldugu dusunulen noktalari grupla

% Benzer noktaları belirlemek için bir matrisi başlatır.
[row1,col1] = size(DifferenceArray);
%disp(row1);

% Belirli bir eşik değerine göre benzer noktaları belirler.
for DifferenceIndex_1 = 1:row1
    
    for DifferenceIndex_2 = 1:col1
        
        if (DifferenceArray(DifferenceIndex_1,DifferenceIndex_2) < 70 && DifferenceArray(DifferenceIndex_1,DifferenceIndex_2) ~= 0)    
            SamePoint(DifferenceIndex_1,DifferenceIndex_2) = 1;  
        else
            SamePoint(DifferenceIndex_1,DifferenceIndex_2) = 0;
        end
        
    end
    
end

% Benzer noktaların indislerini içeren bir matris oluşturur.
Input2=[];

for DifferenceIndex_1 = 1:ceil(row1/2)
    
    k = 1;
    
    for DifferenceIndex_2 = 1:col1
        
        if(SamePoint(DifferenceIndex_1,DifferenceIndex_2) == 1)
            
                Input2(DifferenceIndex_1,k) = DifferenceIndex_1;
                Input2(DifferenceIndex_1,k+1) = DifferenceIndex_2;
                k = k + 2;
                
        end
        
    end
    
end


% Fazlaliklari ve tekrarlari siler

% Daha fazla işlem için gerekli değişkenleri başlatır.
[row2,col2] = size(Input2);
%disp(size(Input2));
flag = 0;
B_Input2 = Input2;

% Input2 matrisinden fazla elemanları ve tekrarları kaldırır.
for  Temp= 2:col2/2+1
    
    if(mod(Temp,2) == 1 && flag == 0)
       B_Input2(:,Temp) = [];
       flag = 1;
    end
    
    if(mod(Temp,2) == 0  && flag == 1)
        flag = 0;
        B_Input2(:,Temp) = [];
    end
    
end

% Daha fazla işlem için gerekli değişkenleri başlatır.
[row3,col3] = size(B_Input2);
a = 1;
DelNum = [];

% Silinecek indisleri belirler ve DelNum matrisine kaydeder.
for DifferenceIndex_1 = 1:row3
    
    for DifferenceIndex_2 = 1:col3
        
        b = B_Input2(DifferenceIndex_1,DifferenceIndex_2);
        
        if (b < ceil(row1/2) && b ~= DifferenceIndex_1 && b ~= 0)
            DelNum(a) = b;
            a = a + 1;
        end
        
    end
    
end

% Belirlenen indisleri B_Input2_2 matrisinden çıkarır.
B_Input2_2 = B_Input2;
DelRow=0;
[row4,col4] = size(DelNum);

for DelIndex = 1:col4
    B_Input2_2(DelNum(DelIndex)-DelRow,:) = [];
    DelRow=DelRow+1;
end

% Kordinatlarin eslesmesi icin


%Daha fazla işlem için gerekli değişkenleri başlatır.
[row5 , col5] = size(B_Input2_2);
B_Input2_3 = B_Input2_2;
B_Input2_3(:,col5+1) = -1; % ayrac

% Daha fazla işlem için B_Input2_2 matrisini transpoze eder.
B_Input2Transpose_2 = B_Input2_2';

% Karşılık gelen noktaları bulur ve B_Input2_3 matrisini günceller.
for row_i = 1:row5
    
    for col_i = 1:col5
        
            if(B_Input2_2(row_i,col_i) ~= 0)
            
                BuffFounder = floor((find(B_Input2Transpose_2==PointsGroup(B_Input2_2(row_i,col_i),3)))/col5+1); % hangi satir'da oldugu bulunur
            
            if(BuffFounder ~= 0)    
                BuffPointChosen = B_Input2_2(BuffFounder,1);
                B_Input2_3(row_i,col5+1+col_i)=BuffPointChosen;
            end
            
        end
        
    end
    
end


%Orijinal resmi ekranda gösterir.
imshow(Group4+255);
hold on ;

% Belirlenen noktaları birleştiren mavi renkte çizgileri çizer.
[row6 , col6]=size(B_Input2_3);

for r_o = 1:row5
    
    for c_o = col5+2:col6
        
        if(B_Input2_3(r_o,c_o) ~= 0)
            Output1_x = Input1(B_Input2_2(r_o,1),1);
            Output1_y = Input1(B_Input2_2(r_o,1),2);
            Output2_x = Input1(B_Input2_3(r_o,c_o),1);
            Output2_y = Input1(B_Input2_3(r_o,c_o),2);
            drawline('Position',[Output1_x,Output1_y;Output2_x,Output2_y],'Color','blue');
        end
        
    end
    hold on;
end

% Mevcut figürü bir görüntü olarak yakalar.
Group4_2 = getframe(gcf);
[X, Map] = frame2im(Group4_2);

figure;
imshow(X);

