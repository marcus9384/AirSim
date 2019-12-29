
sudo apt-get install software-properties-common
sudo apt-get install tzdata
==================================================================
sudo chown -R marcus9384:marcus9384 ~/.local //create this ownership in Dockerfile
./Setup.sh 
./GenerateProjectFiles.sh 
make 
cd Engine/Binaries/Linux/
./UE4Editor 

==================================================================

==================================================================
 AirSim plugin is built! Here's how to build Unreal project.
==================================================================
If you are using Blocks environment, its already updated.
If you are using your own environment, update plugin using,
rsync -a --delete Unreal/Plugins path/to/MyUnrealProject

For help see:
https://github.com/Microsoft/AirSim/blob/master/docs/build_linux.md
==================================================================
$ docker info
