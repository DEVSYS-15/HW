# Домашнее задание к занятию «Виртуальные частные сети (VPN)»

В качестве результата пришлите ответы на вопросы в личном кабинете студента на сайте [netology.ru](https://netology.ru).

**Важно**: убедитесь, что вы предварительно:
1. [Установили VirtualBox](../virtualbox/virtualbox.md)
1. Ознакомились с дополнительным видео по работе с виртуальными машинами
1. [Ознакомились с руководством по работе в терминале](../terminal/terminal.md) 

Материалы с лекции:
1. [WebVPN](./assets/webvpn.pkt)
1. [Site-to-Site](./assets/site2site.pkt)

## OpenVPN

В рамках данной лабораторной работы мы попрактикуемся в использовании самого популярного Open Source решения для организации VPN - [OpenVPN](https://openvpn.net/community-downloads/).

Первое с чего мы начнём - немного теории. OpenVPN предлагает два виртуальных устройства: TUN (только IP-трафик) и TAP (любой трафик). Соответственно, для приложений всё выглядит так, как будто оно использует не обычный Ethernet-интерфейс, а другой, направляя через него трафик. OpenVPN же "шифрует" данный трафик и перенаправляет его через Ethernet-интерфейс.

Поднимите две виртуальные машины:

1\. Ubuntu с Адаптер 1 - NAT и Адаптер 2 - Internal Network (10.0.0.1 - вручную)

2\. Kali с Адаптер 1 - NAT и Адаптер 2 - Internal Network (10.0.0.2 - вручную)

3\. Удостоверьтесь, что машины видят друг друга по адресам 10.0.0.1 и 10.0.0.2 соответственно (команда `ping`)

4\. Установите на обеих машинах OpenVPN:

```shell script
sudo apt update
sudo apt install openvpn
```

5\. Дополнительно на Ubuntu установите сервер openssh:

```shell script
sudo apt install openssh-server
```

6\. А на Kali - mc:

```shell script
sudo apt install mc
```

### P2P

Начнём с режима P2P (Point-to-Point).

#### PlainText

Первое, что мы сделаем, попробуем создать туннель без всяких механизмов шифрования и аутентификации.

Ubuntu
```shell script
sudo openvpn --ifconfig 10.1.0.1 10.1.0.2 --dev tun
```
Где, 10.1.0.1 - это локальный VPN endpoint, 10.1.0.2 - удалённый VPN endpoint

Kali
```shell script
sudo openvpn --ifconfig 10.1.0.2 10.1.0.1 --dev tun --remote 10.0.0.1
```
В данном случае адреса меняются местами и мы указываем к какому адресу нужно подключиться (режим P2P).

Откройте в Kali Wireshark и выберите интерфейс `eth1`.

Для тестирования мы будем использовать утилиту netcat (она позволит прослушивать на сервере определённый порт, а с клиента подключаться к этому порту).

Вам нужно и на Ubuntu и на Kali открыть ещё по одному терминалу (или вкладке терминала) и не завершая `openvpn` проделать остальные команды.

Ubuntu (прослушиваем порт 3000):
```shell script
nc -l 3000
```

Kali (подключаемся через туннель к порту 3000 сервера):
```shell script
nc 10.1.0.1 3000

Передаём любой текст, он будет отображаться на сервере в консоли
```

Удостоверьтесь в Wireshark, что данные передаются в открытом виде (`Follow UDP Stream`).

Завершите работу `openvpn` на сервере и на клиенте (Ctrl + C).

#### Shared Key

В этом режиме мы будем использовать один ключ для клиента и сервера.

Ubuntu (генерация ключа):
```shell script
openvpn --genkey --secret vpn.key
cat vpn.key
```

Ключ будет выглядеть следующим образом:
```text
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END OpenVPN Static key V1-----
```

Теперь нам необходимо безопасно передать ключ с сервера на клиент. Проще всего это сделать, воспользовавшись `mc` (файловый менеджер). Запустите его, набрав в терминале `mc`:

![](pic/mc01.png)

Нажмите клавишу F9 после чего Enter, чтобы попасть в выпадающее меню. С помощью стрелок переместитесь на пункт `Shell link...` и нажмите Enter:

![](pic/mc02.png)

В строке подключения введите `ubuntu@10.0.0.1`, где `ubuntu` - это ваш логин на машине с Ubuntu (будет другой, если вы использовали образ с OSBoxes), после чего нажмите Enter:

![](pic/mc03.png)

Согласитесь с подключением (и сохранением отпечатка) к 10.0.0.1 (введите `yes` после чего нажмите Enter и введите пароль от учётной записи на машине Ubuntu):

![](pic/mc04.png)

**Важно**: пароль не будет отображаться при вводе в целях безопасности.

Вы попадёте в корневой каталог вашего Ubuntu Server'а, по которому сможете перемещаться с помощью стрелок вверх вниз, заходить в каталоги - с помощью Enter, выходить - с помощью Enter на каталоге `..`.

Копирование в правую панель (где находится файловая система вашего локального компьютера с Kali) осуществляется с помощью клавиши F5 с подтверждением клавишей Enter:

![](pic/mc05.png)

Выход из mc осуществляется с помощью клавиши F10.

Ubuntu
```shell script
sudo openvpn --ifconfig 10.1.0.1 10.1.0.2 --dev tun --secret vpn.key
```

Kali
```shell script
sudo openvpn --ifconfig 10.1.0.2 10.1.0.1 --dev tun --remote 10.0.0.1 --secret vpn.key --providers legacy default
```
Примечание: если соединение не создается для новых версий OpenVPN (старше 2.5),
то вместо "--secret vpn.key" укажите "--genkey secret vpn.key"

Ubuntu (прослушиваем порт 3000):
```shell script
nc -l 3000
```

Kali (подключаемся через туннель к порту 3000 сервера):
```shell script
nc 10.1.0.1 3000

Передаём любой текст, он будет отображаться на сервере в консоли
```

Удостоверьтесь в Wireshark, что данные не передаются в открытом виде (`Follow UDP Stream`).

### Вопросы

1\. Пришлите скриншот Wireshark, где видно, что данные передаются в открытом виде (для раздела PlainText)
![PlainText](pic/PlainText.jpg)


2\. Пришлите скриншот Wireshark, где видно, что данные не передаются в открытом виде (для раздела Shared Key)
![PlainText](pic/Shared%20Key.jpg)
На сервере или на клиенте запустите команду с флагом `--verb 3`, например, на Kali - `sudo openvpn --ifconfig 10.1.0.2 10.1.0.1 --dev tun --remote 10.0.0.1 --secret vpn.key --verb 3`

Внимательно изучите вывод и пришлите ответы на следующие вопросы:

3\. Какая версия OpenSSL используется

```text
2024-03-10 15:15:57 library versions: OpenSSL 3.1.5 30 Jan 2024, LZO 2.10
```

4\. Какой алгоритм (и с какой длиной ключа) используется для шифрования

```text
cipher 'BF-CBC'
BF-CBC  (128 bit key, 64 bit block)
```

5\. Какой алгоритм (и с какой длиной ключа) используется дла HMAC аутентификации

```text
 auth 'SHA1'
 160 bit digest size
```

Посмотреть все доступные алгоритмы с помощью команд: `sudo openvpn --show-ciphers` и `sudo openvpn --show-digests` соответственно.

```bash
 openvpn --show-ciphers
The following ciphers and cipher modes are available for use
with OpenVPN.  Each cipher shown below may be used as a
parameter to the --data-ciphers (or --cipher) option. In static
key mode only CBC mode is allowed.
See also openssl list -cipher-algorithms

AES-128-CBC  (128 bit key, 128 bit block)
AES-128-CFB  (128 bit key, 128 bit block, TLS client/server mode only)
AES-128-CFB1  (128 bit key, 128 bit block, TLS client/server mode only)
AES-128-CFB8  (128 bit key, 128 bit block, TLS client/server mode only)
AES-128-GCM  (128 bit key, 128 bit block, TLS client/server mode only)
AES-128-OFB  (128 bit key, 128 bit block, TLS client/server mode only)
AES-192-CBC  (192 bit key, 128 bit block)
AES-192-CFB  (192 bit key, 128 bit block, TLS client/server mode only)
AES-192-CFB1  (192 bit key, 128 bit block, TLS client/server mode only)
AES-192-CFB8  (192 bit key, 128 bit block, TLS client/server mode only)
AES-192-GCM  (192 bit key, 128 bit block, TLS client/server mode only)
AES-192-OFB  (192 bit key, 128 bit block, TLS client/server mode only)
AES-256-CBC  (256 bit key, 128 bit block)
AES-256-CFB  (256 bit key, 128 bit block, TLS client/server mode only)
AES-256-CFB1  (256 bit key, 128 bit block, TLS client/server mode only)
AES-256-CFB8  (256 bit key, 128 bit block, TLS client/server mode only)
AES-256-GCM  (256 bit key, 128 bit block, TLS client/server mode only)
AES-256-OFB  (256 bit key, 128 bit block, TLS client/server mode only)
ARIA-128-CBC  (128 bit key, 128 bit block)
ARIA-128-CFB  (128 bit key, 128 bit block, TLS client/server mode only)
ARIA-128-CFB1  (128 bit key, 128 bit block, TLS client/server mode only)
ARIA-128-CFB8  (128 bit key, 128 bit block, TLS client/server mode only)
ARIA-128-GCM  (128 bit key, 128 bit block, TLS client/server mode only)
ARIA-128-OFB  (128 bit key, 128 bit block, TLS client/server mode only)
ARIA-192-CBC  (192 bit key, 128 bit block)
ARIA-192-CFB  (192 bit key, 128 bit block, TLS client/server mode only)
ARIA-192-CFB1  (192 bit key, 128 bit block, TLS client/server mode only)
ARIA-192-CFB8  (192 bit key, 128 bit block, TLS client/server mode only)
ARIA-192-GCM  (192 bit key, 128 bit block, TLS client/server mode only)
ARIA-192-OFB  (192 bit key, 128 bit block, TLS client/server mode only)
ARIA-256-CBC  (256 bit key, 128 bit block)
ARIA-256-CFB  (256 bit key, 128 bit block, TLS client/server mode only)
ARIA-256-CFB1  (256 bit key, 128 bit block, TLS client/server mode only)
ARIA-256-CFB8  (256 bit key, 128 bit block, TLS client/server mode only)
ARIA-256-GCM  (256 bit key, 128 bit block, TLS client/server mode only)
ARIA-256-OFB  (256 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-128-CBC  (128 bit key, 128 bit block)
CAMELLIA-128-CFB  (128 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-128-CFB1  (128 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-128-CFB8  (128 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-128-OFB  (128 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-192-CBC  (192 bit key, 128 bit block)
CAMELLIA-192-CFB  (192 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-192-CFB1  (192 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-192-CFB8  (192 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-192-OFB  (192 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-256-CBC  (256 bit key, 128 bit block)
CAMELLIA-256-CFB  (256 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-256-CFB1  (256 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-256-CFB8  (256 bit key, 128 bit block, TLS client/server mode only)
CAMELLIA-256-OFB  (256 bit key, 128 bit block, TLS client/server mode only)
CHACHA20-POLY1305  (256 bit key, stream cipher, TLS client/server mode only)
SEED-CBC  (128 bit key, 128 bit block)
SEED-CFB  (128 bit key, 128 bit block, TLS client/server mode only)
SEED-OFB  (128 bit key, 128 bit block, TLS client/server mode only)
SM4-CBC  (128 bit key, 128 bit block)
SM4-CFB  (128 bit key, 128 bit block, TLS client/server mode only)
SM4-GCM  (128 bit key, 128 bit block, TLS client/server mode only)
SM4-OFB  (128 bit key, 128 bit block, TLS client/server mode only)

The following ciphers have a block size of less than 128 bits,
and are therefore deprecated.  Do not use unless you have to.

BF-CBC  (128 bit key, 64 bit block)
BF-CFB  (128 bit key, 64 bit block, TLS client/server mode only)
BF-OFB  (128 bit key, 64 bit block, TLS client/server mode only)
CAST5-CBC  (128 bit key, 64 bit block)
CAST5-CFB  (128 bit key, 64 bit block, TLS client/server mode only)
CAST5-OFB  (128 bit key, 64 bit block, TLS client/server mode only)
DES-CBC  (64 bit key, 64 bit block)
DES-CFB  (64 bit key, 64 bit block, TLS client/server mode only)
DES-CFB1  (64 bit key, 64 bit block, TLS client/server mode only)
DES-CFB8  (64 bit key, 64 bit block, TLS client/server mode only)
DES-EDE-CBC  (128 bit key, 64 bit block)
DES-EDE-CFB  (128 bit key, 64 bit block, TLS client/server mode only)
DES-EDE-OFB  (128 bit key, 64 bit block, TLS client/server mode only)
DES-EDE3-CBC  (192 bit key, 64 bit block)
DES-EDE3-CFB  (192 bit key, 64 bit block, TLS client/server mode only)
DES-EDE3-CFB1  (192 bit key, 64 bit block, TLS client/server mode only)
DES-EDE3-CFB8  (192 bit key, 64 bit block, TLS client/server mode only)
DES-EDE3-OFB  (192 bit key, 64 bit block, TLS client/server mode only)
DES-OFB  (64 bit key, 64 bit block, TLS client/server mode only)
DESX-CBC  (192 bit key, 64 bit block)
RC2-40-CBC  (40 bit key, 64 bit block)
RC2-64-CBC  (64 bit key, 64 bit block)
RC2-CBC  (128 bit key, 64 bit block)
RC2-CFB  (128 bit key, 64 bit block, TLS client/server mode only)
RC2-OFB  (128 bit key, 64 bit block, TLS client/server mode only)
```

```bash
openvpn --show-digests
The following message digests are available for use with
OpenVPN.  A message digest is used in conjunction with
the HMAC function, to authenticate received packets.
You can specify a message digest as parameter to
the --auth option.
See also openssl list -digest-algorithms

SHA512-256 256 bit digest size
SHA224 224 bit digest size
SHA3-224 224 bit digest size
SHA1 160 bit digest size
SHA3-384 384 bit digest size
RIPEMD160 160 bit digest size
RIPEMD160 160 bit digest size
SHA512 512 bit digest size
SHA512-224 224 bit digest size
SHAKE256 256 bit digest size
SHA384 384 bit digest size
SM3 256 bit digest size
SHA3-256 256 bit digest size
WHIRLPOOL 512 bit digest size
SHA3-512 512 bit digest size
MD4 128 bit digest size
MD5 128 bit digest size
BLAKE2s256 256 bit digest size
SHA256 256 bit digest size
BLAKE2b512 512 bit digest size
MD5-SHA1 288 bit digest size
SHAKE128 128 bit digest size
KECCAK-KMAC-128 256 bit digest size
KECCAK-KMAC-256 512 bit digest size
NULL 0 bit digest size

```

Указать конкретные с помощью флага `--cipher`, например, `--cipher AES-128-CBC` (или просто `--cipher AES128`) и `--auth`, например, `--auth SHA256`, соответственно (удостоверьтесь, что после указания иных алгоритмов в логе вывод тоже меняется).

6\. Что будет выведено в консоли сервера (`sudo openvpn --ifconfig 10.1.0.1 10.1.0.2 --dev tun --secret vpn.key --cipher AES128 --auth SHA256 --verb 3`), если:

6\.1\. Подключиться с клиента командой: `sudo openvpn --ifconfig 10.1.0.2 10.1.0.1 --dev tun --remote 10.0.0.1 --secret vpn.key --cipher AES256 --auth SHA256 --verb 3`

```bash
openvpn --ifconfig 10.1.0.1 10.1.0.2 --dev tun --secret vpn.key --cipher AES128 --auth SHA256 --verb 3
2024-03-10 22:04:58 Cipher negotiation is disabled since neither P2MP client nor server mode is enabled
2024-03-10 22:04:58 OpenVPN 2.5.9 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Sep 29 2023
2024-03-10 22:04:58 library versions: OpenSSL 3.0.2 15 Mar 2022, LZO 2.10
2024-03-10 22:04:58 Outgoing Static Key Encryption: Cipher 'AES-128-CBC' initialized with 128 bit key
2024-03-10 22:04:58 Outgoing Static Key Encryption: Using 256 bit message hash 'SHA256' for HMAC authentication
2024-03-10 22:04:58 Incoming Static Key Encryption: Cipher 'AES-128-CBC' initialized with 128 bit key
2024-03-10 22:04:58 Incoming Static Key Encryption: Using 256 bit message hash 'SHA256' for HMAC authentication
2024-03-10 22:04:58 TUN/TAP device tun0 opened
2024-03-10 22:04:58 net_iface_mtu_set: mtu 1500 for tun0
2024-03-10 22:04:58 net_iface_up: set tun0 up
2024-03-10 22:04:58 net_addr_ptp_v4_add: 10.1.0.1 peer 10.1.0.2 dev tun0
2024-03-10 22:04:58 Could not determine IPv4/IPv6 protocol. Using AF_INET
2024-03-10 22:04:58 Socket Buffers: R=[212992->212992] S=[212992->212992]
2024-03-10 22:04:58 UDPv4 link local (bound): [AF_INET][undef]:1194
2024-03-10 22:04:58 UDPv4 link remote: [AF_UNSPEC]
2024-03-10 22:05:10 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:11 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:12 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:13 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:14 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:14 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:15 Authenticate/Decrypt packet error: cipher final failed
```

6\.2\. Подключиться с клиента командой: `sudo openvpn --ifconfig 10.1.0.2 10.1.0.1 --dev tun --remote 10.0.0.1 --secret vpn.key --cipher AES128 --auth SHA512 --verb 3`

```bash
openvpn --ifconfig 10.1.0.1 10.1.0.2 --dev tun --secret vpn.key --cipher AES128 --auth SHA256 --verb 3
2024-03-10 22:04:58 Cipher negotiation is disabled since neither P2MP client nor server mode is enabled
2024-03-10 22:04:58 OpenVPN 2.5.9 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Sep 29 2023
2024-03-10 22:04:58 library versions: OpenSSL 3.0.2 15 Mar 2022, LZO 2.10
2024-03-10 22:04:58 Outgoing Static Key Encryption: Cipher 'AES-128-CBC' initialized with 128 bit key
2024-03-10 22:04:58 Outgoing Static Key Encryption: Using 256 bit message hash 'SHA256' for HMAC authentication
2024-03-10 22:04:58 Incoming Static Key Encryption: Cipher 'AES-128-CBC' initialized with 128 bit key
2024-03-10 22:04:58 Incoming Static Key Encryption: Using 256 bit message hash 'SHA256' for HMAC authentication
2024-03-10 22:04:58 TUN/TAP device tun0 opened
2024-03-10 22:04:58 net_iface_mtu_set: mtu 1500 for tun0
2024-03-10 22:04:58 net_iface_up: set tun0 up
2024-03-10 22:04:58 net_addr_ptp_v4_add: 10.1.0.1 peer 10.1.0.2 dev tun0
2024-03-10 22:04:58 Could not determine IPv4/IPv6 protocol. Using AF_INET
2024-03-10 22:04:58 Socket Buffers: R=[212992->212992] S=[212992->212992]
2024-03-10 22:04:58 UDPv4 link local (bound): [AF_INET][undef]:1194
2024-03-10 22:04:58 UDPv4 link remote: [AF_UNSPEC]
2024-03-10 22:05:10 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:11 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:12 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:13 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:14 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:14 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:15 Authenticate/Decrypt packet error: cipher final failed
2024-03-10 22:05:50 Authenticate/Decrypt packet error: packet HMAC authentication failed
2024-03-10 22:05:51 Authenticate/Decrypt packet error: packet HMAC authentication failed
2024-03-10 22:05:52 Authenticate/Decrypt packet error: packet HMAC authentication failed
2024-03-10 22:05:53 Authenticate/Decrypt packet error: packet HMAC authentication failed
2024-03-10 22:05:54 Authenticate/Decrypt packet error: packet HMAC authentication failed
2024-03-10 22:05:54 Authenticate/Decrypt packet error: packet HMAC authentication failed
2024-03-10 22:05:55 Authenticate/Decrypt packet error: packet HMAC authentication failed
```
