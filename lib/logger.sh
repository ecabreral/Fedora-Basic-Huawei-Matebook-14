#!/usr/bin/env bash
# ==============================================================================
# logger.sh — Sistema de logging limpio para el instalador
# ==============================================================================

# ── Evitar recarga en el mismo proceso ────────────────────────────────────────
[ -n "${_LOGGER_LOADED:-}" ] && return 0
_LOGGER_LOADED=1

# ── Directorio de logs (siempre relativo a lib/, no al script que lo sourcea) ─
LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/logs"
mkdir -p "$LOG_DIR"

# ── Heredar el log del runner si existe (evita duplicados y archivos huérfanos)
if [ -n "${_INSTALL_LOG_FILE:-}" ] && [ -f "$_INSTALL_LOG_FILE" ]; then
    LOG_FILE="$_INSTALL_LOG_FILE"
    _LOG_SILENCED=1  # el runner ya captura la salida vía tee
else
    INSTALL_START=$(date +%s)
    INSTALL_ID=$(date +%Y%m%d-%H%M%S)
    LOG_FILE="$LOG_DIR/install-${INSTALL_ID}.log"
fi
CURRENT_LOG="$LOG_DIR/install.log"

# ── Colores para terminal ─────────────────────────────────────────────────────
_LOG_BOLD="\e[1m"
_LOG_DIM="\e[2m"
_LOG_GREEN="\e[32m"
_LOG_CYAN="\e[36m"
_LOG_YELLOW="\e[33m"
_LOG_RED="\e[31m"
_LOG_BLUE="\e[34m"
_LOG_RESET="\e[0m"

# El azul/cian estándar pierde contraste sobre fondos claros.
if [ "${INSTALL_LIGHT_MODE:-false}" = true ]; then
    _LOG_CYAN="\e[34m"
    _LOG_BLUE="\e[34m"
    _LOG_GREEN="\e[32m"
    _LOG_YELLOW="\e[33m"
    _LOG_RED="\e[31m"
fi

# ── Función: escribir al log (sin ANSI) ───────────────────────────────────────
_log_write() {
    if [ -n "${_LOG_SILENCED:-}" ]; then
        return 0
    fi
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
}

# ── Función: imprimir en terminal + escribir al log ───────────────────────────
log_info() {
    local msg="$1"
    echo -e "${_LOG_CYAN}${_LOG_BOLD}  ->${_LOG_RESET} $msg"
    _log_write "INFO" "$msg"
}

log_success() {
    local msg="$1"
    echo -e "${_LOG_GREEN}${_LOG_BOLD} [OK]${_LOG_RESET} $msg"
    _log_write "SUCCESS" "$msg"
}

log_warn() {
    local msg="$1"
    echo -e "${_LOG_YELLOW}${_LOG_BOLD} [WARN]${_LOG_RESET} $msg"
    _log_write "WARN" "$msg"
}

log_error() {
    local msg="$1"
    echo -e "${_LOG_RED}${_LOG_BOLD} [ERROR]${_LOG_RESET} $msg" >&2
    _log_write "ERROR" "$msg"
}

log_section() {
    local title="$1"
    echo ""
    echo -e "${_LOG_BLUE}${_LOG_BOLD}== $title${_LOG_RESET}"
    echo ""
    _log_write "SECTION" "== $title"
}

# ── Función: encabezado de instalación ────────────────────────────────────────
log_header() {
    local os_name="$1"
    local components="$2"
    
    # Crear symlink al log actual
    ln -sf "$(basename "$LOG_FILE")" "$CURRENT_LOG"
    
    # Escribir encabezado en el log
    {
        echo "================================================================"
        echo "  System Setup"
        echo "  Equipo: Huawei MateBook 14"
        echo "  Fecha: $(date +"%Y-%m-%d %H:%M:%S")"
        echo "  OS: $os_name"
        echo "  Componentes: $components"
        echo "================================================================"
        echo ""
    } >> "$LOG_FILE"
    
    # Mostrar en terminal
    echo ""
    echo -e "${_LOG_BLUE}${_LOG_BOLD}System Setup${_LOG_RESET}"
    echo -e "${_LOG_DIM}Equipo: Huawei MateBook 14 | $os_name${_LOG_RESET}"
    echo -e "${_LOG_DIM}$(date +"%Y-%m-%d %H:%M:%S")${_LOG_RESET}"
    echo ""
}

# ── Función: paso de instalación ──────────────────────────────────────────────
log_step() {
    local current="$1"
    local total="$2"
    local desc="$3"
    
    echo ""
    echo -e "${_LOG_BLUE}${_LOG_BOLD}Paso ${current}/${total}: $desc${_LOG_RESET}"
    echo ""
    _log_write "STEP" "[$current/$total] $desc"
}

# ── Función: progreso con barra ───────────────────────────────────────────────
log_progress() {
    local current="$1"
    local total="$2"
    local desc="$3"
    
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r  ${_LOG_BLUE}${_LOG_BOLD}[%-50s] %d%%${_LOG_RESET}" \
        "$(printf '#%.0s' $(seq 1 $filled 2>/dev/null))" "$percent" 2>/dev/null || \
    printf "\r  [$(printf '#%.0s' $(seq 1 $filled 2>/dev/null))$(printf '.%.0s' $(seq 1 $empty 2>/dev/null))] %d%%" "$percent" 2>/dev/null
    
    _log_write "PROGRESS" "$desc ($percent%)"
}

# ── Función: resumen final ────────────────────────────────────────────────────
log_summary() {
    local -a results=("$@")
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - INSTALL_START))
    local mins=$((duration / 60))
    local secs=$((duration % 60))
    
    local success_count=0
    local error_count=0
    
    # Contar resultados
    for r in "${results[@]}"; do
        if [[ "$r" == *"[OK]"* ]]; then
            success_count=$((success_count + 1))
        elif [[ "$r" == *"[SKIP]"* ]]; then
            :
        else
            error_count=$((error_count + 1))
        fi
    done
    
    # Escribir resumen al log
    {
        echo ""
        echo "================================================================"
        echo "  RESUMEN FINAL"
        echo "================================================================"
        for r in "${results[@]}"; do
            echo "  $r"
        done
        echo ""
        echo "  Éxitos: $success_count | Errores: $error_count"
        echo "  Duración total: ${mins}m ${secs}s"
        echo "  Log completo: $LOG_FILE"
        echo "================================================================"
    } >> "$LOG_FILE"
    
    # Mostrar en terminal
    echo ""
    echo -e "${_LOG_GREEN}${_LOG_BOLD}Resumen de instalación${_LOG_RESET}"
    echo ""
    
    for r in "${results[@]}"; do
        if [[ "$r" == *"[OK]"* ]]; then
            echo -e "  ${_LOG_GREEN}[OK]${_LOG_RESET} ${r%% [OK]*}"
        elif [[ "$r" == *"[SKIP]"* ]]; then
            echo -e "  ${_LOG_YELLOW}[SKIP]${_LOG_RESET} ${r%% [SKIP]*} (omitido)"
        else
            echo -e "  ${_LOG_RED}[FAIL]${_LOG_RESET} ${r%% [FAIL]*} (falló)"
        fi
    done
    
    echo ""
    echo -e "  ${_LOG_BOLD}Duración total:${_LOG_RESET} ${mins}m ${secs}s"
    echo -e "  ${_LOG_BOLD}Log completo:${_LOG_RESET} $LOG_FILE"
    echo ""
    
    # Rotar logs antiguos (mantener últimos 5)
    _rotate_logs
}

# ── Función: rotar logs antiguos ──────────────────────────────────────────────
_rotate_logs() {
    local keep=5
    local max_bytes=1048576  # 1MB
    local count
    local -a logs=()
    while IFS= read -r log; do logs+=("$log"); done < <(
        for log in "$LOG_DIR"/install-*.log; do
            [ -e "$log" ] && stat -c '%Y %n' "$log"
        done | sort -rn | cut -d' ' -f2-
    )
    count=${#logs[@]}

    if [ "$count" -gt "$keep" ]; then
        local to_remove=$((count - keep))
        local i
        for ((i = keep; i < count; i++)); do
            rm -f "${logs[i]}"
        done
    fi

    # Eliminar logs que excedan 1MB (excepto el actual)
    local f
    for f in "$LOG_DIR"/install-*.log; do
        [ -e "$f" ] || continue
        if [ "$f" = "$LOG_FILE" ]; then
            continue
        fi
        if [ "$(stat -c%s "$f" 2>/dev/null || echo 0)" -gt "$max_bytes" ]; then
            rm -f "$f"
        fi
    done
}

# ── Función: obtener ruta del log actual ──────────────────────────────────────
get_log_file() {
    echo "$LOG_FILE"
}

# ── Función: tiempo transcurrido ──────────────────────────────────────────────
get_elapsed() {
    local now
    now=$(date +%s)
    local elapsed=$((now - INSTALL_START))
    local mins=$((elapsed / 60))
    local secs=$((elapsed % 60))
    printf "%dm %ds" "$mins" "$secs"
}
