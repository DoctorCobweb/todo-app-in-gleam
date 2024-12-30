import lustre/element
import wisp.{type Request, type Response}
import gleam/io
import gleam/http
import todo_app/web.{type Context}
import todo_app/pages
import todo_app/pages/layout.{layout}
import todo_app/routes/item_routes.{items_middleware}

pub fn handle_request(req: Request, ctx: Context) -> Response {
    io.print("Handling request\n")
    use req <- web.middleware(req, ctx)
    use ctx <- items_middleware(req, ctx)

    case wisp.path_segments(req) {
        // homepage
        [] -> {
            [pages.home(ctx.items)]
            |> layout
            |> element.to_document_string_builder
            |> wisp.html_response(200)
        }
        ["items", "create"] -> {
            use <- wisp.require_method(req, http.Post)
            item_routes.post_create_item(req, ctx)
        }
        ["items", id] -> {
            io.print("deleting item with id::")
            io.debug(id)
            use <- wisp.require_method(req, http.Delete)
            io.print("yoyoyo")
            item_routes.delete_item(req, ctx, id)
        }
        ["items", id, "completion"] -> {
            use <- wisp.require_method(req, http.Patch)
            item_routes.patch_toggle_todo(req, ctx, id)
        }
        // all the empty responses
        ["internal-server-error"] -> wisp.internal_server_error() 
        ["unprocessable-entity"] -> wisp.unprocessable_entity() 
        ["method-not-allowed"] -> wisp.method_not_allowed([]) 
        ["entity-too-large"] -> wisp.entity_too_large() 
        ["bad-request"] -> wisp.bad_request() 
        _ -> wisp.not_found() 
    }
}