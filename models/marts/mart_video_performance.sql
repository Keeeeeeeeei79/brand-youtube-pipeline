-- Latest state of every video currently in a channel's newest-200 window
select
    channel_key,
    video_id,
    title,
    published_at,
    snapshot_date,
    days_since_publish,
    duration_iso,
    view_count,
    like_count,
    like_count * 1.0 / nullif(view_count, 0) as like_rate,
    view_count * 1.0 / nullif(days_since_publish, 0) as views_per_day,
    views_gained as views_gained_last_day
from {{ ref('int_video_growth') }}
where snapshot_date = (select max(snapshot_date) from {{ ref('int_video_growth') }})
