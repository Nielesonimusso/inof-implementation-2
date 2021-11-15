if %1 = "up" ]]; then
  docker load --input ./model-sharing-platform/db_files/graphdb_9.1.1-free.tar
  docker-compose build --pull --force-rm
  docker-compose up -d --remove-orphan
elif [[ $1 = "down" ]]; then
  docker-compose down
elif [[ $1 = "seed" ]]; then
  docker exec -it $(docker ps -aqf "name=model-sharing-backend") flask seed-db
  docker exec -it $(docker ps -aqf "name=ingredient-service") flask seed-db
  docker exec -it $(docker ps -aqf "name=tomato-saltiness-model-access-gateway") flask seed-db
  docker exec -it $(docker ps -aqf "name=sweet-sourness-model-access-gateway") flask seed-db
  docker exec -it $(docker ps -aqf "name=nutrition-model-access-gateway") flask seed-db
  docker exec -it $(docker ps -aqf "name=pasteurization-model-access-gateway") flask seed-db
  docker exec -it $(docker ps -aqf "name=shelflife-model-access-gateway") flask seed-db
  docker exec -it $(docker ps -aqf "name=ingredient-access-gateway") flask seed-db
  docker exec -it $(docker ps -aqf "name=microbe-hex-access-gateway") flask seed-db
  docker exec -it $(docker ps -aqf "name=model-sharing-backend") flask cache-om
else
  echo 'USAGE:' $0 ' [up|down|seed]'
fi
