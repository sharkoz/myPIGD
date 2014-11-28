SELECT stop_name, GROUP_CONCAT(arrival_time ORDER BY arrival_time SEPARATOR ', ') FROM
(
SELECT stops.stop_name, stop_times.arrival_time FROM stop_times
JOIN stops
	USING (stop_id)
JOIN  (
	SELECT DISTINCT all_trips.trip_id FROM (
	SELECT stop_times.* FROM stop_times 
	JOIN stops 
		USING (stop_id)
	WHERE stops.COD="BGV"
	AND departure_time > CURTIME()) all_trips
	JOIN trips
		USING (trip_id)
	JOIN calendar
		USING (service_id)
	LEFT OUTER JOIN calendar_dates
		USING (service_id)
	WHERE 
		trips.service_id IN (SELECT service_id FROM calendar_dates WHERE date = CURDATE() AND exception_type = 1) OR
		(
			trips.service_id NOT IN (SELECT service_id FROM calendar_dates WHERE date = CURDATE() AND exception_type = 2) AND
			calendar.start_date <= CURDATE() AND calendar.end_date >= CURDATE()
		)
	) filtered_trips
	USING (trip_id)
WHERE stop_times.arrival_time > CURTIME() AND stops.COD NOT LIKE "BGV"
) a
GROUP BY stop_name



SELECT stop_id FROM stops WHERE COD = "PSL" and location_type = 0 LIMIT 1 INTO @DEP; 


SELECT stops.stop_name, dep_time.departure_time, stop_times.arrival_time, SUBSTR(stop_times.trip_id, 6, 6) as train_id 
FROM
	stop_times
JOIN (select trip_id, departure_time FROM stop_times WHERE stop_id = @DEP) dep_time
    USING (trip_id)
JOIN stops
	USING (stop_id)
JOIN  (
	SELECT DISTINCT all_trips.trip_id FROM (
	SELECT stop_times.* FROM stop_times 
	WHERE departure_time > CURTIME() AND stop_id = @DEP) all_trips
	JOIN trips
		USING (trip_id)
	JOIN calendar
		USING (service_id)
	LEFT OUTER JOIN calendar_dates
		USING (service_id)
	WHERE 
		trips.service_id IN (SELECT service_id FROM calendar_dates WHERE date = CURDATE() AND exception_type = 1) OR
		(
			trips.service_id NOT IN (SELECT service_id FROM calendar_dates WHERE date = CURDATE() AND exception_type = 2) AND
			calendar.start_date <= CURDATE() AND calendar.end_date >= CURDATE()
		)
	) filtered_trips
	USING (trip_id)
WHERE dep_time.departure_time >= CURTIME() AND dep_time.departure_time < stop_times.arrival_time AND stop_id <> @DEP

