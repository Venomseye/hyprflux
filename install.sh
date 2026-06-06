#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# HyprFlux — Installation Script
# ══════════════════════════════════════════════════════════════════════════════
# Installs the HyprFlux Hyprland desktop environment on a fresh Arch Linux
# system. Safe to re-run; existing configs are backed up automatically.
#
# Usage:
#   ./install.sh              Interactive installation (recommended)
#   ./install.sh --help       Show usage information
#
# Requirements:
#   - Arch Linux (or derivative)
#   - Internet connection
#   - Non-root user with sudo privileges
# ══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Script metadata ───────────────────────────────────────────────────────────
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LOG_FILE="${SCRIPT_DIR}/install.log"
readonly BACKUP_DIR="${HOME}/.config/hyprflux-backup/$(date +%Y%m%d_%H%M%S)"
readonly CONFIG_DEST="${HOME}/.config"
readonly THEMES_DEST="${HOME}/.config/hyprflux/themes"
readonly SCRIPTS_DEST="${HOME}/.local/share/hyprflux/scripts"
readonly WALLPAPER_DEST="${HOME}/Pictures/Wallpapers"

# ── Colour palette ────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN=''
    BOLD='' DIM='' RESET=''
fi

# ── Logging helpers ───────────────────────────────────────────────────────────
log()     { echo -e "${BOLD}${BLUE}  ==> ${RESET}${*}" | tee -a "${LOG_FILE}"; }
success() { echo -e "${BOLD}${GREEN}  ✔  ${RESET}${*}" | tee -a "${LOG_FILE}"; }
warn()    { echo -e "${BOLD}${YELLOW}  ⚠  ${RESET}${*}" | tee -a "${LOG_FILE}"; }
error()   { echo -e "${BOLD}${RED}  ✖  ${RESET}${*}" | tee -a "${LOG_FILE}"; }
info()    { echo -e "${DIM}      ${*}${RESET}" | tee -a "${LOG_FILE}"; }
header()  { echo -e "\n${BOLD}${MAGENTA}━━━  ${*}  ━━━${RESET}\n" | tee -a "${LOG_FILE}"; }
divider() { echo -e "${DIM}──────────────────────────────────────────────────────${RESET}"; }

# ── Error handler ─────────────────────────────────────────────────────────────
on_error() {
    local exit_code=$?
    local line_num=$1
    error "Installation failed at line ${line_num} (exit code: ${exit_code})."
    error "Check ${LOG_FILE} for details."
    exit "${exit_code}"
}
trap 'on_error ${LINENO}' ERR

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
    cat <<EOF
${BOLD}HyprFlux Installer${RESET}

Usage:
  ${SCRIPT_NAME} [options]

Options:
  -h, --help        Show this help message and exit
  -y, --yes         Skip all confirmation prompts (non-interactive)
  --skip-optional   Skip optional package selection
  --skip-backup     Do not back up existing configs (dangerous)

Example:
  ./${SCRIPT_NAME}
  ./${SCRIPT_NAME} --yes --skip-optional
EOF
}

# ── Argument parsing ──────────────────────────────────────────────────────────
OPT_YES=false
OPT_SKIP_OPTIONAL=false
OPT_SKIP_BACKUP=false

for arg in "$@"; do
    case "${arg}" in
        -h|--help)          usage; exit 0 ;;
        -y|--yes)           OPT_YES=true ;;
        --skip-optional)    OPT_SKIP_OPTIONAL=true ;;
        --skip-backup)      OPT_SKIP_BACKUP=true ;;
        *)
            error "Unknown option: ${arg}"
            usage
            exit 1
            ;;
    esac
done

# ── Initialise log file ───────────────────────────────────────────────────────
{
    echo "══════════════════════════════════════════════════════"
    echo "  HyprFlux Installation Log"
    echo "  Started: $(date)"
    echo "══════════════════════════════════════════════════════"
} > "${LOG_FILE}"

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — PRE-FLIGHT CHECKS
# ═══════════════════════════════════════════════════════════════════════════════

preflight_checks() {
    header "Pre-flight Checks"

    # Print banner
    if [[ -f "${SCRIPT_DIR}/assets/hyprflux-banner.txt" ]]; then
        echo -e "${CYAN}"
        cat "${SCRIPT_DIR}/assets/hyprflux-banner.txt"
        echo -e "${RESET}"
    fi

    # 1. Must not be root
    if [[ "${EUID}" -eq 0 ]]; then
        error "Do not run this script as root. Run as a regular user with sudo privileges."
        exit 1
    fi
    success "Running as non-root user: ${USER}"

    # 2. Arch Linux check
    if [[ ! -f /etc/arch-release ]]; then
        error "This installer only supports Arch Linux."
        error "Detected OS: $(grep -oP '(?<=^NAME=).*' /etc/os-release 2>/dev/null || echo 'unknown')"
        exit 1
    fi
    success "Arch Linux detected"

    # 3. Internet connectivity
    if ! ping -c 1 -W 3 archlinux.org &>/dev/null; then
        error "No internet connection. Please connect and retry."
        exit 1
    fi
    success "Internet connection available"

    # 4. sudo access
    if ! sudo -n true 2>/dev/null; then
        log "Sudo password required for package installation."
        if ! sudo true; then
            error "sudo authentication failed."
            exit 1
        fi
    fi
    success "sudo privileges confirmed"

    # 5. Required source directories exist
    for dir in configs scripts packages themes assets; do
        if [[ ! -d "${SCRIPT_DIR}/${dir}" ]]; then
            error "Required directory not found: ${SCRIPT_DIR}/${dir}"
            error "Please run this script from the HyprFlux repository root."
            exit 1
        fi
    done
    success "Repository structure verified"

    # 6. Package list files exist
    for pkg_file in packages/required.txt packages/optional.txt; do
        if [[ ! -f "${SCRIPT_DIR}/${pkg_file}" ]]; then
            error "Package list not found: ${SCRIPT_DIR}/${pkg_file}"
            exit 1
        fi
    done
    success "Package lists found"

    divider
    info "Install log: ${LOG_FILE}"
    info "Backup dir:  ${BACKUP_DIR}"
    divider
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — AUR HELPER
# ═══════════════════════════════════════════════════════════════════════════════

ensure_aur_helper() {
    header "AUR Helper"

    if command -v yay &>/dev/null; then
        success "yay is already installed ($(yay --version | head -1))"
        return 0
    fi

    if command -v paru &>/dev/null; then
        success "paru is already installed — using paru as AUR helper"
        # Create a yay shim so the rest of the script stays uniform
        mkdir -p "${HOME}/.local/bin"
        cat > "${HOME}/.local/bin/yay" <<'SHIM'
#!/usr/bin/env bash
exec paru "$@"
SHIM
        chmod +x "${HOME}/.local/bin/yay"
        export PATH="${HOME}/.local/bin:${PATH}"
        return 0
    fi

    log "yay not found — bootstrapping from AUR..."
    info "This requires git and base-devel."

    sudo pacman -S --needed --noconfirm git base-devel 2>>"${LOG_FILE}"

    local tmp_dir
    tmp_dir="$(mktemp -d)"
    # shellcheck disable=SC2064
    trap "rm -rf '${tmp_dir}'" EXIT

    git clone https://aur.archlinux.org/yay-bin.git "${tmp_dir}/yay-bin" 2>>"${LOG_FILE}"
    (cd "${tmp_dir}/yay-bin" && makepkg -si --noconfirm) 2>>"${LOG_FILE}"

    if ! command -v yay &>/dev/null; then
        error "yay installation failed. Check ${LOG_FILE} for details."
        exit 1
    fi

    success "yay installed successfully"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — PACKAGE INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════════

# Parse package list file: returns only package names, strips comments and AUR
# markers, skips blank lines.
parse_packages() {
    local file="$1"
    grep -v '^\s*#' "${file}" | grep -v '^\s*$' | awk '{print $1}'
}

# Separate AUR packages from the list (those on lines containing [AUR])
parse_aur_packages() {
    local file="$1"
    grep '\[AUR\]' "${file}" | grep -v '^\s*#[^[]' | awk '{print $1}'
}

# All non-AUR packages from a file
parse_official_packages() {
    local file="$1"
    grep -v '^\s*#' "${file}" | grep -v '\[AUR\]' | grep -v '^\s*$' | awk '{print $1}'
}

install_required_packages() {
    header "Installing Required Packages"

    local req_file="${SCRIPT_DIR}/packages/required.txt"
    local official_pkgs aur_pkgs

    mapfile -t official_pkgs < <(parse_official_packages "${req_file}")
    mapfile -t aur_pkgs     < <(parse_aur_packages "${req_file}")

    log "Updating package databases..."
    sudo pacman -Sy 2>>"${LOG_FILE}"

    log "Installing ${#official_pkgs[@]} official packages via pacman..."
    # Install in one shot; --needed skips already-installed packages
    sudo pacman -S --needed --noconfirm "${official_pkgs[@]}" 2>>"${LOG_FILE}" \
        && success "Official packages installed" \
        || { error "pacman failed — see ${LOG_FILE}"; exit 1; }

    if [[ ${#aur_pkgs[@]} -gt 0 ]]; then
        log "Installing ${#aur_pkgs[@]} AUR packages via yay..."
        yay -S --needed --noconfirm "${aur_pkgs[@]}" 2>>"${LOG_FILE}" \
            && success "AUR packages installed" \
            || { error "yay failed — see ${LOG_FILE}"; exit 1; }
    fi
}

install_optional_packages() {
    header "Optional Packages"

    if [[ "${OPT_SKIP_OPTIONAL}" == "true" ]]; then
        info "Skipping optional packages (--skip-optional)"
        return 0
    fi

    local opt_file="${SCRIPT_DIR}/packages/optional.txt"
    local all_optional selected_pkgs=()

    mapfile -t all_optional < <(parse_packages "${opt_file}")

    if [[ "${OPT_YES}" == "true" ]]; then
        info "Non-interactive mode: skipping optional packages"
        return 0
    fi

    echo -e "\n${BOLD}The following optional packages can enhance your experience:${RESET}"
    echo -e "${DIM}Press Enter to skip, 'y' to select, 'a' to select all, 'n' to skip all.${RESET}\n"

    local install_all=false
    local skip_all=false

    read -r -p "  Install ALL optional packages? [y/N] " choice
    case "${choice}" in
        y|Y) install_all=true ;;
        n|N) skip_all=true ;;
    esac

    if [[ "${skip_all}" == "true" ]]; then
        info "Skipping all optional packages."
        return 0
    fi

    if [[ "${install_all}" == "true" ]]; then
        selected_pkgs=("${all_optional[@]}")
    else
        # Per-package selection
        local pkg desc
        while IFS= read -r line; do
            [[ "${line}" =~ ^\s*# ]] && continue
            [[ -z "${line// }" ]]    && continue
            pkg="${line%% *}"
            desc="${line#*# }"
            [[ "${desc}" == "${line}" ]] && desc=""
            read -r -p "  Install ${BOLD}${pkg}${RESET} ${DIM}${desc}${RESET}? [y/N] " ans
            case "${ans}" in
                y|Y) selected_pkgs+=("${pkg}") ;;
            esac
        done < "${opt_file}"
    fi

    if [[ ${#selected_pkgs[@]} -eq 0 ]]; then
        info "No optional packages selected."
        return 0
    fi

    log "Installing ${#selected_pkgs[@]} selected optional package(s)..."
    yay -S --needed --noconfirm "${selected_pkgs[@]}" 2>>"${LOG_FILE}" \
        && success "Optional packages installed" \
        || warn "Some optional packages failed. Continuing..."
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — BACKUP EXISTING CONFIGS
# ═══════════════════════════════════════════════════════════════════════════════

backup_existing_configs() {
    header "Backing Up Existing Configurations"

    if [[ "${OPT_SKIP_BACKUP}" == "true" ]]; then
        warn "Skipping backup (--skip-backup). Existing configs will be overwritten."
        return 0
    fi

    local targets=(
        "${HOME}/.config/hypr"
        "${HOME}/.config/waybar"
        "${HOME}/.config/rofi"
        "${HOME}/.config/kitty"
        "${HOME}/.config/dunst"
        "${HOME}/.config/swaync"
        "${HOME}/.config/wlogout"
        "${HOME}/.config/fastfetch"
        "${HOME}/.config/fish"
        "${HOME}/.config/gtk-3.0"
        "${HOME}/.config/gtk-4.0"
        "${HOME}/.config/qt5ct"
        "${HOME}/.config/qt6ct"
        "${HOME}/.config/Kvantum"
        "${HOME}/.zshrc"
    )

    local backed_up=0
    for target in "${targets[@]}"; do
        if [[ -e "${target}" ]]; then
            mkdir -p "${BACKUP_DIR}"
            local dest="${BACKUP_DIR}/$(basename "${target}")"
            cp -r "${target}" "${dest}" 2>>"${LOG_FILE}"
            info "Backed up: ${target} → ${dest}"
            (( backed_up++ )) || true
        fi
    done

    if [[ ${backed_up} -gt 0 ]]; then
        success "${backed_up} config(s) backed up to: ${BACKUP_DIR}"
    else
        info "No existing configs found — nothing to back up."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — DIRECTORY CREATION
# ═══════════════════════════════════════════════════════════════════════════════

create_directories() {
    header "Creating Required Directories"

    local dirs=(
        "${HOME}/.config/hypr"
        "${HOME}/.config/waybar"
        "${HOME}/.config/rofi"
        "${HOME}/.config/kitty"
        "${HOME}/.config/dunst"
        "${HOME}/.config/swaync"
        "${HOME}/.config/wlogout"
        "${HOME}/.config/fastfetch"
        "${HOME}/.config/fish/functions"
        "${HOME}/.config/gtk-3.0"
        "${HOME}/.config/gtk-4.0"
        "${HOME}/.config/qt5ct"
        "${HOME}/.config/qt6ct"
        "${HOME}/.config/Kvantum"
        "${HOME}/.config/hyprflux/themes"
        "${HOME}/.local/share/hyprflux/scripts"
        "${HOME}/.local/share/hyprflux/cache"
        "${HOME}/.local/share/hyprflux/wallpaper-cache"
        "${HOME}/Pictures/Wallpapers"
        "${HOME}/.local/bin"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "${dir}"
        info "Created: ${dir}"
    done

    success "All directories created"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — COPY CONFIGURATIONS
# ═══════════════════════════════════════════════════════════════════════════════

copy_configs() {
    header "Copying Configuration Files"

    # Helper: copy a file or directory, report result
    install_config() {
        local src="$1"
        local dest="$2"
        if [[ ! -e "${src}" ]]; then
            warn "Source not found, skipping: ${src}"
            return 0
        fi
        if [[ -d "${src}" ]]; then
            cp -r "${src}/." "${dest}/"
        else
            cp "${src}" "${dest}"
        fi
        info "Installed: ${src} → ${dest}"
    }

    # Hyprland
    install_config "${SCRIPT_DIR}/configs/hypr"          "${HOME}/.config/hypr"

    # Hyprlock (screen locker config — read automatically by hyprlock)
    install_config "${SCRIPT_DIR}/configs/hypr/hyprlock.conf"  "${HOME}/.config/hypr/hyprlock.conf"

    # Hypridle (idle daemon config — read automatically by hypridle)
    install_config "${SCRIPT_DIR}/configs/hypr/hypridle.conf"  "${HOME}/.config/hypr/hypridle.conf"

    # Hyprpaper (initial wallpaper config — overwritten by wallpaper.sh)
    install_config "${SCRIPT_DIR}/configs/hypr/hyprpaper.conf" "${HOME}/.config/hypr/hyprpaper.conf"

    # Waybar
    install_config "${SCRIPT_DIR}/configs/waybar"        "${HOME}/.config/waybar"

    # Rofi
    install_config "${SCRIPT_DIR}/configs/rofi"          "${HOME}/.config/rofi"

    # Kitty
    install_config "${SCRIPT_DIR}/configs/kitty"         "${HOME}/.config/kitty"

    # Dunst
    install_config "${SCRIPT_DIR}/configs/dunst"         "${HOME}/.config/dunst"

    # SwayNC
    install_config "${SCRIPT_DIR}/configs/swaync"        "${HOME}/.config/swaync"

    # Wlogout
    install_config "${SCRIPT_DIR}/configs/wlogout"       "${HOME}/.config/wlogout"

    # Fastfetch
    install_config "${SCRIPT_DIR}/configs/fastfetch"     "${HOME}/.config/fastfetch"

    # Fish shell
    install_config "${SCRIPT_DIR}/configs/fish/config.fish"              "${HOME}/.config/fish/config.fish"
    install_config "${SCRIPT_DIR}/configs/fish/functions/fish_prompt.fish"  "${HOME}/.config/fish/functions/fish_prompt.fish"
    install_config "${SCRIPT_DIR}/configs/fish/functions/fish_greeting.fish" "${HOME}/.config/fish/functions/fish_greeting.fish"

    # Zsh
    install_config "${SCRIPT_DIR}/configs/zsh/.zshrc"   "${HOME}/.zshrc"

    # GTK
    install_config "${SCRIPT_DIR}/configs/gtk/settings.ini"      "${HOME}/.config/gtk-3.0/settings.ini"
    install_config "${SCRIPT_DIR}/configs/gtk/gtk4-settings.ini" "${HOME}/.config/gtk-4.0/settings.ini"

    # Qt
    install_config "${SCRIPT_DIR}/configs/qt/qt5ct.conf" "${HOME}/.config/qt5ct/qt5ct.conf"

    # Themes
    install_config "${SCRIPT_DIR}/themes"                "${HOME}/.config/hyprflux/themes"

    success "All configuration files installed"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — INSTALL SCRIPTS
# ═══════════════════════════════════════════════════════════════════════════════

install_scripts() {
    header "Installing HyprFlux Scripts"

    local scripts=(
        wallpaper.sh
        powermenu.sh
        theme-switch.sh
        screenshot.sh
        record-screen.sh
        volume.sh
        brightness.sh
        update-system.sh
        nowplaying.sh
        cava-waybar.sh
    )

    for script in "${scripts[@]}"; do
        local src="${SCRIPT_DIR}/scripts/${script}"
        local dest="${SCRIPTS_DEST}/${script}"
        if [[ ! -f "${src}" ]]; then
            warn "Script not found, skipping: ${src}"
            continue
        fi
        cp "${src}" "${dest}"
        chmod +x "${dest}"
        info "Installed: ${dest}"
    done

    # Symlink scripts to ~/.local/bin so they are on $PATH
    for script in "${scripts[@]}"; do
        local link="${HOME}/.local/bin/${script%.sh}"
        ln -sf "${SCRIPTS_DEST}/${script}" "${link}"
        info "Symlinked: ${link} → ${SCRIPTS_DEST}/${script}"
    done

    success "Scripts installed and symlinked to ~/.local/bin"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 8 — APPLY ACTIVE THEME
# ═══════════════════════════════════════════════════════════════════════════════

apply_active_theme() {
    header "Applying Active Theme"

    mkdir -p "${HOME}/.config/hyprflux/themes"

    # Copy all theme files
    if [[ -d "${SCRIPT_DIR}/themes" ]]; then
        cp -r "${SCRIPT_DIR}/themes/." "${HOME}/.config/hyprflux/themes/"
        success "Theme files installed"
    fi

    local active_theme="${HOME}/.config/hyprflux/themes/active.conf"
    local dark_theme="${HOME}/.config/hyprflux/themes/dark.conf"

    if [[ ! -f "$dark_theme" ]]; then
        warn "Dark theme not found: ${dark_theme}"
        return 0
    fi

    # Create symlink — use -sf so re-runs update it safely
    ln -sf "$dark_theme" "$active_theme"
    success "Active theme → dark (Tokyo Night Dark)"

    # Generate waybar colors.css from the active theme so Waybar has colours on first launch
    local colors_dest="${HOME}/.config/waybar/colors.css"
    if [[ -f "$dark_theme" ]]; then
        {
            printf "/* HyprFlux — auto-generated by install.sh — do not edit manually */\n"
            printf "* {\n"
            grep "^#@wb" "$dark_theme" | sed "s/^#@wb//"
            printf "}\n"
        } > "$colors_dest"
        success "Waybar colors.css generated for theme: dark"
    fi

    info "Switch themes: theme-switch select  or  Super+Shift+T"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 9 — XDG & USER DIRS
# ═══════════════════════════════════════════════════════════════════════════════

configure_xdg() {
    header "Configuring XDG & User Directories"

    # Create standard XDG user directories
    xdg-user-dirs-update 2>>"${LOG_FILE}" || warn "xdg-user-dirs-update failed (non-fatal)"

    # Set default portal
    mkdir -p "${HOME}/.config/xdg-desktop-portal"
    cat > "${HOME}/.config/xdg-desktop-portal/hyprland-portals.conf" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Secret=gnome-keyring
EOF

    success "XDG configuration applied"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 10 — ENABLE SYSTEM SERVICES
# ═══════════════════════════════════════════════════════════════════════════════

enable_services() {
    header "Enabling System Services"

    local user_services=(
        pipewire
        pipewire-pulse
        wireplumber
    )

    local system_services=(
        NetworkManager
        bluetooth
    )

    for svc in "${user_services[@]}"; do
        if systemctl --user enable --now "${svc}" &>>"${LOG_FILE}"; then
            success "User service enabled: ${svc}"
        else
            warn "Failed to enable user service: ${svc} (may already be running)"
        fi
    done

    for svc in "${system_services[@]}"; do
        if sudo systemctl enable --now "${svc}" &>>"${LOG_FILE}"; then
            success "System service enabled: ${svc}"
        else
            warn "Failed to enable system service: ${svc} (may already be running)"
        fi
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 11 — SHELL SETUP
# ═══════════════════════════════════════════════════════════════════════════════

configure_shell() {
    header "Shell Configuration"

    # Ensure ~/.local/bin is in PATH for current session
    export PATH="${HOME}/.local/bin:${PATH}"

    # Install Fisher (Fish plugin manager) if fish is present
    if command -v fish &>/dev/null; then
        log "Installing Fisher (Fish plugin manager)..."
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" &>>"${LOG_FILE}" \
            && success "Fisher installed" \
            || warn "Fisher installation failed (non-fatal — plugins can be installed manually)"

        log "Installing Fish plugins..."
        fish -c "fisher install PatrickF1/fzf.fish" &>>"${LOG_FILE}" \
            && success "Fish plugin: fzf.fish" \
            || warn "fzf.fish install failed (non-fatal)"
    fi

    # Check if Starship is available (prompt for both shells)
    if command -v starship &>/dev/null; then
        success "Starship prompt available"
    else
        warn "Starship not found — prompt will fall back to built-in"
    fi

    # Ask user if they want to change default shell
    if [[ "${OPT_YES}" == "true" ]]; then
        info "Non-interactive: keeping current shell (${SHELL})"
        return 0
    fi

    echo ""
    echo -e "${BOLD}Default shell selection:${RESET}"
    echo "  1) Keep current shell: ${SHELL}"
    echo "  2) Switch to Fish"
    echo "  3) Switch to Zsh"
    read -r -p "  Choice [1/2/3]: " shell_choice

    local new_shell=""
    case "${shell_choice}" in
        2)
            new_shell="$(command -v fish)"
            ;;
        3)
            new_shell="$(command -v zsh)"
            ;;
        *)
            info "Keeping current shell."
            return 0
            ;;
    esac

    if [[ -n "${new_shell}" ]]; then
        if grep -q "${new_shell}" /etc/shells; then
            chsh -s "${new_shell}" \
                && success "Default shell changed to: ${new_shell}" \
                || warn "chsh failed — change your shell manually with: chsh -s ${new_shell}"
        else
            warn "${new_shell} not in /etc/shells — adding it..."
            echo "${new_shell}" | sudo tee -a /etc/shells >>"${LOG_FILE}"
            chsh -s "${new_shell}" \
                && success "Default shell changed to: ${new_shell}" \
                || warn "chsh failed — change your shell manually"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 12 — WALLPAPER SETUP
# ═══════════════════════════════════════════════════════════════════════════════

setup_wallpapers() {
    header "Wallpaper Setup"

    # Copy bundled wallpapers if any exist in the repo
    if [[ -d "${SCRIPT_DIR}/configs/wallpapers" ]]; then
        local count
        count="$(find "${SCRIPT_DIR}/configs/wallpapers" -maxdepth 1 \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \) | wc -l)"
        if [[ ${count} -gt 0 ]]; then
            cp "${SCRIPT_DIR}"/configs/wallpapers/*.{jpg,jpeg,png} "${WALLPAPER_DEST}/" 2>/dev/null || true
            success "Copied ${count} bundled wallpaper(s) to ${WALLPAPER_DEST}"
        fi
    fi

    info "Add your wallpapers to: ${WALLPAPER_DEST}"
    info "Use the wallpaper picker with: Super+W"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 13 — FONT CACHE & ICON CACHE
# ═══════════════════════════════════════════════════════════════════════════════

refresh_caches() {
    header "Refreshing System Caches"

    log "Rebuilding font cache..."
    fc-cache -fv &>>"${LOG_FILE}" \
        && success "Font cache rebuilt" \
        || warn "fc-cache failed (non-fatal)"

    log "Updating icon cache..."
    gtk-update-icon-cache -f -t /usr/share/icons/Papirus &>>"${LOG_FILE}" 2>&1 \
        || warn "Icon cache update failed (non-fatal)"

    log "Updating desktop database..."
    update-desktop-database "${HOME}/.local/share/applications" &>>"${LOG_FILE}" 2>&1 || true

    success "System caches updated"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 14 — VERIFICATION
# ═══════════════════════════════════════════════════════════════════════════════

verify_installation() {
    header "Verifying Installation"

    local errors=0

    verify_file() {
        local path="$1"
        if [[ -e "${path}" ]]; then
            success "OK: ${path}"
        else
            error "MISSING: ${path}"
            (( errors++ )) || true
        fi
    }

    verify_cmd() {
        local cmd="$1"
        if command -v "${cmd}" &>/dev/null; then
            success "Command available: ${cmd}"
        else
            error "Command missing: ${cmd}"
            (( errors++ )) || true
        fi
    }

    # Critical commands
    for cmd in Hyprland waybar rofi kitty hyprpaper hyprlock hypridle nautilus; do
        verify_cmd "${cmd}"
    done

    # Critical config files
    verify_file "${HOME}/.config/hypr/hyprland.conf"
    verify_file "${HOME}/.config/hypr/keybinds.conf"
    verify_file "${HOME}/.config/hypr/hyprlock.conf"
    verify_file "${HOME}/.config/hypr/hypridle.conf"
    verify_file "${HOME}/.config/hypr/hyprpaper.conf"
    verify_file "${HOME}/.config/waybar/config.jsonc"
    verify_file "${HOME}/.config/waybar/style.css"
    verify_file "${HOME}/.config/rofi/config.rasi"
    verify_file "${HOME}/.config/kitty/kitty.conf"
    verify_file "${HOME}/.config/dunst/dunstrc"
    verify_file "${HOME}/.config/hyprflux/themes/active.conf"

    divider
    if [[ ${errors} -eq 0 ]]; then
        success "All checks passed!"
    else
        warn "${errors} check(s) failed. Review the output above."
        warn "The desktop may not function correctly for missing items."
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECTION 15 — COMPLETION SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

print_summary() {
    echo ""
    divider
    echo -e "${BOLD}${GREEN}  HyprFlux installation complete!${RESET}"
    divider
    echo ""
    echo -e "  ${BOLD}Getting started:${RESET}"
    echo -e "    • Log out and select ${BOLD}Hyprland${RESET} from your display manager"
    echo -e "    • Or run ${BOLD}Hyprland${RESET} from a TTY (no display manager needed)"
    echo ""
    echo -e "  ${BOLD}Key bindings:${RESET}"
    echo -e "    • ${BOLD}Super + Return${RESET}  → Kitty terminal"
    echo -e "    • ${BOLD}Super + Space${RESET}   → Rofi app launcher"
    echo -e "    • ${BOLD}Super + W${RESET}       → Wallpaper picker"
    echo -e "    • ${BOLD}Super + T${RESET}       → Theme switcher"
    echo -e "    • ${BOLD}Super + Q${RESET}       → Close active window"
    echo -e "    • ${BOLD}Super + Shift + E${RESET} → Power menu"
    echo ""
    echo -e "  ${BOLD}Configuration:${RESET}"
    echo -e "    • Hyprland:  ${CYAN}~/.config/hypr/${RESET}"
    echo -e "    • Waybar:    ${CYAN}~/.config/waybar/${RESET}"
    echo -e "    • Themes:    ${CYAN}~/.config/hyprflux/themes/${RESET}"
    echo -e "    • Wallpapers: ${CYAN}~/Pictures/Wallpapers/${RESET}"
    echo ""
    echo -e "  ${BOLD}Logs:${RESET}          ${DIM}${LOG_FILE}${RESET}"
    echo -e "  ${BOLD}Backup:${RESET}        ${DIM}${BACKUP_DIR}${RESET}"
    echo ""
    divider
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    preflight_checks
    ensure_aur_helper
    install_required_packages
    install_optional_packages
    backup_existing_configs
    create_directories
    copy_configs
    install_scripts
    apply_active_theme
    configure_xdg
    enable_services
    configure_shell
    setup_wallpapers
    refresh_caches
    verify_installation
    print_summary
}

main "$@"
