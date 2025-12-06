docker run --rm -it debian:bookworm-slim bash -lc '
  set -euo pipefail

  apt-get update >/dev/null
  apt-get install -y --no-install-recommends gnupg >/dev/null

  export GNUPGHOME=/tmp/gnupg
  mkdir -p "$GNUPGHOME"
  chmod 700 "$GNUPGHOME"

  NAME_EMAIL="robertsinfosec APT Signing <apt@robertsinfosec.com>"

  echo ">>> Generating signing key for: $NAME_EMAIL"
  gpg --batch --quick-generate-key "$NAME_EMAIL" rsa3072 sign 10y

  echo
  echo ">>> Listing keys:"
  gpg --list-keys "$NAME_EMAIL"

  FPR=$(gpg --list-keys --with-colons "$NAME_EMAIL" | awk -F: "/^fpr:/ {print \$10; exit}")

  echo
  echo ">>> Fingerprint:"
  echo "$FPR"

  echo
  echo ">>> PUBLIC KEY (copy into password manager as public entry):"
  gpg --armor --export "$FPR"

  echo
  echo ">>> PRIVATE KEY (copy into password manager as secret entry):"
  gpg --armor --export-secret-keys "$FPR"
'
