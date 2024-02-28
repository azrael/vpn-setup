# OpenVPN setup

### Подготовка
Установка необходимых утилит:
```
apt update
apt install openvpn easy-rsa ufw
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
cp pki/ca.crt pki/issued/server.crt /etc/openvpn/server

openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn/server
```

### Ключи и сертификаты клиента
`client1` — имя клиента.

```
mkdir -p ~/client-configs/keys
cp ta.key pki/ca.crt  ~/client-configs/keys

./easyrsa gen-req client1 nopass
cp pki/private/client1.key ~/client-configs/keys/
./easyrsa sign-req client client1
cp pki/issued/client1.crt ~/client-configs/keys
```

### Конфигурация OpenVPN
Порт выбран 443.

```
nano /etc/openvpn/server/server.conf
```

Вставить содержимое `server.conf` в `/etc/openvpn/server/server.conf`.

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
ufw allow 443/udp
ufw allow OpenSSH
ufw disable
ufw enable
```
(проверить порт)

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
Проверить IP и порт OpenVPN сервера в директиве `remote` в конфиге.

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

Конфиг тут `~/client-configs/files/client1.ovpn`.

### Источники
- [Установка и настройка сервера OpenVPN](https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-20-04-ru)
- [OpenVPN How To](https://openvpn.net/community-resources/how-to/)