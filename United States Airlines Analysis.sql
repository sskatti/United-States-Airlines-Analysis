create schema capstone3;

use capstone3;

select count(*) from run_2;
/* Find number of flights delayed on different days of the week */

SELECT 
    DayOfWeek,
    ROUND(SUM(Delay) / COUNT(*) * 100, 2) AS percent_flights_delay
FROM
    airlines
GROUP BY DayOfWeek
ORDER BY DayOfWeek;

/* Find the number of delayed flights for different airlines */

SELECT 
    Airline,
    ROUND(SUM(Delay) / COUNT(*) * 100, 2) AS percent_of_delayed_flights
FROM
    airlines
GROUP BY Airline
ORDER BY percent_of_delayed_flights DESC;


/* use the air_run data from python */
/* Find the number of delayed flights landing on the airports which have more than or equal to 10 runways. */


SELECT 
    a.AirportTo,
    COUNT(*) AS count_of_delay,
    MAX(b.runway_count) AS runway_count
FROM
    airlines a
        LEFT JOIN
    run_3 b ON a.AirportTo = b.iata_code
WHERE
    runway_count > 10 AND Delay = 1
GROUP BY AirportTo;


/* Compare the number of delayed flights for the airports which are at above average elevation and those that 
   are at below average elevation. Do it for source as well as destination airports.*/
   
CREATE TABLE elevation_data AS (SELECT yy.AirportFrom,
    yy.AirportTo,
    yy.elevation_ft_source,
    xx.elevation_ft AS elevation_ft_dest,
    yy.Delay FROM
    (SELECT 
        a.*, b.elevation_ft AS elevation_ft_source
    FROM
        airlines a
    LEFT JOIN (SELECT DISTINCT
        iata_code, elevation_ft
    FROM
        run_3) b ON a.AirportFrom = b.iata_code) yy
        LEFT JOIN
    (SELECT DISTINCT
        iata_code, elevation_ft
    FROM
        run_3) xx ON xx.iata_code = yy.AirportTo);
 
 
SELECT 
    AVG(elevation_ft)
FROM
    run_3;
SELECT 
    'Destination airports' AS airport,
    'above average' AS status_,
    COUNT(*) AS count_of_delay
FROM
    elevation_data
WHERE
    elevation_ft_dest > (SELECT 
            AVG(elevation_ft)
        FROM
            run_3
        WHERE
            iata_code <> '0')
        AND delay = 1 
UNION 
SELECT 
    'Source airports' AS airport,
    'above average' AS status_,
    COUNT(*) AS count_of_delay
FROM
    elevation_data
WHERE
    elevation_ft_source > (SELECT 
            AVG(elevation_ft)
        FROM
            run_3)
        AND delay = 1 
UNION SELECT 
    'Destination airports' AS airport,
    'below average' AS status_,
    COUNT(*) AS count_of_delay
FROM
    with_elevation
WHERE
    elevation_ft_dest < (SELECT 
            AVG(elevation_ft)
        FROM
            run_3)
        AND delay = 1 
UNION 

SELECT 
    'Source airports' AS airport,
    'below average' AS status_,
    COUNT(*) AS count_of_delay
FROM
    elevation_data
WHERE
    elevation_ft_source < (SELECT 
            AVG(elevation_ft)
        FROM
            run_3)
        AND delay = 1;
