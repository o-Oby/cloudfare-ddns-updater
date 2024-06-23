# Cloudflare DDNS Updater

This script updates a DNS record on Cloudflare with your current public IP address. It is useful for dynamic DNS setups where your public IP address may change frequently.

## Prerequisites

Ensure you have the following installed on your system:

- `curl`
- `jq` (for processing JSON)

### Installation on Debian-based systems

```bash
sudo apt-get update
sudo apt-get install curl jq
```

## Configuration

Before using the script, you need to set up some configurations:

1. **API Token**: Generate an API token from your Cloudflare account with permissions to edit DNS records.
    - You can create the API token here: [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens).

2. **Zone ID**: Find your zone ID on the Cloudflare dashboard for your domain.
    - You can find a tutorial on how to find your Zone ID here: [Finding Account and Zone IDs](https://developers.cloudflare.com/fundamentals/setup/find-account-and-zone-ids/).

3. **DNS Record Name**: Specify the subdomain you want to update (e.g., `ssh.example.com`).

## Usage

1. **Clone the repository**

    ```bash
    git clone https://github.com/o-Oby/cloudflare-ddns-updater.git
    cd cloudflare-ddns-updater
    ```

2. **Create the `config.json` file**

    Create a `config.json` file with the following content and update it with your configurations:

    ```json
    {
      "API_TOKEN": "your_cloudflare_api_token",
      "ZONE_ID": "your_zone_id",
      "DNS_RECORD_NAME": "your_subdomain.example.com",
      "CF_API_URL": "https://api.cloudflare.com/client/v4"
    }
    ```

3. **Set Permissions on `config.json`**

    Ensure that the `config.json` file has the correct read permissions:

    ```bash
    chmod 644 config.json
    ```

4. **Create the script file**

    Create a shell script file (e.g., `cloudfare-ddns-updater.sh`) and copy the provided script into the file.

5. **Make the script executable**

    ```bash
    chmod +x cloudfare-ddns-updater.sh
    ```

6. **Run the script**

    ```bash
    ./cloudfare-ddns-updater.sh
    ```

## Script Explanation

This script does the following:

1. **Fetches your current public IP address** using `https://api.ipify.org`.
2. **Retrieves the DNS record details** from Cloudflare using the API token and zone ID.
3. **Checks if the current public IP address** is different from the one in the DNS record.
4. **Updates the DNS record** on Cloudflare if the IP address has changed.

## Example Output

```text
Fetching current public IP address...
Current public IP: 123.456.789.012
Retrieving DNS record details from Cloudflare...
IP address has changed from 123.456.789.000 to 123.456.789.012. Updating DNS record...
DNS record updated successfully.
```

## Scheduling the Script

To ensure the script runs every hour and at reboot, add the following entries to your crontab:

1. **Open the Crontab File**:

    ```bash
    crontab -e
    ```

2. **Add the Reboot and Hourly Jobs**:

    ```bash
    @reboot /path/to/your/script/cloudfare-ddns-updater.sh >> /path/to/your/script/cloudfare-ddns-updater.log 2>&1
    0 * * * * /path/to/your/script/cloudfare-ddns-updater.sh >> /path/to/your/script/cloudfare-ddns-updater.log 2>&1
    ```

    Replace `/path/to/your/script/cloudfare-ddns-updater.sh` with the actual path to your script if it is different.

3. **Save and Exit**.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

### Note

This project is designed to keep sensitive data in a separate configuration file (`config.json`). This helps to maintain security and manageability by avoiding hardcoded sensitive data within the script. Ensure that you handle and store your `config.json` file securely.
