{{ config(severity='warn') }}
-- Warns when the newest snapshot is older than 1 day (collection may have stopped)
select max(snapshot_date) as last_snapshot_date
from {{ ref('stg_video_daily') }}
having max(snapshot_date) < current_date - 1
