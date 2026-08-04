# 🔥 FiveM Web Remote Control

Control your FiveM mod menu from ANY device - phone, tablet, laptop!

---

## 🚀 Method 1: Render.com (FREE 24/7 Hosting)

### Step 1: Push to GitHub
```
1. Create a GitHub account (free)
2. Create new repo: "fivem-web-control"
3. Upload ALL files from this folder to the repo
```

### Step 2: Deploy on Render
```
1. Go to https://render.com (free account)
2. Click "New" → "Web Service"
3. Connect your GitHub repo
4. Settings:
   - Name: fivem-web-control
   - Runtime: Python 3
   - Build Command: (leave empty)
   - Start Command: python server.py
   - Free plan ($0/month)
5. Click "Create Web Service"
6. After 2 minutes → Your URL: https://fivem-web-control.onrender.com
```

### Step 3: Update Lua Menu
```lua
-- In lol_with_eventlogs.lua, find:
pollUrl = "http://localhost:9999/commands"

-- Change to your Render URL:
pollUrl = "https://YOUR-APP.onrender.com/commands"
```

---

## 🚀 Method 2: ngrok (Quickest - from your PC)

```
1. Download ngrok: https://ngrok.com/download
2. Run: ngrok http 9999
3. Get URL like: https://abc123.ngrok.io
4. Update pollUrl in Lua menu to that URL
5. Share ngrok URL with anyone!
```

---

## 🚀 Method 3: Replit (Free)
```
1. Create account on https://replit.com
2. New Python Repl
3. Upload server.py + index.html
4. Run → gets public URL
```

---

## 📱 Commands from Any Browser:

| Command | Action |
|---|---|
| `heal` | Heal + Revive + Armor |
| `godmode on/off` | Godmode |
| `killall` | Kill all players |
| `giveweapons` | All weapons |
| `spawnveh adder` | Spawn vehicle |
| `explodeall` | Explode everyone |
| `tpall` | TP all to you |
| `massfreeze` | Freeze all |
| `menu toggle` | Show/hide menu |
| `explode 123` | Explode player ID 123 |
| `launch 456` | Launch player ID 456 |

---

## ⚠️ API Endpoints:

| URL | Method | Purpose |
|---|---|---|
| `/` | GET | Web control panel |
| `/commands` | GET | Lua menu polls this |
| `/send` | POST | Send command `{"cmd":"heal","key":"onyx2024"}` |
