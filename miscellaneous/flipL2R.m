function newIm = flipLtRt(im)
% newIm is impage im flipped from left to right

[nr,nc,np]= size(im);    % dimensions of im
newIm= zeros(nr,nc,np);  % initialize newIm with zeros
% newIm= uint8(newIm);     % Matlab uses unsigned 8-bit int for color values


for r= 1:nr
    for c= 1:nc
        for p= 1:np
            newIm(r,c,p)= im(nr-r+1,c,p);
        end
    end
end


% newIm(r,c,p)= im(nr-r+1,c,p);

% newIm(r,c,p)= im(r,nc-c+1,p);  % for figures, change columns
% The code iterate over the rows of the image im, which is represented by a
% matrix with nr rows and nc columns, flipping:
% 
%     The 1st column with the last;
%     The 2nd column with the penultimate;
%     The c-th column with the nc-(c-1)th column;
