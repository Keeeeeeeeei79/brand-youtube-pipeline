import os, json, time, yaml, requests
from datetime import datetime, timezone

API_KEY = os.environ["YOUTUBE_API_KEY"]
BASE = "https://www.googleapis.com/youtube/v3"
MAX_VIDEOS_PER_CHANNEL = 200

cfg = yaml.safe_load(open("config/channels.yml", encoding="utf-8"))
CHANNELS = {c["key"]: c["id"]
            for ind in cfg["industries"].values() for c in ind}

def get(endpoint, **params):
    params["key"] = API_KEY
    r = requests.get(f"{BASE}/{endpoint}", params=params, timeout=30)
    r.raise_for_status()
    return r.json()

def get_video_ids(channel_id):
    playlist_id = "UU" + channel_id[2:]
    ids, token = [], None
    while len(ids) < MAX_VIDEOS_PER_CHANNEL:
        res = get("playlistItems", part="contentDetails",
                  playlistId=playlist_id, maxResults=50, pageToken=token)
        ids += [i["contentDetails"]["videoId"] for i in res.get("items", [])]
        token = res.get("nextPageToken")
        if not token:
            break
    return ids[:MAX_VIDEOS_PER_CHANNEL]

def get_video_stats(video_ids):
    out = []
    for i in range(0, len(video_ids), 50):
        res = get("videos", part="snippet,statistics,contentDetails",
                  id=",".join(video_ids[i:i+50]), maxResults=50)
        out += res.get("items", [])
        time.sleep(0.2)
    return out

def main():
    snapshot_at = datetime.now(timezone.utc).isoformat()
    date_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    outdir = f"data/raw/{date_str}"
    os.makedirs(outdir, exist_ok=True)

    for name, cid in CHANNELS.items():
        try:
            videos = get_video_stats(get_video_ids(cid))
        except Exception as e:
            print(f"[FAIL] {name}: {e}")
            continue
        payload = {
            "snapshot_at": snapshot_at,
            "channel_key": name,
            "channel_id": cid,
            "video_count": len(videos),
            "videos": videos,
        }
        with open(f"{outdir}/{name}.json", "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False)
        print(f"[OK] {name}: {len(videos)} videos")

if __name__ == "__main__":
    main()
