#!/bin/bash

IP=visiobook.cloud
curl -X POST https://$IP/api/v1/auth/register -H "Content-Type: application/json" -d '{"email":"user@example.com","password":"SecurePassword123!","username":"myusername"}'
curl -X POST https://$IP/api/v1/auth/login -H "Content-Type: application/json" -d '{"email":"user@example.com","password":"SecurePassword123!"}'