{
  # Enable aliases with `sudo`
  sudo = "sudo ";

  # System utilities
  df = "df -Tha --total";
  du = "du -ach | sort -h";
  free = "free -mt";
  ps = "ps auxf";
  psg = "ps aux | grep -v grep | grep -i -e VSZ -e";

  # Navigating
  "cd.." = "cd ..";
  d = "dirs -v | head -10";
  l = "exa -hl --git --icons";
  la = "exa -ahl --git --icons";
  lal = "la | less";
  ll = "l";
  ls = "ls -h --color='auto'";
  lsa = "ls -a";
  lsl = "ls | less";
  tree = "l --tree";

  # File reading
  cat = "bat";
  grep = "rg";

  # File manager
  rr = "ranger";

  # Calendar shortcuts
  cal = "khal -v ERROR calendar 2>/dev/null";
  yesterday = "cal yesterday 24h --format '{start-end-time-style} {title}'";
  today = "cal today 24h --format '{start-end-time-style} {title}'";
  tomorrow = "cal tomorrow 24h --format '{start-end-time-style} {title}'";

  # Open Fontawesome icon selector
  fa = "fontawesome-menu -f icon-list.txt";

  # Java REPL
  jshell = "nix-shell -p openjdk --command jshell";
  visualvm = "visualvm --cp:a ~/jmx/jmxremote_optional.jar";

  # PDF viewer
  mupdf = "mupdf-x11";

  # Password manager
  pass = "source pass";

  # Web
  wget = "wget -c";
  myip = "curl http://ipecho.net/plain; echo";
}
