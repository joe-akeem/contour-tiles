create index on contourlines (elev);

create index on planet_osm_line (building);
create index on planet_osm_line (highway);
create index on planet_osm_line (waterway);
create index on planet_osm_line (railway);
create index on planet_osm_line (route);
create index on planet_osm_line (aerialway);
create index on planet_osm_line (junction);

create index on planet_osm_polygon (landuse);
create index on planet_osm_polygon (aeroway);
create index on planet_osm_polygon (amenity);
create index on planet_osm_polygon ("natural");
create index on planet_osm_polygon (leisure);
create index on planet_osm_polygon (building);
create index on planet_osm_polygon (boundary);
create index on planet_osm_polygon (waterway);

create index on planet_osm_point ("natural");
create index on planet_osm_point (place);
create index on planet_osm_point (amenity);
create index on planet_osm_point (tourism);


