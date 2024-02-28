# OpenVPN setup

## Автонастройка

### Настройка сервера 
```
cd vpn-setup
./init.sh
```
Далее следуйте указаниям установщика.

### Генерация конфига клиента
```
cd vpn-setup
./init.sh
```
Далее следуйте указаниям установщика.

## Ручная настройка

### Подготовка
Установка необходимых утилит:
```
apt update
apt install -y openvpn easy-rsa ufw
```

### Ключи и сертификаты сервера
```
mkdir ~/easy-rsa
ln -s /usr/share/easy-rsa/* ~/easy-rsa/

cd ~/easy-rsa
nano vars
```
Вставить содержимое `vars` в `~/easy-rsa/vars`.

```
./easyrsa init-pki
./easyrsa gen-req server nopass
./easyrsa build-ca
./easyrsa sign-req server server
cp pki/ca.crt pki/issued/server.crt pki/private/server.key /etc/openvpn/server

openvpn --genkey secret ta.key
cp ta.key /etc/openvpn/server
```

### Общие ключи и сертификаты клиентов
```
mkdir -p ~/client-configs/keys
cp ta.key pki/ca.crt  ~/client-configs/keys
```

### Конфигурация OpenVPN
```
nano /etc/openvpn/server/server.conf
```
Вставить содержимое `server.conf` в `/etc/openvpn/server/server.conf`. Поправить IP и порт.

```
nano /etc/sysctl.conf
```
Вставить содержимое `sysctl.conf` в `/etc/sysctl.conf`.

```
sysctl -p
```

### Брандмауэр
```
ip route list default
```
Узнать имя интерфейса (e.g. `eth0`).

```
nano /etc/ufw/before.rules
```
Вставить содержимое `before.rules` в `/etc/ufw/before.rules`.

```
nano /etc/default/ufw
```
Вставить содержимое `ufw` в `/etc/default/ufw`.

```
ufw allow <PORT>/udp
ufw allow OpenSSH
ufw disable
ufw enable
```
Указать выбранный порт.

### Запуск OpenVPN
```
systemctl -f enable openvpn-server@server.service
systemctl start openvpn-server@server.service
systemctl status openvpn-server@server.service
```

### Генератор клиентских конфигов
```
mkdir -p ~/client-configs/files
nano ~/client-configs/base.conf
```

Вставить содержимое `base.conf` в `~/client-configs/base.conf`.
Указать IP и порт OpenVPN сервера в директиве `remote` в конфиге.

```
nano ~/client-configs/make_config.sh
```
Вставить содержимое `make_config.sh` в `~/client-configs/make_config.sh`.

```
chmod +x ~/client-configs/make_config.sh
```

Генерация конфига:
```
cd ~/client-configs
./make_config.sh client1
```

Конфиг будет тут `~/client-configs/files/client1.ovpn`.

### Источники
- [Установка и настройка сервера OpenVPN](https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-20-04-ru)
- [OpenVPN How To](https://openvpn.net/community-resources/how-to/)