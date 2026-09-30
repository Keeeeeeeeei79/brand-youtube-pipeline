select *
from {{ ref('stg_video_snapshot') }}
where view_count < 0 or like_count < 0
