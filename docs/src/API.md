# API
```@meta
CurrentModule = GriddingMachine
```

GrridingMachine contains three major submodules:
`Collector, Indexer, and Requestor`...


## Collector
The `Collector` module is the file system manager for GriddingMachine. It is responsible for:
1. **Database Management:** Synchronizing the local Artifacts.yaml with the remote Zenodo repository.
2. **Dataset Acquisition:** Downloading specific datasets (NetCDF files) from the fastest available mirror.
3. **Maintenance:** Cleaning up obsolete files to save disk space.

### Database Management
The first step when using GriddingMachine is usually to ensure your local library definition is up to date. This creates the necessary folder structure (cache and public) and downloads the latest metadata.

```@docs
Collector.update_database!
Collector.initialize_database!
Collector.download_database!
Collector.load_database!
```

### Dataset Operations
These functions are used to acquire specific data or manage the local storage.
```@docs
Collector.download_dataset!
Collector.clean_database!
Collector.sync_database!
```

### Helper Functions & Metadata
These functions allow you to query information about specific datasets (e.g., file paths, URLs) or inspect the status of the local database.

```@docs
Collector.dataset_found
Collector.dataset_path
Collector.dataset_cache
Collector.dataset_dir
Collector.dataset_url
Collector.latest_datasets
Collector.local_datasets
```

### Structure Breakdown: 
1.  **logical structure**：
    * **Database Management**：Added `update`, `initialize`, `download`, `load`, which are the basis for user configuration of the environment.
    * **Dataset Operations**：：Added `download_dataset!` (Core functions) as well as `clean` and `sync`, which are user operations for adding and deleting data.
    * **Helper Functions**：Added `dataset-path`, `dataset_found`, etc., which are usually called by advanced users or developers when obtaining paths in scripts.
2.  **Document string reference**：The prefix `Collector` was used to ensure that Documenter. jl can correctly locate these functions.



## Indexer

The `Indexer` module serves as the **data interface** for GriddingMachine. It handles:
1.  **Data I/O**: Reading NetCDF files directly or via artifact tags.
2.  **Spatial Indexing**: Converting Latitude/Longitude to grid indices.
3.  **Model Preparation**: Packaging data into structures (`LandDatasets`, `WeatherDrivers`) or dictionaries for land surface models (e.g., Emerald).

### Basic Data Reading & Indexing
These are the core functions for general-purpose data access. `read_dataset` is the primary entry point for retrieving data arrays.
```@docs
Indexer.read_dataset
Indexer.lat_ind
Indexer.lon_ind
```


### Environmental Data (CO₂)
Helper functions to retrieve historical atmospheric CO₂ concentrations.
```@docs
Indexer.CO₂_ppm
```

### Model Drivers & Structures (Emerald/SPAC)
These structures and functions are designed to prepare gridded data for the Emerald land surface model or similar SPAC (Soil-Plant-Atmosphere Continuum) simulations. They handle the grouping of various datasets (Soil, Vegetation, Weather) into unified structures.

### Data Structures
Definitions for grouping dataset labels and weather driver data.

```docs
Indexer.LandDatasetLabels
Indexer.WeatherDriverLabels
Indexer.WeatherDrivers
```

### Grid Generators
Functions to extract data for a specific spatial grid point and package it into a dictionary for model consumption.
```docs
Indexer.grid_dict
Indexer.grid_weather
```
### Structure Breakdown:：

1.  **Basic Data Reading & Indexing**：
    * Corresponds to `dataset-read.jl (read_dataset)` and `dataset-index.jl (lat_ind, lon_ind)`. These represent the core functionalities required for general data access.
2.  **Environmental Data (CO₂)**：
    * Corresponds to `emerald-co2.jl`. This is a standalone component dedicated to handling historical atmospheric CO₂ data.
3.  **Model Drivers & Structures**：
    * Encompasses files prefixed with `emerald-` and `grid- `(`emerald-land-datasets.jl`, `emerald-weather-drivers.jl`, `grid-dict.jl`, `grid-weather.jl`).
    * These are categorized into **Data Structures** (type definitions) and **Grid Generators** (data processing functions) to clearly distinguish between data configuration and operational logic.



## Requestor

The `Requestor` module acts as a **client interface** for the GriddingMachine server. It allows users to retrieve data for specific sites (Latitude/Longitude) directly from a remote server without downloading the full global datasets locally.

### Generic Data Requests

This function is the primary tool for querying a single data point (or time series cycle) from any dataset hosted on the GriddingMachine server using its artifact tag (e.g., `LM_4X_1Y_V1`).

```@docs
Requestor.request_site_data
```