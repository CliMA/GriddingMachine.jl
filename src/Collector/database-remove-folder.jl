"""
    remove_empty_folders!(target_dir::String)

Helper function to recursively remove empty directories within a target directory.
It uses a bottom-up approach (topdown=false) so that if a child directory is removed 
and makes the parent empty, the parent will also be removed.
"""
function remove_empty_folders! end

function remove_empty_folders!(target_dir::String) :: Nothing
    if !isdir(target_dir)
        return nothing
    end

    # topdown=false It means traversing the child nodes first, and then traversing the parent node
    for (root, dirs, files) in walkdir(target_dir; topdown=false)
        for d in dirs
            cur_path = joinpath(root, d)
            try
                # Check if the current folder is empty
                if isempty(readdir(cur_path))
                    rm(cur_path)
                end
            catch e
                if !(e isa SystemError && (e.code == Base.Libc.EACCES || e.code == Base.Libc.ENOENT))
                     @error "Error while removing empty folder: $cur_path - $(e)"
                end
            end
        end
    end
    
    return nothing
end