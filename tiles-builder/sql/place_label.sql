select
    name,
    case
        when place in ('country') then place
        when place in ('city', 'town', 'village', 'hamlet') then 'settlement'
        when place in ('suburb', 'quarter', 'neighbourhood') then 'settlement_subdivision'
    end as class,
    case
        when place in ('country') then place
        when place in ('city', 'town', 'village', 'hamlet', 'suburb', 'quarter', 'neighbourhood') then place
    end as type,
    capital,
    way as geom
from planet_osm_point
where
    place in ('country', 'city', 'town', 'village', 'hamlet', 'suburb', 'quarter', 'neighbourhood')