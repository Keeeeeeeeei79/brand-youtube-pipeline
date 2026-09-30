-- 5-company comparison on the same period: videos published in the last 90 days
-- Note: avg_like_rate is NULL for bandainamcoentertainment. YouTube lets a
-- channel hide its like count publicly; when hidden, the API returns no
-- likeCount at all (confirmed: 0 of 8639 rows have a like_count for this
-- channel). This is a platform setting, not a data quality issue.
with latest as (
    select max(snapshot_date) as d from {{ ref('int_video_growth') }}
),
recent as (
    select g.*
    from {{ ref('int_video_growth') }} g
    cross join latest
    where g.snapshot_date = latest.d
      and g.published_at >= cast(latest.d as timestamp) - interval 90 day
)

select
    channel_key,
    count(*) as videos_published_90d,
    round(count(*) / (90 / 7.0), 2) as videos_per_week,
    round(avg(view_count), 0) as avg_views,
    median(view_count) as median_views,
    round(avg(like_count * 1.0 / nullif(view_count, 0)), 4) as avg_like_rate
from recent
group by 1
