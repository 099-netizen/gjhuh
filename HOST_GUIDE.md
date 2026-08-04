# 🔥 Render.com FREE Hosting Guide

Follow these 7 steps exactly:

---

## 📋 STEP 1: Create GitHub Account
```
1. Go to https://github.com
2. Click "Sign Up" (free)
3. Create account with your email
4. Verify email
```

---

## 📋 STEP 2: Create Repository
```
1. Click "+" (top right) → "New repository"
2. Repository name: fivem-web-control
3. Check "Public"
4. Click "Create repository"
```

---

## 📋 STEP 3: Upload Files
```
1. On repo page, click "uploading an existing file"
2. Drag & drop ALL these files:
   - server.py
   - index.html
   - requirements.txt
   - render.yaml
3. Click "Commit changes"
```

---

## 📋 STEP 4: Create Render Account
```
1. Go to https://render.com
2. Click "Get Started" (free)
3. Sign up with GitHub (connect your GitHub account)
```

---

## 📋 STEP 5: Deploy
```
1. Click "New +" → "Web Service"
2. Click "Connect" next to your repo "fivem-web-control"
3. Fill in:
   Name: fivem-web-control
   Region: Oregon (US West)
   Runtime: Python 3
   Build Command: (leave empty)
   Start Command: python server.py
   Instance Type: Free ($0/month)
4. Click "Create Web Service"
```

---

## 📋 STEP 6: Wait 2 Minutes
```
Render will build and deploy automatically.
Green "Live" status appears.
Your URL will look like:
https://fivem-web-control.onrender.com
```

---

## 📋 STEP 7: Update Menu
```
In lol_with_eventlogs.lua, find:
  pollUrl = "http://localhost:9999/commands"

Replace with your URL:
  pollUrl = "https://fivem-web-control.onrender.com/commands"
```

---

## ✅ DONE!

```
Open this in any browser:
https://fivem-web-control.onrender.com

Click buttons → Control your FiveM menu!
```

---

## ⚠️ IMPORTANT:
- Free Render sleeps after 15 min of no use
- First visit takes ~30 sec to wake up
- It's FREE forever for personal use
