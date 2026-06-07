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
        child = render.Stack(
            children = [
                # Dark map background
                render.Box(
                    width = 64,
                    height = 32,
                    color = "#1A1A2E",
                ),

                # I-210 horizontal segment (top, going west)
                render.Padding(
                    pad = (4, 8, 0, 0),
                    child = render.Box(
                        width = 22,
                        height = 2,
                        color = "#4285F4",
                    ),
                ),

                # I-110 connector going south
                render.Padding(
                    pad = (24, 8, 0, 0),
                    child = render.Box(
                        width = 2,
                        height = 8,
                        color = "#4285F4",
                    ),
                ),

                # I-10 horizontal segment (going west to SM)
                render.Padding(
                    pad = (14, 14, 0, 0),
                    child = render.Box(
                        width = 22,
                        height = 2,
                        color = "#4285F4",
                    ),
                ),

                # Home dot (Monrovia - top right of route)
                render.Padding(
                    pad = (2, 6, 0, 0),
                    child = render.Circle(
                        color = "#4285F4",
                        diameter = 4,
                    ),
                ),

                # Work dot (Santa Monica - end of I-10)
                render.Padding(
                    pad = (34, 12, 0, 0),
                    child = render.Circle(
                        color = "#EA4335",
                        diameter = 4,
                    ),
                ),

                # Duration text on right side
                render.Padding(
                    pad = (40, 4, 0, 0),
                    child = render.Column(
                        children = [
                            render.Text(
                                content = "DRIVE",
                                font = "CG-pixel-3x5-mono",
                                color = "#888888",
                            ),
                            render.Box(height = 2),
                            render.Text(
                                content = duration,
                                font = "CG-pixel-3x5-mono",
                                color = "#00CC44",
                            ),
                        ],
                    ),
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
