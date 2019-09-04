SELECT way as geom
FROM planet_osm_polygon
WHERE ("natural" IN ('water', 'pond')
    OR waterway IN ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream'))
  AND way_area <= 1000