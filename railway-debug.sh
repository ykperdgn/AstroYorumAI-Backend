#!/bin/sh
# Railway Debug Helper - Running this script will print diagnostic information

echo "========== RAILWAY DEPLOYMENT DEBUG =========="
echo "Date: $(date)"
echo ""

echo "=== ENVIRONMENT VARIABLES ==="
echo "PORT: $PORT"
echo "PWD: $PWD"
echo "PATH: $PATH"
echo ""

echo "=== FILE STRUCTURE ==="
ls -la
echo ""

echo "=== START SCRIPT CONTENT ==="
cat start.sh
echo ""

echo "=== START SCRIPT PERMISSIONS ==="
ls -la start.sh
echo ""

echo "=== DOCKER ENTRYPOINT CHECKS ==="
if [ -f "/proc/1/cmdline" ]; then
  echo "PID 1 command: $(cat /proc/1/cmdline | tr '\0' ' ')"
else
  echo "Cannot access PID 1 command line"
fi

echo "=== LISTENING PORTS ==="
netstat -tulpn 2>/dev/null || echo "netstat not available"
echo ""

echo "=== PYTHON/GUNICORN INFO ==="
which python || echo "Python not found in PATH"
which gunicorn || echo "Gunicorn not found in PATH"
python --version 2>/dev/null || echo "Python version check failed"
gunicorn --version 2>/dev/null || echo "Gunicorn version check failed"
echo ""

echo "=== RAILWAY METADATA ==="
env | grep RAILWAY || echo "No RAILWAY_ environment variables found"
echo ""

echo "=== END OF DEBUG INFO ==="
