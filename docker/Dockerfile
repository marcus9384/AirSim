FROM nvidia/cudagl:10.0-devel-ubuntu16.04 as intermediate

# Default arguments; should be overridden with the username/uid/gid of the
# user you want the container to run as.

ARG GIT_USER=marcus9384
ARG GIT_PASS=bananas


RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 77DCF3C3D260870D
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        git \
    && rm -rf /var/lib/apt/lists/*


#RUN git clone https://${GIT_USER}:${GIT_PASS}@github.com/EpicGames/UnrealEngine.git --branch 4.18 /home/$UNAME/Unreal --progress

RUN git clone https://${GIT_USER}:${GIT_PASS}@github.com/EpicGames/UnrealEngine.git --branch 4.18 --progress


#FROM nvidia/opengl:1.0-glvnd-devel-ubuntu16.04
FROM nvidia/cudagl:10.0-devel-ubuntu16.04
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

LABEL maintainer="marc.brooks@swri.org"

ARG UNAME=user
ARG UID=1000
ARG GID=1000

VOLUME /home/$UNAME/src

# First, configure apt repos and install useful packages
COPY sources.list /etc/apt/sources.list
COPY ros-latest.list /etc/apt/sources.list.d/


RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 77DCF3C3D260870D
RUN apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
        bash-completion \
        build-essential \
        git \
        sudo \
        openssh-client \
        rsync \
        tmux \
        vim \
        wget \
        emacs \
        tree \
        software-properties-common \
        tzdata \
        xdg-user-dirs \
        clang++-5.0 \
        clang-5.0 \
    && rm -rf /var/lib/apt/lists/*
# RUN . /opt/ros/kinetic/setup.sh && rosdep init


# Allow the user to run sudo without a password
RUN echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# All superuser tasks are done now; add a normal user with the same name/uid/gid
# as the host user.
RUN groupadd -g $GID $UNAME
RUN useradd -m -u $UID -g $GID -s /bin/bash $UNAME
RUN chown $UID:$GID /home/$UNAME


# RUN chown -R $UID:$GID /home/$UNAME/Unreal

# Switch to the non-root user and set up the local environment.
USER $UNAME

# RUN chown -R $UID:$GID /home/$UNAME/.local

#Copy Unreal Repo from Intermediate Image
COPY --from=intermediate --chown=$UNAME:$UNAME UnrealEngine /home/$UNAME/Unreal
RUN sudo apt-get update && sudo apt-get upgrade -y && sudo -u $UNAME ./home/$UNAME/Unreal/Setup.sh && sudo rm -rf /var/lib/apt/lists/*
# Generate and make Unreal Engine
RUN ./home/$UNAME/Unreal/GenerateProjectFiles.sh
RUN make -C /home/$UNAME/Unreal

#Setup for Airsim
RUN git clone https://github.com/microsoft/AirSim.git /home/$UNAME/AirSim --progress
RUN ./home/$UNAME/AirSim/setup.sh
# RUN chown -R $UID:$GID /home/$UNAME/AirSim
# Build Airsim
#RUN ./home/$UNAME/AirSim/build.sh



RUN cp /etc/skel/.bash_logout /home/$UNAME/
RUN cp /etc/skel/.bashrc /home/$UNAME/
RUN cp /etc/skel/.profile /home/$UNAME/
COPY bashrc_additions /home/$UNAME/bashrc_additions
RUN cat /home/$UNAME/bashrc_additions >> /home/$UNAME/.bashrc && rm /home/$UNAME/bashrc_additions
COPY .git-prompt.sh /home/$UNAME
COPY .bash_prompt /home/$UNAME



CMD ["/bin/bash"]
