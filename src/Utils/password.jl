###############################################################################
#
# update the passwords for data portals
#
###############################################################################
"""
    update_MODIS_password!()

Update global user name and password for LP DAAC, if eithe of them is empty
"""
function update_MODIS_password!()
    # input MODIS_USER_ID and MODIS_USER_PWD
    global MODIS_USER_ID, MODIS_USER_PWD;
    if MODIS_USER_ID == "" || MODIS_USER_PWD == ""
        @warn "Do not share your user name and password with others.";
        @info "Please indicate your user name for LP DAAC data portal:";
        MODIS_USER_ID  = readline();
        @info "Please indicate your password for LP DAAC Data portal:";
        MODIS_USER_PWD = read(Base.getpass("Password (invisble)"), String);
    end;

    return nothing
end;
