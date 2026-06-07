load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("time.star", "time")

def main(config):
    api_key = config.get("api_key")
    origin = config.get("origin")
    destination = config.get("destination")

    if not api_key:
        return render.Root(
            child = render.Text("No key", color = "#FF0000"),
        )

    if not origin or not destination:
        return render.Root(
            child = render.Text("Set addrs", color = "#FFAA00"),
        )

    url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins={}&destinations={}&departure_time=now&traffic_model=best_guess&key={}".format(
        origin.replace(" ", "+"),
        destination.replace(" ", "+"),
        api_key,
    )

    resp = http.get(url)
    if resp.status_code != 200:
        return render.Root(
            child = render.Text("HTTP fail", color = "#FF0000"),
        )

    data = resp.json()
    element = data["rows"][0]["elements"][0]

    if element["status"] != "OK":
        return render.Root(
            child = render.Text("API fail", color = "#FF0000"),
        )

    duration_secs = element["duration_in_traffic"]["value"]

    now = time.now().in_location("America/Los_Angeles")
    arrival = now + time.parse_duration("{}s".format(duration_secs))
    arrival_str = arrival.format("3:04pm")
    current_time_str = now.format("3:04pm")

    return render.Root(
        child = render.Column(
            expanded = True,
            main_align = "center",
            cross_align = "center",
            children = [
                render.Text(
                    content = "COMMUTE",
                    font = "CG-pixel-3x5-mono",
                    color = "#4285F4",
                ),
                render.Box(height = 3),
                render.Text(
                    content = "ETA " + arrival_str,
                    font = "CG-pixel-3x5-mono",
                    color = "#00CC44",
                ),
                render.Box(height = 2),
                render.Text(
                    content = current_time_str,
                    font = "tom-thumb",
                    color = "#444444",
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
            schema.Text(
                id = "origin",
                name = "Starting Address",
                desc = "e.g. 450 N Roxbury Dr Beverly Hills CA",
                icon = "house",
            ),
            schema.Text(
                id = "destination",
                name = "Destination Address",
                desc = "e.g. 1600 Vine St Los Angeles CA",
                icon = "briefcase",
            ),
        ],
    )
