###############################################################################
#
# Determine the latitude and longitude index in matrix
#
###############################################################################
"""
    update_password()

Update global user name and password for LP DAAC, if eithe of them is empty
"""
function update_password()
    # input USER_NAME and USER_PASS
    global USER_NAME, USER_PASS;
    if USER_NAME == "" || USER_PASS == ""
        @warn "Do not share your user name and password with others.";
        @info "Please indicate your user name for LP DAAC data portal:";
        USER_NAME = readline();
        @info "Please indicate your password for LP DAAC Data portal:";
        USER_PASS = readline();
    end

    return nothing
end
