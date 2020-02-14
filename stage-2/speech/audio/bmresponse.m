function bm = bmresponse(signal, fs, nfilts, f_low, f_high)
% Decompose a signal into bannds of BM responses
% USAGE:
%   bm = itfs(signal, fs, nfilts);
%
% INPUTS:
%   signal - input signal to be band-pass filtered
%   fs - sampling rate of the signals involved
%   nfilts (optional) - number of bands to contruct TF representation with 
%   f_low (optional) - low end of the frequency bands
%   f_high (optional) - high end of the frequency bands
%
% OUTPUTS:
%   bm - basilar membrane reponses from nfilts channels, if signal is a row
%   vector, bm would be a matrix of nfilts rows
%

if ~exist('nfilts', 'var')
    nfilts  = 128;
end

if ~exist('f_low', 'var')
    f_low = 80;
end

if ~exist('f_high', 'var')
    f_high = 8000;
end

% Equally space CFs on an ERB scale
cfs = invcams(linspace(cams(f_low), cams(f_high), nfilts));

% Extract BM responses 
% Phase align the filters so that resynthesizing is trivial

fprintf(1, 'Extracting basilar membrane filter outputs!\n');
bm = gammatoneFast(signal, cfs, fs, true);
