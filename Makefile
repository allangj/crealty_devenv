# Name of the docker image
IMAGE_NAME = dev-env

# Name of the container
CONTAINER_NAME = dev_container

# SSH port
SSH_PORT = 2222


.PHONY: build_dev run_dev stop_dev clean_images

# Build the Docker image
build_dev:
	docker build -t $(IMAGE_NAME) .

# Run the container with the repo mounted and an interactive shell
run_dev:
	docker run -d --rm -v $(CURDIR):/home/devuser -p $(SSH_PORT):22 --privileged --name $(CONTAINER_NAME) $(IMAGE_NAME)

stop_dev:
	docker stop $(CONTAINER_NAME)

# Clean up dangling images
clean_images:
	docker rmi $(IMAGE_NAME)

# Show the SSH connection details
ssh_info:
	@echo "To connect via SSH, use the following:"
	@echo "ssh devuser@localhost -p $(SSH_PORT)"

setup_conan:
	@echo "Set up Conan profile"
	conan profile new --detect linux && conan profile update settings.compiler.libcxx=libstdc++11 linux

setup_qt:
	wget https://qt.mirror.constant.com/archive/qt/5.15/5.15.2/single/qt-everywhere-src-5.15.2.tar.xz -O /tmp/qt-5.15.2.tar.xz
	cd /tmp && tar xvf qt-5.15.2.tar.xz
	cp files/qt.5.15.2.patch /tmp/qt-everywhere-src-5.15.2 && cd /tmp/qt-everywhere-src-5.15.2/ && patch -p0 < qt.5.15.2.patch
	cd /tmp/qt-everywhere-src-5.15.2/ && ./configure && make && sudo make install

# Setup Crealty env
setup_creality:
	@echo "Setup CrealtyPrint"
	export PATH=/usr/local/Qt-5.15.2/bin:${PATH} && \
	export LD_LIBRARY_PATH=/usr/local/Qt-5.15.2/lib:${LD_LIBRARY_PATH} && \
	cd CrealityPrint && git submodule update --init && python3 ./cmake/ci/cmake.py -c -b -e --channel_name=opensource --cmake_args='-DCMAKE_BUILD_TYPE=Release -DOPENMP_ROOT=/usr/lib/llvm-11 -DCMAKE_PREFIX_PATH=/usr/local/Qt-5.15.2/'
