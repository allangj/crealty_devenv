# Small project to build CrealityPrint in linux

The build environment creates a docker image as dev environment
To create the build env run:

```
make build_env
```

To bring up the build env run:

```
make run_dev
```

A docker container will be brought up and you can connect to it using ssh.
To how to connect to the container:

```
make ssh_info
```

Connect to the container and once inside of it you can start building crealityPrint

```
ssh devuser@localhost -p 2222
```

Once inside the container first setup conan profile. If already done this will fail.

```
make setup_conan
```

Next, there is a dependency to QT. Currently we are downloading a mirror of
QT 15.5.2 source code and building it. This version needs a patch that is located
on the directory files.

```
make setup_qt
```

Last and still in cleanup is setup and build CrealityPrint, we have a target however
at this point it fails to find correctly QT references and fix some things, so at the
moment we will list the steps followed to build manually.

1. There is a issue which I cant solve yet that QT_DIR or CMAKE_PREFIX_PATH is not
   considered in the  when configuring, therefore copy the QT libs to a standard location (either mv or cp)
2. Create a sym link to zlib: ```sudo ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/x86_64-linux-gnu/libzlib.so```
2. Apply Creality patch located in files to fix some bugs on the code for linux.
3. Make sure the submodules inside creality repo are initialized.
4. Configure the project: ```python3 ./cmake/ci/cmake.py -c -b -e --channel_name=opensource --cmake_args='-DCMAKE_BUILD_TYPE=Release -DOPENMP_ROOT=/usr/lib/llvm-11' ```
5. If configuration is successful build the code: ``` cd linux-build/build/ && cmake --build . ```


## Package
This is still WIP

Install  libssl and lib crypto. DO this only after compilation is done already and in the packaging state.

```
$ cd tmp/
# Download a supported openssl version. e.g., openssl-1.1.1o.tar.gz or openssl-1.1.1t.tar.gz
$ wget https://www.openssl.org/source/openssl-1.1.1o.tar.gz
$ tar -zxvf openssl-1.1.1o.tar.gz
$ cd openssl-1.1.1o
$ ./config && make && make test
$ mv libcrypto.so.1.1 /lib/x86_64-linux-gnu/
$ mv libssl.so.1.1 /lib/x86_64-linux-gnu/
```
