function [B] = svd_mod(A,k)

[U,S,V]=svd(A,0);
size(S);
ST=S(1:k,1:k);
UT=U(:,1:k);
VT=V(:,1:k);


B=UT*ST*VT';
min(min(B));
