function test_matlab(directory)
% Exercise the installed download function inside a real licensed MATLAB session.
config = jsondecode(fileread(fullfile(directory, 'fixture.json')));
original_directory = pwd;
original_path = path;
% Restore caller state even if a regression causes the validation to fail.
restore = onCleanup(@() restore_state(original_directory, original_path));
addpath(config.bundle);
cd(config.work);
fprintf('MATLAB version: %s\n', version);

% Use UTF-8 characters and shell punctuation while keeping every file temporary.
output_directory = fullfile(config.work, 'new nested folder');
scenarios = {'legacy_url', 'integrity', 'tag', 'bad_sha', 'bad_size', 'explicit_script'};
passed = {};
for index = 1:numel(scenarios)
    scenario = scenarios{index};
    filename = [char([25968, 25454]), ' output & 20% '' ! ', scenario, '.nc'];
    output = fullfile(output_directory, filename);
    failure = any(strcmp(scenario, {'bad_sha', 'bad_size'}));
    if failure
        % A rejected transfer must preserve an already valid local file.
        previous = uint8('previous-valid-file');
        write_bytes(output, previous);
    end
    caught = false;
    try
        switch scenario
            case 'legacy_url'
                gm_download(config.url, output);
            case 'integrity'
                gm_download(config.url, output, 'Size', config.size, 'SHA256', config.sha256);
            case 'tag'
                gm_download('', output, 'Tag', 'TEST_FIXTURE', 'Catalog', config.catalog);
            case 'bad_sha'
                gm_download(config.url, output, 'Size', config.size, 'SHA256', repmat('0', 1, 64));
            case 'bad_size'
                gm_download('', output, 'Tag', 'TEST_FIXTURE', 'Catalog', config.bad_catalog);
            case 'explicit_script'
                gm_download(config.url, output, 'Script', config.script);
        end
    catch problem
        if ~failure, rethrow(problem); end
        % A script-launch or licensing error cannot count as an integrity-test pass.
        assert(strcmp(problem.identifier, 'GriddingMachine:Download'), problem.message);
        expected = 'SHA256 mismatch';
        if strcmp(scenario, 'bad_size'), expected = 'size mismatch'; end
        assert(contains(problem.message, expected), problem.message);
        caught = true;
    end
    if failure
        assert(caught, 'An invalid integrity check incorrectly succeeded.');
        assert(isequal(read_bytes(output), previous(:)), 'Previous file was modified.');
    else
        assert(isequal(read_bytes(output), uint8(config.payload(:))), 'Downloaded bytes differ.');
    end
    % Check hidden sibling temporary files as well as visible files.
    assert(isempty(dir(fullfile(output_directory, '*.part'))), 'Temporary download residue remains.');
    passed{end + 1} = scenario;
    fprintf('PASS MATLAB %s\n', scenario);
end

% Persist machine-readable evidence only after all six runtime cases pass.
report = struct('matlab_version', version, 'passed', {passed}, 'count', numel(passed));
file = fopen(fullfile(directory, 'matlab_results.json'), 'w', 'n', 'UTF-8');
assert(file >= 0, 'Unable to write validation results.');
close_report = onCleanup(@() fclose(file));
fprintf(file, '%s\n', jsonencode(report));
fprintf('MATLAB: %d/%d cases passed.\n', numel(passed), numel(scenarios));
end

function result = read_bytes(filename)
% Compare binary content without text decoding or newline conversion.
file = fopen(filename, 'rb');
assert(file >= 0, 'Unable to open downloaded file.');
close_file = onCleanup(@() fclose(file));
result = fread(file, Inf, '*uint8');
end

function write_bytes(filename, bytes)
% Set up the previous-file fixture without altering the production downloader.
[parent, ~, ~] = fileparts(filename);
if exist(parent, 'dir') ~= 7, mkdir(parent); end
file = fopen(filename, 'wb');
assert(file >= 0, 'Unable to create previous-file fixture.');
close_file = onCleanup(@() fclose(file));
fwrite(file, bytes, 'uint8');
end

function restore_state(directory, saved_path)
% Leave a reusable MATLAB session with the same search path and working directory.
cd(directory);
path(saved_path);
end
