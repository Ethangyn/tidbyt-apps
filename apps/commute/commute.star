load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        return render.Root(
            child = render.Text("No key", color = "#FF0000"),
        )

    url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=Monrovia+CA&destinations=Santa+Monica+CA&departure_time=now&traffic_model=best_guess&key={}".format(api_key)

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

    return render.Root(
        child = render.Text(duration, color = "#00CC44"),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_key",
                name = "Google Maps API Key",
                desc = "Your API key",
                icon = "key",
            ),
        ],
    )
