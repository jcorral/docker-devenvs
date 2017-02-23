FROM node:6.9.5
LABEL maintainer "jmc.leira@gmail.com"

# Install development tools.
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  locales \
  python-dev \
  python3-dev \
  vim

# Configure locales.
ENV DEBIAN_FRONTEND noninteractive
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Configure the environment:
# - grunt as automation system .
# - yarn as package manager.
# - create-react-app as react app bootstrapper.
RUN npm install -g grunt-cli yarn create-react-app

# Creates a custom user to avoid using root.
# We do also force the 2000 UID to match the host
# user and avoid permissions problems.
# There are some issues about it:
# https://github.com/docker/docker/issues/2259
# https://github.com/nodejs/docker-node/issues/289
RUN  useradd -ms /bin/bash dev && \
  usermod -o -u 2000 dev

# Set the working dir
WORKDIR /home/dev

# Run from the dev user.
USER dev

# Download custom preferences using dotfiles.
RUN git clone https://github.com/jcorral/dotfiles.git /home/dev/dotfiles && \
  cd /home/dev/dotfiles &&  git submodule init && git submodule update

# Make the vim custom preferences, bash profile and custom scripts
# available for the dev user.
RUN ln -fs /home/dev/dotfiles/.bashrc /home/dev/.bashrc && \
    ln -fs /home/dev/dotfiles/.scripts /home/dev/.scripts && \
    ln -fs /home/dev/dotfiles/.vim /home/dev/.vim && \
    ln -fs /home/dev/dotfiles/.vimrc /home/dev/.vimrc

RUN /home/dev/dotfiles/.vim/bundle/YouCompleteMe/install.py --tern-completer

ENTRYPOINT ["/bin/bash"]
