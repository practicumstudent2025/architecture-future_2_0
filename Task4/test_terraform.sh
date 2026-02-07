#!/bin/bash
# Скрипт для тестирования Terraform конфигурации

echo "=== Тестирование Terraform конфигурации ==="
echo ""

# Проверка наличия terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform не установлен!"
    echo "Установите Terraform: brew install terraform"
    exit 1
fi

echo "✓ Terraform установлен: $(terraform version | head -n 1)"
echo ""

# Проверка terraform.tfvars
if grep -q "YOUR_OAUTH_TOKEN_HERE" terraform.tfvars 2>/dev/null; then
    echo "⚠️  ВНИМАНИЕ: terraform.tfvars содержит placeholder значения!"
    echo "   Заполните реальными credentials перед выполнением terraform apply"
    echo ""
fi

# Шаг 1: Инициализация
echo "=== Шаг 1: terraform init ==="
terraform init
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при инициализации Terraform"
    exit 1
fi
echo "✓ Инициализация завершена успешно"
echo ""

# Шаг 2: План
echo "=== Шаг 2: terraform plan ==="
terraform plan -out=tfplan
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при создании плана"
    exit 1
fi
echo "✓ План создан успешно"
echo ""

# Шаг 3: Применение (только если не placeholder значения)
if ! grep -q "YOUR_OAUTH_TOKEN_HERE" terraform.tfvars 2>/dev/null; then
    echo "=== Шаг 3: terraform apply ==="
    echo "⚠️  ВНИМАНИЕ: Это создаст реальную инфраструктуру в Yandex Cloud!"
    read -p "Продолжить? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        terraform apply tfplan
        echo ""
        echo "=== Результаты ==="
        terraform output
    else
        echo "Применение отменено"
    fi
else
    echo "=== Шаг 3: terraform apply (пропущен - нужны реальные credentials) ==="
    echo "Заполните terraform.tfvars и запустите: terraform apply"
fi

echo ""
echo "=== Тестирование завершено ==="
