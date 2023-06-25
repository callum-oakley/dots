link:
    mkdir -p ~/.config/helix
    mkdir -p ~/.config/kitty
    mkdir -p ~/.hammerspoon
    ln -sf "$(pwd)/.zshrc" ~/.zshrc
    ln -sf "$(pwd)/helix/config.toml" ~/.config/helix/config.toml
    ln -sf "$(pwd)/helix/languages.toml" ~/.config/helix/languages.toml
    ln -sf "$(pwd)/kitty/current-theme.conf" ~/.config/kitty/current-theme.conf
    ln -sf "$(pwd)/kitty/kitty.conf" ~/.config/kitty/kitty.conf
    ln -sf "$(pwd)/hammerspoon/init.lua" ~/.hammerspoon/init.lua
