@echo off
if "%1"=="up" (
  docker load --input ./model-sharing-platform/db_files/graphdb_9.1.1-free.tar
  docker-compose build --pull --force-rm
  docker-compose up -d --remove-orphan
) else (
    if "%1"=="down" (
      docker-compose down
    ) else (
      if "%1"=="seed" (
        for /F %%w in ('docker ps -aqf "name=model-sharing-backend"') do set msb=%%w
        docker exec -it %msb% flask seed-db
        for /F %%w in ('docker ps -aqf "name=ingredient-service"') do set is=%%w
        docker exec -it %is% flask seed-db
        for /F %%w in ('docker ps -aqf "name=tomato-saltiness-model-access-gateway"') do set tsmag=%%w
        docker exec -it %tsmag% flask seed-db
        for /F %%w in ('docker ps -aqf "name=sweet-sourness-model-access-gateway"') do set ssmag=%%w
        docker exec -it %ssmag% flask seed-db
        for /F %%w in ('docker ps -aqf "name=nutrition-model-access-gateway"') do set nmag=%%w
        docker exec -it %nmag% flask seed-db
        for /F %%w in ('docker ps -aqf "name=pasteurization-model-access-gateway"') do set pmag=%%w
        docker exec -it %pmag% flask seed-db
        for /F %%w in ('docker ps -aqf "name=shelflife-model-access-gateway"') do set smag=%%w
        docker exec -it %smag% flask seed-db
        for /F %%w in ('docker ps -aqf "name=ingredient-access-gateway"') do set iag=%%w
        docker exec -it %iag% flask seed-db
        for /F %%w in ('docker ps -aqf "name=microbe-hex-access-gateway"') do set mhag=%%w
        docker exec -it %mhag% flask seed-db
        rem docker exec -it ('docker ps -aqf "name=model-sharing-backend"') flask cache-om
      ) else (
        echo USAGE: %0 [up^|down^|seed]
      )
    )
)