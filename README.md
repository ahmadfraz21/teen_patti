# 🃏 Teen Patti – Full Platform

A legal, social Teen Patti card game built with Flutter (frontend) and Node.js (backend).

## Project Structure

```
teen_patti/
├── frontend/          # Flutter app (Web + Android APK + iOS)
├── backend/           # Node.js game server (Socket.io + REST)
├── .github/workflows/ # CI/CD pipelines
└── README.md
```

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile / Web | Flutter (Dart) |
| Game Server | Node.js + Socket.io |
| Auth | Firebase Auth |
| Database | Firebase Firestore |
| Real-time cache | Upstash Redis |
| Frontend hosting | Vercel |
| Backend hosting | Railway |

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0
- Node.js >= 18
- Firebase project
- Vercel account
- Railway account

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/teen_patti.git
cd teen_patti
```

### 2. Setup frontend
```bash
cd frontend
flutter pub get
flutter run -d chrome        # web
flutter build apk            # Android APK
```

### 3. Setup backend
```bash
cd backend
npm install
cp .env.example .env         # fill in your keys
npm run dev
```

## Deployment

- **Frontend** → Vercel (auto-deploys from GitHub on push to `main`)
- **Backend** → Railway (auto-deploys from GitHub on push to `main`)

See [DEPLOYMENT.md](./DEPLOYMENT.md) for full instructions.

## Game Modes (planned)
- Classic Teen Patti
- Joker
- Muflis (lowball)
- AK47
- Tournament mode

## License
MIT
