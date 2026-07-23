#!/usr/bin/env bash

if grep -q '"version": "1.0"' ~/.config/chromium/themes/manifest.json; then
    sed -i 's/"version": "1.0"/"version": "1.1"/' ~/.config/chromium/themes/manifest.json
else
    sed -i 's/"version": "1.1"/"version": "1.0"/' ~/.config/chromium/themes/manifest.json
fi

