function output = gm_download(url, output, varargin)
% Download by URL or catalog tag through the shared Python implementation.
% Example: gm_download('', out, 'Tag', tag, 'Catalog', catalog).

% Preserve the two-argument API while exposing Python's integrity options.
p = inputParser;
addParameter(p, 'Tag', '');
addParameter(p, 'Catalog', '');
addParameter(p, 'Size', []);
addParameter(p, 'SHA256', '');
addParameter(p, 'Python', '');
addParameter(p, 'Script', '');
parse(p, varargin{:});
opts = p.Results;
args = {'--output', char(output)};
if ~isempty(opts.Tag)
    if ~isempty(url), error('GriddingMachine:Arguments', 'Use URL or Tag, not both.'); end
    args = [args, {'--tag', char(opts.Tag), '--catalog', char(opts.Catalog)}];
else
    args = [args, {'--url', char(url)}];
end
if ~isempty(opts.Size), args = [args, {'--size', num2str(opts.Size, 17)}]; end
if ~isempty(opts.SHA256), args = [args, {'--sha256', char(opts.SHA256)}]; end

% Resolve the script beside this function, independently of the working directory.
script = char(opts.Script);
if isempty(script), script = getenv('GM_DOWNLOADER'); end
if isempty(script), script = fullfile(fileparts(mfilename('fullpath')), 'download.py'); end
python = char(opts.Python);
if isempty(python), python = getenv('GM_PYTHON'); end
if isempty(python)
    if ispc, python = 'python'; else, python = 'python3'; end
end
if exist(script, 'file') ~= 2, error('GriddingMachine:Script', 'Downloader not found: %s', script); end

% Encode the script and user arguments so shells never interpret their contents.
bootstrap = 'import runpy,sys;runpy.run_path(bytes.fromhex(sys.argv.pop(1)).decode(''utf-8''),run_name=''__main__'')';
cmd = [shell_quote(python), ' -c ', shell_quote(bootstrap), ' ', hex_utf8(script), ' --encoded-args'];
for k = 1:numel(args), cmd = [cmd, ' x', hex_utf8(args{k})]; end
[status, message] = system(cmd);
% Propagate download and integrity failures to the calling scientific program.
if status ~= 0, error('GriddingMachine:Download', 'Download failed (%d): %s', status, message); end
end

function encoded = hex_utf8(value)
% Preserve UTF-8 text, spaces, quotes, and shell metacharacters in ASCII tokens.
encoded = lower(reshape(dec2hex(unicode2native(char(value), 'UTF-8'), 2).', 1, []));
end

function quoted = shell_quote(value)
% Only the interpreter and fixed bootstrap enter shell syntax.
if ispc
    if any(ismember(value, ['"', '%', '!', char(10), char(13)]))
        error('GriddingMachine:Python', 'Use an interpreter path without quotes or shell expansion characters.');
    end
    quoted = ['"', value, '"'];
else
    quoted = ['''', strrep(value, '''', '''"''"'''), ''''];
end
end
