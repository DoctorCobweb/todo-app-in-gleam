import pages/home
import models/item.{type Item}

pub fn home(items: List(Item)) {
    home.root(items)
}