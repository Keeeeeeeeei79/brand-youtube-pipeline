-- Grain: 1 row = 1 video x 1 snapshot (every collection run)
-- The raw JSON is read with an explicit schema so that field drift between runs cannot break inference.
with raw as (
    select
        snapshot_at,
        channel_key,
        channel_id,
        filename as source_file,
        unnest(from_json(videos, '["JSON"]')) as video
    from read_json(
        'data/raw/*/*.json',
        columns = {
            'snapshot_at': 'VARCHAR',
            'channel_key': 'VARCHAR',
            'channel_id': 'VARCHAR',
            'videos': 'JSON'
        },
        filename = true,
        maximum_object_size = 67108864
    )
)

select
    channel_key,
    channel_id,
    json_extract_string(video, '$.id')                              as video_id,
    (cast(snapshot_at as timestamptz) at time zone 'UTC')           as snapshot_at,
    cast((cast(snapshot_at as timestamptz) at time zone 'UTC') as date) as snapshot_date,
    (cast(json_extract_string(video, '$.snippet.publishedAt') as timestamptz)
        at time zone 'UTC')                                         as published_at,
    json_extract_string(video, '$.snippet.title')                   as title,
    json_extract_string(video, '$.snippet.channelTitle')            as channel_title,
    json_extract_string(video, '$.snippet.categoryId')              as category_id,
    json_extract_string(video, '$.contentDetails.duration')         as duration_iso,
    try_cast(json_extract_string(video, '$.statistics.viewCount') as bigint) as view_count,
    try_cast(json_extract_string(video, '$.statistics.likeCount') as bigint) as like_count,
    source_file
from raw
