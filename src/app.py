import subprocess
import hashlib

# Vulnerabilidade 1: uso de MD5 (hash fraco)
def hash_password(password):
    return hashlib.md5(password.encode()).hexdigest()

# Vulnerabilidade 2: SQL Injection
def get_user(username):
    query = "SELECT * FROM users WHERE name = '" + username + "'"
    return query

# Vulnerabilidade 3: comando do sistema sem sanitização
def run_command(cmd):
    subprocess.call(cmd, shell=True)

# Vulnerabilidade 4: senha hardcoded (Gitleaks vai pegar isso)
# Vulnerabilidade 4: credenciais hardcoded (Gitleaks vai pegar isso)
DB_PASSWORD = "super_secret_password_123"
API_KEY = "ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ123456789"
AWS_SECRET = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
STRIPE_KEY = "sk_live_4eC39HqLyjWDarjtT1zdp7dc"