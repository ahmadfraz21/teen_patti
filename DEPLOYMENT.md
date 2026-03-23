# Deployment Guide

## Frontend → Vercel

### 1. Build Flutter for Web
Vercel can't run Flutter directly, so we pre-build the web output and Vercel serves it as static files.

The `vercel.json` in the `frontend/` folder handles this automatically.

### 2. Connect to Vercel
1. Go to [vercel.com](https://vercel.com) and sign in with GitHub
2. Click **Add New Project**
3. Import your `teen_patti` GitHub repo
4. Set **Root Directory** to `frontend`
5. Vercel will auto-detect the config from `vercel.json`
6. Click **Deploy**

### 3. Environment variables on Vercel
In your Vercel project → Settings → Environment Variables, add:
```
FLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/
```

---

## Backend → Railway

### 1. Connect to Railway
1. Go to [railway.app](https://railway.app) and sign in with GitHub
2. Click **New Project → Deploy from GitHub repo**
3. Select your `teen_patti` repo
4. Set **Root Directory** to `backend`
5. Railway auto-detects Node.js

### 2. Environment variables on Railway
In Railway project → Variables, add:
```
PORT=3000
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_client_email
FIREBASE_PRIVATE_KEY=your_private_key
UPSTASH_REDIS_URL=your_redis_url
UPSTASH_REDIS_TOKEN=your_redis_token
FRONTEND_URL=https://your-app.vercel.app
```

### 3. Get your backend URL
After deploy, Railway gives you a URL like:
`https://teen-patti-production.up.railway.app`

Update this in your Flutter app's `lib/config/app_config.dart`.

---

## Firebase Setup

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a new project named `teen-patti`
3. Enable **Authentication** → Email/Password + Google
4. Enable **Firestore Database** (start in test mode)
5. Download `google-services.json` → place in `frontend/android/app/`
6. Download `GoogleService-Info.plist` → place in `frontend/ios/Runner/`

---

## Upstash Redis (free tier)

1. Go to [upstash.com](https://upstash.com)
2. Create a new Redis database (free tier = 10,000 requests/day)
3. Copy the REST URL and token into Railway environment variables
