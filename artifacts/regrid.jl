###############################################################################
#
# Re-grid the GPP and save it to new nc files
# Un-comment the #==# to redo the regridding
#
###############################################################################
#=
using GriddingMachine

FT = Float32;

# regrid MPI and VPM model to 1 degree resolution to preview
reg_loc = "/net/fluo/data1/ftp/XYZT_CLIMA_LUT/GPP/regridded/";
for year in 2001:2019
    println("MPI GPP @ year ", year);
    mpi_lut = load_LUT(GPPMPIv006{FT}(), year, "2X", "8D");
    reg_lut = regrid_LUT(mpi_lut, 2; nan_weight=true);
    _file   = reg_loc * "GPP_MPI_v006_1X_8D_" * string(year) * ".nc";
    rm(_file, force=true);
    save_LUT(reg_lut, _file);
end

for year in 2000:2019
    println("VPM GPP @ year ", year);
    vpm_lut = load_LUT(GPPVPMv20{FT}(), year, "5X", "8D");
    reg_lut = regrid_LUT(vpm_lut, 5; nan_weight=true);
    _file   = reg_loc * "GPP_VPM_v20_1X_8D_" * string(year) * ".nc";
    rm(_file, force=true);
    save_LUT(reg_lut, _file);
end
=#
