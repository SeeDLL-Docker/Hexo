Hexo 🐋
============

[English](./README.md) | 简体中文

Dockerized Hexo with Hexo Admin

A Hexo environment running the latest Node.js (currently Node.js 24).

[https://github.com/SeeDLL/Ubuntu_Docker](https://github.com/SeeDLL/Ubuntu_Docker)

The image is available directly from [Docker Hub](https://hub.docker.com/r/seedll/hexo/).

### Credits:
Node.js:
[https://hub.docker.com/_/node](https://hub.docker.com/_/node)

Hexo Blog Framework:
[https://hexo.io](https://hexo.io)

---

### Docker CLI Setup:

1. **Pull the Image**

   | Source      | Command                           |
   |-------------|-----------------------------------|
   | Docker Hub  | `docker pull seedll/hexo:latest`  |

2. **Create a Container**

   ```dockerfile
   docker create \
      --name=hexo \
      -p 4000:13389 \
      -e HEXO_SERVER_PORT=13389 \
      -e RUN_MODE=server \
      -e APP_CHECK_UPDATE=true \
      -e CUSTOM_SCRIPTS=true \
      -e CUSTOM_SCRIPT1="xx1.sh" \
      -e CUSTOM_SCRIPT2="xx2.sh" \
      -e GIT_USER=xxxxxx \
      -e GIT_EMAIL=xxxxxx@gmail.com \
      -v {your_hexo_dir_path}:/app \
      -v {your_custom_scripts_dir_path}:/custom_scripts \
      --restart unless-stopped \
      seedll/hexo:latest
   ```

   | Variable             | Description                                                                 |
   |----------------------|-----------------------------------------------------------------------------|
   | `HEXO_SERVER_PORT`   | Custom port for Hexo server.                                                |
   | `RUN_MODE`           | Hexo operation mode: `server` (live server) or `build` (static site generation). Default: `server`. |
   | `APP_CHECK_UPDATE`   | If `true`, checks for updates to Hexo and dependencies on container start.  |
   | `CUSTOM_SCRIPTS`     | Enable (`true`/`false`) custom scripts execution.                           |
   | `CUSTOM_SCRIPT1`     | Filename for Script 1 (executed *before* `requirements.txt` installation).  |
   | `CUSTOM_SCRIPT2`     | Filename for Script 2 (executed *after* `requirements.txt` installation).   |
   | `GIT_USER`           | Git username configuration.                                                 |
   | `GIT_EMAIL`          | Git email configuration.                                                    |
   | `/app`               | Host directory bound to Hexo’s working directory in the container.          |
   | `/custom_scripts`    | Host directory for custom scripts.                                          |

---

### Notes:
- If the `-v` bound directory is empty, a **fresh Hexo setup** will be auto-initialized.
- If the bound directory has existing Hexo files **without** `node_modules`, `node_modules` will be initialized.
- If `requirements.txt` exists, required modules will be installed after `node_modules` initialization.
- Set `APP_CHECK_UPDATE=true` to auto-update Hexo and dependencies on container start.

---

3. **Run**
   - **Static Site Generation (Build Mode):**
     ```bash
     sudo docker run -it -d --name=GithubBlog \
       -e HEXO_SERVER_PORT=4000 \
       -e RUN_MODE=build \
       -e CUSTOM_SCRIPTS=true \
       -e CUSTOM_SCRIPT1="diy1.sh" \
       -e CUSTOM_SCRIPT2="diy2.sh" \
       -v /home/temp/code/MyBolgSource/:/app \
       -v /home/temp/code/custDir:/custom_scripts \
       -p 127.0.0.1:4000:4000 \
       seedll/hexo
     ```

   - **Live Server Mode:**
     ```bash
     sudo docker run -it -d --name=GithubBlog \
       -e HEXO_SERVER_PORT=4000 \
       -e RUN_MODE=server \
       -e CUSTOM_SCRIPTS=true \
       -e CUSTOM_SCRIPT1="diy1.sh" \
       -e CUSTOM_SCRIPT2="diy2.sh" \
       -v /home/temp/code/MyBolgSource/:/app \
       -v /home/temp/code/custDir:/custom_scripts \
       -p 127.0.0.1:4000:4000 \
       seedll/hexo
     ```

4. **Stop the Container**
   ```bash
   docker stop hexo
   ```

5. **Remove the Container**
   ```bash
   docker rm hexo
   ```

6. **Remove the Image**
   ```bash
   docker image rm seedll/hexo:latest
   ```

--- 

### Key Adjustments:
- Kept technical terms consistent (e.g., `node_modules`, `requirements.txt`).
- Used imperative mood for commands (e.g., "Run", "Stop").
- Simplified repetitive phrases (e.g., "检查并升级" → "auto-update").
- Preserved code blocks, tables, and markdown formatting.

Let me know if you'd like any refinements!