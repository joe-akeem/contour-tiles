select
    name,
   case
       when junction in ('roundabout') then junction
       when highway in ('motorway_link', 'trunk_link', 'primary_link', 'secondary', 'secondary_link',
                        'tertiary', 'tertiary_link', 'pedestrian', 'construction', 'track', 'mini_roundabout',
                        'turning_circle', 'turning_loop', 'service') then highway
       when highway in ('unclassified', 'residential', 'road', 'living_street') then 'street'
       when highway in ('path', 'cycleway', 'steps', 'corridor', 'footway', 'bridleway') then 'path'
       when route = 'ferry' then route
       when route in ('ski', 'piste') then 'path'
       when railway in ('light_rail', 'monorail', 'tram') then 'minor_rail'
       when aerialway is not null then 'aerialway'
    end as class,
    case
        when highway = 'construction' and construction is not null then concat('construction:', construction)
        when highway = 'construction' and construction is  null then 'construction'
        when highway = 'track' and tracktype in ('grade1', 'grade2', 'grade3', 'grade4', 'grade5') then concat('track:', tracktype)
        when highway = 'track' and tracktype is null or tracktype not in ('grade1', 'grade2', 'grade3', 'grade4', 'grade5') then 'track'
        when highway = 'service' and service is not null then concat('service:', service)
        when highway = 'service' and service is  null then 'service'
        when highway in ('steps', 'corridor', 'path', 'cycleway', 'footway', 'bridleway') then highway
        when highway in ('unclassified', 'residential', 'road', 'living_street') then highway
        when route in ('ski', 'piste') then 'piste'
        when route = 'ferry' then route
        when aerialway is not null then concat('aerialway:', aerialway)
        when highway in  ('motorway_link', 'trunk_link', 'primary_link', 'secondary', 'secondary_link',
                          'tertiary', 'tertiary_link', 'pedestrian', 'mini_roundabout',
                          'turning_circle', 'turning_loop') then highway
    end as type,
    case
        when tunnel in ('yes', 'tunnel') then 'tunnel'
        when bridge in ('yes') then 'bridge'
        else 'none'
    end as structure,
    way as geom
from planet_osm_line
where
    highway in ('motorway_link', 'trunk_link', 'primary_link', 'secondary', 'secondary_link',
                 'tertiary', 'tertiary_link', 'unclassified', 'residential', 'road', 'living_street', 'pedestrian',
                  'construction', 'track', 'service', 'path', 'cycleway', 'mini_roundabout', 'turning_circle',
                  'turning_loop', 'steps', 'corridor', 'footway', 'bridleway')
    or route in ('ferry', 'ski', 'piste')
    or railway in ('light_rail', 'monorail', 'tram')
    or aerialway is not null
    or junction in ('roundabout')
