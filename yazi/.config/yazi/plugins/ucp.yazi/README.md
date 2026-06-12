# Universal Copy/Paste for Yazi

Should support **Wayland**, **Xorg** and **macOS**, though tested only on wayland. 

Integrates yazi copy/paste with system clipboard similar to GUI file managers.

## Features

- **Copy files to system clipboard** - Works with other file managers, browsers, and applications
- **Paste files from external sources** - Supports pasting files from other file managers and code editors (including VS Code)
- **Text paste to new file** - Automatically suggests creating new files when clipboard contains text
- **Smart collision handling** - Manages file conflicts during paste operations

- Native Yazi commands like cut and symlink work with the plugin
- Fallbaks to native yazi copy and paste commands so it should work anywhere yazi works


## Previews

### Copy
![Copy preview](https://github.com/user-attachments/assets/8894ca14-402b-4885-b2b6-d9666a4661b4)

---

### Paste
![Paste preview](https://github.com/user-attachments/assets/ae29d283-fec1-4e56-8857-c57d17c0d4f8)

---

### File collision handling & paste into new file
![Collision preview](https://github.com/user-attachments/assets/92746b8d-e93e-4c0c-8bbb-7845be5f57e1)


## Installation

**Requires:**

- **Wayland**: `wl-clipboard` package
- **Xorg**: `xclip` package  

```bash
ya pkg add simla33/ucp
```

## Configuration

> [!NOTE]
> You need yazi 3.x for this plugin to work.

```toml
[mgr]
prepend_keymap = [
    { on = "p", run = "plugin ucp paste", desc = "Paste" },
    { on = "y", run = "plugin ucp copy", desc = "Copy" }
]
```

You can enable notifications for successful/failed operations:

```toml
[mgr]
prepend_keymap = [
    { on = "p", run = "plugin ucp paste notify", desc = "Paste" },
    { on = "y", run = "plugin ucp copy notify", desc = "Copy" }
]
```

## Credits

- **Paste into a new file** taken from [boydaihungst/save-clipboard-to-file.yazi](https://github.com/boydaihungst/save-clipboard-to-file.yazi)
- **Copy** based on [grappas/wl-clipboard.yazi](https://github.com/grappas/wl-clipboard.yazi)