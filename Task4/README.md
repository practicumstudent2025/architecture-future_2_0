# Terraform конфигурация для инфраструктуры Будущее 2.0

## Структура проекта

```
Task4/
├── main.tf              # Основная конфигурация инфраструктуры
├── variables.tf         # Определение переменных
├── outputs.tf          # Вывод ключевых параметров
├── terraform.tfvars.example  # Пример значений переменных
├── justification.md     # Обоснование конфигурации
└── diagram.png         # Диаграмма автоматизации развёртывания
```

## Предварительные требования

1. Установленный Terraform (>= 1.0)
2. Yandex Cloud аккаунт с созданным облаком и папкой
3. OAuth токен для доступа к Yandex Cloud
4. SSH ключ для доступа к виртуальным машинам

## Установка

1. Скопируйте пример файла переменных:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Заполните `terraform.tfvars` реальными значениями:
   - `yandex_token` - OAuth токен из Yandex Cloud
   - `cloud_id` - ID облака
   - `folder_id` - ID папки
   - При необходимости измените размеры VM и дисков

## Использование

1. Инициализация Terraform:
   ```bash
   terraform init
   ```

2. Просмотр плана изменений:
   ```bash
   terraform plan
   ```

3. Применение конфигурации:
   ```bash
   terraform apply
   ```

4. Просмотр выходных значений:
   ```bash
   terraform output
   ```

5. Удаление инфраструктуры:
   ```bash
   terraform destroy
   ```

## Создаваемая инфраструктура

- VPC с 5 подсетями (1 публичная, 4 приватные)
- NAT Gateway для доступа в интернет
- 7 виртуальных машин:
  - Bastion host
  - Data Lakehouse
  - Event Bus (Kafka)
  - Data Catalog
  - Финтех домен
  - AI домен
  - BI Portal
- 3 диска для данных
- Security Groups для управления доступом

## Важно

⚠️ Файл `terraform.tfvars` содержит чувствительные данные и не должен попадать в Git. Убедитесь, что он добавлен в `.gitignore`.
