#!/bin/bash
# SP_SLAM3 Run Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBTORCH_LIB="/home/xzb/Sanexis/ALIKED_CPP/external/libtorch/lib"

# Set library path
export LD_LIBRARY_PATH="$LIBTORCH_LIB:$LD_LIBRARY_PATH"

# Paths
VOCABULARY="$SCRIPT_DIR/Vocabulary/superpoint_voc.dbow3"
CAMERA_CONFIG="$SCRIPT_DIR/Examples/Monocular/s100p_mono.yaml"
DATASET="$HOME/Sanexis/dataset/large_Fri_offline"
TIMESTAMPS="$DATASET/timestamps.txt"

echo "============================================================"
echo "  SP_SLAM3"
echo "  Dataset: $DATASET"
echo "============================================================"

cd "$SCRIPT_DIR"

./Examples/Monocular/mono_euroc \
    "$VOCABULARY" \
    "$CAMERA_CONFIG" \
    "$DATASET" \
    "$TIMESTAMPS"
