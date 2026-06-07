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

    data = resp.json()
    tasks = data["results"][:3]

    if not tasks:
        return render.Root(
            child = render.Text("All done!", color = "#00CC44"),
        )

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

    t1 = task_row(tasks[0]["content"])
    t2 = task_row(tasks[1]["content"]) if len(tasks) > 1 else render.Box(height = 1)
    t3 = task_row(tasks[2]["content"]) if len(tasks) > 2 else render.Box(height = 1)

    return render.Root(
        child = render.Column(
            children = [
                t1,
                render.Box(height = 2),
                t2,
                render.Box(height = 2),
                t3,
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
