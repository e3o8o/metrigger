#!/bin/bash

# Trig Network Renaming Analysis Script
# This script helps identify and fix naming inconsistencies across the codebase

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories to analyze
DIRECTORIES=(
    "docs"
    "scripts"
    "src"
    "contracts"
    "packages"
)

# Naming patterns to search for (old names)
OLD_NAMES=(
    "Metrigger"
    "metrigger"
    "Parametrigger"
    "parametrigger"
)

# New naming conventions
PROTOCOL_NEW="Trig Network"
PROTOCOL_NEW_LOWER="trig network"
APP_NEW="Trig Tickets"
APP_NEW_LOWER="trig tickets"
PARENT_NEW="Parametrigger Inc."

# File types to analyze
FILE_TYPES=("*.md" "*.sol" "*.ts" "*.js" "*.json" "*.yml" "*.yaml" "*.txt")

echo -e "${BLUE}=== Trig Network Renaming Analysis ===${NC}"
echo

# Function to search for old naming patterns
analyze_naming_usage() {
    echo -e "${YELLOW}Searching for old naming patterns...${NC}"
    echo

    total_count=0
    for pattern in "${OLD_NAMES[@]}"; do
        echo -e "${GREEN}Pattern: $pattern${NC}"
        count=0
        for dir in "${DIRECTORIES[@]}"; do
            if [ -d "$dir" ]; then
                for file_type in "${FILE_TYPES[@]}"; do
                    files=$(find "$dir" -name "$file_type" -type f 2>/dev/null || true)
                    for file in $files; do
                        if grep -q "$pattern" "$file" 2>/dev/null; then
                            matches=$(grep -c "$pattern" "$file")
                            ((count += matches))
                            ((total_count += matches))
                            echo -e "  ${RED}Found $matches in: $file${NC}"
                        fi
                    done
                done
            fi
        done
        echo -e "  Total for '$pattern': $count"
        echo
    done

    echo -e "${YELLOW}Total instances found: $total_count${NC}"
    echo
}

# Function to show replacement suggestions
show_replacement_suggestions() {
    echo -e "${YELLOW}Recommended Replacements:${NC}"
    echo
    echo -e "  ${RED}Metrigger${NC} → ${GREEN}Trig Network${NC} (protocol)"
    echo -e "  ${RED}metrigger${NC} → ${GREEN}trignetwork${NC} (package/technical)"
    echo -e "  ${RED}Parametrigger${NC} → ${GREEN}Parametrigger Inc.${NC} (parent company)"
    echo -e "  ${RED}parametrigger${NC} → ${GREEN}parametrigger${NC} (keep for parent company)"
    echo
    echo -e "${YELLOW}Domain Strategy:${NC}"
    echo -e "  Protocol: ${GREEN}trig.network${NC}"
    echo -e "  Application: ${GREEN}trigtickets.com${NC}"
    echo
}

# Function to check domain availability (basic check)
check_domains() {
    echo -e "${YELLOW}Recommended Domain Check:${NC}"
    echo
    domains=("trig.network" "trigtickets.com" "trig.com" "trig.org")

    for domain in "${domains[@]}"; do
        # Simple check - in real implementation, use whois or dig
        echo -e "  ${BLUE}$domain${NC} - Check availability manually"
    done
    echo
}

# Function to generate find/replace commands
generate_commands() {
    echo -e "${YELLOW}Sample Find/Replace Commands:${NC}"
    echo
    echo "# For protocol references"
    echo "find . -type f -name \"*.md\" -exec sed -i '' 's/Metrigger Protocol/Trig Network/g' {} +"
    echo "find . -type f -name \"*.sol\" -exec sed -i '' 's/Metrigger/Trig/g' {} +"
    echo
    echo "# For package names"
    echo "find . -type f -name \"*.json\" -exec sed -i '' 's/@metrigger/@trignetwork/g' {} +"
    echo
    echo "# For parent company references"
    echo "find . -type f -name \"*.md\" -exec sed -i '' 's/Parametrigger/Parametrigger Inc./g' {} +"
    echo
}

# Function to check social media handle availability
check_social_handles() {
    echo -e "${YELLOW}Recommended Social Media Handles:${NC}"
    echo
    handles=(
        "@trignetwork"
        "@trigtickets"
        "trignetwork"
        "trigtickets"
    )

    platforms=("Twitter" "GitHub" "Discord" "LinkedIn" "Instagram" "Facebook")

    for handle in "${handles[@]}"; do
        echo -e "  ${BLUE}$handle${NC}:"
        for platform in "${platforms[@]}"; do
            echo -e "    $platform - Check availability"
        done
        echo
    done
}

# Main execution
main() {
    echo -e "${BLUE}Starting renaming analysis...${NC}"
    echo

    analyze_naming_usage
    show_replacement_suggestions
    check_domains
    check_social_handles
    generate_commands

    echo -e "${GREEN}Analysis complete! Review the recommendations above.${NC}"
    echo
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Secure domains and social handles immediately"
    echo "2. Create detailed renaming plan for each directory"
    echo "3. Execute find/replace operations carefully"
    echo "4. Test thoroughly after changes"
    echo "5. Update documentation and marketing materials"
}

# Run main function
main "$@"
