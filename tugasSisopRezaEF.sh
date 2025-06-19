#!/bin/bash

# Warna terminal
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Reset

# Cek dependencies
function check_dependencies() {
    MISSING=()

    for dep in jq curl lsb_release tune2fs; do
        if ! command -v $dep &>/dev/null; then
            MISSING+=("$dep")
        fi
    done

    # Khusus nmcli karena tidak selalu diperlukan
    if ! command -v nmcli &>/dev/null; then
        echo -e "${YELLOW}⚠️  'nmcli' tidak ditemukan. Beberapa fitur jaringan akan terbatas.${NC}"
        echo -e "${YELLOW}    Jika ingin fitur lengkap, jalankan:${NC} ${GREEN}sudo apt install network-manager${NC}"
    fi

    if [[ ${#MISSING[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Beberapa dependencies wajib belum terinstal:${NC}"
        for pkg in "${MISSING[@]}"; do
            echo -e "   - ${YELLOW}$pkg${NC}"
        done
        echo -e "\n${CYAN}💡 Silakan install dengan perintah:${NC}"
        echo -e "${GREEN}   sudo apt update && sudo apt install ${MISSING[*]}${NC}"
        echo
        read -p "Tekan Enter untuk lanjut (dengan risiko fitur tidak lengkap)..."
    fi
}

# Fungsi loading spinner
function loading_spinner() {
    echo -n "Memproses "
    spin='-\|/'
    for i in $(seq 1 20); do
        printf "\b${spin:i%4:1}"
        sleep 0.05
    done
    echo -e "\b Done!"
    echo
}

# Fungsi header
function show_header() {
    clear
    echo -e "${YELLOW}"
    cat << "EOF"
::::::'########:'##::::'##::'######::::::'###:::::'######::::::::::::::
::::::... ##..:: ##:::: ##:'##... ##::::'## ##:::'##... ##:::::::::::::
::::::::: ##:::: ##:::: ##: ##:::..::::'##:. ##:: ##:::..::::::::::::::
::::::::: ##:::: ##:::: ##: ##::'####:'##:::. ##:. ######::::::::::::::
::::::::: ##:::: ##:::: ##: ##::: ##:: #########::..... ##:::::::::::::
::::::::: ##:::: ##:::: ##: ##::: ##:: ##.... ##:'##::: ##:::::::::::::
::::::::: ##::::. #######::. ######::: ##:::: ##:. ######::::::::::::::
:::::::::..::::::.......::::......::::..:::::..:::......:::::::::::::::
:::::::'######::'####::'######::'########:'########:'##::::'##::::::::: 
::::::'##... ##:. ##::'##... ##:... ##..:: ##.....:: ###::'###:::::::::  
:::::: ##:::..::: ##:: ##:::..::::: ##:::: ##::::::: ####'####:::::::::  
::::::. ######::: ##::. ######::::: ##:::: ######::: ## ### ##:::::::::  
:::::::..... ##:: ##:::..... ##:::: ##:::: ##...:::: ##. #: ##:::::::::  
::::::'##::: ##:: ##::'##::: ##:::: ##:::: ##::::::: ##:.:: ##:::::::::  
::::::. ######::'####:. ######::::: ##:::: ########: ##:::: ##:::::::::  
:::::::......:::....:::......::::::..:::::........::..:::::..::::::::::  
:'#######::'########::'########:'########:::::'###:::::'######::'####:: 
'##.... ##: ##.... ##: ##.....:: ##.... ##:::'## ##:::'##... ##:. ##::: 
 ##:::: ##: ##:::: ##: ##::::::: ##:::: ##::'##:. ##:: ##:::..::: ##::: 
 ##:::: ##: ########:: ######::: ########::'##:::. ##:. ######::: ##::: 
 ##:::: ##: ##.....::: ##...:::: ##.. ##::: #########::..... ##:: ##::: 
 ##:::: ##: ##:::::::: ##::::::: ##::. ##:: ##.... ##:'##::: ##:: ##::: 
. #######:: ##:::::::: ########: ##:::. ##: ##:::: ##:. ######::'####:: 
:.......:::..:::::::::........::..:::::..::..:::::..:::......:::....::: 
EOF
    echo
    echo -e "${GREEN}Reza Eka Firmansyah${NC}"
    echo
}

# Menu 1: Waktu Saat Ini
function menu_waktu_saat_ini() {
    clear
    loading_spinner

    echo -e "${YELLOW}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║           ${CYAN}INFORMASI WAKTU SAAT INI (WIB)         ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════╝${NC}"

    echo -e "${CYAN}Tanggal dan Waktu:${NC}"
    echo -e "  📅 Hari    : $(TZ='Asia/Jakarta' date '+%A')"
    echo -e "  🗓️ Tanggal : $(TZ='Asia/Jakarta' date '+%d %B %Y')"
    echo -e "  🕒 Waktu   : $(TZ='Asia/Jakarta' date '+%H:%M:%S')"
    echo -e "  🌐 Zona    : ${GREEN}WIB (Asia/Jakarta, UTC+7)${NC}"

    echo -e "${YELLOW}────────────────────────────────────────────────────${NC}"
    read -p "Tekan Enter untuk kembali ke menu utama..."
}


# Menu 2: Isi Direktori
function menu_direktori() {
    clear
    loading_spinner
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║           ${CYAN}DAFTAR ISI DIREKTORI SAAT INI${NC}              ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}📁 Direktori: ${NC}${PWD}"
    echo
    ls -lah --color=always | while read line; do
        if echo "$line" | grep -q '^d'; then
            echo -e "📁  $line"
        elif echo "$line" | grep -q '^l'; then
            echo -e "🔗  $line"
        elif echo "$line" | grep -q '^-' ; then
            echo -e "📄  $line"
        else
            echo -e "    $line"
        fi
    done
    echo
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    read -p "Tekan Enter untuk kembali ke menu utama..."
}

# Menu 3: Informasi Jaringan
function menu_jaringan() {
    clear
    loading_spinner
    echo -e "${YELLOW}╔═════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                ${CYAN}🔧 STATUS DAN INFORMASI JARINGAN${NC}             ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚═════════════════════════════════════════════════════════════╝${NC}"

    echo -e "${CYAN}📡 IP & DNS:${NC}"
    echo -e "  🌐 IP Lokal   : ${GREEN}$(hostname -I | awk '{print $1}')${NC}"
    echo -e "  🚪 Gateway    : ${GREEN}$(ip r | grep default | awk '{print $3}')${NC}"
    echo -e "  🧮 Netmask    : ${GREEN}$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n1)${NC}"

    # DNS Fallback jika systemd-resolve tidak tersedia
    if command -v systemd-resolve &> /dev/null; then
        DNS_SERVER=$(systemd-resolve --status | grep 'DNS Servers' | awk '{print $3}' | head -n 1)
    else
        DNS_SERVER=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}' | head -n 1)
    fi
    echo -e "  🧭 DNS Server : ${GREEN}${DNS_SERVER}${NC}"
    echo

    echo -e "${CYAN}🌍 Koneksi Internet:${NC}"
    if ping -q -c1 8.8.8.8 &> /dev/null; then
        echo -e "  ✅ ${GREEN}Tersambung ke Internet${NC}"
    else
        echo -e "  ❌ ${RED}Tidak Tersambung ke Internet${NC}"
    fi
    echo

    echo -e "${CYAN}📶 Perangkat & Status Jaringan:${NC}"
    if command -v nmcli &> /dev/null; then
        interfaces=$(nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device | grep ':connected' || echo "")
        if [[ -z "$interfaces" ]]; then
            echo -e "  ⚠️  ${RED}Tidak ada perangkat jaringan yang aktif${NC}"
        else
            echo "$interfaces" | while IFS=: read -r dev type state conn; do
                echo -e "  🔌 Perangkat : $dev ($type)"
                echo -e "  📶 Status    : $state"
                echo -e "  🌐 Terhubung : $conn"
                echo
            done
        fi
    else
        echo -e "  ⚠️  ${RED}Perintah 'nmcli' tidak ditemukan.${NC}"
        echo -e "      ${YELLOW}Silakan install dengan: sudo apt install network-manager${NC}"
    fi
    echo

    echo -e "${CYAN}🗺️  Lokasi IP Publik (via IPinfo):${NC}"
    curl -s "https://ipinfo.io?token=3cb090c9250373" | jq -r '
    "  🌐  IP Publik : \(.ip)\n" +
    "  🏙️  Kota      : \(.city)\n" +
    "  🗺️  Wilayah   : \(.region)\n" +
    "  🇮🇩  Negara    : \(.country)\n" +
    "  📌  Lokasi    : \(.loc)\n" +
    "  🏢  ISP       : \(.org)\n" +
    "  🏷️  Kode Pos  : \(.postal)"
    '

    echo
    echo -e "${YELLOW}───────────────────────────────────────────────────────────────${NC}"
    read -p "Tekan Enter untuk kembali ke menu utama..."
}

# Menu 4: Detail Sistem Operasi
function menu_os() {
    clear
    loading_spinner
    echo -e "${YELLOW}╔═════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║             ${CYAN}🖥️  INFORMASI SISTEM OPERASI LINUX${NC}          ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚═════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}📘 Sistem Operasi:${NC}"
    lsb_release -a 2>/dev/null | while read line; do echo -e "  🔹 $line"; done
    echo
    echo -e "${CYAN}🧬 Kernel dan Arsitektur:${NC}"
    echo -e "  🧩 Kernel     : $(uname -r)"
    echo -e "  🏗️ Arsitektur : $(uname -m)"
    echo
    echo -e "${CYAN}🖥️  Penggunaan CPU:${NC}"
    cpu_load=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
    echo -e "  ⚙️ Beban CPU  : $cpu_load%"
    echo -e "  🔄 Core Aktif : $(nproc)"
    echo
    echo -e "${CYAN}📦 Penggunaan Memori:${NC}"
    free -h | awk 'NR==2{printf "  📊 Terpakai : %s / %s\n", $3, $2}'
    echo
    echo -e "${CYAN}💽 Penggunaan Disk:${NC}"
    df -h | grep -E '^Filesystem|^/dev/' | awk '{printf "  📁 %-15s %10s / %s (%s digunakan)\n", $1, $3, $2, $5}'
    echo
    echo -e "${YELLOW}────────────────────────────────────────────────────────────${NC}"
    read -p "Tekan Enter untuk kembali ke menu utama..."
}

# Menu 5: Waktu Install OS
function menu_install_time() {
    clear
    loading_spinner
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║           ${CYAN}🕓 INFORMASI WAKTU INSTALL SISTEM OPERASI${NC}      ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
    ROOT_PART=$(df / | tail -1 | awk '{print $1}')
    INSTALL_DATE=$(sudo tune2fs -l "$ROOT_PART" 2>/dev/null | grep 'Filesystem created' | cut -d ':' -f2-)
    if [[ -z "$INSTALL_DATE" ]]; then
        echo -e "❌ ${RED}Gagal membaca informasi filesystem.${NC}"
    else
        echo -e "${CYAN}📅 Estimasi Waktu Install:${NC}"
        echo -e "  🗓️ Filesystem Dibuat  : ${GREEN}${INSTALL_DATE}${NC}"
        echo -e "  💡 Catatan            : Waktu ini adalah saat partisi root (${ROOT_PART}) pertama kali dibuat."
    fi
    echo
    echo -e "${YELLOW}────────────────────────────────────────────────────────────${NC}"
    read -p "Tekan Enter untuk kembali ke menu utama..."
}

# Menu 6: Informasi Pengguna
function menu_user_info() {
    clear
    loading_spinner
    echo -e "${YELLOW}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║              ${CYAN}👤 INFORMASI PENGGUNA SAAT INI${NC}        ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}🧑 Detail Akun:${NC}"
    echo -e "  👤 Username     : $USER"
    echo -e "  🆔 User ID      : $(id -u)"
    echo -e "  👥 Group ID     : $(id -g)"
    echo -e "  🧾 Nama Lengkap : $(getent passwd "$USER" | cut -d ':' -f 5 | cut -d ',' -f1)"
    echo -e "  🖥️ Shell        : $SHELL"
    echo -e "  🏠 Home Dir     : $HOME"
    echo -e "${YELLOW}──────────────────────────────────────────────────────${NC}"
    read -p "Tekan Enter untuk kembali ke menu utama..."
}

# Menu 7: Keluar
function menu_keluar() {
    clear
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║            ${CYAN}👋 TERIMA KASIH TELAH MENGGUNAKAN${NC}         ${YELLOW}║${NC}"
    echo -e "${YELLOW}║              ${CYAN}PROGRAM TUGAS SISOP FIRMAN${NC}              ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════╝${NC}"
    echo 
    pesan=("Menutup program" "Membersihkan terminal" "Sampai jumpa 👋")
    for msg in "${pesan[@]}"; do
        echo -ne "${CYAN}$msg"
        for dot in {1..3}; do
            echo -n "."
            sleep 0.2
        done
        echo -e "${NC}"
        sleep 0.4
    done
    echo
    echo -e "${GREEN}✨ Program telah keluar dengan aman.${NC}"
    read -p "Tekan Enter untuk keluar..."
    echo
    exit 0
}

check_dependencies

# Main Menu Loop
while true; do
    show_header
    echo -e "${CYAN}Silakan pilih menu:${NC}"
    echo -e "${YELLOW} 1)${NC} Waktu Saat Ini"
    echo -e "${YELLOW} 2)${NC} Isi Direktori"
    echo -e "${YELLOW} 3)${NC} Informasi Jaringan"
    echo -e "${YELLOW} 4)${NC} Detail Sistem Operasi"
    echo -e "${YELLOW} 5)${NC} Waktu Install OS"
    echo -e "${YELLOW} 6)${NC} Informasi Pengguna"
    echo -e "${YELLOW} 7)${NC} Keluar"
    echo

    read -p "$(echo -e "${CYAN}Masukkan pilihan [1-7]: ${NC}")" pilihan
    case $pilihan in
        1) menu_waktu_saat_ini ;;
        2) menu_direktori ;;
        3) menu_jaringan ;;
        4) menu_os ;;
        5) menu_install_time ;;
        6) menu_user_info ;;
        7) menu_keluar ;;
        *) echo -e "${RED}Pilihan tidak valid. Silakan coba lagi.${NC}"; sleep 1 ;;
    esac
done
