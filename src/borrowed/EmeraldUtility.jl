# global constants
const MDAYS_LEAP  = [0,31,60,91,121,152,182,213,244,274,305,335,366];
const MDAYS       = [0,31,59,90,120,151,181,212,243,273,304,334,365];


"""

    month_ind(year::Int, doy::Number)

Return the month index, given
- `year` Year
- `doy` Day of year (typically 1-365, 1-366 for leap years)

"""
function month_ind(year::Int, doy::Number)
    # if is leap year
    if isleapyear(year)
        @assert 1 <= doy <= 366;
        _month = 1;
        for i in 1:12
            if MDAYS_LEAP[i] < doy <= MDAYS_LEAP[i+1]
                _month = i;
                break;
            end;
        end;

        return _month
    end;

    # if not leap year
    @assert 1 <= doy <= 365;
    _month = 1;
    for i in 1:12
        if MDAYS[i] < doy <= MDAYS[i+1]
            _month = i;
            break;
        end;
    end;

    return _month
end
