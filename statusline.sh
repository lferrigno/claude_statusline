#!/bin/bash

# Claude Code Status Line Script
# Shows: Session Name | Model | Directory (git branch) | Context %

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')

session_id=$(echo "$input" | jq -r '.session_id')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
escaped_project_dir=$(echo "$project_dir" | sed 's|/|-|g')
sessions_index="$HOME/.claude/projects/${escaped_project_dir}/sessions-index.json"
session_jsonl="$HOME/.claude/projects/${escaped_project_dir}/${session_id}.jsonl"

session_name=""

# Try sessions-index.json first
if [ -f "$sessions_index" ]; then
    session_name=$(jq -r --arg sid "$session_id" '.entries[] | select(.sessionId == $sid) | .customTitle // empty' "$sessions_index")
fi

# Fallback: read from session transcript (for freshly renamed sessions)
if [ -z "$session_name" ] && [ -f "$session_jsonl" ]; then
    session_name=$(grep '"type":"custom-title"' "$session_jsonl" | tail -1 | jq -r '.customTitle // empty')
fi

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$cwd")

git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    [ -n "$git_branch" ] && git_branch=" ($git_branch)"
fi

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
context_info=""
[ -n "$used_pct" ] && context_info=" | $(printf "%.1f" "$used_pct")%"

session_part=""
[ -n "$session_name" ] && session_part="${session_name} | "

echo "${session_part}${model} | ${dir_name}${git_branch}${context_info}"
