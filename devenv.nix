{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
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
        name = "myapp_development";
      }
      {
        name = "myapp_test";
      }
    ];
    initialScript = ''
      CREATE USER myapp_development WITH PASSWORD 'myapp_development';
      ALTER ROLE myapp_development WITH LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myapp_development;

      CREATE USER myapp_test WITH PASSWORD 'myapp_test';
      ALTER ROLE myapp_test WITH LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
      GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myapp_test;
    '';
  };

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
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
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
