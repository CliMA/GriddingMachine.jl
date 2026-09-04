#=
"""
    check_log_for_condition(df::DataFrame, variable::String, match::String, condition::String)

Check if condition is true for a specific row in the dataframe (where some variable matches a specific value)
- `df` DataFrame to check
- `variable` The variable to match
- `match` The value that the variable should match
- `condition` The condition to check
"""
function check_log_for_condition end;

check_log_for_condition(df::DataFrame, variable::String, match::String, condition::String) = (
    for row in eachrow(df)
        if (row[variable] == match && row[condition])
            return true;
        end;
    end;
    return false;
);

"""
    change_log_condition(df::DataFrame, variable::String, match::String, condition::String, new_val::Bool)

Change condition to specified value for a specific row in the dataframe (where some variable matches a specific value)
- `df` DataFrame to check
- `variable` The variable to match
- `match` The value that the variable should match
- `condition` The condition to check
- `new_val` The new value to store
"""
function change_log_condition end;

change_log_condition(df::DataFrame, variable::String, match::String, conditions::Vector{String}, new_val::Bool) = (
    for row in eachrow(df)
        if (row[variable] == match)
            for con in conditions
                row[con] = new_val
            end;
        end;
    end;
);

change_log_condition(df::DataFrame, variable::String, match::String, condition::String, new_val::Bool) = (
    change_log_condition(df, variable, match, [condition], new_val)
);


"""
    append_to_log(file_path::String, message::String)

Append message to end of log file
- `file_path` Path to log file
- `message` The message to be written in the log file

"""
function append_to_log end;

append_to_log(file_path::String, message::String) = (
    open(file_path, "a") do log
        write(log, "$(message)\n");
    end;
    return nothing;
);


"""
    write_to_log(file_path::String, message::String)

Write message to end of log file as a separate line if message does not exist already
- `file_path` Path to log file
- `message` The message to be written in the log file

"""
function write_to_log end;

write_to_log(file_path::String, message::String) = (
    #Check if file already in log
    written = check_log_for_message(file_path, message);
    #Add file to unsuccessful_files.log if not already in unsuccessful log
    if !written
        append_to_log(file_path, message);
    end;
    return nothing;
)
=#
