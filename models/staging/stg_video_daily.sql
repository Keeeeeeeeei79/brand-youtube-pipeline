-- Grain: 1 row = 1 video x 1 day (latest snapshot of that UTC day)
with ranked as (
    select
        *,
        row_number() over (
            partition by video_id, snapshot_date
            order by snapshot_at desc
        ) as rn
    from {{ ref('stg_video_snapshot') }}
)

select * exclude (rn)
from ranked
where rn = 1
