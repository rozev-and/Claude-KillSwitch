<div align="center">

# 🛡️ Claude Code VPN Kill Switch (Windows 11)

**English** | [Русский](#-русская-версия)

A lightweight background PowerShell watchdog script designed to protect your Anthropic account while using **Claude Code** in the terminal.

</div>

---

## 🇬🇧 English Version

The script prevents accidental real IP leaks caused by connection drops, VPN client crashes, or unexpected region switches.

### ✨ Features

* **Dual-Layer Verification:** Checks every second if your VPN client process (default: `Happ`) is running, and verifies your actual external IP country every 5 seconds against your allowed region (e.g., `NL`).
* **Instant Process Termination:** Immediately force-closes `claude` and `claude-code` processes if the connection drops or the country mismatches, preventing them from relaunching until the VPN is restored.
* **Desktop Toast Notifications:** Sends a native Windows 11 toast notification to the bottom-right corner of your screen whenever the kill switch is triggered.
* **Interactive Setup & Uninstaller:** Allows you to configure your allowed country code, specify your VPN process name, register a hidden startup task in Windows Task Scheduler, or completely remove the tool in a few clicks.

### 🚀 Installation & Usage

1. Download `Claude_VPN_Guard_Setup.ps1` from this repository.
2. Right-click the file and select **Run with PowerShell** (the script will automatically request Administrator privileges).
3. Choose an option from the interactive menu:
   * **`1`** — Install or update protection (enter a two-letter country code like `NL`, `DE`, `US`, and your VPN process name without `.exe`).
   * **`2`** — Stop the background watchdog, remove it from Windows startup, and delete the script from your drive.
   * **`3`** — Exit.

### ⚙️ How It Works

* The installer saves the background script to `C:\Scripts\claude_guard.ps1` and registers a hidden task named `Claude_VPN_Guard` in **Windows Task Scheduler** (triggers at logon, runs on both AC and battery power with no execution time limit).
* For proper protection, make sure your VPN client is running in **TUN (VPN) mode** so that all terminal traffic is routed through the tunnel.

### ⚠️ Disclaimer

This tool is intended solely to secure your network connection and prevent accidental traffic leaks. The author is not responsible for any account restrictions imposed by third-party services.

---

## 🇷🇺 Русская версия

Легкий фоновый скрипт-предохранитель на PowerShell для защиты аккаунта Anthropic при работе с **Claude Code** в терминале. Скрипт предотвращает случайную утечку вашего реального IP-адреса при обрыве соединения, закрытии VPN-клиента или смене региона.

### ✨ Возможности

* **Двойной контроль:** каждую секунду проверяет, запущен ли процесс вашего VPN-клиента (по умолчанию `Happ`), и каждые 5 секунд сверяет реальную страну внешнего IP-адреса с разрешенной (например, `NL`).
* **Мгновенная блокировка:** при любых сбоях или несовпадении страны принудительно завершает процессы `claude` и `claude-code`, не давая им запуститься снова до восстановления соединения.
* **Уведомления на рабочий стол:** отправляет стандартное всплывающее уведомление (Toast) в правый нижний угол экрана Windows 11 при срабатывании защиты.
* **Интерактивный установщик:** позволяет в пару кликов выбрать нужную страну, имя процесса VPN, добавить защиту в автозапуск Windows (через Планировщик заданий без висящего окна консоли) или полностью удалить её.

### 🚀 Установка и использование

1. Скачайте файл `Claude_VPN_Guard_Setup.ps1` из этого репозитория.
2. Нажмите на файл правой кнопкой мыши и выберите **«Выполнить с помощью PowerShell»** (скрипт автоматически запросит права администратора).
3. В открывшемся меню выберите действие:
   * **`1`** — Установить или обновить защиту (потребуется ввести двухбуквенный код страны, например `NL`, `DE`, `US`, и имя процесса VPN без `.exe`).
   * **`2`** — Полностью остановить фоновый процесс, удалить задачу из автозапуска и стереть рабочий скрипт с диска.
   * **`3`** — Выход.

### ⚙️ Как это работает под капотом

* Установщик сохраняет рабочий скрипт в `C:\Scripts\claude_guard.ps1` и регистрирует скрытую задачу `Claude_VPN_Guard` в **Планировщике заданий Windows** (запуск при входе в систему, работа от батареи и от сети без ограничений по времени).
* Для корректной работы убедитесь, что ваш VPN-клиент работает в режиме **TUN (VPN-режим)**, чтобы весь трафик терминала маршрутизировался через туннель.

### ⚠️ Отказ от ответственности

Инструмент предназначен исключительно для защиты сетевого соединения и предотвращения случайных утечек трафика. Автор не несет ответственности за возможные ограничения со стороны сторонних сервисов.

<img width="414" height="360" alt="world_cup_clawd" src="https://github.com/user-attachments/assets/ab70258b-2f88-46ba-97ce-8d0fab28677c" />
