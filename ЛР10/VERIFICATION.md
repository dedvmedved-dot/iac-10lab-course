# ЛР10 — Верификация Kubernetes + деплой приложений

**Статус**: 🔴 КРИТИЧЕСКИЙ
**Дата**: 2026-06-25

## Ключевой результат

ЛР10 не содержит Terraform-код. 3-6 ВМ (k8s control-plane + workers). `student` в Ansible.

### Найденные проблемы

1. **🔴 CRITICAL: Отсутствует Terraform main.tf**

2. **🔴 CRITICAL: `ansible_user=student`** (сквозной)

3. **🟡 MEDIUM: `local-lvm` в примерах** (сквозной)

4. **🟡 LOW: Версия Kubernetes зафиксирована**

### Рекомендации

Стандартный исправленный main.tf как для ЛР3 с clone, vm-storage, ubuntu.
