#! /usr/bin/env bash
python -c 'print(" \033[102;30m Removing images,containers and volumes.. \033[0m ")'
docker-compose down -h
python -c 'print(" \033[92m Running system prune.. \033[0m ")'
docker system prune --force
python -c 'print(" \033[92m Running docker-compose build.. \033[0m ")'
docker-compose build --no-cache
python -c 'print(" \033[92m Running docker-compose up.. \033[0m ")'
docker-compose up
python -c 'print(" \033[102;30m Process completed sccessfully. \033[0m ")'