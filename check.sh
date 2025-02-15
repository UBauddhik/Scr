#!/bin/bash

echo "🔍 Starting diagnostic to find the math confirmation check..."

# 1. Check if an alias is wrapping commands
echo -e "\n🔹 Checking for suspicious aliases..."
alias | grep -E 'math|confirm|verify|challenge|sudo' --color=auto

# 2. Check if a function is handling command execution
echo -e "\n🔹 Checking for custom command wrappers in shell functions..."
declare -F | grep -E 'math|confirm|verify|challenge' --color=auto

# 3. Check if PROMPT_COMMAND is set (might trigger pre-command hooks)
echo -e "\n🔹 Checking PROMPT_COMMAND..."
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
