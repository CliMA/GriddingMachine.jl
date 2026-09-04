module GriddingMachineServer

import Genie.Renderer.Json as GRJSON

using Genie: down, params, route, up
using OrderedCollections: OrderedDict

using GriddingMachine.Collector: YAML_TAGS, dataset_found, download_dataset!
using GriddingMachine.Indexer: LandDatasetLabels, WeatherDriverLabels, grid_dict, grid_weather, read_dataset

export setup_url_input_routes, down_servers!, up_servers!

include("responses.jl");
include("json-site-data.jl");
include("json-grid-dict.jl");
include("json-grid-weather.jl");
include("web-page.jl");
include("route-setup.jl");
include("route-up-down.jl");


end; # module
