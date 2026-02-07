# Инструкция по тестированию Terraform конфигурации

## Предварительные требования

1. **Установите Terraform** (если еще не установлен):
   ```bash
   # macOS
   brew install terraform
   
   # Или скачайте с https://www.terraform.io/downloads
   ```

2. **Заполните `terraform.tfvars`** реальными значениями:
   - `yandex_token` - OAuth токен из Yandex Cloud
   - `cloud_id` - ID вашего облака
   - `folder_id` - ID папки в облаке
   - Проверьте путь к SSH ключу: `ssh_public_key_path`

3. **Убедитесь, что SSH ключ существует**:
   ```bash
   ls -la ~/.ssh/id_rsa.pub
   # Если ключа нет, создайте его:
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

## Шаги тестирования

### 1. Инициализация Terraform

```bash
cd Task4
terraform init
```

**Ожидаемый результат:**
- Terraform загрузит необходимые провайдеры (yandex-cloud/yandex)
- Создастся директория `.terraform/`
- Должно появиться сообщение: "Terraform has been successfully initialized!"

### 2. Проверка плана развертывания

```bash
terraform plan
```

**Ожидаемый результат:**
- Terraform покажет план создания всех ресурсов
- Должно быть создано примерно 20 ресурсов:
  - 1 VPC Network
  - 5 подсетей
  - 1 NAT Gateway
  - 1 Route Table
  - 2 Security Groups
  - 3 диска
  - 7 виртуальных машин

**Важно:** Проверьте, что план выглядит корректно и нет ошибок.

### 3. Применение конфигурации

```bash
terraform apply
```

**Ожидаемый результат:**
- Terraform попросит подтверждение (введите `yes`)
- Начнется создание ресурсов
- В конце должно появиться сообщение:
  ```
  Apply complete! Resources: X added, 0 changed, 0 destroyed.
  
  Outputs:
  
  ai_private_ip = "..."
  bastion_public_ip = "..."
  bi_portal_public_ip = "..."
  ...
  ```

**⚠️ ВАЖНО:** 
- Это создаст реальную инфраструктуру в Yandex Cloud
- Создание ресурсов может занять 5-10 минут
- Ресурсы будут стоить денег (проверьте тарифы Yandex Cloud)

### 4. Скриншот результата

**Сделайте скриншот:**
1. Выполните `terraform apply`
2. Дождитесь завершения (сообщение "Apply complete!")
3. Сделайте скриншот терминала с результатом выполнения
4. Сохраните скриншот как `terraform_apply_result.png` в директории Task4

**Альтернатива (сохранение вывода в файл):**
```bash
terraform apply 2>&1 | tee terraform_apply_output.txt
```

### 5. Проверка созданных ресурсов

```bash
# Просмотр outputs
terraform output

# Просмотр состояния
terraform show
```

### 6. Очистка (опционально)

После тестирования можно удалить созданную инфраструктуру:

```bash
terraform destroy
```

**⚠️ ВАЖНО:** Это удалит все созданные ресурсы. Убедитесь, что это то, что вам нужно.

## Возможные проблемы

### Ошибка аутентификации
```
Error: error creating folder: unauthorized
```
**Решение:** Проверьте правильность `yandex_token`, `cloud_id` и `folder_id`

### Ошибка SSH ключа
```
Error: Error reading file '~/.ssh/id_rsa.pub'
```
**Решение:** Укажите полный путь к ключу или создайте ключ

### Ошибка квот
```
Error: quota exceeded
```
**Решение:** Проверьте квоты в Yandex Cloud Console

## Пример успешного выполнения

```
$ terraform apply

Terraform used the selected providers to generate the following execution plan...

Plan: 20 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.main: Creating...
yandex_vpc_network.main: Creation complete after 1s
yandex_vpc_subnet.public: Creating...
...
[создание ресурсов]

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.

Outputs:

ai_private_ip = "10.0.3.10"
bastion_public_ip = "51.250.XX.XX"
bi_portal_public_ip = "51.250.XX.XX"
data_catalog_private_ip = "10.0.5.12"
data_lakehouse_private_ip = "10.0.5.10"
event_bus_private_ip = "10.0.5.11"
fintech_private_ip = "10.0.2.10"
nat_gateway_id = "e9b..."
vpc_network_id = "enp..."
```

## Примечания

- Для выполнения `terraform apply` нужны реальные credentials Yandex Cloud
- Создание инфраструктуры может занять время (5-10 минут)
- Ресурсы будут стоить денег согласно тарифам Yandex Cloud
- После тестирования рекомендуется выполнить `terraform destroy` для очистки
