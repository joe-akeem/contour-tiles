.. singletrail-map.eu Vector Tiles documentation master file, created by
   sphinx-quickstart on Sun Sep  8 20:38:07 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

singletrail-map.eu Vector Tiles Documentation!
==============================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

Overview
========

Data sources & updates
----------------------
t.b.d.

Common Fields
=============

name - *text*
-------------
Each feature has an optional lable name. Label names are available in one language only.

Layer Reference
===============

The singeltrail-map.eu tileset contains the following layers. For reference, the current minimum-available zoom level
for each layer is mentioned. It does not apply to all features within a layer - only the most prominent features are
available at lower-numbered zoom levels, and more features are available as you zoom in.

+------------------------+---------------------------------+
| **Layer**              | **Min. zoom level**             |
+------------------------+---------------------------------+
| :ref:`admin`           | 0                               |
+------------------------+---------------------------------+
| :ref:`aeroway`         | 9                               |
+------------------------+---------------------------------+
| :ref:`building`        | 13                              |
+------------------------+---------------------------------+
| :ref:`landuse`         | 5                               |
+------------------------+---------------------------------+
| :ref:`natural_label`   | 0                               |
+------------------------+---------------------------------+
| :ref:`place_label`     | 0                               |
+------------------------+---------------------------------+
| :ref:`poi_label`       | 5                               |
+------------------------+---------------------------------+
| :ref:`landuse_overlay` | 5                               |
+------------------------+---------------------------------+
| :ref:`road`            | 5                               |
+------------------------+---------------------------------+
| :ref:`water`           | 0                               |
+------------------------+---------------------------------+
| :ref:`waterway`        | 7                               |
+------------------------+---------------------------------+

.. _admin:

admin
-----
This layer contains boundary lines for national and subnational administrative units.

admin_level - *number*
^^^^^^^^^^^^^^^^^^^^^^
Type: Linestring

The ``admin_level`` field separates different levels of boundaries.

+------------------------+----------------------------------------+
| **Value**              | **Description**                        |
+------------------------+----------------------------------------+
| 2                      | Countries                              |
+------------------------+----------------------------------------+
| 3                      | First-level administrative divisions   |
+------------------------+----------------------------------------+
| 4                      | Second-level administrative divisions  |
+------------------------+----------------------------------------+

.. _building:

.. _aeroway:

aeroway
-------
Type: Polygon, Linestring

The aeroway layer includes both lines and polygons representing runways, helipads, etc.

type - *text*
^^^^^^^^^^^^^
The ``type`` field separates different types of aeroways for styling.`

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| runway                 | Where planes take off & land                                         |
+------------------------+----------------------------------------------------------------------+
| taxiway                | Where planes move between runways, gates, and hangars                |
+------------------------+----------------------------------------------------------------------+
| apron                  | Where planes park, refuel, load                                      |
+------------------------+----------------------------------------------------------------------+
| helipad                | Where helicopters take off & land                                    |
+------------------------+----------------------------------------------------------------------+


building
--------
Type: Polygon

Large buildings appear at zoom level 13, and all buildings are included in zoom level 15 and up.

type - *text*
^^^^^^^^^^^^^
Will have the value ``building`` if tagged as building=yes on OpenStreetMap,
otherwise the value will match the building tag from OpenStreetMap.

.. _landuse:

landuse
-------
Type: Polygon

This layer includes polygons representing both land-use and land-cover.

class - *text*
^^^^^^^^^^^^^^
The main field used for styling the landuse layer is ``class``.

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| agriculture            | Various types of crop and farmland including orchards                |
+------------------------+----------------------------------------------------------------------+
| airport                | Airport grounds                                                      |
+------------------------+----------------------------------------------------------------------+
| cemetery               | Cemeteries and graveyards                                            |
+------------------------+----------------------------------------------------------------------+
| glacier                | Glaciers or permanent ice/snow                                       |
+------------------------+----------------------------------------------------------------------+
| grass                  | Grasslands, meadows, fields, lawns, etc                              |
+------------------------+----------------------------------------------------------------------+
| hospital               | Hospital grounds                                                     |
+------------------------+----------------------------------------------------------------------+
| park                   | City parks, village greens, playgrounds, national parks,             |
|                        | nature reserves, etc                                                 |
+------------------------+----------------------------------------------------------------------+
| rock                   | Bare rock, scree, quarries                                           |
+------------------------+----------------------------------------------------------------------+
| sand                   | Sand, beaches, dunes                                                 |
+------------------------+----------------------------------------------------------------------+
| school                 | Primary, secondary, post-secondary school grounds, universities,...  |
+------------------------+----------------------------------------------------------------------+
| scrub                  | Bushes, scrub, heaths                                                |
+------------------------+----------------------------------------------------------------------+
| wood                   | Woods and forestry areas                                             |
+------------------------+----------------------------------------------------------------------+

type - *text*
^^^^^^^^^^^^^
The type field is pulled from the primary OpenStreetMap tags for that class.

.. _landuse_overlay:

landuse_overlay
---------------
Type: Polygon

This layer is for landuse / landcover polygons that your style should draw above the :ref:`water` layer.

class - *text*
^^^^^^^^^^^^^^
The main field used for styling the landuse_overlay layer is ``class``.

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| national_park          | Relatively large area of land set aside by a government for human    |
|                        | recreation and environmental protection                              |
+------------------------+----------------------------------------------------------------------+
| wetland                | Wetlands that may include vegetation (marsh, swamp, bog)             |
+------------------------+----------------------------------------------------------------------+

.. _natural_label:

natural_label
-------------
Type: Linestring, Point

The ``natural_label`` layer contains points and lines for styling natural features such as bodies of water,
mountain peaks, valleys, deserts, and so on.

class - *text*, maki - *text*
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

+------------------------+-------------------+--------------------------------------------------+
| **class**              | **maki values**   | **feature types**                                |
+------------------------+-------------------+--------------------------------------------------+
| canal                  | marker            | canal                                            |
+------------------------+-------------------+--------------------------------------------------+
| glacier                | marker            | glacier                                          |
+------------------------+-------------------+--------------------------------------------------+
| landform               | mountain,         | peak, meadow, cave_entrance, saddle, fell,       |
|                        | volcano, marker   | valley                                           |
+------------------------+-------------------+--------------------------------------------------+
| river                  | marker            | river                                            |
+------------------------+-------------------+--------------------------------------------------+
| stream                 | marker            | stream                                           |
+------------------------+-------------------+--------------------------------------------------+
| water_feature          | waterfall, marker | waterfall                                        |
+------------------------+-------------------+--------------------------------------------------+
| water                  | marker            | lake, river, ponds, etc.                         |
+------------------------+-------------------+--------------------------------------------------+
| wetland                | marker            | marsh, swamp, mud, etc.                          |
+------------------------+-------------------+--------------------------------------------------+

elevation - *number*
^^^^^^^^^^^^^^^^^^^^
Holds the feature elevation in meters. May be *null*.

.. _place_label:

place_label
-----------
Type: Point

This layer contains points for labeling places including countries, cities, towns, and neighborhoods.

class - *text*
^^^^^^^^^^^^^^
The ``class`` field provides a broad distinction between place types. The possible values are:

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Encompasses Types**                                                |
+------------------------+----------------------------------------------------------------------+
| country                | country                                                              |
+------------------------+----------------------------------------------------------------------+
| settlement             | city, town, village, hamlet                                          |
+------------------------+----------------------------------------------------------------------+
| settlement_subdivision | suburb, quarter, neighbourhood                                       |
+------------------------+----------------------------------------------------------------------+

type - *text*
^^^^^^^^^^^^^
The main field for styling labels for different kinds of places is type.

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| country                | Sovereign or partially-recognized states                             |
+------------------------+----------------------------------------------------------------------+
| city                   | Settlement of about 100,000 or more people.                          |
+------------------------+----------------------------------------------------------------------+
| town                   | Urban or rural settlement of about 10,000-100,000 people.            |
+------------------------+----------------------------------------------------------------------+
| village                | Usually rural settlement of less than about 10,000.                  |
+------------------------+----------------------------------------------------------------------+
| hamlet                 | Rural settlement with a population of about 200 or fewer.            |
+------------------------+----------------------------------------------------------------------+
| suburb                 | A distinct section of an urban settlement such as an annexed town,   |
|                        | historical district, or large & important neighborhood.              |
+------------------------+----------------------------------------------------------------------+
| quarter                | A large neighborhood or section of a larger city or town.            |
+------------------------+----------------------------------------------------------------------+
| neighbourhood          | A smaller neighborhood or part of a larger settlement.               |
+------------------------+----------------------------------------------------------------------+

.. _poi_label:

poi_label
----------
Type: Point

class - *text*, type - *text*
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Possible Values for Type**                                         |
+------------------------+----------------------------------------------------------------------+
| sustenance             | bar, biergarten, cafe, drinking_water, pub, restaurant               |
+------------------------+----------------------------------------------------------------------+
| education              | college, kindergarten, library, school, university                   |
+------------------------+----------------------------------------------------------------------+
| transportation         | bicycle_repair_station, bicycle_rental, bus_station, ferry_terminal, |
|                        | parking, parking_space, taxi                                         |
+------------------------+----------------------------------------------------------------------+
| financial              | atm, bank                                                            |
+------------------------+----------------------------------------------------------------------+
| healthcare             | clinic, dentist, doctors, hospital, pharmacy, social_facility        |
+------------------------+----------------------------------------------------------------------+
| tourism                | caravan_site, alpine_hut, zoo, summit_cross, lodge, hostel,          |
|                        | guest_house, hotel, camp_site, motel, youth hostel                   |
+------------------------+----------------------------------------------------------------------+

.. _water:

water
-----
Type: Polygon

This layer includes all types of water bodies: oceans, rivers, lakes, ponds, streams and more.

Each zoom level includes a set of water bodies that has been filtered and simplified according to scale. The tileset
shows only oceans, seas, and large lakes at the lowest zoom levels, while smaller and smaller lakes and ponds appear as you zoom in.

.. _waterway:

waterway
--------
Type: Linestring

The waterway layer contains classes for rivers, streams, canals, etc represented as lines. These classes can represent
a wide variety of possible widths. Since larger rivers and canals are usually also represented by polygons in the
:ref:`water` layer, make your line styling biased toward the smaller end of the scales. It should also be under the :ref:`water` layer.

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| river                  |                                                                      |
+------------------------+----------------------------------------------------------------------+
| canal                  |                                                                      |
+------------------------+----------------------------------------------------------------------+
| stream                 |                                                                      |
+------------------------+----------------------------------------------------------------------+
| drain                  |                                                                      |
+------------------------+----------------------------------------------------------------------+
| ditch                  |                                                                      |
+------------------------+----------------------------------------------------------------------+

class - *text*
^^^^^^^^^^^^^^
The waterway layer has two fields for styling - ``class`` and ``type`` - each with similar values.

.. _road:

road
----
Type: Linestring, Polygon, Point

The roads layer contains lines, points, and polygons needed for drawing features such as roads, railways, paths and their labels.

class - *text*
^^^^^^^^^^^^^^
The main field used for styling the road layers is ``class``.

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| motorway               | High-speed, grade-separated highways                                 |
+------------------------+----------------------------------------------------------------------+
| motorway_link          | Link roads/lanes/ramps connecting to motorways                       |
+------------------------+----------------------------------------------------------------------+
| trunk                  | Important roads that are not motorways.                              |
+------------------------+----------------------------------------------------------------------+
| trunk_link             | Link roads/lanes/ramps connecting to trunk roads                     |
+------------------------+----------------------------------------------------------------------+
| primary                | A major highway linking large towns.                                 |
+------------------------+----------------------------------------------------------------------+
| primary_link           | Link roads/lanes connecting to primary roads                         |
+------------------------+----------------------------------------------------------------------+
| secondary              | A highway linking large towns.                                       |
+------------------------+----------------------------------------------------------------------+
| secondary_link         | Link roads/lanes connecting to secondary roads                       |
+------------------------+----------------------------------------------------------------------+
| tertiary               | A road linking small settlements, or the local centres of a          |
|                        | large town or city.                                                  |
+------------------------+----------------------------------------------------------------------+
| tertiary_link          | Link roads/lanes connecting to tertiary roads                        |
+------------------------+----------------------------------------------------------------------+
| street                 | Standard unclassified, residential, road, and living_street          |
|                        | road types                                                           |
+------------------------+----------------------------------------------------------------------+
| pedestrian             | Includes pedestrian streets, plazas, and public transportation       |
|                        | platforms.                                                           |
+------------------------+----------------------------------------------------------------------+
| construction           | Includes motor roads under construction                              |
|                        | (but not service roads, paths, etc).                                 |
+------------------------+----------------------------------------------------------------------+
| track                  | Roads mostly for agricultural and forestry use etc.                  |
+------------------------+----------------------------------------------------------------------+
| service                | Access roads, alleys, agricultural tracks, and other services roads. |
|                        | Also includes parking lot aisles, public & private driveways.        |
+------------------------+----------------------------------------------------------------------+
| ferry                  | Those that serves automobiles and no or unspecified                  |
|                        | automobile service.                                                  |
+------------------------+----------------------------------------------------------------------+
| major_rail             | Railways, including mainline, commuter rail, and rapid transit.      |
+------------------------+----------------------------------------------------------------------+
| minor_rail             | Includes light rail & tram lines.                                    |
+------------------------+----------------------------------------------------------------------+
| minor_rail             | Includes light rail & tram lines.                                    |
+------------------------+----------------------------------------------------------------------+
| aerialway              | Ski lifts, gondolas, and other types of aerialway.                   |
+------------------------+----------------------------------------------------------------------+
| roundabout             | Circular continuous-flow intersection                                |
+------------------------+----------------------------------------------------------------------+
| mini_roundabout        | Smaller variation of a roundabout with no center island or obstacle  |
+------------------------+----------------------------------------------------------------------+
| turning_circle         | (point) Widened section at the end of a cull-de-sac for              |
|                        | turning around a vehicle                                             |
+------------------------+----------------------------------------------------------------------+
| turning_loop           | (point) Similar to a turning circle but with an island               |
|                        | or other obstruction at the centerpoint                              |
+------------------------+----------------------------------------------------------------------+

structure - *text*
^^^^^^^^^^^^^^^^^^
The structure field describes whether the road segment is a ``bridge``, ``tunnel``, ``ford``, or ``none`` of those.

type - *text*
^^^^^^^^^^^^^
The ``type`` field is the value of the road's "primary" OpenStreetMap tag. For most roads this is the highway tag,
but for aerialways it will be the aerialway tag.

Possible ``construction`` class ``type`` values::

   construction:motorway
   construction:motorway_link
   construction:trunk
   construction:trunk_link
   construction:primary
   construction:primary_link
   construction:secondary
   construction:secondary_link
   construction:tertiary
   construction:tertiary_link
   construction:unclassifed
   construction:residential
   construction:road
   construction:living_street
   construction:pedestrian
   construction

Possible ``track`` class ``type`` values::

   track:grade1
   track:grade2
   track:grade3
   track:grade4
   track:grade5
   track

Possible ``service`` class ``type`` values::

   service:alley
   service:emergency_access
   service:drive_through
   service:driveway
   service:parking
   service:parking_aisle
   service

For the ``path`` class, the tileset made custom type assignments based on insight from various categorical, physical,
and access tags from OpenStreetMap.

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| steps                  | aka stairs                                                           |
+------------------------+----------------------------------------------------------------------+
| corridor               | An indoors passageway                                                |
+------------------------+----------------------------------------------------------------------+
| piste                  | Ski & snowboard trails, both downhill and cross-country              |
+------------------------+----------------------------------------------------------------------+
| cycleway               | Paths primarily or exclusively for cyclists                          |
+------------------------+----------------------------------------------------------------------+
| footway                | Paths primarily or exclusively for pedestrians                       |
+------------------------+----------------------------------------------------------------------+
| path                   | Unspecified or mixed-use paths                                       |
+------------------------+----------------------------------------------------------------------+
| bridleway              | Equestrian trails                                                    |
+------------------------+----------------------------------------------------------------------+

Possible ``ferry`` class ``type`` values:

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| ferry                  | No or unspecified automobile service                                 |
+------------------------+----------------------------------------------------------------------+

Possible ``aerialway`` class type values:

+------------------------+----------------------------------------------------------------------+
| **Value**              | **Description**                                                      |
+------------------------+----------------------------------------------------------------------+
| aerialway:cablecar     |                                                                      |
+------------------------+----------------------------------------------------------------------+
| aerialway:gondola      |                                                                      |
+------------------------+----------------------------------------------------------------------+
| aerialway:mixed_lift   |                                                                      |
+------------------------+----------------------------------------------------------------------+
| aerialway:chair_lift   |                                                                      |
+------------------------+----------------------------------------------------------------------+
| aerialway:drag_lift    |                                                                      |
+------------------------+----------------------------------------------------------------------+
| aerialway:magic_carpet |                                                                      |
+------------------------+----------------------------------------------------------------------+
| aerialway              | Other or unspecified type of aerialway                               |
+------------------------+----------------------------------------------------------------------+


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
