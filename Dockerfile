FROM ros:noetic-robot

RUN useradd -ms /bin/bash docker && echo 'docker:Docker23' | chpasswd && usermod -a -G sudo docker

RUN apt-get update && apt-get -y install apt-utils && apt-get -y upgrade && apt-get -y install --autoremove python-is-python3 python3-rosinstall-generator ros-noetic-roslint \
    $(: Intera SDK dependencies) \
    git-core python3-wstool python3-vcstools python3-rosdep ros-noetic-control-msgs ros-noetic-joy ros-noetic-xacro ros-noetic-tf2-ros ros-noetic-rviz ros-noetic-cv-bridge ros-noetic-actionlib ros-noetic-actionlib-msgs ros-noetic-dynamic-reconfigure ros-noetic-trajectory-msgs ros-noetic-rospy-message-converter \
    $(: Gazebo) \
    gazebo11 ros-noetic-gazebo-ros ros-noetic-gazebo-ros-control ros-noetic-gazebo-ros-pkgs ros-noetic-ros-control ros-noetic-control-toolbox ros-noetic-realtime-tools ros-noetic-ros-controllers ros-noetic-xacro python3-wstool ros-noetic-tf-conversions ros-noetic-kdl-parser \
    $(: moveit) \
    ros-noetic-moveit

USER docker
WORKDIR /home/docker

# Initialize ROS Workspace
RUN . /opt/ros/noetic/setup.sh && mkdir -p ~/ros_ws/src && catkin_make -C ~/ros_ws && rosdep update && echo ". ~/ros_ws/devel/setup.sh" >> ~/.profile && . ~/.profile

# Install Intera SDK
RUN . ~/ros_ws/devel/setup.sh && cd ~/ros_ws/src && wstool init . && \
    wstool merge 'https://raw.githubusercontent.com/RethinkRobotics/sawyer_moveit/melodic_devel/sawyer_moveit.rosinstall' && \
    git clone 'https://github.com/AdrianZw/sawyer_simulator.git' -b noetic_devel && \
    git clone 'https://github.com/RethinkRobotics-opensource/sns_ik.git' -b melodic-devel && \
    wstool update && \
    cd ~/ros_ws && \
    sed -e 's/^.*ros_version=.*$/ros_version="noetic"/g' ~/ros_ws/src/intera_sdk/intera.sh > ./intera.sh && chmod +x ./intera.sh && \
    catkin_make

CMD ["/bin/bash", "--login"]
