module Processer

include("borrowed/GriddingMachineData.jl")

"""
    reprocess_files()

Reprocess user's dataset(s) and create corresponding JSON file(s). All information is entered manually by the user.

#
    reprocess_files(folder_j::String, folder_r::String)

Reprocess user's dataset(s) and create corresponding JSON file(s) with folder paths given.

- `folder_j` Path of folder where the created JSON file will be stored
- `folder_r` Path of folder where the reprocessed dataset will be stored

"""
function reprocess_files end

reprocess_files() = (
    @info "Please follow the instructions to create a JSON file for your dataset(s) and reprocess your dataset(s)";

    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);
    _jdg_6(x) = (isdir(x));
    _jdg_7(x) = (length(x) >= 5 && x[end-4:end] == ".json");
    
    while true
        #Get user input for directories
        _msg = "Please input the folder path of the JSON file you want to create > ";
        folder_j = verified_input(_msg, _jdg_6); #check if folder exists
        _msg = "Please input the file name of the JSON file you want to create (file_name.json) > ";
        file_j = verified_input(_msg, _jdg_7); #check if a JSON file name is given
        _msg = "Please input the folder path of the reprocessed file you want to create > ";
        folder_r = verified_input(_msg, _jdg_6); #check if folder exists

        _json = "$(folder_j)/$(file_j)";
        process_single_file(_json, folder_r);

        #Ask user if they want to reprocess another dataset
        _msg = "Do you want to reprocess another dataset? Type Y/y or N/n to continue > ";
        if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
            return nothing;
        end;
    end;
    
    return nothing;
    
);

reprocess_files(folder_j::String, folder_r::String) = (
    @info "Please follow the instructions to create a JSON file for your dataset(s) and reprocess your dataset(s)";

    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);
    _jdg_7(x) = (length(x) >= 5 && x[end-4:end] == ".json");

    while true
        #Get user input for directories
        _msg = "Please input the file name of the JSON file you want to create (file_name.json) > ";
        file_j = verified_input(_msg, _jdg_7); #check if a JSON file name is given

        _json = "$(folder_j)/$(file_j)";

        process_single_file(_json, folder_r);

        #Ask user if they want to reprocess another dataset
        _msg = "Do you want to reprocess another dataset? Type Y/y or N/n to continue > ";
        if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
            return nothing;
        end;
    end;

    return nothing;

);


"""
    process_single_file(_json::String, folder_r::String)

This is a helper method that creates a single JSON file based on user input and reprocesses the data represented by the JSON file 

- `_json` Path of JSON file to be created
- `folder_r` Path of folder where the reprocessed dataset will be stored

"""
function process_single_file end;

process_single_file(_json::String, folder_r::String) = (

    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);
    
    #Check if JSON file exists already
    if isfile(_json)
        @info "File $(_json) exists already";
        _msg = "Do you still want to create the JSON file? Type Y/y or N/n to continue > ";
        if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
            _msg = "Do you still want to reprocess the dataset based on the JSON file? Type Y/y or N/n to continue > ";
            if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
                @info "Terminating...";
                return nothing;
            else
                @info "Skipping...";
            end;
        else
            #Create JSON file
            griddingmachine_json!(_json);
            @info "JSON file successfully saved";
        end;
    else
        @info "File $(_json) does not exist, creating...";
        #Create JSON file
        griddingmachine_json!(_json);
        @info "JSON file successfully saved";
    end;

    #Reprocess data
    @info "Reprocessing data...";
    create_from_json(_json, folder_r);

    return true;
);


"""
    create_from_json(_json::String, folder_r::String)

This is a helper method that reprocesses the data represented by a given JSON file 

- `_json` Path of JSON file to be parsed
- `folder_r` Path of folder where the reprocessed dataset will be stored

"""
function create_from_json end;

create_from_json(_json::String, folder_r::String) = (
    #Parse JSON file created
    json_dict = JSON.parse(open(_json));
    name_function = (f = eval(Meta.parse(json_dict["INPUT_MAP_SETS"]["FILE_NAME_FUNCTION"])); x -> Base.invokelatest(f, x));
    data_scaling_f = [_dict["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_VAR_SETS"]];
    std_scaling_f = if "INPUT_STD_SETS" in keys(json_dict)
        [_dict["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_STD_SETS"]];
    else
        [nothing for _dict in json_dict["INPUT_VAR_SETS"]];
    end;
    data_masking_f = [_dict["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_VAR_SETS"]];
    std_masking_f = if "INPUT_STD_SETS" in keys(json_dict)
        [_dict["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_STD_SETS"]];
    else
        [nothing for _dict in json_dict["INPUT_VAR_SETS"]];
    end;

    #Reprocess the data
    reprocess_data!(folder_r, json_dict;
                    file_name_function = name_function, 
                    data_scaling_functions = data_scaling_f, 
                    std_scaling_functions = std_scaling_f,
                    data_masking_functions = data_masking_f,
                    std_masking_functions = std_masking_f);
    @info "Process complete";
)

end; #module