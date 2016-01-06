#! /usr/bin
#################################################################
# Compilation of ffmpeg for ubuntu opencv clean build
#  
# Robotics Lab, Amazon Robotics, North Reading, MA. January, 2016.
# wiki:CompilationGuide/Ubuntu
# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
#
# Author: Olalekan Ogunmolu <<olalekan.ogunmolu@utdallas.edu>>
# Disclaimer: This script has nothing in conjunction with Amazon 
# Robotics LLC
#################################################################

if [[ "$uname" == "Darwin" ]]; then
  # This is a Mac
  echo "Sorry, this does not support MAC yet. You are welcome to add a PR"
  exit
else

	cd ~;
	sudo apt-get update
	wait

	sudo apt-get -y --force-yes install autoconf automake build-essential libass-dev libfreetype6-dev \
	  libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev \
	  libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev

	mkdir ~/ffmpeg_sources

	wait
	printf '\n\n Yasm will help your installion run faster\n\n'

	sudo apt-get install yasm

	wait
	printf '\n\n'

	echo 'installing libx264'
	printf '\n\n'

	sudo apt-get install libx264-dev

	wait
	printf '\n\n'

	echo "installing libx265 encoder"
	printf '\n\n'

	sudo apt-get install mercurial;
	cd ~/ffmpeg_sources;
	hg clone https://bitbucket.org/multicoreware/x265;
	cd ~/ffmpeg_sources/x265/build/linux;
	PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source;
	make;
	make install;
	make distclean;

	printf '\n\n

	libfdk-aac

	AAC audio encoder. See the AAC Audio Encoding Guide for more information and usage examples.

	Requires ffmpeg to be configured with --enable-libfdk-aac (and --enable-nonfree if you also included --enable-gpl).
	\n\n'

	cd ~/ffmpeg_sources;
	wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master;
	tar xzvf fdk-aac.tar.gz;
	cd mstorsjo-fdk-aac*;
	autoreconf -fiv;
	./configure --prefix="$HOME/ffmpeg_build" --disable-shared;
	make;
	make install;
	make distclean;

	wait
	printf '\n\n 
		libopus: \n

		Opus audio decoder and encoder.

		Requires ffmpeg to be configured with --enable-libopus.

		If your repository offers a libopus-dev package ≥ 1.1 then you can install that instead of compiling:\n\n'

	printf '\n\n
		libmp3lame\n\n

		MP3 audio encoder.\n

		Requires ffmpeg to be configured with --enable-libmp3lame.\n

		If your repository offers a libmp3lame-dev package ≥ 3.98.3 then you can install that instead of compiling:\n

		sudo apt-get install libmp3lame-dev\n
		Otherwise you can compile:\n'

		if [[ $(apt-cache search libmp3lame-dev)==true ]]; then
			printf '\n\n I am installing from the ubuntu repositories \n\n'
			sudo apt-get install libmp3lame-dev
			wait
		else
			printf '\n\n Repo has no dev libmp3lame packages. I am installing from the source files. \n\n'
			sudo apt-get install nasm;
			cd ~/ffmpeg_sources;
			wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz;
			tar xzvf lame-3.99.5.tar.gz;
			cd lame-3.99.5;
			./configure --prefix="$HOME/ffmpeg_build" --enable-nasm --disable-shared;
			make;
			make install;
			make distclean;
		fi

	printf '\n\n Installing libopus-dev \n\n'
		if [[ $(apt-cache search libopus)==true ]]; then
			#statements		
			sudo apt-get install libopus-dev
			wait
		else
			cd ~/ffmpeg_sources;
			wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz;
			tar xzvf opus-1.1.tar.gz;
			cd opus-1.1;
			./configure --prefix="$HOME/ffmpeg_build" --disable-shared;
			make;
			make install;
			make clean;
		fi



	wait
	printf '\n\nlibvx
	VP8/VP9 video encoder and decoder. See the VP8 Video Encoding Guide for more information and usage examples.

	Requires ffmpeg to be configured with --enable-libvpx.
	\n\n'

	cd ~/ffmpeg_sources;
	wget http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-1.5.0.tar.bz2;
	tar xjvf libvpx-1.5.0.tar.bz2;
	cd libvpx-1.5.0;
	PATH="$HOME/bin:$PATH" ./configure --prefix="$HOME/ffmpeg_build" --disable-examples --disable-unit-tests;
	PATH="$HOME/bin:$PATH" make;
	make install;
	make clean;

	wait
	printf '\n\n ffmpeg \n\n'
	cd ~/ffmpeg_sources;
	wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2;
	tar xjvf ffmpeg-snapshot.tar.bz2;
	cd ffmpeg;
	PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
	  --prefix="$HOME/ffmpeg_build" \
	  --pkg-config-flags="--static" \
	  --extra-cflags="-I$HOME/ffmpeg_build/include" \
	  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
	  --bindir="$HOME/bin" \
	  --enable-gpl \
	  --enable-libass \
	  --enable-libfdk-aac \
	  --enable-libfreetype \
	  --enable-libmp3lame \
	  --enable-libopus \
	  --enable-libtheora \
	  --enable-libvorbis \
	  --enable-libvpx \
	  --enable-libx264 \
	  --enable-libx265 \
	  --enable-nonfree
	PATH="$HOME/bin:$PATH" make;
	make install;
	make distclean;
	hash -r

	wait

	printf '\n\n Installation is now complete and ffmpeg is now ready for use. Your newly compiled FFmpeg programs are in ~/bin. \n\n'

	cat <<-EOT

		Installation is now complete and ffmpeg is now ready for use. Your newly compiled FFmpeg programs are in ~/bin.

		Usage

		There are several methods to use your new ffmpeg.

		Navigate to ~/bin and execute the binary: cd ~/bin && ./ffmpeg -i ~/input.mp4 ~/videos/output.mkv (notice the ./)
		Or use the full path to the binary: /home/yourusername/bin/ffmpeg -i ../input.mp4 ../videos/output.mkv
		If you want the ffmpeg command to just work from anywhere:

		Log in and log out
		Or run source ~/.profile
		Note: ~/bin is included in the standard Ubuntu $PATH by default (via the ~/.profile file), but only when the ~/bin directory actually exists. This is why you must log out then log in or run source ~/.profile if you just created ~/bin. See ​Ubuntu Wiki: Persistent Environment Variables for more info.

		Documentation

		If you want to run man ffmpeg to have local access to the documentation:

		echo "MANPATH_MAP $HOME/bin $HOME/ffmpeg_build/share/man" >> ~/.manpath
		You may then have to log out and then log in for man ffmpeg to work.

		HTML formatted documentation is available in ~/ffmpeg_build/share/doc/ffmpeg.

		You can also refer to the online FFmpeg documentation, but remember that it is regenerated daily and is meant to be used with the most current ffmpeg (meaning an old build may not be compatible with the online docs).

		Additional Notes

		See the H.264 Encoding Guide for some encoding examples.
		If you do not see FFmpeg developers in your ffmpeg console output then something went wrong and you're probably using the ​fake "ffmpeg" from the repository (the counterfeit "ffmpeg" was eventually removed and the real ffmpeg returned in 15.04).
		You can delete the ffmpeg_sources directory if you want to.

	EOT
fi
