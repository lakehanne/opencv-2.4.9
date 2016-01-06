#! /usr/bin
###########################################################################
# First we install ffmpeg from source files using the script ffmpeg.sh
# Then we install opencv with CUDA install following my amended cmake file
###########################################################################

printf '\n\n Installing dependencies \n\n'

#sudo apt-get -qq install build-essential checkinstall cmake pkg-config yasm \
#ibjpeg-dev libjasper-dev libavcodec-dev libavformat-dev \
#ibswscale-dev libdc1394-22-dev libxine-dev libgstreamer0.10-dev \
#ibgstreamer-plugins-base0.10-dev libv4l-dev python-dev python-numpy \
#ibtbb-dev libqt4-dev libgtk2.0-dev libfaac-dev libmp3lame-dev\
#libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev\
#libxvidcore-dev x264 v4l-utils ffmpeg cmake qt5-default checkinstall

chmod 777 ~/Downloads/Shells/ffmpeg.sh;

#Clear directory for ffmpeg.sh that might be in directory a priori

rm ffmpeg.sh;

cp ~/Downloads/Shells/ffmpeg.sh `pwd`;

sh ffmpeg.sh;

###################################################
#Install CUDA v7.0
###################################################

nvidia = $(lspci | grep -i nvidia| grep "VGA compatible controller")

driver="$(lspci | grep -i nvidia | grep 'VGA compatible controller')"
#| grep "VGA compatible controller"
#$(driver) == *"NVIDIA"* &&
#$(gcc --version | grep gcc) == "*gcc*"
if true ; then
	printf "\n\n Installing CUDA"
	echo "Details here: http://docs.nvidia.com/cuda/cuda-getting-started-guide-for-linux/#axzz3vTMAvnnO"
	cd ~/Downloads;
	wget http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/rpmdeb/cuda-repo-ubuntu1404-7-0-local_7.0-28_amd64.deb
	wait
	#Verify conflicting installation methods
	sudo /usr/local/cuda-7.0/bin/uninstall_cuda_*.*;
	wait
	cd ~/Downloads;
	sudo dpkg -i cuda-repo-ubuntu1404-7-0-local_7.0-28_amd64.deb
	wait
	sudo apt-get update;
	sudo apt-get install cuda
	wait

	```bash
		The PATH variable needs to include /usr/local/cuda-7.0/bin
		Setting it up 'for ya'
	```
	if [[ $(uname -m) == "x86_64" ]]; then
		$(export PATH=/usr/local/cuda-7.0/bin:$PATH)
		$(export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH)
	else  #[[ $(uname -m) -ne x86_64 ]]; then  #assume 32-bit OS
		$(export PATH=/usr/local/cuda-7.0/bin:$PATH)
		$(export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib:$LD_LIBRARY_PATH)
		#statements
	fi

	
	#if [[ $driver == *"NVIDIA"* ]]; then
	if [[ true ]]; then
		#install cuda examples
		sh cuda-install-samples-7.0.sh ~/Documents/
		cd ~/Documents/NVIDIA_CUDA-7.0_Samples;
		make -j8
		#statements
	fi

	#Verify driver version and path are installed correctly
	echo -e "\n\n NVIDIA Driver Version is: \n\n"
	cat /proc/driver/nvidia/version

else 

	   printf "\n\n You have no cuda capable gpu. Exiting the Cuda installation .\n\n"
		
fi


mkdir -p ~/libs/opencv-2.4.9;
mkdir release;				#I'm compiling the release version
cd  release;

cd ../; rm build -rf; mkdir build; cd build; 

printf '\n\n Compiling Cmake with \n
		cuda_fast opengl v4l \n
		python_examples \n
		cuda_fastcuda_fast_math \n
		cublas \n
		openi \n
		openmp \n
		opencl \n
		opengl \n
		v4l \n
		tbb \n
		qt \n
		ON \n\n' 

cmake -DBUILD_SHARED_LIBS=ON -D CMAKE_BUILD_TYPE=RELEASE \
 -D CMAKE_INSTALL_PREFIX=/home/local/ANT/ogunmolu/libs/opencv-2.4.9/release/build/ \
 -D WITH_TBB=ON \
 -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D \
 WITH_QT=ON -D INSTALL_PYTHON_EXAMPLES=ON -D WITH_OPENGL=ON -D \
 WITH_CUDA=ON -D ENABLE_FAST_MATH=1 -D CUDA_FAST_MATH=1 -D \
 WITH_CUBLAS=1 -D WITH_OPENNI=ON -D WITH_OPENMP=ON -D \
 WITH_OPENCL=ON -D WITH_OPENGL=ON -D CMAKE_BUILD_TYPE=RELEASE -D \
 WITH_V4L=ON -D CMAKE_INSTALL_PREFIX=/usr/local -D \
 CUDA_GENERATION=Kepler ../

 wait

echo -e "Just to make sure V4L does not give us hell during make install\n
		we do this"
$"(grep -rl -- -lv4l1 samples/* modules/* | xargs sed -i 's/-lv4l1/-lv4l1 -lv4l2/g)"

make -j8;
sudo make install;
sudo sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf';
sudo ldconfig -v;


