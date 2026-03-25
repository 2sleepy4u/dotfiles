#!/usr/bin/env bash
nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia.json
