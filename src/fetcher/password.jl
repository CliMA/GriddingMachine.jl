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

    update_EARTHDATA_password!()

Update global user name and password for EarthData, if either of them is empty

"""
function update_EARTHDATA_password!(; force::Bool = false)
    # input EARTH_DATA_ID and EARTH_DATA_PWD
    global EARTH_DATA_ID, EARTH_DATA_PWD;
    if EARTH_DATA_ID == "" || EARTH_DATA_PWD == "" || force
        @warn "Do not share your user name and password with others. Please make sure the user name and password are correct, otherwise they will show up in the error message of wget.";
        @info "Please indicate your user name for Earth Data data portal:";
        EARTH_DATA_ID  = readline();
        @info "Please indicate your password for user $(EARTH_DATA_ID) at Earth Data data portal:";
        EARTH_DATA_PWD = read(Base.getpass("Password (invisble)"), String);
    end;

    return nothing
end;
