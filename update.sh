#!/bin/bash

# --- PRE-FLIGHT SYNC ---
echo "--------------------------------------------------------"
echo "           SYNCING FILES TO WORKING DIRECTORIES         "
echo "--------------------------------------------------------"

echo "--> Syncing Citadel Theme..."
mkdir -p themes/citadel
cp -rf Extras/Citadel/themes/citadel/* themes/citadel/

echo "--> Syncing Citadel Editor Extension..."
mkdir -p extensions/Others/CitadelEditor
cp -rf Extras/Citadel/extensions/Others/CitadelEditor/* extensions/Others/CitadelEditor/

# --- UPDATE PROCESS ---
echo "--------------------------------------------------------"
echo "        STARTING PAYMENTER & CITADEL UPDATE             "
echo "--------------------------------------------------------"

echo "--> Forcing fresh pull of Paymenter base image..."
docker rmi ghcr.io/paymenter/paymenter:latest --force

echo "--> Bringing containers down..."
docker compose down -v

echo "--> Bringing containers up..."
docker compose up -d --build --force-recreate

echo ""
echo "---- INSTALLING DEPENDENCIES ----"
docker compose run --rm asset-builder npm install

echo ""
echo "---- BUILDING CORE ASSETS ----"
docker compose run --rm asset-builder npm run build

echo ""
echo "---- INSTALLING THEME: CITADEL ----"
docker compose run --rm asset-builder npm run build citadel

echo ""
echo "---- CLEARING CACHE ----"
docker compose exec paymenter php artisan cache:clear
docker compose exec paymenter php artisan config:clear
docker compose exec paymenter php artisan route:clear
docker compose exec paymenter php artisan view:clear
docker compose exec paymenter php artisan optimize:clear

echo ""
echo "---- FINALIZING ----"
docker compose restart paymenter

echo ""
echo "--------------------------------------------------------"
echo "                UPDATE COMPLETE!                        "
echo "--------------------------------------------------------"
