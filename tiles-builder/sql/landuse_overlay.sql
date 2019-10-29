select
       name,
       case
           when boundary='national_park' then 'national_park'
           else 'wetland'
       end as class,
       way as geom
from planet_osm_polygon
where
    planet_osm_polygon.natural='wetland'
    OR boundary='national_park'
order by class