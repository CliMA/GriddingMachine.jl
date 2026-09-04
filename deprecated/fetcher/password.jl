#######################################################################################################################################################################################################
#
# Changes to the function
# General
#
#######################################################################################################################################################################################################
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
