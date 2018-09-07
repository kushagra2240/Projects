function [] = mat(k,comp)

if (nargin < 2) comp=30;, end
if (nargin < 1) k=40;, end
    
load mat_test.txt;
A=mat_test';
[r,c]=size(A);
%ctr is a counter matrix, keeping track of which cluster contains which sentences
%initially, each sentence is a cluster, thus only diagonals are 1
ctr = zeros (c,c);
for i=1:c
	ctr(i,i)=1;
end
k
comp
%k is the number of features we want
%k=40;
%comp is the compression ratio  ratio
%comp = 30;
%AS is the matrix after performing svd on A
AS = svd_mod (A,k);
[row,cols]=size (AS);
col=cols;
%while the number of columns in AS > columns/compression ratio
%col is the number of columns in the current AS matrix
while col > (cols/comp)
%as we get more clusters, we must reduce the number of features we are looking at	
	if ((k+1)>=(cols/comp))
		v=floor(cols/comp);
		k=v-1;
	end
	%calculate similarity matrix
	Sim = similar(AS,col);
	%find oordinates of maximum elements
	[x,y]=find ( (max(max(Sim))) == Sim );
	%x(1),y(1) hold the coords of the most similar sentences
	%kcol is the column number of the vector to be kept, dcol the column number of vector to be deleted
	[AS,kcol,dcol] = cluster (AS,x(1),y(1));
	%modify the ctr matrix
	ctr(kcol,:)=ctr(kcol,:)+ctr(dcol,:);
	ctr(dcol,:)=[];
	% again perform svd on the new matrix
	AS = svd_mod(AS,k);
	[row,col]=size (AS);
end
centroid(A,ctr);
%save('test','ctr', '-ascii')
