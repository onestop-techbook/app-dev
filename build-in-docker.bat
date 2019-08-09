@echo off
docker run --rm -v %cd%/articles:/work vvakame/review /bin/sh -c "cd /work && yarn && yarn build"
pause
