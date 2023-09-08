module Collector

using Artifacts: @artifact_str, load_artifacts_toml
using DocStringExtensions: TYPEDEF, TYPEDFIELDS
using LazyArtifacts

import Base: show

export clean_collections!, query_collection, sync_collections!


# collection types
"""

$(TYPEDEF)

Structure for general gridded dataset collection.

# Fields

$(TYPEDFIELDS)

---
# Examples
```julia
vcmax_collection = GriddedCollection("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"], "2X_1Y_V2");
```

"""
struct GriddedCollection
    "Artifact label name"
    LABEL::String
    "Supported combinations"
    SUPPORTED_COMBOS::Vector{String}
    "Default combination"
    DEFAULT_COMBO::String
end


# constructors for GriddedCollection
include("collector/biomass.jl")
include("collector/canopy.jl")
include("collector/gpp.jl")
include("collector/lai.jl")
include("collector/land.jl")
include("collector/le.jl")
include("collector/leaf.jl")
include("collector/pft.jl")
include("collector/sif.jl")
include("collector/soil.jl")


show(io::IO, col::GriddedCollection) = (
    # display the label
    print(io, "\n");
    printstyled(io, "    LABEL           ", color=:light_magenta);
    print(io, " ⇨ \""* col.LABEL* "\"\n");

    # display the supported combos
    printstyled(io, "    SUPPORTED_COMBOS", color=:light_magenta);
    print(io," ⇨ [\n");
    for _i in eachindex(col.SUPPORTED_COMBOS)
        if _i < length(col.SUPPORTED_COMBOS)
            print(io, "                        \"" * col.SUPPORTED_COMBOS[_i] * "\",\n");
        else
            print(io, "                        \"" * col.SUPPORTED_COMBOS[_i] * "\"\n");
        end;
    end;
    print(io, "                       ]\n");

    # display the default combo
    printstyled(io, "    DEFAULT_COMBO   ", color=:light_magenta);
    print(io, " ⇨ \"" * col.DEFAULT_COMBO * "\"\n");

    return nothing
);



"""

    query_collection(ds::GriddedCollection)
    query_collection(ds::GriddedCollection, version::String)
    query_collection(artname::String)

This method queries the local data path from collection for the default data, given
- `ds` [`GriddedCollection`](@ref) type collection
- `version` Queried dataset version (must be in `ds.SUPPORTED_COMBOS`)
- `artname` Artifact name

---
# Examples
```julia
dat_file = query_collection(canopy_height_collection());
dat_file = query_collection(canopy_height_collection(), "20X_1Y_V1");
```

"""
function query_collection end

query_collection(ds::GriddedCollection) = query_collection(ds, ds.DEFAULT_COMBO);

query_collection(ds::GriddedCollection, version::String) = (
    # make sure requested version is in the
    @assert version in ds.SUPPORTED_COMBOS "$(version)";

    # determine file name from label and supported version
    _fn = "$(ds.LABEL)_$(version)";

    return query_collection(_fn)
);

query_collection(artname::String) = (
    _metas = load_artifacts_toml(joinpath(@__DIR__, "../Artifacts.toml"));
    _artns = [_name for (_name,_) in _metas];
    @assert artname in _artns artname;

    return @artifact_str(artname) * "/$(artname).nc"
);


"""

    clean_collections!(selection::String="old")
    clean_collections!(selection::Vector{String})
    clean_collections!(selection::GriddedCollection)

This method cleans up all selected artifacts of GriddingMachine.jl (through identify the `GRIDDINGMACHINE` file in the artifacts), given
- `selection`
    - A string indicating which artifacts to clean up
        - `old` Artifacts from an old version of GriddingMachine.jl (default)
        - `all` All Artifacts from GriddingMachine.jl
    - A vector of artifact names
    - A [`GriddedCollection`](@ref) type collection

---
# Examples
```julia
clean_collections!();
clean_collections!("old");
clean_collections!("all");
clean_collections!(["PFT_2X_1Y_V1"]);
clean_collections!(pft_collection());
```

"""
function clean_collections! end

clean_collections!(selection::String="old") = (
    # read the SHA1 identifications in Artifacts.toml
    _metas = load_artifacts_toml(joinpath(@__DIR__, "../Artifacts.toml"));
    _hashs = [_meta["git-tree-sha1"] for (_,_meta) in _metas];

    # iterate through the artifacts and remove the old one that is not in current Artifacts.toml or remove all artifacts within GriddingMachine.jl
    _artifact_dirs = readdir("$(homedir())/.julia/artifacts");
    for _dir in _artifact_dirs
        if isdir("$(homedir())/.julia/artifacts/$(_dir)")
            if isfile("$(homedir())/.julia/artifacts/$(_dir)/GRIDDINGMACHINE")
                if selection == "all"
                    rm("$(homedir())/.julia/artifacts/$(_dir)"; recursive=true, force=true);
                else
                    if !(_dir in _hashs)
                        rm("$(homedir())/.julia/artifacts/$(_dir)"; recursive=true, force=true);
                    end;
                end;
            end;
        end;
    end;

    return nothing
);

clean_collections!(selection::Vector{String}) = (
    # read the SHA1 identifications in Artifacts.toml
    _metas = load_artifacts_toml(joinpath(@__DIR__, "../Artifacts.toml"));
    _hashs = [_metas[_artn]["git-tree-sha1"] for _artn in selection];

    # iterate the artifact hashs to remove corresponding folder
    for _dir in _hashs
        rm("$(homedir())/.julia/artifacts/$(_dir)"; recursive=true, force=true);
    end;

    return nothing
);

clean_collections!(selection::GriddedCollection) = (
    clean_collections!(["$(selection.LABEL)_$(_ver)" for _ver in selection.SUPPORTED_COMBOS]);

    return nothing
);


"""

    sync_collections!()
    sync_collections!(gcs::GriddedCollection)

Sync collection datasets to local drive, given
- `gc` [`GriddedCollection`](@ref) type collection

"""
function sync_collections! end

sync_collections!(gc::GriddedCollection) = (
    for _version in gc.SUPPORTED_COMBOS
        query_collection(gc, _version);
    end;

    return nothing
);

sync_collections!() = (
    # loop through all datasets
    _functions = Function[biomass_collection, canopy_height_collection, clumping_index_collection, elevation_collection, gpp_collection, lai_collection, land_mask_collection,
                          leaf_chlorophyll_collection, leaf_nitrogen_collection, leaf_phosphorus_collection, pft_collection, sif_collection, sil_collection, soil_color_collection,
                          soil_hydraulics_collection, soil_texture_collection, sla_collection, surface_area_collection, tree_density_collection, vcmax_collection, wood_density_collection];
    for _f in _functions
        sync_collections!(_f());
    end;

    return nothing
);


end # module
