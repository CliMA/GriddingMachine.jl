#=
Shared helpers for the Server endpoints.

Note on the `user` parameter used throughout this module: it is a free-form label that is
echoed into responses and written to the log. It is NOT an access control mechanism — any
caller may supply any value. This server is meant for a local or trusted intranet network.
=#

"""Stable, machine-readable reasons returned to clients."""
const REASON_UNSUPPORTED = "unsupported version"
const REASON_NO_LAND = "no land at target grid"
const REASON_NOT_VEGETATED = "grid is not vegetated"
const REASON_INTERNAL = "internal error"

"""Value used in place of `NaN`, which JSON cannot represent."""
const MISSING_CODE = -9999

"""Encode `NaN` as `MISSING_CODE`; other values pass through unchanged."""
function encode_missing end

encode_missing(value) = value
encode_missing(value::Number) = isnan(value) ? MISSING_CODE : value
encode_missing(value::AbstractArray) = replace(value, NaN => MISSING_CODE)

"""Parse `raw` as `Float64`, falling back to `default` when empty or malformed."""
function parse_float(raw, default::Real)
    text = strip(String(raw))
    isempty(text) && return Float64(default)
    parsed = tryparse(Float64, text)
    return isnothing(parsed) ? Float64(default) : parsed
end

"""Parse `raw` as `Int`, falling back to `default` when empty or malformed."""
function parse_int(raw, default::Int)
    text = strip(String(raw))
    isempty(text) && return default
    parsed = tryparse(Int, text)
    return isnothing(parsed) ? default : parsed
end

const TRUTHY_TEXT = ("true", "1", "yes", "on")
const FALSY_TEXT = ("false", "0", "no", "off")

"""Parse `raw` as a flag, falling back to `default` when empty or unrecognised.

Deliberately lenient: `parse(Bool, "1")` throws, which made the equivalent query parameter
in the previous implementation crash the request.
"""
function parse_bool(raw, default::Bool)
    text = lowercase(strip(String(raw)))
    isempty(text) && return default
    text in TRUTHY_TEXT && return true
    text in FALSY_TEXT && return false
    return default
end

function _payload(head::AbstractDict, fields::AbstractDict)
    payload = OrderedDict{String,Any}(head)
    for (key, value) in fields
        payload[String(key)] = value
    end
    return payload
end

"""Build a failure payload carrying a stable `Reason` and the request context."""
function warning_payload(reason::AbstractString, fields::AbstractDict)
    head = OrderedDict{String,Any}(
        "Warning" => "Your request cannot be completed",
        "Reason" => String(reason),
    )
    return _payload(head, fields)
end

"""Build a payload naming every catalog tag the request needs but cannot find."""
function missing_datasets_payload(absent::Vector{String}, fields::AbstractDict)
    head = OrderedDict{String,Any}(
        "Warning" => "Required datasets are not available",
        "MissingTags" => absent,
        "Hint" => "These tags are not registered in the local catalog",
    )
    return _payload(head, fields)
end

"""Map an exception to a stable reason, keeping its message out of the response.

`grid_dict` signals its entry conditions through `ErrorException` messages, so this matches
on the message text. That is a deliberate trade-off: re-implementing the land-mask and LAI
checks here would create a second copy of logic that lives in `Indexer`. The tests pin both
mappings, so an upstream wording change fails the suite instead of silently degrading to
`internal error`.
"""
function classify_error(exception)
    message = sprint(showerror, exception)
    occursin("does not contain land", message) && return REASON_NO_LAND
    occursin("not vegetated", message) && return REASON_NOT_VEGETATED
    return REASON_INTERNAL
end

"""Return every catalog tag a labels struct depends on, read from its `tag_*` fields."""
function required_tags(labels)
    names = fieldnames(typeof(labels))
    return String[getfield(labels, name) for name in names if startswith(String(name), "tag_")]
end

"""Return the subset of `tags` that is absent from the local catalog."""
function missing_tags(tags::Vector{String})
    return String[tag for tag in tags if !dataset_found(tag)]
end
