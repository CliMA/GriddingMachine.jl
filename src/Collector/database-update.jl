""" Update the database of GriddingMachine.jl """
function update_database!()
    download_database!();
    load_database!();

    return nothing
end;
