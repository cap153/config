<img width="3840" height="2160" alt="image" src="https://github.com/user-attachments/assets/50d9e5f1-1a4d-4a5a-9593-cf7ac4df2143" />

## Dependencies

* [`television`](https://github.com/alexpasmantier/television)
* [`fd`](https://github.com/sharkdp/fd)
* [`ripgrep`](https://github.com/BurntSushi/ripgrep)
* [`bat`](https://github.com/sharkdp/bat) (Optional)
* [`neovim`](https://github.com/neovim/neovim) (Optional)

## Installation

```sh
ya pkg add cap153/tv
```

## Usage

> [!WARNING]
> I only tested the built-in `files`, `dirs` and `text` Channel.

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on  = "<C-t>"
run = "plugin tv"
desc = "Jump to a file via television"

[[mgr.prepend_keymap]]
on  = "<C-d>"
run = "plugin tv dirs"
desc = "Jump to a directory via television"

[[mgr.prepend_keymap]]
on  = "<C-f>"
run = "plugin tv text"
desc = "Open files using neovim and jump to where the string is located"
```

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.
