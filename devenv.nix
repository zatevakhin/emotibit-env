{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # https://devenv.sh/basics/
  env.CONTAINER_NAME = "emotibit-tools";

  # https://devenv.sh/packages/
  packages = [pkgs.git];

  # https://devenv.sh/scripts/
  scripts.container-build.exec = ''
    docker build -t "$CONTAINER_NAME:latest" -f Dockerfile .
  '';

  # https://devenv.sh/scripts/
  scripts.container-runx.exec = ''
    # Disable X11 server access control
    xhost +

    # Run Container
    docker run --name $CONTAINER_NAME -it --gpus all --rm --network=host \
      -e DISPLAY \
      -v "$HOME/.Xauthority:/root/.Xauthority" \
      "$CONTAINER_NAME:latest" "$@"
  '';

  enterShell = ''
  '';

  # https://devenv.sh/tests/
  enterTest = ''
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
