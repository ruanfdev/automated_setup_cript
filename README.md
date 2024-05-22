# Automated Setup Script

Automation Script to streamline local development setup. Either follow the steps below or download the script and tweak as necessary.

## Tested and working:

### Ubuntu-based systems:

* Step 1 - Install Curl:

```
sudo apt install curl
```

* Step 2 - Install Curl:

```
curl -fsSL https://raw.githubusercontent.com/ruanfdev/automated_setup_script/master/ubuntu_setup.sh | bash
```

## Not tested (tweak as necessary):

### Fedora-based systems:

* Step 1 - Install Curl:

```
sudo dnf install curl
```

* Step 2 - Install Curl:

```
curl -fsSL https://raw.githubusercontent.com/ruanfdev/automated_setup_script/master/fedora_setup.sh
```

## Curl explanation:

1. curl: Downloads the script content from the specified URL.
2. -fsSL:
    * -f: Fail silently (don't show progress meter or error messages).
    * -s: Silent mode (don't show progress meter or error messages).
    * -S: Show error messages if the download fails.
    * -L: Follow redirects (in case the URL changes).
3. |: Pipes (sends) the downloaded script content as input.
4. bash: Executes the script in a Bash shell.