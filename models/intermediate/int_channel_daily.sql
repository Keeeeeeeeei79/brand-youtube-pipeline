-- Channel-level daily growth.
-- Only growth is summed: the total views of the window can fall when old videos drop out.
select
    channel_key,
    snapshot_date,
    count(*) as videos_in_window,
    sum(views_gained) as daily_views_gained,
    sum(likes_gained) as daily_likes_gained,
    count(*) filter (where cast(published_at as date) = snapshot_date) as videos_published
from {{ ref('int_video_growth') }}
group by 1, 2
