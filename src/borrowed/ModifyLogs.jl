"""
    remove_from_log(file_path::String, message::String)

Remove message from log if it exists
- `file_path` Path to log file
- `message` The message to be removed
"""
function remove_from_log end;

remove_from_log(file_path::String, message::String) = (
    log = open(file_path);
    lines = readlines(log);
    close(log);

    open(file_path, "w") do log
        for l in lines
            if (l != message)
                write(log, "$(l)\n")
            end;
        end;
    end;
    return nothing;
);


"""
    check_log_for_message(file_path::String, message::String)

Check if message exists in log file already
- `file_path` Path to log file
- `message` The message to be checked in the log file

"""
function check_log_for_message end;

check_log_for_message(file_path::String, message::String) = (
    log = open(file_path);
    for l in eachline(log)
        if (l == message)
            return true;
        end;
    end;
    close(log);
    return false;
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