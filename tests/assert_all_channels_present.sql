-- Every snapshot_date must contain all 5 channels
select snapshot_date, count(distinct channel_key) as channels
from {{ ref('stg_video_daily') }}
group by 1
having count(distinct channel_key) < 5
