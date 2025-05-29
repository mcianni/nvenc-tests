#!/bin/bash
set -e

echo "+-----------------------------------------------------------------------------------------+"
echo "🔧  Checking /dev/nvidia* devices..."
find /usr/lib /lib -type f -name 'libnvidia-*.so*' | grep -E "(encode|glvkspirv|dispatch)"

echo "+-----------------------------------------------------------------------------------------+"
echo "🔍 GPU info from nvidia-smi:"
nvidia-smi | head -12 || echo "❌ nvidia-smi not available"

echo "+-----------------------------------------------------------------------------------------+"
echo "Listing encoders:"
ffmpeg -hide_banner -encoders 2>/dev/null | grep nvenc

echo "+-----------------------------------------------------------------------------------------+"
echo "🎥  Testing NVENC with ffmpeg..."
ffmpeg -hide_banner -f lavfi -i testsrc=duration=3:size=1280x720:rate=30 -c:v h264_nvenc -y /tmp/test.mp4 && echo "✅ NVENC success" || echo "❌ NVENC fail"
echo "+-----------------------------------------------------------------------------------------+"

echo "✅ All GPU tests complete."

tail -f /dev/null
