function [M, P] = grady(I, I_fg, seeds, labels, beta)
%GRADY Wrapper for the random walker segmentation algorithm proposed by Leo Grady [1].
%   Part of the leaf annotation tool described in [2].
%
%   [1] L. Grady, "Random walks for image segmentation," IEEE Transactions on Pattern Analysis and Machine
%       Intelligence, vol. 28, no. 11, pp. 1768-1783, Nov. 2006.
%   [2] M. Minervini, M. V. Giuffrida, S. A. Tsaftaris, "An interactive tool for semi-automated leaf annotation,"
%       in Proceedings of the Computer Vision Problems in Plant Phenotyping (CVPPP) Workshop, pp. 6.1–6.13.
%       BMVA Press, Sep. 2015.
%
%   Input:
%           I - Input RGB image
%        I_fg - Foreground/background segmentation mask (if not available, use [])
%       seeds - Seed locations
%      labels - Integer object labels for each seed
%        beta - Weighting parameter
%
%   Output:
%           M - Leaf segmentation mask
%           P - Probability estimates for each label
%
%   Author(s): Massimo Minervini
%   Contact:   massimo.minervini@imtlucca.it
%   Version:   1.1
%   Date:      19/10/2015
%
%   Copyright (C) 2015 Pattern Recognition and Image Analysis (PRIAn) Unit,
%   IMT Institute for Advanced Studies, Lucca, Italy.
%   All rights reserved.

% Read image and annotations
[M, N, ~] = size(I);

% Remove background, i.e. differences among neighboring bg pixels will be 0
if ~isempty(I_fg)
    I = I.*repmat(I_fg, 1, 1, 3);
end

% Convert RGB image to L*a*b* color space
cform = makecform('srgb2lab');
lab = double(applycform(I, cform));

% Apply the random walker algorithm
idx = sub2ind([M N], seeds(:,2), seeds(:,1));
[idx, l] = unique(idx);

[M, P] = random_walker(lab, idx, labels(l), beta);

end