#!/bin/bash
# Быстрый скрипт для получения credentials через Yandex Cloud CLI

echo "=== Получение credentials для Yandex Cloud ==="
echo ""

# Проверка наличия yc CLI
if ! command -v yc &> /dev/null; then
    echo "❌ Yandex Cloud CLI не установлен!"
    echo ""
    echo "Установите его:"
    echo "  brew install yandex-cloud-cli"
    echo ""
    echo "Или следуйте инструкциям:"
    echo "  https://cloud.yandex.ru/docs/cli/quickstart"
    exit 1
fi

echo "✓ Yandex Cloud CLI установлен"
echo ""

# Проверка инициализации
if ! yc config list &> /dev/null; then
    echo "⚠️  Yandex Cloud CLI не инициализирован"
    echo "Выполните: yc init"
    exit 1
fi

echo "=== Текущие настройки ==="
echo ""

# Получение данных
TOKEN=$(yc config get token 2>/dev/null)
CLOUD_ID=$(yc config get cloud-id 2>/dev/null)
FOLDER_ID=$(yc config get folder-id 2>/dev/null)
ZONE=$(yc config get zone 2>/dev/null || echo "ru-central1-a")

echo "OAuth Token:"
if [ -n "$TOKEN" ]; then
    echo "  ${TOKEN:0:20}..." # Показываем только первые 20 символов
else
    echo "  ❌ Не найден"
fi

echo ""
echo "Cloud ID:"
if [ -n "$CLOUD_ID" ]; then
    echo "  $CLOUD_ID"
else
    echo "  ❌ Не найден"
fi

echo ""
echo "Folder ID:"
if [ -n "$FOLDER_ID" ]; then
    echo "  $FOLDER_ID"
else
    echo "  ❌ Не найден"
fi

echo ""
echo "Zone:"
echo "  ${ZONE:-ru-central1-a}"

echo ""
echo "=== Инструкция ==="
echo ""
echo "Скопируйте эти значения в terraform.tfvars:"
echo ""
echo "yandex_token = \"$TOKEN\""
echo "cloud_id     = \"$CLOUD_ID\""
echo "folder_id    = \"$FOLDER_ID\""
echo "zone         = \"$ZONE\""
echo ""

# Предложение автоматически заполнить terraform.tfvars
if [ -f "terraform.tfvars" ] && [ -n "$TOKEN" ] && [ -n "$CLOUD_ID" ] && [ -n "$FOLDER_ID" ]; then
    read -p "Заполнить terraform.tfvars автоматически? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        # Создаем резервную копию
        cp terraform.tfvars terraform.tfvars.backup
        
        # Заменяем значения
        sed -i '' "s|yandex_token = \".*\"|yandex_token = \"$TOKEN\"|" terraform.tfvars
        sed -i '' "s|cloud_id     = \".*\"|cloud_id     = \"$CLOUD_ID\"|" terraform.tfvars
        sed -i '' "s|folder_id    = \".*\"|folder_id    = \"$FOLDER_ID\"|" terraform.tfvars
        sed -i '' "s|zone         = \".*\"|zone         = \"$ZONE\"|" terraform.tfvars
        
        echo "✓ terraform.tfvars обновлен!"
        echo "  Резервная копия сохранена как terraform.tfvars.backup"
    fi
fi

