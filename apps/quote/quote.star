load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")

def main(config):
    resp = http.get("https://zenquotes.io/api/random")

    if resp.status_code != 200:
        return render.Root(
            child = render.Text("No quote", color = "#FF0000"),
        )

    data = resp.json()
    quote = data[0]["q"]

    return render.Root(
        child = render.Marquee(
            width = 64,
            height = 32,
            scroll_direction = "vertical",
            child = render.WrappedText(
                content = quote,
                width = 64,
                font = "CG-pixel-3x5-mono",
                color = "#FFFFFF",
            ),
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [],
    )
