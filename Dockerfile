# This Dockerfile is used to build an headles vnc image based on Debian

FROM debian:12

ENV REFRESHED_AT 2024-05-19

LABEL io.k8s.description="Headless VNC Container with Xfce window manager, firefox and chromium" \
      io.k8s.display-name="Headless VNC Container based on Debian" \
      io.openshift.expose-services="6901:http,5901:xvnc" \
      io.openshift.tags="vnc, debian, xfce" \
      io.openshift.non-scalable=true

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1080x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

RUN apt-get update && apt-get upgrade

### Add all install scripts for further steps
ADD ./src/common/install/ $INST_SCRIPTS/

### Install some common tools
RUN apt-get install -y vim wget net-tools locales bzip2 procps apt-utils
RUN apt-get install -y python3-numpy ttf-wqy-zenhei tigervnc-standalone-server

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'


RUN printf '\n# docker-headless-vnc-container:\n$localhost = "no";\n1;\n' >>/etc/tigervnc/vncserver-config-defaults

RUN mkdir -p $NO_VNC_HOME/utils/websockify; \
    wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME; \
    wget -qO- https://github.com/novnc/websockify/archive/refs/tags/v0.11.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify; \
    ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html

RUN install -d -m 0755 /etc/apt/keyrings; \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null; \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

RUN $INST_SCRIPTS/firefox.sh

RUN apt-get update; apt-get install -y firefox


RUN apt-get install -y chromium; \
    ln -sfn /usr/bin/chromium /usr/bin/chromium-browser

RUN apt-get install -y supervisor xfce4 xfce4-terminal xterm dbus-x11 libdbus-glib-1-2 libnss-wrapper gettext; \
    apt-get purge -y pm-utils *screensaver*


ADD ./src/common/xfce/ $HOME/

RUN echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

RUN apt-get clean -y

USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
