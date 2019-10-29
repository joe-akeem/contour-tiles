select
       'normal' as type,
       '20m' as distance,
       contourlines.elev,
       contourlines.geom
from contourlines
where mod(cast(contourlines.elev as integer), 100) <> 0