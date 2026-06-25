# ЛР8 — Верификация Consul Service Discovery + DNS

**Статус**: 🔴 КРИТИЧЕСКИЙ
**Дата**: 2026-06-25

## Ключевой результат

ЛР8 не содержит Terraform-код. 3-4 ВМ (Consul cluster + клиенты). `student` в Ansible.

### Найденные проблемы

1. **🔴 CRITICAL: Отсутствует Terraform main.tf**

2. **🔴 CRITICAL: `ansible_user=student`** (сквозной)

3. **🟡 MEDIUM: `local-lvm` в примерах** (сквозной)

### Рекомендации

Стандартный исправленный main.tf как для ЛР3 с clone, vm-storage, ubuntu.
