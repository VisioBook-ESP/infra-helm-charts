#!/bin/bash

read -p "Entrez une adresse IP : " IP

echo "IP saisie : $IP"
curl -X POST http://$IP/api/v1/auth/register -H "Content-Type: application/json" -d '{"email":"user@example.com","password":"SecurePassword123!","username":"myusername"}'
curl -X POST http://$IP/api/v1/auth/login -H "Content-Type: application/json" -d '{"email":"user@example.com","password":"SecurePassword123!"}'