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
    end

    return nothing
end




"""
    update_CDSAPI_password!()

Update global user name and password for CDSAPI, note that the `uid:api-key`
    should not contain `{}`.
"""
function update_CDSAPI_password!()
    global CDSAPI_CLIENT, CDSAPI_KEY, CDSAPI_PORTAL;
    if CDSAPI_KEY=="" || CDSAPI_PORTAL==""
        # Install cdsapi if not existing already
        try
            pyimport("cdsapi");
        catch e
            install_cdsapi!();
        end

        # update password and client
        if isfile("$(homedir())/.cdsapirc")
            @info "Load cdsapi information from $(homedir())/.cdsapirc";
            cdsapi        = pyimport("cdsapi");
            CDSAPI_CLIENT = cdsapi.Client();
            CDSAPI_KEY    = CDSAPI_CLIENT.key;
            CDSAPI_PORTAL = CDSAPI_CLIENT.url;
        else
            @warn "Do not share your user name and password with others.";
            @info "Please indicate the cdsapi data portal (url):";
            CDSAPI_PORTAL = readline();
            @info "Please indicate the cdsapi key combo (uid:api-key):";
            CDSAPI_KEY    = read(Base.getpass("Password (invisble)"), String);
            cdsapi        = pyimport("cdsapi");
            CDSAPI_CLIENT = cdsapi.Client(url=CDSAPI_PORTAL, key=CDSAPI_KEY);
        end
    end

    return nothing
end
