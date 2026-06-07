load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        return render.Root(
            child = render.Text("No key", color = "#FF0000"),
        )

    resp = http.get(
        "https://api.todoist.com/api/v1/tasks?filter=next+7+days",
        headers = {"Authorization": "Bearer {}".format(api_key)},
    )

    if resp.status_code != 200:
        return render.Root(
            child = render.Text("Err " + str(resp.status_code), color = "#FF0000"),
        )

    data = resp.json()
    tasks = data["results"]

    if not tasks:
        return render.Root(
            child = render.Column(
                expanded = True,
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Text(
                        content = "All done!",
                        font = "CG-pixel-3x5-mono",
                        color = "#00CC44",
                    ),
                ],
            ),
        )

    top3 = tasks[:3]

    rows = []
    for task in top3:
        name = task["content"]
        if len(name) > 10:
            name = name[:10] + ".."
        rows.append(
            render.Row(
                cross_align = "center",
                children = [
                    render.Box(width = 5, height = 5, color = "#444444"),
                    render.Box(width = 2),
                    render.Text(
                        content = name,
                        font = "CG-pixel-3x5-mono",
                        color = "#FFFFFF",
                    ),
                ],
            ),
        )
        rows.append(render.Box(height = 3))

    return render.Root(
        child = render.Padding(
            pad = (2, 3, 0, 0),
            child = render.Column(
                children = rows,
            ),
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_key",
                name = "Todoist API Token",
                desc = "Your Todoist API token from settings",
                icon = "key",
            ),
        ],
    )
