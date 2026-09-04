#=
`rm` and `readdir` report failures as `Base.IOError`, a libuv wrapper carrying a negative
`code`, not as `SystemError`. Matching on `SystemError` here would never fire.
=#

"""Failures that only mean "nothing to tidy here" and are not worth reporting."""
const BENIGN_IO_CODES = (Base.UV_EACCES, Base.UV_ENOENT, Base.UV_EPERM, Base.UV_ENOTEMPTY)

function _report_unless_benign(caught, path::AbstractString)
    caught isa Base.IOError && caught.code in BENIGN_IO_CODES && return nothing
    @error "Could not remove empty folder" path caught
    return nothing
end

"""

    remove_empty_folders!(target_dir::String)

Recursively remove empty directories inside `target_dir`, given
- `target_dir` directory to clean up

Traversal is bottom-up, so a parent that becomes empty after its children are removed is
removed as well. `target_dir` itself is kept, and a missing `target_dir` is a no-op.

A directory that cannot be listed or removed is skipped rather than aborting the walk: this
only tidies up, so a permission error or a directory that reappeared is not a failure.

`clean_database!` deletes files but leaves the directories that held them, so this is
offered as a separate step rather than wired into it.
"""
function remove_empty_folders! end

function remove_empty_folders!(target_dir::String) :: Nothing
    isdir(target_dir) || return nothing

    # walkdir aborts the whole traversal on an unreadable subdirectory unless onerror is given
    skip_unreadable(caught) = _report_unless_benign(caught, target_dir)

    # topdown = false visits children before their parent
    for (root, dirs, files) in walkdir(target_dir; topdown = false, onerror = skip_unreadable)
        for dir in dirs
            current = joinpath(root, dir)
            try
                isempty(readdir(current)) && rm(current)
            catch caught
                _report_unless_benign(caught, current)
            end
        end
    end

    return nothing
end
