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
        "https://api.todoist.com/api/v1/tasks",
        headers = {"Authorization": "Bearer {}".format(api_key)},
    )

    data = resp.json()

    # Show what type the response is
    if type(data) == "list":
        count = str(len(data))
        return render.Root(
            child = render.Text("list:" + count, color = "#FFFFFF"),
        )
    elif type(data) == "dict":
        keys = ",".join(data.keys()[:3])
        return render.Root(
            child = render.Text(keys, color = "#FFFFFF"),
        )
    else:
        return render.Root(
            child = render.Text("unknown", color = "#FF0000"),
        )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_key",
                name = "Todoist API Token",
                desc = "Your Todoist API token",
                icon = "key",
            ),
        ],
    )
