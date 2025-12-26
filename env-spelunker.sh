#!/usr/bin/env bash
# ENV Var Spelunker - Because hunting for missing variables shouldn't require a PhD in archaeology

# Colors for our spelunking adventure
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color (reset)

# Where to dig for .env files (because developers love hiding them)
SEARCH_DIRS=("." "src" "config" "app" "backend" "frontend")

# The sacred variables we're hunting for (edit this list, you lazy developer)
TARGET_VARS=(
    "DATABASE_URL"
    "API_KEY"
    "SECRET_KEY"
    "DEBUG"
    "PORT"
    "REDIS_URL"
)

# Function to print with dramatic flair
print_find() {
    echo -e "${BLUE}[SPELUNKING]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[FOUND]${NC} $1"
}

print_error() {
    echo -e "${RED}[MISSING]${NC} $1"
}

# Main spelunking expedition
print_find "Starting expedition in search of .env files..."

ENV_FILES=()
for dir in "${SEARCH_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        while IFS= read -r -d '' file; do
            ENV_FILES+=("$file")
            print_success "Found treasure map: $file"
        done < <(find "$dir" -name ".env*" -type f -print0 2>/dev/null)
    fi

done

# Check if we found anything (spoiler: probably not)
if [[ ${#ENV_FILES[@]} -eq 0 ]]; then
    print_warning "No .env files found. Did you check under the couch?"
    exit 1
fi

print_find "\nAnalyzing environment variables..."
print_find "Looking for: ${TARGET_VARS[*]}"
echo

# The grand analysis (it's not that grand)
for var in "${TARGET_VARS[@]}"; do
    FOUND=false
    
    # Check current environment first (the obvious place nobody looks)
    if [[ -n "${!var}" ]]; then
        print_success "$var is set in current environment (value: ${!var})"
        FOUND=true
    fi
    
    # Dig through all .env files (because consistency is overrated)
    for env_file in "${ENV_FILES[@]}"; do
        if grep -q "^$var=" "$env_file" 2>/dev/null; then
            value=$(grep "^$var=" "$env_file" | cut -d'=' -f2-)
            print_success "$var found in $env_file (value: $value)"
            FOUND=true
        fi
    done
    
    # The sad truth
    if [[ "$FOUND" == false ]]; then
        print_error "$var not found anywhere. Did it run away?"
    fi
    
    echo "---"

done

print_find "Expedition complete. Now go fix your configs, you animal."
