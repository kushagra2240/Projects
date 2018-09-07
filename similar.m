function [E] = similar(A,cols)

[x,y]=size(A);
C=zeros(x,y);
%creating the similarity matrix
E=zeros(cols,cols);
%first normalize the c matrix
for i = 1:cols
	C(:,i)=normal(A(:,i));
end

E=C'*C;
%sometimes the cluster is just 1 sentence
if (cols > 1)
	for i=1:cols
		E(i,i)=0;
	end
end

function [D] = normal (A)
	if (norm(A)==0)
		D=0;
	else
		D=A/norm(A);
	end
