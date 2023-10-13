AntiZapret Installer
====================

Если вы попали сюда, то знаете зачем нужен данный сервис, подробнее можно прочитать [здесь](https://antizapret.prostovpn.org).

- [Установка](#установка)
- [Удаление](#удаление)
- [Какой VPS выбрать?](#какой-vps-выбрать)
  - [Минимальные системные требования при выборе VPS](#минимальные-системные-требования-при-выборе-vps)

## Установка

Входим в систему используя SSH: IP-адрес хоста, логин и пароль обычно выдает хостер.
Все команды выполняем от пользователя `root` или используя `sudo`.

Установщику можно задать следующие переменные окружения:

* `IMAGE` - URL-адрес или путь к файлу с образом
* `NAME` - имя контейнера, по-умолчанию `antizapret-vpn`

1.  Установка официального контейнера:
    ```shell
    wget -qO- https://kyzima-spb.github.io/antizapret/installer.sh | bash
    ```
2.  Установка моей версии контейнера с улучшениями:
    ```shell
    wget -qO- https://kyzima-spb.github.io/antizapret/installer.sh |\
    IMAGE=https://kyzima-spb.github.io/antizapret/rootfs.tar.xz \
    bash
    ```
3.  Установка контейнера с указанием имени:
    ```shell
    wget -qO- https://kyzima-spb.github.io/antizapret/installer.sh |\
    NAME=antizapret \
    bash
    ```

После успешной установки, в текущей директории должен появиться файл
`antizapret-client-tcp.ovpn` - это конфигурационный файл для клиента OpenVPN.
В Linux данный файл можно скачать с сервера следующей командой:
```shell
scp <USER>@<PUBLIC_IP>:<PATH_TO_OVPN_FILE> <DEST_PATH>
```

## Удаление

Чтобы удалить контейнер, образ и все связанные файлы выполните:
```shell
wget -qO- https://kyzima-spb.github.io/antizapret/installer.sh |\
bash /dev/stdin uninstall
```

Если при установке было задано другое имя, то выполните:
```shell
wget -qO- https://kyzima-spb.github.io/antizapret/installer.sh |\
NAME=antizapret \
bash /dev/stdin uninstall
```

## Какой VPS выбрать?

При выборе VPS для VPN стоит ориентироваться на физическое расположение сервера и пинг.
Ниже приведены минимальные необходимые системные требования, все что отсутствует в списке - большой роли не играет.

### Минимальные системные требования при выборе VPS

* Виртуализация KVM или XEN
* Публичный IPv4-адрес
* RAM минимум 1Gb
* Безлимитный трафик, либо как можно больше =)
* ОС Debian или Debain-based

Я выбрал для себя [RoboVPS](https://www.robovps.biz/?ref=39155) (ссылка реферальная!!!)
как оптимальный вариант по соотношению цена/качество.
