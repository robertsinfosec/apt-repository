# apt-repository

Debian and Ubuntu APT repository for robertsinfosec installable tools.

## Installation

To install this repository on your Debian or Ubuntu system, run the following commands:

```bash
# Add the GPG key
curl -fsSL https://apt.robertsinfosec.com/robertsinfosec.gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/robertsinfosec-archive-keyring.gpg

# Add the APT repository
echo "deb [signed-by=/usr/share/keyrings/robertsinfosec-archive-keyring.gpg] \
    https://apt.robertsinfosec.com stable main" | \
    sudo tee /etc/apt/sources.list.d/robertsinfosec.list > /dev/null

# Update package lists
sudo apt update

# Install a package (e.g., compose-upgrade)
sudo apt install compose-upgrade
```

