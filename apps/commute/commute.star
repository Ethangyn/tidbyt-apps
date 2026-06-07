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
    arrival = now + time.second * duration_secs
    arrival_str = arrival.format("3:04pm")

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
                desc = "e.g. 2234 Rochelle Ave Monrovia CA",
                icon = "house",
            ),
            schema.Text(
                id = "destination",
                name = "Destination Address",
                desc = "e.g. 1119 Colorado Ave Santa Monica CA",
                icon = "briefcase",
            ),
        ],
    )
