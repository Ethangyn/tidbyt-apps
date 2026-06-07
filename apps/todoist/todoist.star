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

    def get_due(task):
        due = task.get("due")
        if due == None:
            return "9999-99-99"
        return due.get("date", "9999-99-99")

    sorted_tasks = sorted(tasks, key = get_due)
    task_text = sorted_tasks[0]["content"] + "          "

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
