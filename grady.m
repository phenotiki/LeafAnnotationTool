function [mask, probabilities] = grady(img, img_fg, seeds, labels, beta)
% GRADY Wrapper for the random walker segmentation algorithm.
%
% Author:  Massimo Minervini
% Contact: massimo.minervini@imtlucca.it
% Version: 1.0
% Date:    26/06/2015
%
% Copyright (C) 2015 Pattern Recognition and Image Analysis (PRIAn) Unit,
% IMT Institute for Advanced Studies, Lucca, Italy.
% All rights reserved.

% Read image and annotations
[M, N, ~] = size(img);

% Remove background, i.e. differences among neighboring bg pixels will be 0
img = img.*repmat(img_fg, 1, 1, 3);

% Convert RGB image to L*a*b* color space
cform = makecform('srgb2lab');
lab = double(applycform(img, cform));

% Apply the random walker algorithm
tStart = tic;
idx = sub2ind([M N], seeds(:,2), seeds(:,1));
[idx, l] = unique(idx);

[mask, probabilities] = random_walker(lab, idx, labels(l), beta);
fprintf('Random walker done! -- Elapsed time (s): %.2f\n', toc(tStart))

end