

function [T]= entropy_fuzzy_threshold(C)
%%%%Histogram probability computation
Image=round(C);
for i=1:size(Image,1)
    for j=1:size(Image,2)
        if Image(i,j)==0;
            Image(i,j)=1;
        end;
    end;
end;

Ns=max(max(Image));
% Ns1=min(min(Image));
hist1=zeros(1,Ns);
for h=1:Ns
for i=1:size(Image,1)
    for j=1:size(Image,2)
        if Image(i,j)==h;
            hist1(1,h)=hist1(1,h)+1;
        end;
    end;
end;

if hist1(1,h)==0
    hist1(1,h)=1;
end;

end;
figure,plot(hist1);
hist1=double(hist1/max(hist1));


%%%%%fuzzy entropy method
H=zeros(1,Ns);
for T=1:Ns
    m0=0;m1=0;
    a1=sum(sum(hist1(1:T)));
    nhist1(1:T)=(hist1(1:T))/a1;
    
    for j=1:T
        m0=m0+j*nhist1(j);
    end;
    
    
    a2=sum(sum(hist1(T+1:Ns)));
    nhist2(T+1:Ns)=(hist1(T+1:Ns))/a2;
    
    for j=T+1:Ns
        m1=m1+j*nhist2(j);
    end;
    
    
    H1=0;H2=0;
    for i=1:T
        H1=H1-nhist1(i)*log(nhist1(i))*(1/(1+abs(i-m0)/Ns));
    end;

    
    for i=(T+1):Ns
        H2=H2-nhist2(i)*log(nhist2(i))*(1/(1+abs(i-m1)/Ns));
    end;
    H(T)=H1+H2;
end;

% figure,plot(H);
Tc=round(mean(mean(Image)));
Tenf=find(H==max(H(Tc-30:Tc+30)));
T=Tenf


% bC=C>Ten;
% figure,imagesc(bC);colormap gray;