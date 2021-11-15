#start main (complete)
docker load --input ./model-sharing-platform/db_files/graphdb_9.1.1-free.tar
docker-compose build --pull --force-rm
docker-compose up -d --remove-orphan
#start main (quick)
docker-compose up -d --build
#stop main
docker-compose down

# start/stop taste/nutrition
docker-compose -f .\docker-compose-taste-nutrition.yml up -d --build 
docker-compose -f .\docker-compose-taste-nutrition.yml down
#no recipe
docker-compose -f .\docker-compose-taste-nutrition.yml up -d --build sweet-sourness-model-access-gateway tomato-saltiness-model-access-gateway nutrition-model-access-gateway ingredient-access-gateway
#recipe-only
docker-compose -f .\docker-compose-taste-nutrition.yml up -d --build recipe-access-gateway

#start/stop pasteurization/shelflife
docker-compose -f .\docker-compose-past-shelflife.yml up -d --build
docker-compose -f .\docker-compose-past-shelflife.yml down

#start/stop calibration/dropletsize
docker-compose -f .\docker-compose-cali-droplet.yml up -d --build
docker-compose -f .\docker-compose-cali-droplet.yml down
