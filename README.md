# run-auto-gpt
Helper scripts to easily run/install [Auto-GPT](https://github.com/Significant-Gravitas/Auto-GPT) from within the context of any project.

## Requirements

- [Docker Compose](https://docs.docker.com/compose/install/)

## Usage

The scripts will look for `.auto_gpt/.env` folder, and then in your home path: `~/.auto_gpt/.env`. It will provide this to Auto-GPT.

```
scripts/run-auto-gpt
```

When Auto-GPT runs it will:

- Read/save its goals to your project's `.auto_gpt/ai_settings.yaml` file.
- Save its work in your project's `auto_gpt_workspace` folder.


## Auto-GPT Developers

Set an environment variable `AUTO_GPT_HOME` (it defaults to `~/.auto_gpt`).

If you've been making your own changes to Auto-GPT locally, you can run:

```
scripts/run-auto-gpt --update
```
