function [Z] = Sobel_test( a, n1, b, n2);
%An interactive calculation tool for Mediation tests 
% http://quantpsy.org/sobel/sobel.htm  

p1=y_Corr2p(a,n1);
Sa=(1-p1^2)/sqrt(n1-1)
p2=y_Corr2p(b,n2);
Sb=(1-p2^2)/sqrt(n2-1)
Z=a*b/sqrt(b^2*Sa^2+a^2*Sb^2);
end