#!/bin/bash

# Налаштування змінних
SOURCE_DIR="/home/vagrant/data"  # Директорія для резервного копіювання
BACKUP_DIR="/home/vagrant/backup" # Локальна папка для архівів
REMOTE_USER="vagrant"
REMOTE_HOST="192.168.56.11"
REMOTE_BACKUP_DIR="/home/vagrant/backup"
LOG_FILE="/var/log/backup.log"
DATE=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="backup_${DATE}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

# Функція логування
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Перевірка доступності сервера
ping -c 3 "$REMOTE_HOST" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    log_message "❌ Помилка: Сервер $REMOTE_HOST недоступний."
    exit 1
fi

log_message "🔄 Резервне копіювання розпочато."

# Перевірка існування локального каталогу резервних копій
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_message "📁 Створено локальний каталог резервних копій: $BACKUP_DIR"
fi

# Створення архіву
tar -czf "$ARCHIVE_PATH" -C "$SOURCE_DIR" .
if [ $? -eq 0 ]; then
    log_message "✅ Архів створено: $ARCHIVE_PATH"
else
    log_message "❌ Помилка: Не вдалося створити архів."
    exit 1
fi

# Перевірка існування каталогу backup на сервері
ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_BACKUP_DIR"

# Передача архіву на сервер
scp "$ARCHIVE_PATH" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR/"
if [ $? -eq 0 ]; then
    log_message "🚀 Архів передано на сервер $REMOTE_HOST у $REMOTE_BACKUP_DIR"
else
    log_message "❌ Помилка: Не вдалося передати архів."
    exit 1
fi

# Видалення старих резервних копій (залишаємо лише 3 останні)
ssh "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_BACKUP_DIR && ls -t | tail -n +4 | xargs rm -f"
log_message "🗑️ Старі резервні копії очищено."

log_message "🎉 Резервне копіювання завершено успішно."
exit 0

