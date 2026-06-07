load("render.star", "render")
load("http.star", "http")
load("schema.star", "schema")
load("encoding/json.star", "json")

def main(config):
    api_key = config.get("api_key")

    if not api_key:
        return render.Root(
            child = render.Text("No key", color = "#FF0000"),
        )

    resp = http.get(
        "https://api.todoist.com/rest/v2/tasks",
        headers = {"Authorization": "Bearer {}".format(api_key)},
    )

    if resp.status_code != 200:
        return render.Root(
            child = render.Text("API fail", color = "#FF0000"),
        )

    tasks = resp.json()

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

    # Sort by priority (1 = highest in Todoist)
    top = tasks[0]
    for task in tasks:
        if task["priority"] > top["priority"]:
            top = task

    task_text = top["content"]

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
                render.Marquee(
                    width = 64,
                    child = render.Text(
                        content = task_text,
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
        fields = [
            schema.Text(
                id = "api_key",
                name = "Todoist API Token",
                desc = "Your Todoist API token from settings",
                icon = "key",
            ),
        ],
    )
