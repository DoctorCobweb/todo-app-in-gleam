import wisp.{type Request, type Response}
import gleam/bool
import gleam/string_tree
import gleam/io
import todo_app/models/item.{type Item}


pub type Context {
    Context(static_directory: String, items: List(Item))
}

pub fn middleware(
    req: Request,
    ctx: Context,
    handle_request: fn(Request) -> wisp.Response
) -> Response {
    let req = wisp.method_override(req)
    use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)
    use <- wisp.log_request(req)
    use <- wisp.rescue_crashes
    use req <- wisp.handle_head(req)
    use <- default_responses
    handle_request(req)
}

pub fn default_responses(handle_request: fn() -> wisp.Response) -> wisp.Response {
  let response = handle_request()
  use <- bool.guard(when: response.body != wisp.Empty, return: response)
  case response.status {
    404 -> {
        let body = string_tree.from_string("<h1>Not Found</h1>")
        wisp.html_response(body, response.status)
    }
    400 | 422 -> {
      let body = string_tree.from_string("<h1>Bad request</h1>")
      wisp.html_response(body, response.status)

    }
    413 -> {
        let body = string_tree.from_string("<h1>Request entity too large</h1>")
        wisp.html_response(body, response.status)
    }
    500 -> {
        let body = string_tree.from_string("<h1>Internal server errorrrr</h1>")
        wisp.html_response(body, response.status)
    }
    _ -> {
        io.print("Returning response")
        response
    }
  }
}
