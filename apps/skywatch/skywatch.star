load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("cache.star", "cache")
load("time.star", "time")
load("math.star", "math")

LAT = "34.1478"
LON = "-117.9748"

def get_weather():
    cached = cache.get("weather_v1")
    if cached:
        parts = cached.split("|")
        return int(parts[0]), parts[1]

    url = "https://api.open-meteo.com/v1/forecast?latitude={}&longitude={}&current=temperature_2m,weathercode&temperature_unit=fahrenheit&timezone=America%2FLos_Angeles".format(LAT, LON)
    resp = http.get(url)
    if resp.status_code != 200:
        return None, None

    data = resp.json()
    temp = int(data["current"]["temperature_2m"])
    code = data["current"]["weathercode"]

    if code == 0:
        condition = "Clear"
    elif code <= 3:
        condition = "Cloudy"
    elif code <= 67:
        condition = "Rain"
    elif code <= 77:
        condition = "Snow"
    else:
        condition = "Storm"

    cache.set("weather_v1", "{}|{}".format(temp, condition), ttl_seconds = 600)
    return temp, condition

def main(config):
    now = time.now().in_location("America/Los_Angeles")
    hour = now.hour
    minute = now.minute

    temp, condition = get_weather()

    # time of day calculations
    is_day = hour >= 6 and hour < 20
    # sun/moon position: map hour to x position across 64px
    if is_day:
        progress = (hour - 6 + minute / 60.0) / 14.0
        sky_color = "#1a6fba"
        body_color = "#FFD700"
    else:
        if hour >= 20:
            progress = (hour - 20 + minute / 60.0) / 10.0
        else:
            progress = (hour + 4 + minute / 60.0) / 10.0
        sky_color = "#0a0a2a"
        body_color = "#DDDDDD"

    x_pos = int(progress * 54)
    # arc: y is highest (lowest value) at midpoint
    arc_progress = progress * 2 - 1  # -1 to 1
    y_pos = int(4 + 6 * arc_progress * arc_progress)  # 4 at peak, 10 at edges

    # format time
    if hour == 0:
        display_hour = 12
        ampm = "AM"
    elif hour < 12:
        display_hour = hour
        ampm = "AM"
    elif hour == 12:
        display_hour = 12
        ampm = "PM"
    else:
        display_hour = hour - 12
        ampm = "PM"

    minute_str = str(minute)
    if minute < 10:
        minute_str = "0" + minute_str

    time_str = "{}:{}".format(display_hour, minute_str)
    temp_str = "{}F {}".format(temp, condition) if temp else "..."

    return render.Root(
        child = render.Stack(
            children = [
                # sky background
                render.Box(
                    width = 64,
                    height = 32,
                    color = sky_color,
                ),
                # sun or moon
                render.Padding(
                    pad = (x_pos, y_pos, 0, 0),
                    child = render.Circle(
                        diameter = 5,
                        color = body_color,
                    ),
                ),
                # bottom info bar
                render.Padding(
                    pad = (0, 18, 0, 0),
                    child = render.Column(
                        children = [
                            render.Box(
                                width = 64,
                                height = 1,
                                color = "#ffffff22",
                            ),
                            render.Box(height = 1),
                            render.Row(
                                expanded = True,
                                main_align = "center",
                                children = [
                                    render.Text(
                                        content = time_str,
                                        font = "CG-pixel-4x5-mono",
                                        color = "#FFFFFF",
                                    ),
                                    render.Text(
                                        content = ampm,
                                        font = "CG-pixel-3x5-mono",
                                        color = "#AAAAAA",
                                    ),
                                ],
                            ),
                            render.Box(height = 1),
                            render.Row(
                                expanded = True,
                                main_align = "center",
                                children = [
                                    render.Text(
                                        content = temp_str,
                                        font = "CG-pixel-3x5-mono",
                                        color = "#FFD700",
                                    ),
                                ],
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
        fields = [],
    )
