SELECT
       name,
       case
           when waterway IN ('canal', 'river', 'stream') then waterway
           when waterway = 'waterfall' then 'water_feature'
           when planet_osm_line.natural in ('valley') then 'landform'
       end as class,
       case
           when waterway in ('canal', 'river', 'stream') then 'marker'
           when waterway = 'waterfall' then 'waterfall'
           when planet_osm_line.natural in ('valley') then 'marker'
       end as maki,
       case
           when waterway IN ('canal', 'river', 'stream') then waterway
           when planet_osm_line.natural in ('valley') then planet_osm_line.natural
       end as type,
       null as elevation,
       way as geom
FROM planet_osm_line
WHERE
  (waterway IN ('canal', 'river', 'stream', 'waterfall')
    or planet_osm_line.natural in ('valley'))
  AND name IS NOT NULL

union all

SELECT
    name,
    case
        when  (planet_osm_polygon.natural IN ('water', 'pond')
            OR waterway IN ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream')) then 'water'
        when planet_osm_polygon.natural in ('wetland', 'glacier') then planet_osm_polygon.natural
        when landuse in ('meadow') then 'landform'
        when planet_osm_polygon.natural in ('fell') then 'landform'
    end as class,
    case
        when (planet_osm_polygon.natural IN ('water', 'pond', 'wetland', 'glacier', 'fell')
            or waterway in ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream'))
            or landuse in ('meadow') then 'marker'
    end as maki,
    case
        when planet_osm_polygon.natural in ('glacier', 'fell') then planet_osm_polygon.natural
        when planet_osm_polygon.natural = 'wetland' then wetland
        when planet_osm_polygon.natural IN ('water', 'pond') then water
        when landuse in ('meadow') then landuse
    end as type,
    null as elevation,
    ST_PointOnSurface(way) AS geom
FROM planet_osm_polygon
WHERE
    (planet_osm_polygon.natural IN ('water', 'pond')
        OR waterway IN ('basin', 'canal', 'mill_pond', 'pond', 'riverbank', 'stream')
        or planet_osm_polygon.natural in ('wetland', 'glacier', 'fell')
        or landuse = 'meadow')
  and name IS NOT NULL
  AND ST_IsValid(way)

union all

select
    name,
    case
        when planet_osm_point.natural in ('peak', 'cave_entrance', 'saddle') then 'landform'
    end as class,
    case
        when planet_osm_point.natural in ('peak') then 'mountain'
        when planet_osm_point.natural in ('cave_entrance', 'saddle') then 'marker'
    end as maki,
    case
        when planet_osm_point.natural in ('peak', 'cave_entrance', 'saddle') then planet_osm_point.natural
    end as type,
    ele as elevation,
    way as geom
from planet_osm_point
where
    planet_osm_point.natural in ('peak', 'cave_entrance', 'saddle')
    AND name IS NOT NULL