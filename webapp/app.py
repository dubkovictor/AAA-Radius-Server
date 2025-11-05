import os
import time
from flask import Flask, request, redirect, render_template_string, url_for, session
from pyrad.client import Client
from pyrad.dictionary import Dictionary
from pyrad.packet import AccessRequest, AccessAccept

# --- RADIUS ---
DICT_PATH = os.getenv("RADIUS_DICT_PATH")  # опционально можно передать путь через env
try:
    if DICT_PATH and os.path.exists(DICT_PATH):
        DICT = Dictionary(DICT_PATH)
    else:
        # используем локальный минимальный словарь, который кладём рядом с app.py
        DICT = Dictionary("radius.dict")
except Exception:
    # на крайний случай — ещё одна попытка через системный путь (если есть)
    DICT = Dictionary("/etc/freeradius/dictionary")

RADIUS_HOST = os.getenv("RADIUS_HOST", "radius")
RADIUS_PORT = int(os.getenv("RADIUS_PORT", "1812"))
RADIUS_SECRET = os.getenv("RADIUS_SECRET", "WebSharedSecret123").encode()

# --- Flask ---
app = Flask(__name__)
app.secret_key = os.getenv("FLASK_SECRET", "dev-secret-change-me")


LOGIN_HTML = """
<!doctype html>
<title>AAA Login</title>
<h2>Enter</h2>
<form method="post" action="/login">
  <label>Login: <input name="username" /></label><br/>
  <label>Password: <input type="password" name="password" /></label><br/>
  <button type="submit">Go</button>
</form>
"""

REAL_HTML = """
<!doctype html>
<title>This is real data</title>
<h1>REAL DATA</h1>
<p>You have successfully logged in via AAA (RADIUS).</p>
"""

FAKE_HTML = """
<!doctype html>
<title>Fake data</title>
<h1>This is fake data.</h1>
<p>You have entered incorrect or empty credentials.</p>
"""

def is_authenticated():
    return session.get("auth_ok") is True and isinstance(session.get("user"), str)

@app.get("/")
def index():
    # Если уже залогинен — сразу к реальным данным
    if is_authenticated():
        return redirect(url_for("real"))
    return render_template_string(LOGIN_HTML)

@app.post("/login")
def login():
    username = (request.form.get("username") or "").strip()
    password = (request.form.get("password") or "").strip()

    if not username or not password:
        return redirect(url_for("fake"))

    srv = Client(server=RADIUS_HOST, secret=RADIUS_SECRET, dict=DICT, authport=RADIUS_PORT)

    try:
        req = srv.CreateAuthPacket(code=AccessRequest, User_Name=username)
        req["User-Password"] = req.PwCrypt(password)
    except Exception as e:
        # если вдруг снова словарь/атрибуты — уводим на фейк без 500
        app.logger.exception("Failed to build Access-Request: %s", e)
        return redirect(url_for("fake"))

    try:
        reply = srv.SendPacket(req)
        if reply.code == AccessAccept:
            session["auth_ok"] = True
            session["user"] = username
            session["t"] = int(time.time())
            return redirect(url_for("real"))
    except Exception as e:
        app.logger.exception("RADIUS send failed: %s", e)

    return redirect(url_for("fake"))

@app.get("/real")
def real():
    if not is_authenticated():
        return redirect(url_for("fake"))
    return render_template_string(REAL_HTML, user=session.get("user"))

@app.get("/fake")
def fake():
    # Страница намеренно доступна всем
    return render_template_string(FAKE_HTML)

@app.get("/logout")
def logout():
    session.clear()
    return redirect(url_for("index"))

if __name__ == "__main__":
    # В проде держи за reverse-proxy (TLS)
    app.run(host="0.0.0.0", port=8080)