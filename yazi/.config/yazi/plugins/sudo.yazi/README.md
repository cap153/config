# sudo.yazi

Call `sudo` in yazi.

## Installation

```bash
$ ya pack -a TD-Sky/sudo
```

## Requirements

- [nushell](https://github.com/nushell/nushell)

## Functions

- [x] copy files
- [x] move files
- [x] rename file
- [x] trash files
- [x] remove files
- [x] create absolute-path symbolic links
- [x] create relative-path symbolic links
- [x] create hard links
- [x] touch new file
- [x] make new directory

> You can use [conceal](https://github.com/TD-Sky/conceal) to browse and restore trashed files

## Usage

Here are my own keymap for reference only:

```toml
# sudo cp/mv
[[manager.keymap]]
on = ["R", "p", "p"]
run = "plugin sudo -- paste"
desc = "sudo paste"

# sudo cp/mv --force
[[manager.keymap]]
on = ["R", "P"]
run = "plugin sudo -- paste --force"
desc = "sudo paste"

# sudo mv
[[manager.keymap]]
on = ["R", "r"]
run = "plugin sudo -- rename"
desc = "sudo rename"

# sudo ln -s (absolute-path)
[[manager.keymap]]
on = ["R", "p", "l"]
run = "plugin sudo -- link"
desc = "sudo link"

# sudo ln -s (relative-path)
[[manager.keymap]]
on = ["R", "p", "r"]
run = "plugin sudo -- link --relative"
desc = "sudo link relative path"

# sudo ln
[[manager.keymap]]
on = ["R", "p", "L"]
run = "plugin sudo -- hardlink"
desc = "sudo hardlink"

# sudo touch/mkdir
[[manager.keymap]]
on = ["R", "a"]
run = "plugin sudo -- create"
desc = "sudo create"

# sudo trash
[[manager.keymap]]
on = ["R", "d"]
run = "plugin sudo -- remove"
desc = "sudo trash"

# sudo delete
[[manager.keymap]]
on = ["R", "D"]
run = "plugin sudo -- remove --permanently"
desc = "sudo delete"
```
