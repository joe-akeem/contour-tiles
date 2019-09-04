select
        planet_osm_polygon.name,
        case
                when landuse in ('farmland', 'orchard') then 'agriculture'
                when landuse in ('forest') then 'wood'
                when landuse in ('meadow', 'grass', 'greenfield') then 'grass'
                when landuse in ('cemetery') then 'cemetery'
                when landuse in ('village_green', 'park') then 'park'
                when landuse in ('quarry') then 'rock'
                when landuse in ('scrub') then 'scrub'
                when landuse in ('school') then 'school'
                when planet_osm_polygon.natural in ('wood') then 'wood'
                when planet_osm_polygon.natural in ('scrub', 'heath') then 'scrub'
                when planet_osm_polygon.natural in ('grassland', 'fell') then 'grass'
                when planet_osm_polygon.natural in ('bare_rock', 'scree', 'shingle', 'rock') then 'rock'
                when planet_osm_polygon.natural in ('sand', 'beach', 'dune', 'dunes') then 'sand'
                when planet_osm_polygon.natural in ('glacier') then 'glacier'
                when aeroway is not null then 'airport'
                when amenity in ('hospital') then 'hospital'
                when amenity in ('college', 'kindergarten', 'school', 'university') then 'school'
                when amenity in ('grave_yard') then 'cemetery'
                when leisure in ('garden', 'nature_reserve', 'park', 'playground') then 'park'
                when leisure in ('golf_course', 'pitch') then 'pitch'
        end as "class",
        coalesce(landuse, planet_osm_polygon.natural, aeroway, amenity, leisure) as "type",
        way as geom
 from planet_osm_polygon
 where(
        landuse in ('farmland', 'forest', 'meadow', 'cemetery', 'grass', 'greenfield', 'quarry', 'village_green', 'scrub', 'school', 'park', 'orchard')
        or
        planet_osm_polygon.natural in ('wood', 'scrub', 'heath', 'grassland', 'fell', 'bare_rock', 'scree', 'shingle', 'sand', 'glacier', 'beach', 'dune', 'dunes', 'rock')
        or
        aeroway is not null
        or
        amenity in ('hospital', 'college', 'kindergarten', 'school', 'university', 'grave_yard')
        or
        leisure in ('garden', 'golf_course', 'nature_reserve', 'park', 'pitch', 'playground')
        )
order by z_order,way_area desc
