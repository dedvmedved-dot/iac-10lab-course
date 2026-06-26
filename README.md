# Лабораторные работы по IAC (верифицировано)

Результат верификации 12 глав книги. Все сквозные баги исправлены, каждая ЛР готова к запуску.

## Где и как заполнить свои метаданные

**Файл в каждой ЛР:** `terraform.tfvars.example` — шаблон с вашими будущими значениями.

Порядок действий:
1. Заходите в каталог нужной ЛР, например `cd ЛР8`
2. Копируете шаблон: `cp terraform.tfvars.example terraform.tfvars`
3. Открываете: `nano terraform.tfvars`
4. Заменяете `<...>` на свои реальные значения (токен, URL, ID шаблона и т.д.)

**Пример заполненного `terraform.tfvars`** (ЛР8):

```hcl
proxmox_endpoint    = "https://192.168.0.200:8006/"
proxmox_api_token   = "terraform@pve!lab-token=секретнаястрока"
proxmox_node_name   = "pve"
datastore_id        = "vm-storage"
snippets_datastore  = "snippets"
template_vm_id      = 9000
vm_user             = "ubuntu"
ssh_public_key_path = "~/.ssh/id_ed25519.pub"
gateway             = "192.168.0.1"
```

Ниже — что означает каждый параметр и откуда его взять на ВАШЕМ Proxmox.

## Таблица параметров (заполните колонку «Ваше значение»)

| Параметр | На стенде книги | Ваше значение | Где взять на Proxmox |
|---|---|---|---|
| `proxmox_endpoint` | `https://192.168.0.200:8006/` | | IP вашего Proxmox + порт 8006 |
| `proxmox_api_token` | `terraform@pve!lab-token=...` | | Datacenter → Permissions → API Tokens → Add |
| `proxmox_node_name` | `pve` | | Имя узла (Datacenter → ваш узел → Summary) |
| `template_vm_id` | `9000` | | ID вашего шаблона Ubuntu ( `qm list` ) |
| `vm_user` | `ubuntu` | | Пользователь внутри облачного образа (обычно ubuntu) |
| `datastore_id` | `vm-storage` | | Хранилище для дисков ВМ (Datacenter → Storage) |
| `snippets_datastore` | `snippets` | | Хранилище сниппетов (Datacenter → Storage → Snippets) |
| `vm_bridge` | `vmbr0` | | Сетевой мост (узел → System → Network) |
| `gateway` | `192.168.0.1` | | Ваш шлюз по умолчанию |
| `ssh_public_key_path` | `~/.ssh/id_ed25519.pub` | | Путь к вашему SSH-публичному ключу |

### Как создать API-токен

Datacenter → Permissions → API Tokens → Add. Снимите галочку «Privilege Separation», дайте роль PVEAdmin. Скопируйте **Secret** сразу — он показывается один раз. Формат для файла: `пользователь!токен-id=секрет`.

### Как создать snippets-хранилище (если нет)

Datacenter → Storage → Add → Directory:
- ID: `snippets`
- Directory: `/var/lib/vz/snippets`
- Content: только **Snippets**

### Занятые VM ID — ВАШ список (пример ниже, заполните свой!)

**Это пример для нашего стенда. Вы должны составить такой же список для СВОЕГО Proxmox** — иначе terraform может уничтожить работающие ВМ при совпадении ID.

Как узнать свои занятые ID: выполните `qm list` на вашем Proxmox, запишите все номера.

Пример (наш стенд):

| ID | Назначение |
|----|-----------|
| 102-103 | Windows |
| 110 | llm-lab |
| 202-206 | k8s-кластер |
| 9000 | Шаблон Ubuntu |

Ваш список (впишите):

| ID | Назначение |
|----|-----------|
| | |
| | |
| | |

Перед запуском `terraform apply` убедитесь, что ID ВМ из таблицы ниже НЕ пересекаются с вашим списком занятых.

## ID ВМ по лабораторным работам

| ЛР | Тема | VM ID | IP |
|----|------|-------|----|
| ЛР1 | Terraform: первая ВМ | 101 | 192.168.0.101 |
| ЛР2 | Ansible | 105 | 192.168.0.101 |
| ЛР3 | Nginx + Flask + PostgreSQL | 111, 121, 131 | .111 / .121 / .131 |
| ЛР4 | HAProxy + Keepalived | 201-204 | .141–.144 |
| ЛР5 | Patroni + etcd | 401-403, 411-413, 421 | .151–.171 |
| ЛР6 | OpenSearch + Kafka KRaft | 406, 416-417, 436-437 | .106 / .160 / .161 / .180 / .181 |
| ЛР7 | Percona XtraDB Cluster | 507-509 | .171–.173 |
| ЛР8 | Consul Service Discovery | 608-612 | .181–.185 |
| ЛР9 | NetBox | 600-601 | .190 / .191 |
| ЛР10 | Kubernetes + Velero | 716-718 | .220–.222 |
| Прил. Г | GFS2 + iSCSI | 1130-1133 | .230–.233 |

## Быстрый старт

```bash
git clone https://github.com/dedvmedved-dot/iac-10lab-course.git
cd iac-10lab-course/ЛР8

# 1. Копируете шаблон и вписываете СВОИ значения (см. таблицу выше)
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Развёртываете ВМ
terraform init
terraform apply

# 3. Если в ЛР есть ansible — запускаете плейбук
cd ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml
```

Файл `terraform.tfvars` уже в `.gitignore` — в репозиторий не попадёт.

Для ЛР8 бинарник Consul 2.0.1 разбит на части — плейбук склеивает автоматически.

## Исправленные баги

1. **clone** — добавлен во все главы (`clone { vm_id = var.template_vm_id }`)
2. **ansible_user** — везде `ubuntu` вместо `student`
3. **datastore_id** — параметризован (умолчание `vm-storage`)
4. **cicustom** — если клонируете чужой шаблон: `qm set <ID> --delete cicustom`
5. **host key** — `ANSIBLE_HOST_KEY_CHECKING=False` при первом подключении

## Ограничения

- Terraform заменён на OpenTofu (HashiCorp geo-блокирован)
- Бинарники HashiCorp (Consul) — в репозитории
- Проверено на Ubuntu 24.04
