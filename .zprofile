FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env --use-on-cd`"
  export PATH="$FNM_PATH/aliases/default/bin:$PATH"
fi


# Added by Antigravity CLI installer
export PATH="/home/jcarlosmr/.local/bin:$PATH"
