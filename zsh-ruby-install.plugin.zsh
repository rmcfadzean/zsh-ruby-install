ZSH_RUBYINSTALL_DIR=${0:a:h}

[[ -z "$RUBYINSTALL_DIR" ]] && export RUBYINSTALL_DIR="$HOME/.ruby-install"

_zsh_rubyinstall_latest_release_tag() {
  echo $(cd "$RUBYINSTALL_DIR" && git fetch --quiet origin && git describe --abbrev=0 --tags --match "v[0-9]*" origin)
}

_zsh_rubyinstall_install() {
  echo "Installing ruby-install..."
  git clone https://github.com/postmodern/ruby-install.git "$RUBYINSTALL_DIR"
  $(cd "$RUBYINSTALL_DIR" && git checkout --quiet "$(_zsh_rubyinstall_latest_release_tag)")
}

_zsh_rubyinstall_load() {
  export PATH=$RUBYINSTALL_DIR/bin/:$PATH
  ruby-install() {
    case $1 in
      'upgrade')
        _zsh_rubyinstall_upgrade
        ;;
      *)
        $RUBYINSTALL_DIR/bin/ruby-install "$@"
        ;;
    esac
  }
}

_zsh_rubyinstall_upgrade() {
  local installed_version=$(cd "$RUBYINSTALL_DIR" && git describe --tags)
  echo "Installed version is $installed_version"
  echo "Checking latest version of ruby-install..."
  local latest_version=$(_zsh_rubyinstall_latest_release_tag)
  if [[ "$installed_version" = "$latest_version" ]]; then
    echo "You're already up to date"
  else
    echo "Updating to $latest_version..."
    $(cd "$RUBYINSTALL_DIR" && git fetch --quiet && git checkout "$latest_version")
  fi
}


# Install ruby-install if it isn't already installed
[[ ! -f "$RUBYINSTALL_DIR/bin/ruby-install" ]] && _zsh_rubyinstall_install

_zsh_rubyinstall_load

return true