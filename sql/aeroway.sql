select
    name,
    aeroway as type,
    way as geom
from planet_osm_line
    where aeroway in ('runway', 'taxiway', 'apron', 'helipad')

union all

select
    name,
    aeroway as type,
    way as geom
from planet_osm_polygon
    where aeroway in ('runway', 'taxiway', 'apron', 'helipad')
