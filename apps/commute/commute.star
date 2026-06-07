load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("cache.star", "cache")
load("time.star", "time")

def get_eta(api_key, origin, destination):
    cache_key = "commute_{}_{}_v6".format(origin, destination)
    cached = cache.get(cache_key)
    if cached:
        parts = cached.split("|")
        return parts[0], int(parts[1])

    url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins={}&destinations={}&departure_time=now&traffic_model=best_guess&key={}".format(
        origin.replace(" ", "+"),
        destination.replace(" ", "+"),
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

    cache.set(cache_key, "{}|{}".format(duration_text, duration_secs), ttl_seconds = 300)
    return duration_text, duration_secs

def main(config):
    api_key = config.get("api_key")
    origin = config.get("origin")
    destination = config.get("destination")

    if not api_key:
        return render.Root(
            child = render.Text("No API key", color = "#FF0000"),
        )

    if not origin or not destination:
        return render.Root(
            child = render.Text("Set locations", color = "#FFAA00"),
        )

    result = get_eta(api_key, origin, destination)

    if not result:
        return render.Root(
            child = render.Text("No data", color = "#FF0000"),
        )

    duration, duration_secs = result

    frames = []
    for i in range(0, 55, 3):
        frames.append(
            render.Stack(
                children = [
                    render.Column(
                        expanded = True,
                        main_align = "center",
                        children = [
                            render.Box(height = 1),
                            render.Text(
                                content = "COMMUTE",
                                font = "CG-pixel-3x5-mono",
                                color = "#4285F4",
                            ),
                            render.Box(height = 3),
                            render.Box(
                                width = 64,
                                height = 1,
                                color = "#444444",
                            ),
                            render.Box(height = 3),
                            render.Row(
                                expanded = True,
                                main_align = "center",
                                children = [
                                    render.Text(
                                        content = duration,
                                        font = "CG-pixel-3x5-mono",
                                        color = "#00CC44",
                                    ),
                                ],
                            ),
                        ],
                    ),
                    render.Padding(
                        pad = (i, 10, 0, 0),
                        child = render.Box(
                            width = 5,
                            height = 3,
                            color = "#FFCC00",
                        ),
                    ),
                ],
            ),
        )

    return render.Root(
        delay = 80,
        child = render.Animation(
            children = frames,
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
            schema.Text(
                id = "origin",
                name = "Starting Address",
                desc = "Your home address e.g. 123 Main St Los Angeles CA",
                icon = "house",
            ),
            schema.Text(
                id = "destination",
                name = "Destination Address",
                desc = "Your work address e.g. 456 Office Blvd Santa Monica CA",
                icon = "briefcase",
            ),
        ],
    )
