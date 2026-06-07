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
        "https://api.todoist.com/rest/v2/tasks",
        headers = {"Authorization": "Bearer {}".format(api_key)},
    )

    return render.Root(
        child = render.Text(
            content = str(resp.status_code),
            color = "#FFFFFF",
        ),
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
