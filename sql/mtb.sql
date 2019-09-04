select
       way as geom,
       name,
       mtb->':scale' as scale
from planet_osm_line
where planet_osm_line.mtb is not null
  and highway = 'path'