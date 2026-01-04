module Server

import Genie.Renderer.Json as GRJSON
import Genie.Renderer.Html as GRHTML

using Dates: format, now, seconds
using Genie: down, params, route, up
using Genie.Requests: postpayload
using OrderedCollections: OrderedDict

using ..Collector: YAML_DATABASE, YAML_TAGS, download_dataset!, update_database!
using ..Indexer: LandDatasetLabels, grid_dict, read_dataset
using ..Indexer: grid_weather

# Include feature implementations
include("json-site-data.jl");
include("json-artifact.jl");
include("json-gmdict.jl");
include("json-weather.jl");

# Include web form templates
include("unified-form.jl");
include("web-forms.jl");

# Include route configurations
include("route-setup.jl");
include("route-up-down.jl")





# download the Artifacts.yaml file to local GriddingMachine folder
# GM.update_database!();




# the features meant for different servers
# include("json/artifact_url.jl");
# include("json/sitedata_json.jl");
# include("json/gmdict_json.jl");
# include("json/weather_json.jl");

# setup the the servers
# include("server/url_routes.jl");
# include("server/form_templates.jl");
# include("server/form_routes.jl");
# include("server/up_down.jl");

# tunnel routes to protect private IP to avoid public exposure
# include("server/tunnel_routes.jl");


end; # module
