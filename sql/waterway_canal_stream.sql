SELECT name, waterway as class, waterway AS type, way as geom
FROM planet_osm_line
WHERE waterway IN ('canal', 'stream')