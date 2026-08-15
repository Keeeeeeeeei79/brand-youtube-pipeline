import os, requests, yaml
from collections import defaultdict

API_KEY = os.environ["YOUTUBE_API_KEY"]

def resolve(handle):
    r = requests.get("https://www.googleapis.com/youtube/v3/channels",
        params={"part": "id,snippet,statistics",
                "forHandle": handle.lstrip("@"), "key": API_KEY}, timeout=30)
    r.raise_for_status()
    items = r.json().get("items", [])
    if not items:
        return None
    it = items[0]
    return (it["id"], it["snippet"]["title"],
            it["statistics"].get("subscriberCount", "?"),
            it["statistics"].get("videoCount", "?"))

industries, failed = defaultdict(list), []

for line in open("config/handles.txt", encoding="utf-8"):
    line = line.strip()
    if not line or line.startswith("#"):
        continue
    industry, company, role, handle = [x.strip() for x in line.split(",")]
    res = resolve(handle)
    if not res:
        failed.append(handle)
        print(f"[NG] {handle}")
        continue
    cid, title, subs, vids = res
    print(f"[OK] {handle:24} {title:28} subs={subs:>12} videos={vids:>6}")
    industries[industry].append({
        "key": handle.lstrip("@").lower(),
        "id": cid,
        "company": company,
        "role": role,
    })

with open("config/channels.yml", "w", encoding="utf-8") as f:
    yaml.safe_dump({"industries": dict(industries)}, f,
                   allow_unicode=True, sort_keys=False)

total = sum(len(v) for v in industries.values())
print(f"\n書き出し完了: {total}件" + (f" / 失敗: {failed}" if failed else ""))
