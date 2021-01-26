###############################################################################
#
# Determine the latitude and longitude index in matrix
#
###############################################################################
MONTH_DAYS_LEAP = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366];
MONTH_DAYS      = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
"""
    parse_date(year::Int, doy::Int)

Return a string of YYYY.MM.DD, given
- `year` Which year
- `doy` Which day in year
"""
function parse_date(year::Int, doy::Int)
    if isleapyear(year)
        mon = 1;
        for i in 1:12
            if MONTH_DAYS_LEAP[i] < doy <= MONTH_DAYS_LEAP[i+1]
                mon = i;
            end
        end
        day = doy - MONTH_DAYS_LEAP[mon];
    else
        mon = 1;
        for i in 1:12
            if MONTH_DAYS[i] < doy <= MONTH_DAYS[i+1]
                mon = i;
            end
        end
        day = doy - MONTH_DAYS[mon];
    end

    return string(year) * "." * lpad(mon,2,"0") * "." * lpad(day,2,"0") * "/"
end
