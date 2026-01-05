# skim-rg.yazi

Search files by content via skim and ripgrep, open with neovim

![image](https://github.com/user-attachments/assets/675bf8d7-6ab1-4182-9402-14bdf45ece17)

[yazi+skim模糊查找](https://www.bilibili.com/video/BV1St34zMEV6/?share_source=copy_web&vd_source=d34abe3786a6b85ecc07875a85795885)

## Dependencies

* [skim](https://github.com/skim-rs/skim)
* [ripgrep](https://github.com/BurntSushi/ripgrep)
* [bat](https://github.com/sharkdp/bat)
* [neovim](https://github.com/neovim/neovim)

## Installation

```sh
ya pkg add cap153/skim-rg
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on  = "<C-f>"
run = "plugin skim-rg"
```

Available keybindings:

| Key binding           | Alternate key | Action                                                          |
|-----------------------|---------------|-----------------------------------------------------------------|
| `<esc>`               | -             | Quit the plugin                                                 |
| `<c-q>`               | -             | toggle interactive mode                                         |
| `<c-u>`/`<shift-tab>` | <kbd>↑</kbd>  | Move up                                                         |
| `<c-e>`/`<tab>`       | <kbd>↓</kbd>  | Move down                                                       |
| `<enter>`             | -             | Open files using neovim and jump to where the string is located |

## License

This plugin is MIT-licensed. For more information check the [LICENSE](LICENSE) file.
