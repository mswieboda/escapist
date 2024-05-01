NAME=escapist
SHELL = /bin/sh
OPTS = CRYSTAL_OPTS="--link-flags=-Wl,-ld_classic"
CC = ${OPTS} crystal build
BUILD_DIR = build
OUT_FILE = ${BUILD_DIR}/${NAME}
SOURCE_FILES = src/${NAME}.cr
SFML_DLL_DIR = D:\\Program Files\\SFML-2.5.1\\bin
SFML_MAC_DIR = /Users/matt/code/libs/SFML-2.5.1-macos-clang

build_and_test: clean test

clean:

ifeq ($(OS),Windows_NT)
	@if exist ${BUILD_DIR} ( @echo cleaning... && @rmdir /S /Q ${BUILD_DIR}; )
else
	@if [ -d ${BUILD_DIR} ]; then env echo "cleaning..." && rm -r ${BUILD_DIR}; fi
endif
	@mkdir ${BUILD_DIR}

build_test:
	${CC} ${SOURCE_FILES} -o ${OUT_FILE}_test.o --error-trace

test: build_test
	./${OUT_FILE}_test.o

${OUT_FILE}.o:
	${CC} ${SOURCE_FILES} -o ${OUT_FILE}.o --release --no-debug

release: clean ${OUT_FILE}.o
	./${OUT_FILE}.o

winpack: clean ${OUT_FILE}.o
ifeq ($(OS),Windows_NT)
	copy escapist.exe ${BUILD_DIR}
	rename ${BUILD_DIR}\\${NAME}.o main.o
	copy "${SFML_DLL_DIR}\\*.dll" ${BUILD_DIR}
	xcopy /E assets ${BUILD_DIR}\\assets\\
	rename ${BUILD_DIR} ${NAME}
	7z a -tzip -mx9 ${NAME}\\${NAME}-win.zip ${NAME}\\*
	rename ${NAME} ${BUILD_DIR}
endif

macpack: clean ${OUT_FILE}.o
	mkdir ${BUILD_DIR}/sfml
	cp -r "${SFML_MAC_DIR}/lib" ${BUILD_DIR}/sfml
	cp -r "${SFML_MAC_DIR}/extlibs" ${BUILD_DIR}/sfml
	platypus --load-profile profile.platypus ${OUT_FILE}.app
	mkdir ${NAME}
	cp -r ${OUT_FILE}.app ${NAME}/${NAME}.app
	7zz a -tzip -mx9 ${BUILD_DIR}/${NAME}-mac.zip ${NAME}/${NAME}.app
	rm -rf ${NAME}
