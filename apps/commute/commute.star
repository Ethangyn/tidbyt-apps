load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("cache.star", "cache")
load("animation.star", "animation")

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

def car_frame(position, color):
    return render.Padding(
        pad = (position, 12, 0, 0),
        child = render.Box(
            width = 5,
            height = 3,
            color = color,
        ),
    )

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

    # build animation frames — car moves from x=0 to x=54
    frames = []
    for i in range(0, 55, 3):
        frames.append(
            render.Stack(
                children = [
                    # background
                    render.Column(
                        children = [
                            # top: labels
                            render.Row(
                                expanded = True,
                                main_align = "space_between",
                                children = [
                                    render.Text(
                                        content = "HOME",
                                        font = "CG-pixel-3x5-mono",
                                        color = "#4285F4",
                                    ),
                                    render.Text(
                                        content = "WORK",
                                        font = "CG-pixel-3x5-mono",
                                        color = "#EA4335",
                                    ),
                                ],
                            ),
                            render.Box(height = 3),
                            # road line
                            render.Box(
                                width = 64,
                                height = 1,
                                color = "#555555",
                            ),
                            render.Box(height = 6),
                            # time at bottom
                            render.Row(
                                expanded = True,
                                main_align = "center",
                                children = [
                                    render.Text(
                                        content = duration,
                                        font = "CG-pixel-4x5-mono",
                                        color = "#00CC44",
                                    ),
                                ],
                            ),
                        ],
                    ),
                    # animated car dot
                    car_frame(i, "#FFCC00"),
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
        ],
    )
