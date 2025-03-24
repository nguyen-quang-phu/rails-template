default:
  just --list

alias s := server

server:
  air

server-debug:
  RUBYOPT="-rdebug/open" RUBY_DEBUG_OPEN=true bundle exec rails s

up:
  devenv up
