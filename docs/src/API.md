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
Collector.latent_heat_collection
Collector.leaf_chlorophyll_collection
Collector.leaf_drymass_collection
Collector.leaf_nitrogen_collection
Collector.leaf_phosphorus_collection
Collector.pft_collection
Collector.sif_collection
Collector.sil_collection
Collector.sla_collection
Collector.soil_color_collection
Collector.soil_hydraulics_collection
Collector.surface_area_collection
Collector.tree_density_collection
Collector.vcmax_collection
Collector.vegetation_cover_fraction
Collector.wood_density_collection
```

### Query gridded datasets
```@docs
Collector.query_collection
```

### Clean up collections
```@docs
Collector.clean_collections!
```

### Sync collections
```@docs
Collector.sync_collections!
```


## Indexer
```@docs
Indexer.lat_ind
Indexer.lon_ind
Indexer.read_LUT
```


## Requestor
```@docs
Requestor.request_LUT
```
