#!/usr/bin/env bash
# pre_commit.sh
# Run this before every commit. Must exit 0 before pushing.
# macOS/bash equivalent of pre_commit.ps1 (Windows/PowerShell).

CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}==> Getting dependencies...${NC}"
flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}pub get failed${NC}"
    exit 1
fi

echo -e "${CYAN}==> Checking formatting...${NC}"
dart format --output=none --set-exit-if-changed .
if [ $? -ne 0 ]; then
    echo -e "${RED}Formatting issues found. Run 'dart format .' to fix.${NC}"
    exit 1
fi

echo -e "${CYAN}==> Running static analysis...${NC}"
flutter analyze --fatal-infos
if [ $? -ne 0 ]; then
    echo -e "${RED}Analysis failed${NC}"
    exit 1
fi

echo -e "${CYAN}==> Running tests with coverage...${NC}"
flutter test --coverage
if [ $? -ne 0 ]; then
    echo -e "${RED}Tests failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}All checks passed. Safe to commit.${NC}"
