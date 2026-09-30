-- (video_id, snapshot_date) must be unique in stg_video_daily
select video_id, snapshot_date, count(*) as n
from {{ ref('stg_video_daily') }}
group by 1, 2
having count(*) > 1
