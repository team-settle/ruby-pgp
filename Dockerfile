FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    gpg \
    unzip \
    zip

RUN \curl -sSL "https://get.rvm.io" | bash
RUN echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc

RUN /bin/bash -c "source /etc/profile.d/rvm.sh; rvm install jruby-1.7.27"
RUN /bin/bash -c "source /etc/profile.d/rvm.sh; rvm install jruby-9.2.9.0"

RUN \curl -s "https://get.sdkman.io" | bash
RUN echo "source /root/.sdkman/bin/sdkman-init.sh" >> /etc/bash.bashrc

RUN /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh; sdk install java 6.0.119-zulu"
RUN /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh; sdk install java 7.0.242-zulu"
RUN /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh; sdk install java 8.0.232-open"

