# ======================================================================================
# Example Server Script for GriddingMachine.jl
# ======================================================================================
#
# This script demonstrates how to start the GriddingMachine server with public routes.
# Users can access the server through a web browser or make API requests.
#
# Usage:
#   julia example_server.jl
#
# Or from Julia REPL:
#   include("example_server.jl")
#

using GriddingMachine
using GriddingMachine.Server

# Update the database before starting the server
GriddingMachine.Collector.update_database!();

# Set up public routes (no authentication required)
Server.setup_url_input_routes!(["testuser"]);

# Start the server (this blocks until Ctrl+C)
Server.up_servers!(5055);
