select
    name,
    case
        when aeroway = 'aerodrome' then 'airport'
        when aeroway = 'helipad' then aeroway
    end as type,
    case
        when aeroway = 'aerodrome' then 'airport'
        when aeroway = 'helipad' then 'heliport'
    end as maki,
    ST_PointOnSurface(way) AS geom
from planet_osm_polygon
    where aeroway is not null
    and name is not null
    and aeroway in ('aerodrome', 'helipad')


