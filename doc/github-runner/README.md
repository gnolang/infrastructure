# Github Self-Hosted Runner Setup

- Provision an host for Github Self-Hosted Runner

- From Github.com
  - Go to `Settings > Runners`
  - Add a `Self-Hosted` runner (usually type Linux + Amd64)
  - Perform given commands on target host

    ```bash
    mkdir actions-runner && cd actions-runner
    
    curl -o actions-runner-linux-x64-2.319.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-2.319.1.tar.gz
    
    echo "3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464  actions-runner-linux-x64-2.319.1.tar.gz" | shasum -a 256 -c
    
    tar xzf ./actions-runner-linux-x64-2.319.1.tar.gz
    
    ./config.sh --url https://github.com/gnolang --token AUVKYO7HHG4BRTRGBLXEZDLG6RAXO
    ```

  - When configuring don't forget providing any additional `tag` to the runner (e.g. `benchmark`)

## Create a Systemd service in Linux for the Action Runner

- Create a service runner

  ```bash
  cat <<EOF > /home/ubuntu/actions-runner/action.runner.service
  [Unit]
  Description=Github Action Runner for Gno repository <https://github.com/gnolang/gno>

  [Service]
  User=ubuntu
  WorkingDirectory=/home/ubuntu/actions-runner
  ExecStart=/bin/bash run.sh
  # optional items below
  Restart=always
  RestartSec=3

  [Install]
  WantedBy=multi-user.target

  EOF
  ```

- Link into Systemd

```bash
sudo ln -s /home/ubuntu/actions-runner/action.runner.service /etc/systemd/system
```

- Reload the service files to include the new service

```bash
sudo systemctl daemon-reload
```

- Start the service

```bash
sudo systemctl start action.runner.service
```

- Persist on reboot

```bash
sudo systemctl enable action.runner.service
```

- Check the status of the service

```bash
sudo systemctl status action.runner.service
```

### See also

- [How to create a Systemd service in Linux](https://www.shubhamdipt.com/blog/how-to-create-a-systemd-service-in-linux/)
