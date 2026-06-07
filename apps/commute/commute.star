load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("cache.star", "cache")

ORIGIN = "2234+Rochelle+Ave+Monrovia+CA+91016"
DESTINATION = "1119+Colorado+Ave+Santa+Monica+CA"

def get_eta(api_key):
    cached = cache.get("commute_eta")
    if cached:
        return cached

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

    duration = element["duration_in_traffic"]["text"]
    distance = element["distance"]["text"]

    result = "{} | {}".format(duration, distance)
    cache.set("commute_eta", result, ttl_seconds = 300)
    return result

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        return render.Root(
            child = render.Box(
                render.Text("No API key", color = "#FF0000"),
            ),
        )

    eta = get_eta(api_key)

    if not eta:
        return render.Root(
            child = render.Box(
                render.Text("No data", color = "#FF0000"),
            ),
        )

    parts = eta.split(" | ")
    duration = parts[0]
    distance = parts[1] if len(parts) > 1 else ""

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
                render.Box(height = 2),
                render.Text(
                    content = duration,
                    font = "CG-pixel-4x5-mono",
                    color = "#00CC44",
                ),
                render.Box(height = 1),
                render.Text(
                    content = distance,
                    font = "CG-pixel-3x5-mono",
                    color = "#888888",
                ),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_key",
                name = "Google Maps API Key",
                desc = "Your Google Maps Distance Matrix API key",
                icon = "key",
            ),
        ],
    )
