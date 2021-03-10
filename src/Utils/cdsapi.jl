###############################################################################
#
# Install cdsapi package for Conda Python
#
###############################################################################
"""
    install_cdsapi!()

Install cdsapi package if it does not exist
"""
function install_cdsapi!()
    @info "Install cdsapi from conda-forge channel";
    Conda.add("cdsapi"; channel="conda-forge");

    return nothing
end
