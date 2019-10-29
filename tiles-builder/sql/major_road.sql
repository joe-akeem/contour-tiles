select
    name,
   case
       when highway in ('motorway', 'trunk', 'primary') then highway
       when railway in ('narrow_gauge', 'rail') then 'major_rail'
    end as class,
    case
        when highway in  ('motorway', 'trunk', 'trunk_link', 'primary', 'primary_link') then highway
        when railway in ('narrow_gauge', 'rail') then railway
    end as type,
    case
        when tunnel in ('yes', 'tunnel') then 'tunnel'
        when bridge in ('yes') then 'bridge'
        else 'none'
    end as structure,
    way as geom
from planet_osm_line
where
    highway in ('motorway', 'trunk', 'primary')
    or railway in ('narrow_gauge', 'rail')
