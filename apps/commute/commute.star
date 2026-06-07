load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("cache.star", "cache")
load("time.star", "time")

def main(config):
    api_key = config.get("api_key")
    origin = config.get("origin", "Monrovia CA")
    destination = config.get("destination", "Santa Monica CA")

    if not api_key:
        return render.Root(
            child = render.Text("No key", color = "#FF0000"),
        )

    cache_key = "commute_v7"
    cached = cache.get(cache_key)

    if cached:
        parts = cached.split("|")
        duration = parts[0]
        duration_secs = int(parts[1])
    else:
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

        duration = element["duration_in_traffic"]["text"]
        duration_secs = element["duration_in_traffic"]["value"]
        cache.set(cache_key, "{}|{}".format(duration, duration_secs), ttl_seconds = 300)

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
                render.Box(height = 2),
                render.Text(
                    content = duration,
                    font = "CG-pixel-3x5-mono",
                    color = "#00CC44",
                ),
                render.Box(height = 1),
                render.Text(
                    content = "ETA " + arrival_str,
                    font = "CG-pixel-3x5-mono",
                    color = "#FFAA00",
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
                name =
