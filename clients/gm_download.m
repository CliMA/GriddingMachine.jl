function gm_download(url, output)
% MATLAB/Octave-compatible automatic download entry point.
system(sprintf('python3 clients/download.py --url "%s" --output "%s"', url, output));
end
