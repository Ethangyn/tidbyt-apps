load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("cache.star", "cache")
load("time.star", "time")

ORIGIN = "2234+Rochelle+Ave+Monrovia+CA+91016"
DESTINATION = "1119+Colorado+Ave+Santa+Monica+CA"

def get_eta(api_key):
    cached = cache.get("commute_eta_v4")
    if cached:
        parts = cached.split("|")
        return parts[0], int(parts[1])

    url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins={}&destinations={}&departure_time=now&traffic_model=best_guess&key={}".format(
        ORIGIN,
        DESTINATION,
        api_key,
    )

    resp = http.get(url)
    if resp.status_code != 200:
        return None

    data = resp.json()
    element = data["rows"][0]["elements"][0]

    if element["status"] != "OK":
        return None

    duration_text = element["duration_in_traffic"]["text"]
    duration_secs = element["duration_in_traffic"]["value"]

    cache.set("commute_eta_v4", "{}|{}".format(duration_text, duration_secs), ttl_seconds = 300)
    return duration_text, duration_secs

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        return render.Root(
            child = render.Text("No API
