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

    cache.set("commute_eta", duration, ttl_seconds = 300)
    return duration

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        return render.Root(
            child = render.Text("No API key", color = "#FF0000"),
        )

    duration = get_eta(api_key)

    if not duration:
        return render.Root(
            child = render.Text("No data", color = "#FF0000"),
        )

    return render.Root(
        child = render.Row(
            expanded = True,
            children = [
                # Left side: route visual
                render.Column(
                    main_align = "center",
                    cross_align = "center",
                    children = [
                        render.Circle(color = "#4285F4", diameter = 5),
                        render.Box(width = 1, height = 4, color = "#555555"),
                        render.Box(width = 1, height = 4, color = "#555555"),
                        render.Box(width = 1, height = 4, color = "#555555"),
                        render.Box(width = 1, height = 4, color = "#555555"),
                        render.Circle(color = "#EA4335", diameter = 5),
                    ],
                ),
                render.Box(width = 3),
                # Right side: labels and time
                render.Column(
                    main_align = "center",
                    cross_align = "start",
                    expanded = True,
                    children = [
                        render.Text(
                            content = "Home",
                            font = "CG-pixel-3x5-mono",
                            color = "#4285F4",
                        ),
                        render.Box(height = 2),
                        render.Text(
                            content = duration,
                            font = "CG-pixel-4x5-mono",
                            color = "#00CC44",
                        ),
                        render.Box(height = 2),
                        render.Text(
                            content = "Work",
                            font = "CG-pixel-3x5-mono",
                            color = "#EA4335",
                        ),
                    ],
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
