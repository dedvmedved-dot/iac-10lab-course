# ЛР7 — Верификация MySQL Percona XtraDB Cluster

**Статус**: 🔴 КРИТИЧЕСКИЙ
**Дата**: 2026-06-25

## Ключевой результат

ЛР7 не содержит Terraform-код. Ansible-конфигурация использует `student`.

### Найденные проблемы

1. **🔴 CRITICAL: Отсутствует Terraform main.tf**
   3 ВМ Percona кластер + 2 HAProxy = 5 ВМ. Код не предоставлен.

2. **🔴 CRITICAL: `ansible_user=student`** (сквозной)

3. **🟡 MEDIUM: `local-lvm` в примерах** (сквозной)

### Рекомендации

Добавить Terraform код как в ЛР1, с исправлениями:
- `clone { vm_id = 9000 }`
- `datastore_id = "vm-storage"`  
- `user = "ubuntu"`
- `-parallelism=2`
