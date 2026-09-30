-- Day-over-day growth per video (vs the previous available snapshot_date)
select
    *,
    lag(snapshot_date) over w as prev_snapshot_date,
    view_count - lag(view_count) over w as views_gained,
    like_count - lag(like_count) over w as likes_gained,
    date_diff('day', cast(published_at as date), snapshot_date) as days_since_publish
from {{ ref('stg_video_daily') }}
window w as (partition by video_id order by snapshot_date)
