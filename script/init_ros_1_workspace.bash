#!/bin/bash

path=$1
os_name=$(lsb_release -s -c)

if [ "$os_name" = "focal" ]; then
    ros_name="noetic"
elif [ "$os_name" = "bionic" ]; then
    ros_name="melodic"
else
    >&2 echo "Unsupported os version $os_name"
    exit 1
fi

source "/opt/ros/$ros_name/setup.bash"
catkin_init_workspace "$path"

echo -n "$ros_name"
exit 0
