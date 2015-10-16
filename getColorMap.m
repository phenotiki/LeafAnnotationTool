function cmap = getColorMap()
%GETCOLORMAP Return customized color map (based on Tango color palette).
%   Part of the leaf annotation tool described in [1].
%
%   [1] M. Minervini, M. V. Giuffrida, S. A. Tsaftaris, "An interactive tool for semi-automated leaf annotation,"
%       in Proceedings of the Computer Vision Problems in Plant Phenotyping (CVPPP) Workshop, pp. 6.1–6.13.
%       BMVA Press, Sep. 2015.
%
%   Author:  Massimo Minervini
%   Contact: massimo.minervini@imtlucca.it
%   Version: 1.0
%   Date:    26/06/2015
%
%   Copyright (C) 2015 Pattern Recognition and Image Analysis (PRIAn) Unit,
%   IMT Institute for Advanced Studies, Lucca, Italy.
%   All rights reserved.

cmap = [0,0,0; % background
    252,233,79;
    114,159,207;
    239,41,41;
    173,127,168;
    138,226,52;
    233,185,110;
    252,175,62;
    211,215,207;
    196,160,0;
    32,74,135;
    164,0,0;
    92,53,102;
    78,154,6;
    143,89,2;
    206,92,0;
    136,138,133;
    237,212,0;
    52,101,164;
    204,0,0;
    117,80,123;
    115,210,22;
    193,125,17;
    245,121,0;
    186,189,182;
    136,138,133;
    85,87,83;
    46,52,54;
    238,238,236]/255;

end