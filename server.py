#!/usr/bin/env python3
"""
FiveM Web Control Server - Works with gunicorn + standalone python
Run local: python3 server.py
Render: gunicorn server:app
"""
import http.server
import json
import os
from io import BytesIO

state = {"cmd": "", "args": [], "key": ""}

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        print(f"[{self.client_address[0]}] {args[0]}")

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            self.serve_file("index.html", "text/html")
        elif self.path == "/commands":
            self.send_json(state)
        elif self.path == "/reset":
            state["cmd"] = ""; state["args"] = []
            self.send_json({"ok": True})
        else:
            path = self.path.lstrip("/")
            if os.path.isfile(path):
                ext = path.split(".")[-1]
                mime = {"html":"text/html","js":"text/javascript","css":"text/css"}.get(ext,"text/plain")
                self.serve_file(path, mime)
            else:
                self.send_error(404)

    def do_POST(self):
        if self.path == "/send":
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)
            try:
                data = json.loads(body)
                state["cmd"] = data.get("cmd", "")
                state["args"] = data.get("args", [])
                state["key"] = data.get("key", "")
                print(f"[CMD] {state['cmd']}({state['args']})")
                self.send_json({"ok": True, "cmd": state["cmd"]})
            except Exception as e:
                self.send_json({"ok": False, "error": str(e)})
        else:
            self.send_error(404)

    def do_OPTIONS(self):
        self.send_response(200); self.send_cors(); self.end_headers()

    def send_cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def send_json(self, data):
        self.send_response(200); self.send_cors()
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def serve_file(self, path, mime):
        try:
            with open(path, "rb") as f: content = f.read()
            self.send_response(200); self.send_cors()
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        except FileNotFoundError:
            self.send_error(404)

# ============ WSGI App for Gunicorn/Render ============
def app(environ, start_response):
    path = environ.get("PATH_INFO", "/")
    method = environ.get("REQUEST_METHOD", "GET")

    if path == "/" or path == "/index.html":
        try:
            with open("index.html", "rb") as f: body = f.read()
            start_response("200 OK", [("Content-Type", "text/html"),
                ("Content-Length", str(len(body))), ("Access-Control-Allow-Origin", "*")])
            return [body]
        except:
            start_response("500", [("Content-Type", "text/plain")])
            return [b"Error"]

    if path == "/commands" and method == "GET":
        body = json.dumps(state).encode()
        start_response("200 OK", [("Content-Type", "application/json"),
            ("Content-Length", str(len(body))), ("Access-Control-Allow-Origin", "*")])
        return [body]

    if path == "/send" and method == "POST":
        try:
            cl = int(environ.get("CONTENT_LENGTH", 0))
            raw = environ["wsgi.input"].read(cl)
            data = json.loads(raw)
            state["cmd"] = data.get("cmd", "")
            state["args"] = data.get("args", [])
            state["key"] = data.get("key", "")
            print(f"[CMD] {state['cmd']}({state['args']})")
            resp = json.dumps({"ok": True, "cmd": state["cmd"]}).encode()
            start_response("200 OK", [("Content-Type", "application/json"),
                ("Access-Control-Allow-Origin", "*")])
            return [resp]
        except Exception as e:
            resp = json.dumps({"ok": False, "error": str(e)}).encode()
            start_response("400", [("Content-Type", "application/json")])
            return [resp]

    if method == "OPTIONS":
        start_response("200 OK", [("Access-Control-Allow-Origin", "*"),
            ("Access-Control-Allow-Methods", "GET, POST, OPTIONS"),
            ("Access-Control-Allow-Headers", "Content-Type")])
        return [b""]

    start_response("404 Not Found", [("Content-Type", "text/plain")])
    return [b"404"]

if __name__ == "__main__":
    PORT = int(os.environ.get("PORT", 9999))
    print(f"\n  Σ SIGMA Web Control: http://localhost:{PORT}\n")
    httpd = http.server.HTTPServer(("0.0.0.0", PORT), Handler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[!] Stopped."); httpd.server_close()
