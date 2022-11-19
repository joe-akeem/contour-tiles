select
    'normal' as type,
    '100m' as distance,
    contourlines.elev,
    contourlines.wkb_geometry
from contourlines
where mod(cast(contourlines.elev as integer), 100) = 0