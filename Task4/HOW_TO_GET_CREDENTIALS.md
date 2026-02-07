# Как получить credentials для Yandex Cloud

## 1. OAuth токен (yandex_token)

### Способ 1: Через Yandex Cloud CLI (рекомендуется)

1. **Установите Yandex Cloud CLI** (если еще не установлен):
   ```bash
   # macOS
   brew install yandex-cloud-cli
   
   # Или следуйте инструкциям: https://cloud.yandex.ru/docs/cli/quickstart
   ```

2. **Инициализируйте CLI**:
   ```bash
   yc init
   ```
   Это откроет браузер для авторизации и создаст профиль.

3. **Получите токен**:
   ```bash
   yc config get token
   ```
   Или создайте новый OAuth токен:
   ```bash
   yc iam create-token
   ```

### Способ 2: Через веб-интерфейс

1. Откройте [Yandex Cloud Console](https://console.cloud.yandex.ru/)
2. Войдите в свой аккаунт
3. Перейдите в раздел **IAM** → **Сервисные аккаунты**
4. Создайте новый сервисный аккаунт или выберите существующий
5. Перейдите в **Ключи** → **Создать ключ** → **OAuth токен**
6. Скопируйте токен (он показывается только один раз!)

### Способ 3: Через Yandex ID

1. Перейдите на [Yandex OAuth](https://oauth.yandex.ru/)
2. Создайте приложение
3. Получите токен для доступа к API

**⚠️ Важно:** OAuth токен имеет ограниченный срок действия. Для продакшена рекомендуется использовать сервисный аккаунт с ключом.

---

## 2. Cloud ID (cloud_id)

### Способ 1: Через Yandex Cloud CLI

```bash
yc config get cloud-id
```

### Способ 2: Через веб-интерфейс

1. Откройте [Yandex Cloud Console](https://console.cloud.yandex.ru/)
2. В правом верхнем углу нажмите на имя вашего облака
3. Cloud ID отображается в выпадающем меню или в URL браузера
4. Также можно найти в разделе **Облака и каталоги** → выберите ваше облако → ID будет в описании

### Способ 3: Через API

```bash
yc resource-manager cloud list
```

Cloud ID имеет формат: `b1gxxxxxxxxxxxxxxxx`

---

## 3. Folder ID (folder_id)

### Способ 1: Через Yandex Cloud CLI

```bash
yc config get folder-id
```

Или посмотреть все папки:
```bash
yc resource-manager folder list
```

### Способ 2: Через веб-интерфейс

1. Откройте [Yandex Cloud Console](https://console.cloud.yandex.ru/)
2. В правом верхнем углу нажмите на имя папки
3. Folder ID отображается в выпадающем меню или в URL браузера
4. Также можно найти в разделе **Облака и каталоги** → выберите вашу папку → ID будет в описании

### Способ 3: Через API

```bash
yc resource-manager folder list
```

Folder ID имеет формат: `b1gxxxxxxxxxxxxxxxx`

---

## Быстрая проверка всех данных через CLI

Если у вас установлен Yandex Cloud CLI, выполните:

```bash
yc config list
```

Это покажет все текущие настройки:
- `token` - ваш OAuth токен
- `cloud-id` - ID облака
- `folder-id` - ID папки
- `zone` - зона (например, ru-central1-a)

---

## Пример заполнения terraform.tfvars

После получения всех данных, заполните файл `terraform.tfvars`:

```hcl
# Yandex Cloud credentials
yandex_token = "y0_AgAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # Ваш OAuth токен
cloud_id     = "b1gxxxxxxxxxxxxxxxx"                      # ID облака
folder_id    = "b1gxxxxxxxxxxxxxxxx"                     # ID папки
zone         = "ru-central1-a"                            # Зона (обычно ru-central1-a)

# SSH ключ
ssh_public_key_path = "~/.ssh/id_rsa.pub"                # Путь к вашему SSH ключу
```

---

## Проверка правильности данных

После заполнения можно проверить доступ:

```bash
# Через Yandex Cloud CLI
yc config list

# Или попробовать выполнить команду
yc compute instance list
```

Если команда выполняется без ошибок, значит credentials правильные.

---

## Безопасность

⚠️ **ВАЖНО:**
- Никогда не коммитьте `terraform.tfvars` с реальными credentials в Git
- Файл `terraform.tfvars` уже добавлен в `.gitignore`
- Используйте переменные окружения для продакшена:
  ```bash
  export TF_VAR_yandex_token="your_token"
  export TF_VAR_cloud_id="your_cloud_id"
  export TF_VAR_folder_id="your_folder_id"
  ```

---

## Дополнительные ресурсы

- [Документация Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/)
- [Создание OAuth токена](https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token)
- [Работа с облаками и папками](https://cloud.yandex.ru/docs/resource-manager/concepts/resources-hierarchy)
