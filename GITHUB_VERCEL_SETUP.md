# 🚀 How to Push to GitHub & Deploy on Vercel

## Step 1 — Create GitHub Repository

1. Go to https://github.com/new
2. Name it `teen_patti`
3. Set to **Public** or **Private** (your choice)
4. Do NOT add README or .gitignore (we already have them)
5. Click **Create repository**

---

## Step 2 — Push Your Code to GitHub

Open your terminal, navigate to the project folder, then run:

```bash
cd teen_patti

# Initialize git
git init

# Add all files
git add .

# First commit
git commit -m "🃏 Initial commit - Teen Patti game"

# Connect to your GitHub repo (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/teen_patti.git

# Push to GitHub
git branch -M main
git push -u origin main
```

✅ Your code is now on GitHub!

---

## Step 3 — Deploy Frontend on Vercel

1. Go to https://vercel.com and sign in with GitHub
2. Click **Add New → Project**
3. Find and import your `teen_patti` repo
4. In the **Configure Project** screen:
   - Set **Root Directory** → `frontend`
   - Framework Preset → **Other**
   - Vercel will read the `vercel.json` automatically
5. Click **Deploy**

⏳ First deploy takes ~3-5 minutes (Flutter builds are slow).

After deploy you get a URL like:
`https://teen-patti-xyz.vercel.app`

---

## Step 4 — Deploy Backend on Railway

> Railway supports WebSockets which Vercel does NOT — so the game server goes here.

1. Go to https://railway.app and sign in with GitHub
2. Click **New Project → Deploy from GitHub repo**
3. Select your `teen_patti` repo
4. Set **Root Directory** → `backend`
5. Railway auto-detects Node.js and runs `npm start`
6. Go to **Settings → Networking → Generate Domain**
7. Copy your Railway URL (e.g. `https://teen-patti.up.railway.app`)

Then add environment variables in Railway → Variables:
```
PORT=3000
FRONTEND_URL=https://teen-patti-xyz.vercel.app
```

---

## Step 5 — Connect Frontend to Backend

Open `frontend/lib/config/app_config.dart` and update:

```dart
static const String serverUrl = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'https://teen-patti.up.railway.app',  // ← your Railway URL
);
```

Then push again:
```bash
git add .
git commit -m "Update server URL"
git push
```

Vercel auto-redeploys on every push to `main` ✅

---

## Step 6 — Build Android APK (for testing)

```bash
cd frontend
flutter pub get
flutter build apk --release
```

Your APK is at:
`frontend/build/app/outputs/flutter-apk/app-release.apk`

Share it with testers via WhatsApp, Google Drive, or Firebase App Distribution.

---

## Folder Structure (final)

```
teen_patti/
├── .github/
│   └── workflows/
│       └── ci.yml          ← auto-tests on every push
├── frontend/               ← Flutter app
│   ├── lib/
│   │   ├── config/
│   │   │   └── app_config.dart
│   │   ├── game/           ← game logic (card, deck, engine)
│   │   ├── providers/      ← state management
│   │   └── screens/        ← UI screens
│   ├── pubspec.yaml
│   └── vercel.json         ← Vercel build config
├── backend/                ← Node.js server
│   ├── src/
│   │   ├── index.js        ← entry point
│   │   └── roomManager.js  ← game rooms + socket logic
│   ├── .env.example
│   └── package.json
├── .gitignore
├── README.md
└── DEPLOYMENT.md
```

---

## Quick Commands Reference

```bash
# Run backend locally
cd backend && npm install && npm run dev

# Run Flutter web locally
cd frontend && flutter run -d chrome

# Build APK
cd frontend && flutter build apk

# Push updates to GitHub (auto-deploys to Vercel)
git add . && git commit -m "your message" && git push
```
