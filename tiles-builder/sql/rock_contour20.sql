select
    'rock' as type,
    '20m' as distance,
    contourlines.elev,
    ST_Intersection(contourlines.geom, planet_osm_polygon.way) as geom
from contourlines, planet_osm_polygon
where planet_osm_polygon.natural in ('bare_rock', 'scree')
  and ST_Intersects(planet_osm_polygon.way, contourlines.geom)