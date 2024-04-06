FROM python:3.10-alpine

ENV TZ Europe/Amsterdam

ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install git, process tools, lsb-release (common in install instructions for CLIs) and curl
RUN apk --no-cache update && apk --no-cache upgrade && \
    apk add --no-cache gcc musl-dev linux-headers libffi-dev bash zsh git curl sudo build-base

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir wheel pre-commit

# change default shell from bash to zsh
RUN sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd

# Create the user
RUN addgroup -g $USER_GID $USERNAME \
    && adduser -D -u $USER_UID -G $USERNAME -s /bin/zsh $USERNAME
# add user to sudoer
RUN echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# change user
USER $USERNAME

# install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# install zsh plugins auto suggestions and syntax highlighting
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

COPY config/zshrc /home/$USERNAME/.zshrc
