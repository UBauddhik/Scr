#!/bin/bash

echo "🔍 Starting diagnostic to find the math confirmation check..."

# 1. Check if an alias is wrapping commands
echo -e "\n🔹 Checking for suspicious aliases..."
alias | grep -E 'math|confirm|verify|challenge|sudo' --color=auto

# 2. Check if a function is handling command execution
echo -e "\n🔹 Checking for custom command wrappers in shell functions..."
declare -F | grep -E 'math|confirm|verify|challenge' --color=auto

# 3. Check if PROMPT_COMMAND is set (might trigger pre-command hooks)
echo -e "\n🔹 Checking PROMPT_COMMAND..."#!/bin/bash

echo "🔍 Detecting and removing math check enforcement..."

# 1. Check and remove alias for sudo
echo -e "\n🔹 Checking for sudo alias..."
if alias sudo &>/dev/null; then
    echo "❌ Found sudo alias! Removing..."
    unalias sudo
else
    echo "✅ No alias detected for sudo."
fi

# 2. Check if a function is wrapping sudo
echo -e "\n🔹 Checking if sudo is overridden by a function..."
if declare -F sudo &>/dev/null; then
    echo "❌ Found sudo function! Removing..."
    unset -f sudo
else
    echo "✅ No function override detected for sudo."
fi

# 3. Reset PROMPT_COMMAND
echo -e "\n🔹 Checking PROMPT_COMMAND..."
if [[ -n "$PROMPT_COMMAND" ]]; then
    echo "❌ Found PROMPT_COMMAND modification! Resetting..."
    unset PROMPT_COMMAND
else
    echo "✅ No PROMPT_COMMAND modification detected."
fi

# 4. Check and remove trap-based pre-execution hooks
echo -e "\n🔹 Checking for shell traps..."
trap -p | grep -E 'math|verify|challenge'
if [[ $? -eq 0 ]]; then
    echo "❌ Found a pre-execution hook! Resetting traps..."
    trap - DEBUG
else
    echo "✅ No suspicious shell traps found."
fi

# 5. Scan for modifications in shell startup files
echo -e "\n🔹 Checking shell config files for math enforcement..."
CONFIG_FILES=(~/.bashrc ~/.bash_profile ~/.zshrc)
for FILE in "${CONFIG_FILES[@]}"; do
    if grep -E 'math|challenge|confirm|verify' "$FILE" &>/dev/null; then
        echo "❌ Found suspicious code in $FILE! Removing..."
        sed -i '/math\|challenge\|confirm\|verify/d' "$FILE"
    else
        echo "✅ No suspicious entries found in $FILE."
    fi
done

# 6. Apply changes and restart the shell
echo -e "\n✅ Cleanup complete! Restarting shell..."
exec bash

if [[ -n "$PROMPT_COMMAND" ]]; then
    echo "PROMPT_COMMAND is set: $PROMPT_COMMAND"
else
    echo "PROMPT_COMMAND is not set."
fi

# 4. Check for command_not_found_handle override
echo -e "\n🔹 Checking if command_not_found_handle is modified..."
type command_not_found_handle | grep -v "is a shell builtin"

# 5. Look inside .bashrc, .bash_profile, .zshrc for custom scripts
echo -e "\n🔹 Searching shell config files for math-related checks..."
grep -E 'math|confirm|verify|challenge' ~/.bashrc ~/.bash_profile ~/.zshrc 2>/dev/null

# 6. Check PAM authentication for extra security measures
echo -e "\n🔹 Checking PAM configuration for command execution restrictions..."
grep -E 'pam_exec.so|math' /etc/pam.d/* 2>/dev/null

echo -e "\n✅ Done! If you see anything suspicious, let me know!"
