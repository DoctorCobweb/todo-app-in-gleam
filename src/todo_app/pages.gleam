import todo_app/pages/home
import todo_app/models/item.{type Item}

pub fn home(items: List(Item)) {
    home.root(items)
}