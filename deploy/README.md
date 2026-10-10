ДЗ2. Ubuntu 22.04, Multipass.

Скрипт из ДЗ1 запущен в Docker через Compose. Каждые 5 секунд он записывает
free -h, df -h и uptime в monitor.log. HTTP-сервер Python отдаёт файл на
порту 8080. Nginx проксирует запросы и обслуживает HTTPS с самоподписанным
сертификатом.

Адрес: https://10.77.65.36/monitor.log
Лог на VM: /mnt/logs/my-app/monitor.log

Хранилище:
- disk1.img и disk2.img — RAID 1, смонтирован в /mnt/raid.
- disk3.img — отдельный LVM, vg_data/lv_logs, смонтирован в /mnt/logs.
- Каждый файл-диск занимает 512 МиБ. LV расширен с 200 до 400 МиБ.

lab-storage.service подключает хранилище при загрузке.
my-app.service запускает Compose и перезапускает приложение при завершении.
После перезагрузки VM службы запускаются, данные лога сохраняются.

Конфигурации рассчитаны на эту VM: IP, UUID и WorkingDirectory при переносе
нужно заменить. lab-storage.sh подключает уже созданные файлы-диски.

Команды на настроенной VM:

    sudo docker build -t my-script .
    sudo systemctl restart my-app
    sudo systemctl status my-app --no-pager
    curl -kI https://127.0.0.1/monitor.log
    sudo journalctl -u my-app -n 20 --no-pager
