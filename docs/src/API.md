# API
```@meta
CurrentModule = GriddingMachine
```

GriddingMachine contains three major submodules: ...

## Collector
The Collector module is meant to...
The first step is to update the database library using the `update_database!()`:
```@docs
update_database!
```

```@docs
Collector.clean_database!
Collector.sync_database!
Collector.download_dataset!
```


## Indexer
```@docs
Indexer.lat_ind
Indexer.lon_ind
Indexer.read_LUT
```


## Requestor
```@docs
Requestor.request_site_data
```
