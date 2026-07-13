#!/usr/bin/env bash

set -euo pipefail

PYTHON_FALLBACK_VERSION="3.11.9"

if [[ "${EUID}" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

log() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_apt() {
  command_exists apt-get || fail "This script currently supports Debian/Ubuntu systems with apt-get."
}

get_python_version() {
  local python_cmd="$1"
  "$python_cmd" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")'
}

python_is_supported() {
  local version="$1"
  local major="${version%%.*}"
  local minor="${version##*.}"

  [[ "$major" -gt 3 ]] || [[ "$major" -eq 3 && "$minor" -ge 9 ]]
}

ensure_pip() {
  if "$PYTHON_CMD" -m pip --version >/dev/null 2>&1; then
    return
  fi

  log "Installing pip for ${PYTHON_CMD}"

  $SUDO apt-get update
  $SUDO apt-get install -y python3-pip python3-venv

  if "$PYTHON_CMD" -m pip --version >/dev/null 2>&1; then
    return
  fi

  if "$PYTHON_CMD" -m ensurepip --upgrade >/dev/null 2>&1; then
    return
  fi

  fail "pip could not be installed for ${PYTHON_CMD}."
}

install_docker() {
  local docker_installed=false
  local compose_installed=false
  local docker_repo_os

  if command_exists docker; then
    docker_installed=true
  fi

  if { command_exists docker && docker compose version >/dev/null 2>&1; } || command_exists docker-compose; then
    compose_installed=true
  fi

  if [[ "$docker_installed" == true && "$compose_installed" == true ]]; then
    log "Docker and Docker Compose are already installed"
    return
  fi

  if [[ "$docker_installed" == false && "$compose_installed" == true ]]; then
    log "Docker Compose is already installed; installing Docker"
  elif [[ "$docker_installed" == true && "$compose_installed" == false ]]; then
    log "Docker is already installed; installing Docker Compose"
  else
    log "Installing Docker and Docker Compose"
  fi

  $SUDO apt-get update
  $SUDO apt-get install -y ca-certificates curl gnupg
  $SUDO install -m 0755 -d /etc/apt/keyrings

  . /etc/os-release

  case "${ID}" in
    ubuntu|debian)
      docker_repo_os="${ID}"
      ;;
    *)
      if [[ "${ID_LIKE:-}" == *ubuntu* ]]; then
        docker_repo_os="ubuntu"
      elif [[ "${ID_LIKE:-}" == *debian* ]]; then
        docker_repo_os="debian"
      else
        fail "Docker installation is supported only on Debian/Ubuntu-based systems."
      fi
      ;;
  esac

  if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    curl -fsSL "https://download.docker.com/linux/${docker_repo_os}/gpg" | $SUDO tee /etc/apt/keyrings/docker.asc >/dev/null
    $SUDO chmod a+r /etc/apt/keyrings/docker.asc
  fi

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${docker_repo_os} ${VERSION_CODENAME} stable" \
    | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null

  $SUDO apt-get update
  $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

build_python_from_source() {
  local version="$1"
  local short_version="${version%.*}"
  local archive="Python-${version}.tgz"
  local source_dir="/tmp/Python-${version}"

  log "Installing Python ${version} from source"

  $SUDO apt-get update
  $SUDO apt-get install -y \
    build-essential \
    curl \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncurses5-dev \
    libnss3-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    tk-dev \
    uuid-dev \
    wget \
    xz-utils \
    zlib1g-dev

  rm -rf "$source_dir" "/tmp/${archive}"
  curl -fsSL "https://www.python.org/ftp/python/${version}/${archive}" -o "/tmp/${archive}"
  tar -xzf "/tmp/${archive}" -C /tmp

  (
    cd "$source_dir"
    ./configure --enable-optimizations
    make -j"$(nproc)"
    $SUDO make altinstall
  )

  rm -rf "$source_dir" "/tmp/${archive}"

  "/usr/local/bin/python${short_version}" -m ensurepip --upgrade
}

ensure_python() {
  if command -v python3 >/dev/null 2>&1; then
    local current_version
    current_version="$(get_python_version python3)"
    if python_is_supported "$current_version"; then
      log "Python ${current_version} is already installed"
      PYTHON_CMD="python3"
      ensure_pip
      return
    fi
  fi

  log "Installing Python"

  $SUDO apt-get update
  $SUDO apt-get install -y python3 python3-pip python3-venv

  if command -v python3 >/dev/null 2>&1; then
    local installed_version
    installed_version="$(get_python_version python3)"
    if python_is_supported "$installed_version"; then
      PYTHON_CMD="python3"
      ensure_pip
      return
    fi
  fi

  build_python_from_source "$PYTHON_FALLBACK_VERSION"
  PYTHON_CMD="/usr/local/bin/python${PYTHON_FALLBACK_VERSION%.*}"
  ensure_pip
}

install_django() {
  ensure_pip

  if "$PYTHON_CMD" -m django --version >/dev/null 2>&1; then
    log "Django is already installed"
    return
  fi

  log "Installing Django"

  if ! "$PYTHON_CMD" -m pip install --upgrade pip; then
    "$PYTHON_CMD" -m pip install --upgrade pip --break-system-packages
  fi

  if ! "$PYTHON_CMD" -m pip install Django; then
    "$PYTHON_CMD" -m pip install Django --break-system-packages
  fi
}

print_summary() {
  log "Installation complete"
  docker --version
  docker compose version
  "$PYTHON_CMD" --version
  "$PYTHON_CMD" -m django --version
}

main() {
  require_apt
  install_docker
  ensure_python
  install_django
  print_summary
}

main "$@"