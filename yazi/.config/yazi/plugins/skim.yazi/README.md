# skim.yazi

[skim](https://github.com/skim-rs/skim) plugin for [Yazi](https://github.com/sxyazi/yazi).

![image](https://github.com/user-attachments/assets/88cad36a-0892-49ca-a2cd-7d5e1a085ad1)

[yazi+skim模糊查找](https://www.bilibili.com/video/BV1St34zMEV6/?share_source=copy_web&vd_source=d34abe3786a6b85ecc07875a85795885)

## Dependencies

* [`skim`](https://github.com/skim-rs/skim)
* [`fd`](https://github.com/sharkdp/fd)
* [`bat`](https://github.com/sharkdp/bat)

## Installation

```sh
ya pkg add cap153/skim
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on  = "<C-t>"
run = "plugin skim"
```

Available keybindings:

| Key binding   | Alternate key | Action                      |
|---------------|---------------|-----------------------------|
| `<esc>`       | -             | Quit the plugin             |
| `<c-u>`       | <kbd>↑</kbd>  | Move up                     |
| `<c-e>`       | <kbd>↓</kbd>  | Move down                   |
| `<tab>`       | -             | Multi select and move down  |
| `<shift-tab>` | -             | Multi select and move up    |
| `<enter>`     | -             | Return yazi and go to files |

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.
