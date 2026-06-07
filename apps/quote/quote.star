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
    author = data[0]["a"]

    display = quote + " - " + author + "          "

    return render.Root(
        child = render.Column(
            expanded = True,
            main_align = "center",
            cross_align = "center",
            children = [
                render.Text(
                    content = "INSPIRE",
                    font = "CG-pixel-3x5-mono",
                    color = "#FFD700",
                ),
                render.Box(height = 3),
                render.Marquee(
                    width = 64,
                    child = render.Text(
                        content = display,
                        font = "CG-pixel-3x5-mono",
                        color = "#FFFFFF",
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
