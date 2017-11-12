# Docker Zou

Docker container for Zou, https://cg-wire.com

- See [Zou](https://zou.cg-wire.com/) for details regarding what this Docker image contains.
- See [Kitsu](https://kitsu.cg-wire.com/) for details regarding the user interface.
- See [Gazu](https://gazu.cg-wire.com/) for details regarding the Python API towards this interface.

<br>

### Usage

```bash
$ docker build -t cgwire https://github.com/mottosso/docker-cgwire.git
$ docker run -ti --rm -p 80:80 cgwire
```
If you want the postgresql folder persistent:

```bash
$ docker build -t cgwire https://github.com/mottosso/docker-cgwire.git
$ docker run -ti --rm -p 80:80 -v /path/to/local/folder:/var/lib/postgresql cgwire
```
> No need to clone this project, the above commands will suffice.

In your browser, visit `http://localhost` on Linux, or `http://<your-ip>` with the IP of your VirtualBox session on Docker Toolbox for Windows or MacOS. You'll be greeted by the welcome screen where you enter the email and password you supplied in the interactive session above.

> WARNING: Quitting the above container will remove all data related to it.

![image](https://user-images.githubusercontent.com/2152766/28476110-b1a6f6cc-6e46-11e7-8fc4-23aa90c1b302.png)

<br>

### Troubleshooting

Without the `--rm` flag and restarting the container, server reports:

![image](https://user-images.githubusercontent.com/2152766/28512904-bff87208-704b-11e7-905a-1b03dddb4bcf.png)

```bash
Kitsu a rencontré une erreur en communiquant avec son API de données.
```

I'm not sure how to resolve this yet.
