"""

    remove_empty_folders!(target_dir::String)

Recursively remove empty directories inside `target_dir`, given
- `target_dir` directory to clean up

Traversal is bottom-up, so a parent that becomes empty after its children are removed is
removed as well. `target_dir` itself is kept. A missing `target_dir` is a no-op.

`clean_database!` deletes files but leaves the directories that held them, so this is
provided as a separate step rather than wired into it.
"""
function remove_empty_folders! end

function remove_empty_folders!(target_dir::String) :: Nothing
    isdir(target_dir) || return nothing

    # topdown = false visits children before their parent
    for (root, dirs, files) in walkdir(target_dir; topdown = false)
        for dir in dirs
            current = joinpath(root, dir)
            try
                isempty(readdir(current)) && rm(current)
            catch caught
                if !(caught isa SystemError && caught.errnum in (Base.Libc.EACCES, Base.Libc.ENOENT))
                    @error "Could not remove empty folder" current caught
                end
            end
        end
    end

    return nothing
end
