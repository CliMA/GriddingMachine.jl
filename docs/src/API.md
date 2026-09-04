# API

The paper-facing workflow uses `Collector` for catalog-backed local data management and
`Indexer` for unified NetCDF access. `Server` and `Requestor` remain compatibility
modules but are outside the updated workflow described here.

## Collector
`Collector` keeps the external YAML catalog separate from package releases. Package
loading does not contact the network; call `load_database!` for a local catalog or
`update_database!` to fetch and transactionally replace it.

```@docs
GriddingMachine.Collector.configure!
GriddingMachine.Collector.load_database!
GriddingMachine.Collector.update_database!
GriddingMachine.Collector.clean_database!
GriddingMachine.Collector.sync_database!
GriddingMachine.Collector.download_dataset!
GriddingMachine.Collector.dataset_info
GriddingMachine.Collector.remove_empty_folders!
GriddingMachine.Collector.verify_dataset_file
```


## Indexer
```@docs
GriddingMachine.Indexer.lat_ind
GriddingMachine.Indexer.lon_ind
GriddingMachine.Indexer.read_dataset
GriddingMachine.Indexer.read_LUT
```


## Requestor
```@docs
GriddingMachine.Requestor.request_site_data
```


## GriddingMachineServer
```@docs
GriddingMachineServer.sitedata_json
GriddingMachineServer.gmdict_json
GriddingMachineServer.weather_json
GriddingMachineServer.query_page
GriddingMachineServer.setup_url_input_routes!
GriddingMachineServer.up_servers!
GriddingMachineServer.down_servers!
```
