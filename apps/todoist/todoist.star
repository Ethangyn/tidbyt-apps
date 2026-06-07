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

    # Sort by priority descending
    sorted_tasks = []
    for task in tasks:
        inserted = False
        for i in range(len(sorted_tasks)):
            if task["priority"] > sorted_tasks[i]["priority"]:
                sorted_tasks.insert(i, task)
                inserted = True
                break
        if not inserted:
            sorted_tasks.append(task)

    # Take top 3
    top3 = sorted_tasks[:3]

    task_rows = []
    for task in top3:
        name = task["content"]
        if len(name) > 9:
            name = name[:9] + ".."
        task_rows.append(
            render.Row(
                cross_align = "center",
                children = [
                    render.Box(
                        width = 6,
                        height = 6,
                        color = "#333333",
                        child = render.Box(
                            width = 4,
                            height = 4,
                            color = "#000000",
                        ),
                    ),
                    render.Box(width = 2),
                    render.Text(
                        content = name,
                        font = "CG-pixel-3x5-mono",
                        color = "#FFFFFF",
                    ),
                ],
            ),
        )
        task_rows.append(render.Box(height = 3))

    return render.Root(
        child = render.Column(
            expanded = True,
            main_align = "center",
            cross_align = "start",
            children = task_rows,
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
