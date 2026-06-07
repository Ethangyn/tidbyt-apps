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
        "https://api.todoist.com/api/v1/tasks?filter=today",
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
                        content = "FOCUS",
                        font = "CG-pixel-3x5-mono",
                        color = "#E44332",
                    ),
                    render.Box(height = 3),
                    render.Text(
                        content = "All done!",
                        font = "CG-pixel-3x5-mono",
                        color = "#00CC44",
                    ),
                ],
            ),
        )

    # Just take first 3 tasks as-is
    top3 = tasks[:3]

    def task_row(name):
        if len(name) > 10:
            name = name[:10] + ".."
        return render.Row(
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
        )

    rows = [
        render.Text(
            content = "FOCUS",
            font = "CG-pixel-3x5-mono",
            color = "#E44332",
        ),
        render.Box(height = 2),
    ]

    for task in top3:
        rows.append(task_row(task["content"]))
        rows.append(render.Box(height = 2))

    return render.Root(
        child = render.Column(
            expanded = True,
            main_align = "center",
            cross_align = "start",
            children = rows,
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
