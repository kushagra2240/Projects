function [AS,kcol,dcol] = cluster (AS,x,y)
%merge the two sentences and get rid of the other one
if (x<y)	
	AS(:,x)=AS(:,x)+AS(:,y);
	dcol=y;
	kcol=x;
	AS(:,y)=[];
else 
	AS(:,y)=AS(:,x)+AS(:,y);
	dcol=x;
	kcol=y;
	AS(:,x)=[];
end
