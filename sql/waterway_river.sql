-- Zoomlevel 7

SELECT name, waterway AS class, waterway AS type, way as geom
FROM planet_osm_line
WHERE waterway IN ('river')
