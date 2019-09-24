select
    name,
    case
        when amenity in ('bar', 'bbq', 'biergarten', 'cafe', 'drinking_water', 'fast_food', 'food_court', 'ice_cream',
                        'pub', 'restaurant') then 'sustenance'
        when amenity in ('college', 'driving_school', 'kindergarten', 'language_school', 'library', 'music_school',
                        'school', 'university') then 'education'
        when amenity in ('bicycle_parking', 'bicycle_repair_station', 'bicycle_rental', 'boat_rental', 'boat_sharing',
                        'bus_station', 'car_rental', 'car_sharing', 'car_wash', 'vehicle_inspection', 'charging_station',
                        'ferry_terminal', 'fuel', 'grit_bin', 'motorcycle_parking', 'parking', 'parking_entrance',
                        'parking_space', 'taxi') then 'transportation'
        when amenity in ('atm', 'bank', 'bureau_de_change') then 'financial'
        when amenity in ('baby_hatch', 'clinic', 'dentist', 'doctors', 'hospital', 'nursing_home', 'pharmacy',
                         'social_facility', 'veterinary') then 'healthcare'
        when amenity in ('arts_centre', 'brothel', 'casino', 'cinema', 'community_centre', 'fountain', 'gambling',
                         'nightclub', 'planetarium', 'public_bookcase', 'social_centre', 'stripclub', 'studio',
                         'swingerclub', 'theatre') then 'entertainment'
        else 'other'
    end as class,
    amenity as type,
    way as geom
from planet_osm_point
where
    amenity is not null