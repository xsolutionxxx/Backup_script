#!/bin/bash

# Вихід, якщо виникає помилка
set -e

# Локальна директорія з файлами для бекапу
SRC_DIR="/home/vagrant/data"

# Віддалений сервер і папка для збереження бекапу
REMOTE_USER="vagrant"
REMOTE_HOST="192.168.56.11"
REMOTE_DIR="/home/vagrant/backup"

# Логування дати бекапу
echo "=== Початок резервного копіювання: $(date) ==="

# Виконання передачі файлів через SCP
scp -r "$SRC_DIR"/* "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

# Завершення
echo "=== Бекап завершено успішно: $(date) ==="
