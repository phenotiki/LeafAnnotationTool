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
%   Copyright (C) 2015 Massimo Minervini
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
