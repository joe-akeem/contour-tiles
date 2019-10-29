SELECT
    name,
    case
        when building = 'yes' then 'building'
        else building
    end
    as type,
    way as geom
FROM planet_osm_polygon
WHERE building NOT IN ('', '0','false', 'no')
ORDER BY ST_YMin(ST_Envelope(way)) DESC
