module Collections

using Artifacts: @artifact_str
using DocStringExtensions: METHODLIST, TYPEDEF, TYPEDFIELDS
using LazyArtifacts


# export public types
export VcmaxCollection


# export public functions
export query_collection


# collection types
"""
$(TYPEDEF)

Abstract type for gridded dataset collections.
"""
abstract type AbstractCollection end


"""
$(TYPEDEF)

Structure for Vcmax collection

# Fields
$(TYPEDFIELDS)

---
# Examples
vcmax_collection = VcmaxCollection();
"""
struct VcmaxCollection <: AbstractCollection
    "Artifact label name"
    LABEL::String
    "Supported combinations"
    SUPPORTED_COMBOS::Vector{String}

    # constructors
    VcmaxCollection() = new("VCMAX", ["2X_1Y_V1", "2X_1Y_V2"]);
end


"""
Query the data from Julia Artifacts. Supported methods are

$(METHODLIST)
"""
function query_collection end


"""
    query_collection(ds::VcmaxCollection, version::String)

This method queries the Vcmax dataset localtion from collection, given
- `ds` [`VcmaxCollection`](@ref) type collection
- `version` Queried dataset version (must be in `ds.SUPPORTED_COMBOS`)
"""
query_collection(ds::VcmaxCollection, version::String) = (
    # make sure requested version is in the
    @assert version in ds.SUPPORTED_COMBOS;

    # query file via file name
    _fn   = "$(ds.LABEL)_$(version)";
    _file = @artifact_str(_fn) * "/$(_fn).nc";

    return _file
)


end
