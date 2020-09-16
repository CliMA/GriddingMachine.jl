###############################################################################
#
# This file is meant to create a few low reso examples to test the functions
#
###############################################################################
using NetCDF
using Pkg.Artifacts




# create some random matrices as examples (reso = 5°)
begin
    # data
    _LAI = rand(72,36,12);
    _GPP = rand(72,36,46);
    _lat = collect(-87.5:5:87.5);
    _lon = collect(-177.5:5:177.5);
    _mon = [8,9,10,11,12,1,2,3,4,5,6,7];
    _cyc = collect(1:46);

    # attributes
    latatts = Dict("longname" => "Latitude"    , "units" => "°"       );
    lonatts = Dict("longname" => "Longitude"   , "units" => "°"       );
    monatts = Dict("longname" => "Month number", "units" => "-"       );
    cycatts = Dict("longname" => "Cycle number", "units" => "-"       );
    gppatts = Dict("longname" => "GPP"         , "units" => "umol/m^2");
    laiatts = Dict("longname" => "LAI"         , "units" => "m^2/m^2" );

    # create nc file for LAI and GPP example
    nccreate("lai_example.nc", "LAI",
             "lon", _lon, lonatts,
             "lat", _lat, latatts,
             "mon", _mon, monatts,
             atts = laiatts);
    ncwrite(_LAI, "lai_example.nc", "LAI");
    nccreate("gpp_example.nc", "GPP",
             "lon", _lon, lonatts,
             "lat", _lat, latatts,
             "cyc", _cyc, cycatts,
             atts = gppatts);
    ncwrite(_GPP, "gpp_example.nc", "GPP");
end




# Artifacts.toml file to manipulate
artifact_toml = joinpath(@__DIR__, "../Artifacts.toml");




# FTP url for the datasets
ftp_url = "ftp://fluo.gps.caltech.edu/XYZT_CLIMA_LUT";
ftp_loc = "/net/fluo/data1/ftp/XYZT_CLIMA_LUT";




# Gridded per 5 degree, using for test
# Query the example hash from Artifacts.toml, if not existing create one
exa_hash = artifact_hash("example", artifact_toml);

# need to run this for every new installation, because the calcualted SHA
# differs among computers
if isnothing(exa_hash) || !artifact_exists(exa_hash)
    println("No artifacts found for example, deploy it now...");

    exa_hash = create_artifact() do artifact_dir
        cp("gpp_example.nc", joinpath(artifact_dir, "gpp_example.nc"));
        cp("lai_example.nc", joinpath(artifact_dir, "lai_example.nc"));
    end
    @show exa_hash;

    tar_url  = "$(ftp_url)/example/example.tar.gz";
    tar_loc  = "example.tar.gz";
    tar_hash = archive_artifact(exa_hash, tar_loc);
    @show tar_hash;

    bind_artifact!(artifact_toml, "example", exa_hash;
                   download_info=[(tar_url, tar_hash)],
                   lazy=true,
                   force=true);
else
    println("Artifact of example already exists, skip it");
end
