function [] = centroid(A,ctr)

[row,col]=size(ctr);

final=[];

for i=1:row
%sen is an array storing the sentence number of original corpus
	sen=[];
	sz=0;
	for j=1:col
%we look at the ctr matrix row wise. each row consists of the sentences in the cluster
		if (ctr(i,j)>0)
			sen=[sen j];
			sz=sz+1;
		end
	end
%tempA is a matrix consisting of the relevant sentences of A, which are to be passed to similar, to calculate similarity
%between each of them, to get centroid
	[r,c]=size(A);
	tempA=zeros(r,sz);
	sen
	for k=1:sz
		colA=sen(k);
		tA=A(:,colA);
		tempA(:,k)=tA;
	end
%actually calculating the centroid, and keeping it in the array final
	S=similar(tempA,sz);
	Sf=zeros(1,sz);
	Sf=sum(tempA);
	fin_sen=find(max(Sf)==Sf);
	f=fin_sen(1);
	f1=sen(f);
	final=[final f1];

end
fid1 = fopen('final.txt','w');
for i=1:row
	fprintf (fid1,'%d\n',final(i));
end
