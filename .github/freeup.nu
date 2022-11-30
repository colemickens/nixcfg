#!/usr/bin/env nu

let dirs = [
  "/usr/lib/apache2"
  # "/usr/lib/erlang"
  "/usr/lib/firefox" # wtf
  "/usr/lib/google-cloud-sdk"
  "/usr/lib/gcc"
  "/usr/lib/jvm"
  "/usr/lib/llvm*" # llvm-{10,11,12}
  "/usr/lib/mono"
  "/usr/lib/nginx"
  "/usr/lib/nuget"
  "/usr/lib/php"
  "/usr/lib/packagekit"
  "/usr/lib/postgresql"
  "/usr/lib/python*" # python3 python2.9 etc
  "/usr/lib/R"
  "/usr/lib/ruby"
  "/usr/lib/snapd"

  "/usr/local/.ghcup"
  "/usr/local/aws-cli"
  # "/usr/local/aws-sam-cl"
  "/usr/local/graalvm"
  "/usr/local/julia*" # julia1.8.2
  "/usr/local/n"
  "/usr/local/sqlpackage"
  "/usr/local/bin"
  "/usr/local/julia*"
  "/usr/local/aws-sam*"

  "/usr/local/lib/android"
  "/usr/local/lib/heroku"
  "/usr/local/lib/lein"
  "/usr/local/lib/node_modules"
  "/usr/local/lib/python*"
  "/usr/local/lib/R"

  "/usr/local/share/vcpkg"
  "/usr/local/share/chrome_driver"
  "/usr/local/share/gecko_driver"
  "/usr/local/share/edge_driver"
  "/usr/local/share/chromium"
  "/usr/local/share/phantomjs*"
  "/usr/local/share/powershell"

  "/usr/share/dotnet"
  "/usr/share/gradle*"
  "/usr/share/swift"
  "/usr/share/mecab"
  "/usr/share/java"
  "/usr/share/vim"
  "/usr/share/kotlinc"
  "/usr/share/sbt"
  "/usr/share/az*"
  "/usr/share/php*"
  "/usr/share/miniconda"

  "/opt/az"
  "/opt/cni"
  "/opt/google"
  "/opt/hhvm"
  "/opt/hostedtoolcache"
  "/opt/microsoft"
  "/opt/mssql-tools"
  "/opt/pipx"
  
  "/etc/skel"
  
  "/home/linuxbrew"
  "/home/runner/.cargo"
  "/home/runner/.rustup"
  # "/home/runner/runners" ## might need this?
  "/var/lib/gems"
  "/var/lib/snapd"
  "/var/lib/apt"
  
  # "/snap" # might not be possible, mount?
]

let freespace = ((^df --output=avail -H "/") | tail -n1 | str trim)
print -e $"(ansi blue)df = ($freespace)(ansi reset)"

let dirs2 = ($dirs | where {|it| $it | path exists } | each { |it| (ls --directory $it | get name) } | flatten)
print -e $"(ansi red)clean:\n($dirs2)(ansi reset)"
run-external "sudo" "rm" "-rf" $dirs2

print -e $"(ansi red)clean:\n($dirs)(ansi reset)"
run-external "sudo" "rm" "-rf" $dirs2
# du "/*" | sort-by -r "apparent"
# du "/lib/*" | sort-by -r "apparent"
# du "/usr/*" | sort-by -r "apparent"
# du "/usr/local/*" | sort-by -r "apparent"

let freespace = ((^df --output=avail -H "/") | tail -n1 | str trim)
print -e $"(ansi blue)df = ($freespace)(ansi reset)"

let p = "/var/lib";
print -e $"(ansi light_yellow_reverse) running dust ($p)(ansi reset)"; ^dust -x $p; sleep 1sec

let p = "/home/runner";
print -e $"(ansi light_yellow_reverse) running dust ($p)(ansi reset)"; ^dust -x $p; sleep 1sec

let p = "/usr/local";
print -e $"(ansi light_yellow_reverse) running dust ($p)(ansi reset)"; ^dust -x $p; sleep 1sec

let p = "/usr/lib";
print -e $"(ansi light_yellow_reverse) running dust ($p)(ansi reset)"; ^dust -x $p; sleep 1sec

let p = "/";
print -e $"(ansi light_yellow_reverse) running dust ($p)(ansi reset)"; ^dust -x $p; sleep 1sec
