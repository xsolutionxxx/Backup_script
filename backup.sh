#!/bin/bash

# Налаштування
LOCAL_DIR="/home/vagrant/data"  # Локальна папка для бекапу
REMOTE_USER="vagrant"           # Користувач на сервері
REMOTE_HOST="192.168.56.11"     # IP-адреса сервера
REMOTE_DIR="/home/vagrant/backup"  # Дистанційна папка для збереження бекапу
TIMESTAMP=$(date +"%Y%m%d_%H%M%S") # Поточна дата й час
BACKUP_FILE="backup_${TIMESTAMP}.tar.gz"  # Ім'я архіву
LOCAL_BACKUP_PATH="/tmp/$BACKUP_FILE"  # Де тимчасово зберігати архів

# Створення архіву
echo "📦 Архівуємо $LOCAL_DIR у $LOCAL_BACKUP_PATH..."
tar -czf "$LOCAL_BACKUP_PATH" -C "$LOCAL_DIR" .

# Перевіряємо, чи існує папка backup на сервері, і створюємо її, якщо потрібно
echo "📂 Перевіряємо, чи існує папка backup на сервері..."
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_DIR"

# Передача архіву на сервер через SCP
echo "📤 Передаємо архів $BACKUP_FILE на $REMOTE_HOST..."
scp "$LOCAL_BACKUP_PATH" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

# Видаляємо локальний тимчасовий архів
rm "$LOCAL_BACKUP_PATH"

echo "✅ Резервне копіювання завершено!"

