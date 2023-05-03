"""

    install_cdsapi!()

Install cdsapi package if it does not exist

"""
function install_cdsapi!()
    @info "Install cdsapi from conda-forge channel";
    add("cdsapi"; channel="conda-forge");

    return nothing
end;


"""

    update_CDSAPI_info!()

Update global user name and password for CDSAPI (note that the `uid:api-key` should not contain `{}`).

"""
function update_CDSAPI_info!()
    global CDSAPI_CLIENT, CDSAPI_KEY, CDSAPI_PORTAL;
    if CDSAPI_KEY=="" || CDSAPI_PORTAL==""
        # Install cdsapi if not existing already
        try
            pyimport("cdsapi");
        catch e
            install_cdsapi!();
        end;

        # update password and client
        cdsapi = pyimport("cdsapi");
        if isfile("$(homedir())/.cdsapirc")
            @info "Load cdsapi information from $(homedir())/.cdsapirc";
            CDSAPI_CLIENT = cdsapi.Client();
            CDSAPI_KEY    = CDSAPI_CLIENT.key;
            CDSAPI_PORTAL = CDSAPI_CLIENT.url;
        else
            @warn "Do not share your user name and password with others.";
            @info "Please indicate the cdsapi data portal (url):";
            CDSAPI_PORTAL = readline();
            @info "Please indicate the cdsapi key combo (uid:api-key):";
            CDSAPI_KEY    = read(Base.getpass("Password (invisble)"), String);
            CDSAPI_CLIENT = cdsapi.Client(url=CDSAPI_PORTAL, key=CDSAPI_KEY);
        end;
    end;

    return nothing
end;


"""

    update_MODIS_password!()

Update global user name and password for LP DAAC, if either of them is empty

"""
function update_MODIS_password!()
    # input WGET_USER_ID and WGET_USER_PWD
    global WGET_USER_ID, WGET_USER_PWD;
    if WGET_USER_ID == "" || WGET_USER_PWD == ""
        @warn "Do not share your user name and password with others.";
        @info "Please indicate your user name for LP DAAC data portal:";
        WGET_USER_ID  = readline();
        @info "Please indicate your password for LP DAAC Data portal:";
        WGET_USER_PWD = read(Base.getpass("Password (invisble)"), String);
    end;

    return nothing
end;
