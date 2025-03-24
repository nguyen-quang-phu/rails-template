{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  DATABASE_DEV = "myapp_development";
  DATABASE_TEST = "myapp_test";
in {
  env = {
    # https://devenv.sh/basics/
    RUBY_DEBUG_HOST = "127.0.0.1";
    RUBY_DEBUG_PORT = "38698";
    # RUBYOPT = "-rdebug/open";
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    coreutils
    git
    just
    libyaml
    openssl_1_1
    vips
    msgpack
    postgresql
    killport
  ];

  # https://devenv.sh/languages/
  languages = {
    ruby = {
      enable = true;
      versionFile = ./.ruby-version;
    };
  };

  # https://devenv.sh/processes/
  processes.server.exec = ''
    RUBYOPT="-rdebug/open" RUBY_DEBUG_OPEN=true bundle exec rails s
  '';

  # https://devenv.sh/services/
  services.postgres = {
    enable = true;
    createDatabase = true;
    listen_addresses = "127.0.0.1";
    extensions = extensions: [
      extensions.postgis
      extensions.timescaledb
    ];
    initialDatabases = [
      {
        name = "${DATABASE_DEV}";
      }
      {
        name = "${DATABASE_TEST}";
      }
    ];
    initialScript = ''
      CREATE USER ${DATABASE_DEV} WITH PASSWORD '${DATABASE_DEV}';
      ALTER ROLE ${DATABASE_DEV} WITH LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${DATABASE_DEV};

      CREATE USER ${DATABASE_TEST} WITH PASSWORD '${DATABASE_TEST}';
      ALTER ROLE ${DATABASE_TEST} WITH LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${DATABASE_TEST};
    '';
  };

  # https://devenv.sh/scripts/
  scripts.versions.exec = ''
    ruby --version
    rails --version
    psql --version
  '';

  enterShell = ''
    versions
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  git-hooks = {
    hooks.check-added-large-files.enable = true;
    hooks.check-merge-conflicts.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
