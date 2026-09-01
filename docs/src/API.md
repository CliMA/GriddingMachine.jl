# API
```@meta
CurrentModule = GriddingMachine
```

The paper-facing workflow uses `Collector` for catalog-backed local data management and
`Indexer` for unified NetCDF access. `Server` and `Requestor` remain compatibility
modules but are outside the updated workflow described here.

## Collector
`Collector` keeps the external YAML catalog separate from package releases. Package
loading does not contact the network; call `load_database!` for a local catalog or
`update_database!` to fetch and transactionally replace it.

```@docs
Collector.configure!
Collector.load_database!
Collector.update_database!
Collector.clean_database!
Collector.sync_database!
Collector.download_dataset!
Collector.dataset_info
Collector.remove_empty_folders!
Collector.verify_dataset_file
```


## Indexer
```@docs
Indexer.lat_ind
Indexer.lon_ind
Indexer.read_dataset
Indexer.read_LUT
```


## Requestor
```@docs
Requestor.request_site_data
```


## Server
```@docs
Server.sitedata_json
Server.gmdict_json
Server.weather_json
Server.query_page
Server.setup_url_input_routes!
Server.up_servers!
Server.down_servers!
```
