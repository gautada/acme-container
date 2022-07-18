ARG ALPINE_VERSION=3.16.0

# ╭―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │                                                                           │
# │ STAGE 1: Let's Encrypt ACME certbot container                           │
# │                                                                           │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION as src-gitea

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/acme-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A Let's Encrypt ACME container, using certbot."

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG UID=1001
ARG GID=1001
ARG USER=acme
RUN /usr/sbin/addgroup -g $GID $USER \
 && /usr/sbin/adduser -D -G $USER -s /bin/ash -u $UID $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd

# ╭――――――――――――――――――――╮
# │ CONFIG             │
# ╰――――――――――――――――――――╯
RUN ln -s /etc/container/configmap.d /etc/letsencrypt

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY 10-ep-container.sh /etc/container/entrypoint.d/10-ep-container.sh

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
COPY backup.fnc /etc/container/backup.d/backup.fnc

# ╭――――――――――――――――――――╮
# │ SUDO               │
# ╰――――――――――――――――――――╯
COPY wheel-pip /etc/sudoers.d/wheel-pip
COPY wheel-tee /etc/sudoers.d/wheel-tee

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
# - - - - - - - - - - - -  CERTBOT - - - - - - - - -
RUN /sbin/apk add --no-cache --update build-base lynx nmap python3 py3-augeas py3-cryptography py3-pip \
 && /usr/bin/pip install --upgrade pip \
 && /usr/bin/pip install certbot \
 && /bin/mkdir -p /var/log/letsencrypt /var/lib/letsencrypt
RUN update-ca-certificates

# chown -R nginx:nginx /etc/letsencrypt /var/log/letsencrypt /var/lib/letsencrypt
COPY auth-hook /usr/bin/auth-hook
COPY hover-auth-hook.py /usr/bin/hover-auth-hook
# COPY certbot-wrapper /usr/bin/certbot-wrapper
# COPY certbot-upgrade /etc/periodic/monthly/certbot-upgrade
# COPY default.conf /etc/nginx/http.d/default.conf
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY certbot-container/ca.gautier.org.crt /usr/local/share/ca-certificates/ca.gautier.org.crt
