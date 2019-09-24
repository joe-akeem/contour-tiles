select
    name,
    case
        when amenity in ('bar', 'biergarten', 'cafe', 'drinking_water', 'pub', 'restaurant') then 'sustenance'
        when amenity in ('college', 'kindergarten', 'library',
                        'school', 'university') then 'education'
        when amenity in ('bicycle_repair_station', 'bicycle_rental', 'bus_station', 'ferry_terminal', 'parking',
                        'parking_space', 'taxi') then 'transportation'
        when amenity in ('atm', 'bank') then 'financial'
        when amenity in ('clinic', 'dentist', 'doctors', 'hospital', 'pharmacy') then 'healthcare'
        when tourism in ('caravan_site', 'alpine_hut', 'zoo', 'summit_cross', 'lodge', 'hostel', 'guest_house', 'hotel',
                         'camp_site', 'motel', 'youth hostel') then 'tourism'
    end as class,
    case
        when tourism in ('caravan_site', 'alpine_hut', 'zoo', 'summit_cross', 'lodge', 'hostel', 'guest_house', 'hotel',
                         'camp_site', 'motel', 'youth hostel') then tourism
        else amenity
    end as type,
    way as geom
from planet_osm_point
where
    amenity in ('bar', 'biergarten', 'cafe', 'drinking_water', 'pub', 'restaurant', 'college', 'kindergarten', 'library',
                'school', 'university', 'bicycle_repair_station', 'bicycle_rental', 'bus_station', 'ferry_terminal', 'parking',
                'parking_space', 'taxi', 'atm', 'bank', 'clinic', 'dentist', 'doctors', 'hospital', 'pharmacy', 'Alpine Hut')
    or tourism in ('caravan_site', 'alpine_hut', 'zoo', 'summit_cross', 'lodge', 'hostel', 'guest_house', 'hotel',
                   'camp_site', 'motel', 'youth hostel')
and tourism is not null

