# GitHub Actions Runner for docker builds
_This repo is a reference clone of the original private docker image repo, which uses self-hosted GitHub Actions runners, 
disabled for public repos._
To be used with [myHomeBee home server](https://github.com/mdefenders/myHomeBee.git)
## How to use

```bash
docker run -e RUNNER_NAME=<your_runner_name> -e RUNNER_LABELS=<your runner labels> -e RUNNER_URL=https://github.com/<your_github_org> -e RUNNER_TOKEN=<your_token> -v /var/run/docker.sock:/var/run/docker.sock mdefenders/ga-runner-docker
```
