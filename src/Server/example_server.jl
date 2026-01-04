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
println("Updating GriddingMachine database...");
GriddingMachine.update_database!();

# Set up public routes (no authentication required)
println("\nSetting up server routes...");
Server.setup_public_routes!();

# Start the server on port 5055
println("\nStarting GriddingMachine server on port 5055...");
println("Access the web interface at: http://localhost:5055/");
println("Press Ctrl+C to stop the server.\n");

# Start the server (this blocks until Ctrl+C)
Server.up_servers!(5055);
