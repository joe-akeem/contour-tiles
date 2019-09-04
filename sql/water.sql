SELECT name, way as geom
FROM planet_osm_polygon
WHERE "natural" IN ('water', 'pond')
   OR waterway IN ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream');

-- water_gen0
SELECT name, way as geom
FROM planet_osm_polygon
WHERE ("natural" IN ('water', 'pond')
    OR waterway IN ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream'))
  AND way_area > 10000;

-- water_gen1
SELECT name, way as geom
FROM planet_osm_polygon
WHERE ("natural" IN ('water', 'pond')
    OR waterway IN ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream'))
  AND way_area > 1000;

--- Water
SELECT way, way_area AS area
FROM planet_osm_polygon
WHERE "natural" IN ('water', 'pond')
   OR waterway IN ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream');
