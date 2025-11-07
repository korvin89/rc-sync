# rc-sync

This repository provides a simple way to synchronize a shell prompt configuration across different machines for both `bash` and `zsh`. The prompt displays the current user, path, and git branch.

## How It Works

The `update_rc.sh` script fetches a shell script snippet (`rc_snippet.sh`) from this repository and adds it to your `.bashrc` or `.zshrc` file. It wraps the snippet with markers to easily update or remove it later.

## Installation

To install the prompt, run the following command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/korvin89/bashrc-sync/main/scripts/update_rc.sh | bash
```

This will download and execute the `update_rc.sh` script. The script will automatically detect whether you are using `bash` or `zsh` and update the corresponding configuration file (`~/.bashrc` or `~/.zshrc`).

After installation, reload your shell for the changes to take effect:

For `bash`:
```bash
source ~/.bashrc
```

For `zsh`:
```bash
source ~/.zshrc
```

## Updating

To update the prompt to the latest version, simply run the installation command again. The script will replace the old snippet with the new one.

```bash
curl -fsSL https://raw.githubusercontent.com/korvin89/bashrc-sync/main/scripts/update_rc.sh | bash
```

## Uninstallation

To remove the prompt, you can run the `uninstall.sh` script:

```bash
curl -fsSL https://raw.githubusercontent.com/korvin89/bashrc-sync/main/scripts/uninstall.sh | bash
```

This will remove the snippet from your shell configuration file. Remember to reload your shell afterward.

## Manual Installation

If you prefer not to execute scripts directly from the web, you can clone this repository and run the scripts manually.

1.  Clone the repository:
    ```bash
    git clone https://github.com/korvin89/bashrc-sync.git
    cd bashrc-sync
    ```

2.  Run the update script:
    ```bash
    ./scripts/update_rc.sh
    ```

3.  Reload your shell as described above.
