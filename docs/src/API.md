# API
```@meta
CurrentModule = GriddingMachine
```


## Collector

### Gridded datasets
```@docs
Collector.GriddedCollection
Collector.biomass_collection
Collector.canopy_height_collection
Collector.clumping_index_collection
Collector.elevation_collection
Collector.gpp_collection
Collector.lai_collection
Collector.land_mask_collection
Collector.leaf_chlorophyll_collection
Collector.leaf_nitrogen_collection
Collector.leaf_phosphorus_collection
Collector.pft_collection
Collector.sif_collection
Collector.sla_collection
Collector.soil_color_collection
Collector.soil_hydraulics_collection
Collector.surface_area_collection
Collector.tree_density_collection
Collector.vcmax_collection
Collector.wood_density_collection
```

### Query gridded datasets
```@docs
Collector.query_collection
Collector.query_collection(artname::String)
Collector.query_collection(ds::Collector.GriddedCollection, version::String)
Collector.query_collection(ds::Collector.GriddedCollection)
```

### Clean up collections
```@docs
Collector.clean_collections!
Collector.clean_collections!(selection::String)
Collector.clean_collections!(selection::Vector{String})
Collector.clean_collections!(selection::Collector.GriddedCollection)
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


## Requestor
```@docs
Requestor.request_LUT
Requestor.request_LUT(artname::String, lat::Number, lon::Number, cyc::Int)
```
