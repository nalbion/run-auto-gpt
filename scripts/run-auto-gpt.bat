@echo off

rem container runs in app user home:   /home/appuser
rem dedicated folder for file I/O:     /home/appuser/auto_gpt_workspace
rem AI settings file saved/loaded:     /home/appuser/ai_settings.yaml (unless specified using --ai-settings auto_gpt_workspace/ai_settings.yaml)

rem Auto-GPT Dockerfile copies app to  /home/user/autogpt

rem In the Auto-GPT docker-compose mounts:
rem - `${AUTO_GPT_HOME}/autogpt`:      /app
rem - `${AUTO_GPT_HOME}/.env`:         /app/.env

rem TODO: .auto-gpt or auto_gpt

set "PROJECT_DIR=%cd%"

if "%AUTO_GPT_HOME%"=="" (
  @echo setting AUTO_GPT_HOME to default: ~\.auto_gpt
  set AUTO_GPT_HOME="%USERPROFILE%\.auto_gpt"
)
if not exist "%AUTO_GPT_HOME%" (
  mkdir %AUTO_GPT_HOME%
)

rem Copy the .env file to the .auto_gpt directory if it doesn't exist there already
if exist .auto_gpt\.env (
  set ENV_PATH=.auto_gpt\.env
) else if defined AUTO_GPT_HOME if exist "%AUTO_GPT_HOME%\.env" (
  set ENV_PATH="%AUTO_GPT_HOME%\.env"
) else (
  if defined AUTO_GPT_HOME if exist "%AUTO_GPT_HOME%\.env.template" (
    copy /Y "%AUTO_GPT_HOME%\.env.template" "%AUTO_GPT_HOME%\.env"
  ) else (
    curl -sSL https://github.com/Significant-Gravitas/Auto-GPT/raw/stable/.env.template -o "%AUTO_GPT_HOME%\.env"
  )

  echo Please edit the %AUTO_GPT_HOME%\.env file with your desired configuration and re-run the script.
  echo You will need to provide OPENAI_API_KEY and EXECUTE_LOCAL_COMMANDS=True
  echo https://platform.openai.com/account/api-keys
  exit /b 1
)



REM Check if the --update flag was passed (must be first arg)
if "%1"=="--update" (
  REM Check if the AUTO_GPT_HOME environment variable is set
  if exist "%AUTO_GPT_HOME%\.git" (
    echo Updating Auto-GPT from %AUTO_GPT_HOME% ...
    pushd "!AUTO_GPT_HOME!" || exit /b 1
    git pull || exit /b 1
    docker-compose build auto-gpt || exit /b 1

    copy /Y Dockerfile "%PROJECT_DIR%\.auto_gpt\Dockerfile" || exit /b 1
    copy /Y requirements.txt "%PROJECT_DIR%\.auto_gpt\requirements.txt" || exit /b 1
    popd

    echo Auto-GPT updated!
  ) else (
    echo Updating Auto-GPT from GitHub...
    curl -sSL https://github.com/Significant-Gravitas/Auto-GPT/raw/stable/Dockerfile -o .auto_gpt\Dockerfile
    curl -sSL https://github.com/Significant-Gravitas/Auto-GPT/raw/stable/requirements.txt -o .auto_gpt\requirements.txt
    echo AUTO_GPT_HOME directory not found. Please define the environment variable or install to ~/.auto_gpt
    exit /b 1
  )

  shift
)

REM Run auto-gpt with the provided args
echo Running Auto-GPT...
docker-compose run --rm auto-gpt %*
@REM docker-compose run --rm -v "%PROJECT_DIR%:/app" -v "%ENV_PATH%:/app/.env" auto-gpt %*


@REM copy ai_settings.yaml %USERPROFILE%\auto_gpt_workspace
@REM copy auto-gpt.json %USERPROFILE%\auto_gpt_workspace
@REM docker run-compose run --rm --env-file=%ENV_PATH% -v "%USERPROFILE%/auto_gpt_workspace:/home/appuser/auto_gpt_workspace" significantgravitas/auto-gpt:0.2.2


REM ...or to see inside:
REM docker-compose run --rm --entrypoint /bin/bash auto-gpt

REM Exit with the exit code of the last command
exit /b %ERRORLEVEL%
