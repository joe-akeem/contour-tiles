select
       'glacier' as type,
       '100m' as distance,
       contourlines.elev,
       ST_Intersection(contourlines.wkb_geometry, planet_osm_polygon.way) as geom
from contourlines, planet_osm_polygon
where planet_osm_polygon.natural in ('glacier')
  and mod(cast(contourlines.elev as integer), 100) = 0
  and ST_Intersects(planet_osm_polygon.way, contourlines.wkb_geometry)