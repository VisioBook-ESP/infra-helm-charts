#!/bin/bash
curl -sL https://istio.io/downloadIstioctl | sh -;
export PATH=$HOME/.istioctl/bin:$PATH;
istioctl version 