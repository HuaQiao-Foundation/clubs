#!/bin/bash

# Sprint Status Report Generator
# Generates a status report from TODO.md for sprint reviews

echo "═══════════════════════════════════════════════════════════════"
echo "            PITCHMASTERS SPRINT STATUS REPORT"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Get current date
CURRENT_DATE=$(date +"%Y-%m-%d")
echo "Generated: $CURRENT_DATE"
echo ""

# Check if TODO.md exists
if [ ! -f "TODO.md" ]; then
    echo "Error: TODO.md not found in current directory"
    exit 1
fi

# Extract sprint information
echo "📊 CURRENT SPRINT"
echo "────────────────────────────────────────────────────────────"
grep -A 1 "^## Sprint" TODO.md | head -2 | sed 's/## //'
echo ""

# Count tasks by status
echo "📈 TASK METRICS"
echo "────────────────────────────────────────────────────────────"

# In Progress tasks
IN_PROGRESS=$(grep -c "^- \[ \].*@.*#critical" TODO.md 2>/dev/null || echo "0")
echo "🚧 In Progress (Critical): $IN_PROGRESS tasks"

# Ready tasks
READY=$(grep -c "^- \[ \].*@.*#high" TODO.md 2>/dev/null || echo "0")
echo "📋 Ready (High Priority): $READY tasks"

# All pending tasks
PENDING=$(grep -c "^- \[ \]" TODO.md 2>/dev/null || echo "0")
echo "⏳ Total Pending: $PENDING tasks"

# Completed tasks
COMPLETED=$(grep -c "^- \[x\]" TODO.md 2>/dev/null || echo "0")
echo "✅ Completed: $COMPLETED tasks"

# Calculate completion percentage
if [ $((PENDING + COMPLETED)) -gt 0 ]; then
    COMPLETION=$((COMPLETED * 100 / (PENDING + COMPLETED)))
    echo ""
    echo "📊 Sprint Progress: ${COMPLETION}%"

    # Visual progress bar
    BARS=$((COMPLETION / 5))
    echo -n "   ["
    for i in $(seq 1 20); do
        if [ $i -le $BARS ]; then
            echo -n "█"
        else
            echo -n "░"
        fi
    done
    echo "]"
fi
echo ""

# Extract story points if available
echo "🎯 STORY POINTS"
echo "────────────────────────────────────────────────────────────"
POINTS_PATTERN="\(([0-9]+) pts?\)"
COMPLETED_POINTS=$(grep "^- \[x\]" TODO.md | grep -oE "$POINTS_PATTERN" | grep -oE "[0-9]+" | awk '{sum+=$1} END {print sum}' 2>/dev/null || echo "0")
TOTAL_POINTS=$(grep "^- \[.\]" TODO.md | grep -oE "$POINTS_PATTERN" | grep -oE "[0-9]+" | awk '{sum+=$1} END {print sum}' 2>/dev/null || echo "0")

echo "Completed: ${COMPLETED_POINTS:-0} points"
echo "Total Planned: ${TOTAL_POINTS:-0} points"

if [ "${TOTAL_POINTS:-0}" -gt 0 ]; then
    VELOCITY=$((COMPLETED_POINTS * 100 / TOTAL_POINTS))
    echo "Velocity: ${VELOCITY}%"
fi
echo ""

# Show current blockers
echo "🚨 BLOCKERS"
echo "────────────────────────────────────────────────────────────"
BLOCKERS=$(sed -n '/### Current Blockers/,/### Technical Decisions/p' TODO.md | grep "^-" | head -5)
if [ -n "$BLOCKERS" ]; then
    echo "$BLOCKERS"
else
    echo "No blockers reported"
fi
echo ""

# Show in-progress tasks
echo "🔄 IN PROGRESS TASKS"
echo "────────────────────────────────────────────────────────────"
sed -n '/### In Progress/,/### Ready/p' TODO.md | grep "^- \[ \]" | head -5 | sed 's/^- \[ \]/  ⚡/'
echo ""

# Show upcoming tasks
echo "📅 UPCOMING TASKS"
echo "────────────────────────────────────────────────────────────"
sed -n '/### Ready/,/### Backlog/p' TODO.md | grep "^- \[ \]" | head -5 | sed 's/^- \[ \]/  ▶️ /'
echo ""

# Extract recent completions
echo "✨ RECENT COMPLETIONS"
echo "────────────────────────────────────────────────────────────"
RECENT=$(grep "^- \[x\]" TODO.md | head -3)
if [ -n "$RECENT" ]; then
    echo "$RECENT" | sed 's/^- \[x\]/  ✓/'
else
    echo "No recent completions"
fi
echo ""

# Sprint velocity trend (if historical data available)
echo "📈 SPRINT VELOCITY"
echo "────────────────────────────────────────────────────────────"
grep "Sprint [0-9].*points" TODO.md | head -3 | sed 's/.*Sprint/Sprint/'
echo ""

# Next sprint planning reminder
echo "📆 UPCOMING MILESTONES"
echo "────────────────────────────────────────────────────────────"
grep "Next Sprint Planning:" TODO.md | sed 's/.*Next Sprint Planning:/Next Sprint Planning:/'
grep "Weekly sprint review:" TODO.md | sed 's/.*Weekly/Weekly/'
echo ""

# Export options
echo "═══════════════════════════════════════════════════════════════"
echo "💡 TIP: Run 'git add TODO.md && git commit -m \"Update sprint status\"' to trigger GitHub Issues sync"
echo ""
echo "📤 Export this report: ./scripts/sprint-status.sh > sprint-report-${CURRENT_DATE}.txt"
echo "═══════════════════════════════════════════════════════════════"