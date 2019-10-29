select name, admin_level::int, way as geom
FROM planet_osm_line
WHERE boundary = 'administrative'
  AND admin_level IN ('2','3','4')
order by admin_level asc