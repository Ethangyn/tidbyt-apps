load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("cache.star", "cache")

ORIGIN = "2234+Rochelle+Ave+Monrovia+CA+91016"
DESTINATION = "1119+Colorado+Ave+Santa+Monica+CA"

def get_color(duration_mins):
    if duration_mins <= 45:
        return "#00CC44"
    elif duration_mins <= 70:
        return "#FFAA00"
    else:
        return "#FF3333"

def get_eta(api_key):
    cached = cache.get("commute_eta_v3")
    if cached:
        parts = cached.split("|")
        return parts[0], parts[1], int(parts[2])

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
    distance_text = element["distance"]["text"]
    duration_mins = element["duration_in_traffic"]["value"] // 60

    cache.set("commute_eta_v3", "{}|{}|{}".format(duration_text, distance_text, duration_mins), ttl_seconds = 300)
    return duration_text, distance_text, duration_mins

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        return render.Root(
            child = render.Box(
                child = render.Text("No API key", color = "#FF0000"),
            ),
        )

    result = get_eta(api_key)
    if not result:
        return render.Root(
            child = render.Box(
                child = render.Text("No data", color = "#FF0000"),
            ),
        )

    duration, distance, duration_mins = result
    time_color = get_color(duration_mins)

    return render.Root(
        child = render.Column(
            expanded = True,
            main_align = "center",
            cross_align = "center",
            children = [
                render.Text(
                    content = "TO WORK",
                    font = "CG-pixel-3x5-mono",
                    color = "#4285F4",
                ),
                render.Box(height = 3),
                render.Text(
                    content = duration,
