#!/bin/bash
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz | tar xJ -C $HOME
export PATH=$PATH:$HOME/flutter/bin
cd frontend
flutter pub get
flutter build web --release --web-renderer canvaskit
