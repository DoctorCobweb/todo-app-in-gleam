import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import dot_env
import dot_env/env
import gleam/io
import todo_app/web.{Context}
import todo_app/router


pub fn main() {
  wisp.configure_logger()

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load

  let assert Ok(secret_key_base) = env.get_string("SECRET_KEY_BASE")
  let ctx = Context(static_directory: static_directory(), items: [])

  let handler = router.handle_request(_, ctx)
  io.debug(router.handle_request)
  io.debug(handler)

  let assert Ok(host_to_bind_to) = env.get_string("HOST_TO_BIND_TO")
  let assert Ok(port_for_service) = env.get_int("PORT_FOR_SERVICE")

  let assert Ok(_)  = 
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.bind(host_to_bind_to)
    |> mist.port(port_for_service)
    |> mist.start_http

  process.sleep_forever()
}

fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("todo_app")
  let path = priv_directory <> "/static"
  io.debug("static_directory() :: path :: ")
  io.debug(path)
  path
}