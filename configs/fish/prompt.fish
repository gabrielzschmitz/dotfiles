# Shared prompt: vi mode indicator, working directory and prompt glyph.
# Sourced by the Home Manager fish config.

function __dotfiles_prompt_env
    if set -q IN_NIX_SHELL
        set_color --bold white
        echo -n '[DEVELOP] '
    end
end

function __dotfiles_prompt_mode
    switch $fish_bind_mode
        case default
            set_color --bold cyan
            echo -n '[N]'

        case insert
            set_color --bold magenta
            echo -n '[I]'

        case replace replace_one
            set_color --bold red
            echo -n '[R]'

        case visual
            set_color --bold yellow
            echo -n '[V]'

        case '*'
            set_color --bold cyan
            echo -n '[?]'
    end
end

function __dotfiles_prompt_body
    set_color normal
    echo -n ' '

    set_color --bold cyan
    echo -n $PWD
    set_color normal

    echo
    echo -n '❯ '
end

function fish_mode_prompt
end

function fish_prompt
    __dotfiles_prompt_env
    __dotfiles_prompt_mode
    __dotfiles_prompt_body
end
