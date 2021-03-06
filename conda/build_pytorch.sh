#!/usr/bin/env bash
. /remote/anaconda_token || true

set -e

echo "Building cuda version $1 and pytorch version: $2 build_number: $3"

if [ -z "$ANACONDA_TOKEN" ]; then
    echo "ANACONDA_TOKEN is unset. Please set it in your environment before running this script";
    exit 1
fi

ANACONDA_USER=soumith

BUILD_VERSION="$2"
BUILD_NUMBER="$3"

export PYTORCH_BUILD_VERSION=$BUILD_VERSION
export PYTORCH_BUILD_NUMBER=$BUILD_NUMBER

if [[ "$BUILD_VERSION" == "nightly" ]]; then
    export PYTORCH_BUILD_VERSION="$(date +"%Y.%m.%d")"
fi

conda config --set anaconda_upload no

if [[ "$OSTYPE" == "darwin"* ]]; then
    export CUDA_VERSION="0.0"
    export CUDNN_VERSION="0.0"
    time conda build -c $ANACONDA_USER --no-anaconda-upload --python 2.7 pytorch-$BUILD_VERSION
    time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.5 pytorch-$BUILD_VERSION
    time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.6 pytorch-$BUILD_VERSION
    time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.7 pytorch-$BUILD_VERSION
else
    if [[ "$1" == "80" ]]; then
	. ./switch_cuda_version.sh 8.0
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 2.7 pytorch-cuda80-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.5 pytorch-cuda80-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.6 pytorch-cuda80-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.7 pytorch-cuda80-$BUILD_VERSION
    elif [[ "$1" == "90" ]]; then
	. ./switch_cuda_version.sh 9.0
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 2.7 pytorch-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.5 pytorch-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.6 pytorch-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.7 pytorch-$BUILD_VERSION
    elif [[ "$1" == "92" ]]; then
	. ./switch_cuda_version.sh 9.2
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 2.7 pytorch-cuda92-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.5 pytorch-cuda92-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.6 pytorch-cuda92-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.7 pytorch-cuda92-$BUILD_VERSION
    elif [[ "$1" == "cpu" ]]; then
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 2.7 pytorch-cpu-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.5 pytorch-cpu-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.6 pytorch-cpu-$BUILD_VERSION
	time conda build -c $ANACONDA_USER --no-anaconda-upload --python 3.7 pytorch-cpu-$BUILD_VERSION
    else
	echo "Error, unknown argument $1"
	exit 1
    fi
fi

echo "All builds succeeded, uploading binaries"

set +e

# anaconda -t $ANACONDA_TOKEN upload --user $ANACONDA_USER $(conda build -c $ANACONDA_USER --python 2.7 pytorch-$BUILD_VERSION --output)
# anaconda -t $ANACONDA_TOKEN upload --user $ANACONDA_USER $(conda build -c $ANACONDA_USER --python 3.5 pytorch-$BUILD_VERSION --output)
# anaconda -t $ANACONDA_TOKEN upload --user $ANACONDA_USER $(conda build -c $ANACONDA_USER --python 3.6 pytorch-$BUILD_VERSION --output)

unset PYTORCH_BUILD_VERSION
unset PYTORCH_BUILD_NUMBER
