FROM continuumio/anaconda3

# Install custom tools, runtimes, etc.
# For example "bastet", a command-line tetris clone:
# RUN brew install bastet
#
# More information: https://www.gitpod.io/docs/config-docker/
# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
#
# Copy environment.yml (if found) to a temp locaition so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY environment.yml* .devcontainer/noop.txt /tmp/conda-tmp/

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install git openssh-client less iproute2 procps lsb-release \
    #
    # Install Libasound2 for Speech Services support
    && apt-get -y install libasound2 \
    #
    # Install Python Libraries
    && pip --disable-pip-version-check --no-cache-dir install jupyter \ 
    && pip --disable-pip-version-check --no-cache-dir install matplotlib \
    && pip --disable-pip-version-check --no-cache-dir install pillow \	
    && pip --disable-pip-version-check --no-cache-dir install requests \
    && pip --disable-pip-version-check --no-cache-dir install azure-cognitiveservices-vision-computervision \
    && pip --disable-pip-version-check --no-cache-dir install azure-cognitiveservices-vision-customvision \
    && pip --disable-pip-version-check --no-cache-dir install azure-cognitiveservices-vision-face \
    && pip --disable-pip-version-check --no-cache-dir install azure-cognitiveservices-language-textanalytics \
    && pip --disable-pip-version-check --no-cache-dir install azure.cognitiveservices.speech \
    && pip --disable-pip-version-check --no-cache-dir install azure_ai_formrecognizer \
    #
    # Added Anomaly Detection Client Library
    && pip --disable-pip-version-check --no-cache-dir install azure-cognitiveservices-anomalydetector \
    #
    # Added Personalizer Client Library
    && pip --disable-pip-version-check --no-cache-dir install azure-cognitiveservices-personalizer \
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
