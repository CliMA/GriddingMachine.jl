#######################################################################################################################################################################################################
#
# Changes to this function
# General
#     2023-May-12: add function to read inputs from terminal
#
#######################################################################################################################################################################################################
"""

    verified_input(message::String, operation_function::Function, judge_function::Function)
    verified_input(message::String, judge_function::Function)

Return a verified input, given
- `msg` Message about the input variable
- `operation_function` Function applied to the input before judge
- `judge_function` Function to judge if the input meets the requirements

"""
function verified_input end

verified_input(message::String, operation_function::Function, judge_function::Function) = (
    _input = nothing;

    # loop until a correct input is given
    while true
        print(message);
        try
            _input = operation_function(readline());
            if judge_function(_input)
                break;
            else
                @warn "You input does not meet the requirements, please redo it!"
            end;
        catch e
            @warn e;
        end;
    end;

    return _input
);

verified_input(message::String, judge_function::Function) = (
    _input = nothing;

    # loop until a correct input is given
    while true
        print(message);
        _input = readline();
        if judge_function(_input)
            break;
        else
            @warn "You input does not meet the requirements, please redo it!"
        end;
    end;

    return _input
);
