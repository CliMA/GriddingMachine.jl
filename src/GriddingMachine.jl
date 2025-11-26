module GriddingMachine


# # make sure the GriddingMachine directory exists
GRIDDINGMACHINE_HOME = joinpath(homedir(), "GriddingMachine");
mkpath(GRIDDINGMACHINE_HOME);
mkpath(joinpath(GRIDDINGMACHINE_HOME, "cache"));
mkpath(joinpath(GRIDDINGMACHINE_HOME, "public"));


# include the modules
include("Collector/Collector.jl");


# export Collector, Fetcher, Indexer, Requestor
#
#
# mkpath(joinpath(GRIDDINGMACHINE_HOME, "public"));
# mkpath(joinpath(GRIDDINGMACHINE_HOME, "tarballs"));
#
#
# # database related functions
# include("database/index.jl");
# include("database/judge.jl");
#
# if isfile(YAML_FILE)
#     global YAML_DATABASE, YAML_SHAS, YAML_TAGS;
#     YAML_DATABASE = YAML.load_file(YAML_FILE);
#     YAML_SHAS = [v["SHA"] for v in values(YAML_DATABASE)];
#     YAML_TAGS = [k for k in keys(YAML_DATABASE)];
# else
#     update_database!();
# end;


# include submodules
# include("Fetcher.jl");
# include("Indexer.jl");
# include("Requestor.jl");


end # module
