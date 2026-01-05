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
- [x] change files' mode bits

> You can use [conceal](https://github.com/TD-Sky/conceal) to browse and restore trashed files

## Usage

Here are my own keymap for reference only:

```toml
# sudo cp/mv
[[mgr.prepend_keymap]]
on = ["R", "p", "p"]
run = "plugin sudo -- paste"
desc = "sudo paste"

# sudo cp/mv --force
[[mgr.prepend_keymap]]
on = ["R", "P"]
run = "plugin sudo -- paste --force"
desc = "sudo paste"

# sudo mv
[[mgr.prepend_keymap]]
on = ["R", "r"]
run = "plugin sudo -- rename"
desc = "sudo rename"

# sudo ln -s (absolute-path)
[[mgr.prepend_keymap]]
on = ["R", "p", "l"]
run = "plugin sudo -- link"
desc = "sudo link"

# sudo ln -s (relative-path)
[[mgr.prepend_keymap]]
on = ["R", "p", "r"]
run = "plugin sudo -- link --relative"
desc = "sudo link relative path"

# sudo ln
[[mgr.prepend_keymap]]
on = ["R", "p", "L"]
run = "plugin sudo -- hardlink"
desc = "sudo hardlink"

# sudo touch/mkdir
[[mgr.prepend_keymap]]
on = ["R", "a"]
run = "plugin sudo -- create"
desc = "sudo create"

# sudo trash
[[mgr.prepend_keymap]]
on = ["R", "d"]
run = "plugin sudo -- remove"
desc = "sudo trash"

# sudo delete
[[mgr.prepend_keymap]]
on = ["R", "D"]
run = "plugin sudo -- remove --permanently"
desc = "sudo delete"

# sudo chmod
[[mgr.prepend_keymap]]
on = ["R", "m"]
run = "plugin sudo -- chmod"
desc = "sudo chmod"
```
