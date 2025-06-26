#!/bin/bash

# Quality Checks Script for AI Data Collection Toolkit
# This script runs all code quality, security, and formatting checks

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
SOURCE_DIRS="ai_data_collector tests examples"
MAIN_PACKAGE="ai_data_collector"
TEST_DIR="tests"
EXAMPLES_DIR="examples"

# Check if virtual environment is activated
check_virtual_env() {
    if [[ "$VIRTUAL_ENV" == "" ]]; then
        log_warning "Virtual environment not detected"
        log_info "Activate with: source venv/bin/activate"
    else
        log_info "Using virtual environment: $VIRTUAL_ENV"
    fi
}

# Check required tools
check_tools() {
    log_info "Checking required tools..."
    
    local tools=("black" "isort" "flake8" "mypy" "pylint" "bandit" "safety" "pytest")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing tools: ${missing_tools[*]}"
        log_info "Install with: pip install -r requirements-dev.txt"
        exit 1
    fi
    
    log_success "All required tools are available"
}

# Format code
format_code() {
    log_info "Formatting code with black..."
    
    if black --check --diff $SOURCE_DIRS; then
        log_success "Code is already formatted"
    else
        log_info "Formatting code..."
        black $SOURCE_DIRS
        log_success "Code formatted with black"
    fi
}

# Sort imports
sort_imports() {
    log_info "Sorting imports with isort..."
    
    if isort --check-only --diff $SOURCE_DIRS; then
        log_success "Imports are already sorted"
    else
        log_info "Sorting imports..."
        isort $SOURCE_DIRS
        log_success "Imports sorted with isort"
    fi
}

# Run linting
run_linting() {
    log_info "Running linting checks..."
    
    # Flake8
    log_info "Running flake8..."
    if flake8 $SOURCE_DIRS; then
        log_success "flake8 passed"
    else
        log_error "flake8 failed"
        return 1
    fi
    
    # Pylint
    log_info "Running pylint..."
    if pylint $MAIN_PACKAGE --exit-zero; then
        log_success "pylint completed"
    else
        log_warning "pylint found issues (not blocking)"
    fi
}

# Run type checking
run_type_checking() {
    log_info "Running type checking with mypy..."
    
    if mypy $MAIN_PACKAGE; then
        log_success "mypy passed"
    else
        log_error "mypy failed"
        return 1
    fi
}

# Run security checks
run_security_checks() {
    log_info "Running security checks..."
    
    # Bandit
    log_info "Running bandit security linter..."
    if bandit -r $MAIN_PACKAGE -ll; then
        log_success "bandit passed"
    else
        log_error "bandit found security issues"
        return 1
    fi
    
    # Safety
    log_info "Checking dependencies for known vulnerabilities..."
    if safety check; then
        log_success "safety check passed"
    else
        log_warning "safety check found vulnerabilities"
        # Don't fail on safety issues in development
    fi
}

# Run tests
run_tests() {
    log_info "Running test suite..."
    
    # Unit tests
    log_info "Running unit tests..."
    if pytest $TEST_DIR/unit/ -v --tb=short; then
        log_success "Unit tests passed"
    else
        log_error "Unit tests failed"
        return 1
    fi
    
    # Integration tests (if they exist and are fast)
    if [ -d "$TEST_DIR/integration" ]; then
        log_info "Running integration tests..."
        if pytest $TEST_DIR/integration/ -v --tb=short -m "not slow"; then
            log_success "Integration tests passed"
        else
            log_warning "Some integration tests failed"
        fi
    fi
}

# Run coverage analysis
run_coverage() {
    log_info "Running coverage analysis..."
    
    if pytest --cov=$MAIN_PACKAGE --cov-report=term-missing --cov-report=html:htmlcov $TEST_DIR/; then
        log_success "Coverage analysis completed"
        log_info "Coverage report generated in htmlcov/"
    else
        log_warning "Coverage analysis had issues"
    fi
}

# Check documentation
check_documentation() {
    log_info "Checking documentation..."
    
    # Check for missing docstrings
    log_info "Checking for missing docstrings..."
    if pydocstyle $MAIN_PACKAGE --convention=google --add-ignore=D100,D104,D105,D107; then
        log_success "Documentation style check passed"
    else
        log_warning "Documentation style issues found"
    fi
    
    # Check if README examples work
    if [ -f "$EXAMPLES_DIR/basic_scraping.py" ]; then
        log_info "Validating example scripts..."
        if python -m py_compile "$EXAMPLES_DIR/basic_scraping.py"; then
            log_success "Example scripts compile successfully"
        else
            log_warning "Example scripts have compilation errors"
        fi
    fi
}

# Check package integrity
check_package_integrity() {
    log_info "Checking package integrity..."
    
    # Test imports
    log_info "Testing package imports..."
    if python -c "import $MAIN_PACKAGE; print('✓ Package imports successfully')"; then
        log_success "Package imports successfully"
    else
        log_error "Package import failed"
        return 1
    fi
    
    # Check CLI
    if command -v ai-data-collector &> /dev/null; then
        log_info "Testing CLI interface..."
        if ai-data-collector --version &> /dev/null; then
            log_success "CLI interface works"
        else
            log_warning "CLI interface has issues"
        fi
    else
        log_warning "CLI not installed or not in PATH"
    fi
}

# Generate quality report
generate_report() {
    log_info "Generating quality report..."
    
    local report_file="quality_report.txt"
    
    {
        echo "AI Data Collection Toolkit - Quality Report"
        echo "==========================================="
        echo "Generated: $(date)"
        echo ""
        echo "Python Version: $(python --version)"
        echo "Virtual Environment: ${VIRTUAL_ENV:-None}"
        echo ""
        echo "Code Quality Checks:"
        echo "- Black formatting: $(black --check $SOURCE_DIRS &> /dev/null && echo 'PASS' || echo 'FAIL')"
        echo "- Import sorting: $(isort --check-only $SOURCE_DIRS &> /dev/null && echo 'PASS' || echo 'FAIL')"
        echo "- Flake8 linting: $(flake8 $SOURCE_DIRS &> /dev/null && echo 'PASS' || echo 'FAIL')"
        echo "- MyPy type checking: $(mypy $MAIN_PACKAGE &> /dev/null && echo 'PASS' || echo 'FAIL')"
        echo "- Bandit security: $(bandit -r $MAIN_PACKAGE -ll &> /dev/null && echo 'PASS' || echo 'FAIL')"
        echo ""
        echo "Test Results:"
        echo "- Unit tests: $(pytest $TEST_DIR/unit/ --tb=no -q &> /dev/null && echo 'PASS' || echo 'FAIL')"
        echo "- Package import: $(python -c "import $MAIN_PACKAGE" &> /dev/null && echo 'PASS' || echo 'FAIL')"
        echo ""
        echo "Dependencies:"
        pip freeze | head -20
        echo "..."
    } > "$report_file"
    
    log_success "Quality report saved to $report_file"
}

# Main function
main() {
    echo "========================================"
    echo "AI Data Collection Toolkit Quality Checks"
    echo "========================================"
    echo
    
    # Parse command line arguments
    local run_format=true
    local run_lint=true
    local run_security=true
    local run_tests=true
    local run_coverage=false
    local generate_report_flag=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-format)
                run_format=false
                shift
                ;;
            --no-lint)
                run_lint=false
                shift
                ;;
            --no-security)
                run_security=false
                shift
                ;;
            --no-tests)
                run_tests=false
                shift
                ;;
            --coverage)
                run_coverage=true
                shift
                ;;
            --report)
                generate_report_flag=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --no-format     Skip code formatting"
                echo "  --no-lint       Skip linting checks"
                echo "  --no-security   Skip security checks"
                echo "  --no-tests      Skip test execution"
                echo "  --coverage      Run coverage analysis"
                echo "  --report        Generate quality report"
                echo "  --help, -h      Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Run checks
    local exit_code=0
    
    check_virtual_env
    check_tools
    
    if [ "$run_format" = true ]; then
        format_code || exit_code=1
        sort_imports || exit_code=1
    fi
    
    if [ "$run_lint" = true ]; then
        run_linting || exit_code=1
        run_type_checking || exit_code=1
    fi
    
    if [ "$run_security" = true ]; then
        run_security_checks || exit_code=1
    fi
    
    check_documentation
    check_package_integrity || exit_code=1
    
    if [ "$run_tests" = true ]; then
        if [ "$run_coverage" = true ]; then
            run_coverage || exit_code=1
        else
            run_tests || exit_code=1
        fi
    fi
    
    if [ "$generate_report_flag" = true ]; then
        generate_report
    fi
    
    echo
    if [ $exit_code -eq 0 ]; then
        log_success "All quality checks passed! 🎉"
    else
        log_error "Some quality checks failed. Please review the output above."
    fi
    
    echo
    log_info "Next steps:"
    echo "  - Fix any issues identified above"
    echo "  - Run 'git add .' and 'git commit' to trigger pre-commit hooks"
    echo "  - Push changes to trigger CI pipeline"
    
    exit $exit_code
}

# Run main function with all arguments
main "$@"
