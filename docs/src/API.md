# API
```@meta
CurrentModule = GriddingMachine
```


## Collections

### Gridded datasets
```@docs
Collections.GriddedCollection
Collections.canopy_height_collection
Collections.clumping_index_collection
Collections.elevation_collection
Collections.gpp_collection
Collections.lai_collection
Collections.land_mask_collection
Collections.leaf_chlorophyll_collection
Collections.leaf_nitrogen_collection
Collections.leaf_phosphorus_collection
Collections.pft_collection
Collections.sif_collection
Collections.sla_collection
Collections.soil_color_collection
Collections.soil_hydraulics_collection
Collections.surface_area_collection
Collections.tree_density_collection
Collections.vcmax_collection
Collections.wood_density_collection
```

### Query gridded datasets
```@docs
Collections.query_collection
```

### Clean up collections
```@docs
Collections.clean_collections!
Collections.clean_collections!(selection::String)
Collections.clean_collections!(selection::Vector{String})
Collections.clean_collections!(selection::Collections.GriddedCollection)
```


## Indexer
```@docs
Indexer.lat_ind
Indexer.lon_ind
Indexer.read_LUT
Indexer.read_LUT(fn::String, FT::DataType)
Indexer.read_LUT(fn::String, cyc::Int, FT::DataType)
Indexer.read_LUT(fn::String, lat::Number, lon::Number, res::Number, FT::DataType)
Indexer.read_LUT(fn::String, lat::Number, lon::Number, FT::DataType)
Indexer.read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, res::Number, FT::DataType)
Indexer.read_LUT(fn::String, lat::Number, lon::Number, cyc::Int, FT::DataType)
```
