#!/bin/bash

# Environment Setup Script for AI Data Collection Toolkit
# This script sets up the development and production environment

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
PYTHON_VERSION="3.11"
REQUIRED_PYTHON_MIN="3.8"
PROJECT_NAME="ai-data-collector"
VENV_NAME="venv"

# Check if running on supported OS
check_os() {
    log_info "Checking operating system..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_info "Detected Linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "Detected macOS"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        OS="windows"
        log_info "Detected Windows"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Check Python version
check_python() {
    log_info "Checking Python installation..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    else
        log_error "Python is not installed or not in PATH"
        log_info "Please install Python $PYTHON_VERSION or higher"
        exit 1
    fi
    
    # Check Python version
    PYTHON_VERSION_INSTALLED=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
    log_info "Found Python $PYTHON_VERSION_INSTALLED"
    
    # Simple version comparison
    if ! $PYTHON_CMD -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"; then
        log_error "Python $REQUIRED_PYTHON_MIN or higher is required"
        log_error "Current version: $PYTHON_VERSION_INSTALLED"
        exit 1
    fi
    
    log_success "Python version is compatible"
}

# Install system dependencies
install_system_dependencies() {
    log_info "Installing system dependencies..."
    
    case $OS in
        "linux")
            # Check if we have apt (Debian/Ubuntu)
            if command -v apt-get &> /dev/null; then
                log_info "Installing dependencies with apt-get..."
                sudo apt-get update
                sudo apt-get install -y \
                    build-essential \
                    python3-dev \
                    python3-pip \
                    python3-venv \
                    libxml2-dev \
                    libxslt1-dev \
                    zlib1g-dev \
                    libjpeg-dev \
                    libpng-dev \
                    libffi-dev \
                    libssl-dev \
                    chromium-browser \
                    chromium-chromedriver \
                    wget \
                    curl \
                    git
                
            # Check if we have yum (RedHat/CentOS)
            elif command -v yum &> /dev/null; then
                log_info "Installing dependencies with yum..."
                sudo yum install -y \
                    gcc \
                    gcc-c++ \
                    python3-devel \
                    python3-pip \
                    libxml2-devel \
                    libxslt-devel \
                    zlib-devel \
                    libjpeg-devel \
                    libpng-devel \
                    libffi-devel \
                    openssl-devel \
                    chromium \
                    chromedriver \
                    wget \
                    curl \
                    git
            else
                log_warning "Unknown package manager. Please install dependencies manually."
            fi
            ;;
        "macos")
            # Check if Homebrew is installed
            if command -v brew &> /dev/null; then
                log_info "Installing dependencies with Homebrew..."
                brew update
                brew install \
                    python@3.11 \
                    libxml2 \
                    libxslt \
                    jpeg \
                    libpng \
                    chromium \
                    chromedriver \
                    wget \
                    curl \
                    git
            else
                log_warning "Homebrew not found. Please install it from https://brew.sh/"
            fi
            ;;
        "windows")
            log_info "Windows detected. Please ensure the following are installed:"
            log_info "  - Python $PYTHON_VERSION or higher"
            log_info "  - Microsoft Visual C++ Build Tools"
            log_info "  - Chrome browser"
            log_info "  - Git for Windows"
            ;;
    esac
}

# Create virtual environment
setup_virtual_environment() {
    log_info "Setting up Python virtual environment..."
    
    if [ -d "$VENV_NAME" ]; then
        log_warning "Virtual environment already exists. Removing..."
        rm -rf "$VENV_NAME"
    fi
    
    # Create virtual environment
    $PYTHON_CMD -m venv "$VENV_NAME"
    
    # Activate virtual environment
    if [[ "$OS" == "windows" ]]; then
        source "$VENV_NAME/Scripts/activate"
    else
        source "$VENV_NAME/bin/activate"
    fi
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel
    
    log_success "Virtual environment created and activated"
}

# Install Python dependencies
install_python_dependencies() {
    log_info "Installing Python dependencies..."
    
    # Install main dependencies
    if [ -f "requirements.txt" ]; then
        log_info "Installing main dependencies from requirements.txt..."
        pip install -r requirements.txt
    else
        log_error "requirements.txt not found"
        exit 1
    fi
    
    # Install development dependencies
    if [ -f "requirements-dev.txt" ]; then
        log_info "Installing development dependencies from requirements-dev.txt..."
        pip install -r requirements-dev.txt
    fi
    
    # Install package in editable mode
    log_info "Installing package in development mode..."
    pip install -e .
    
    log_success "Python dependencies installed"
}

# Install optional dependencies
install_optional_dependencies() {
    log_info "Installing optional dependencies..."
    
    # Selenium
    if command -v chromedriver &> /dev/null || command -v chromium-chromedriver &> /dev/null; then
        log_info "Installing Selenium support..."
        pip install selenium webdriver-manager
    else
        log_warning "ChromeDriver not found. Selenium support will be limited."
    fi
    
    # Playwright
    log_info "Installing Playwright support..."
    pip install playwright
    playwright install chromium --with-deps 2>/dev/null || log_warning "Failed to install Playwright browsers"
    
    # Scrapy
    log_info "Installing Scrapy support..."
    pip install scrapy
    
    # Machine learning dependencies
    log_info "Installing ML dependencies..."
    pip install scikit-learn transformers torch
    
    # Export format dependencies
    log_info "Installing export format dependencies..."
    pip install pyarrow tables openpyxl
    
    log_success "Optional dependencies installed"
}

# Setup pre-commit hooks
setup_pre_commit() {
    log_info "Setting up pre-commit hooks..."
    
    if [ -f ".pre-commit-config.yaml" ]; then
        pre-commit install
        log_success "Pre-commit hooks installed"
    else
        log_warning ".pre-commit-config.yaml not found. Skipping pre-commit setup."
    fi
}

# Create necessary directories
setup_directories() {
    log_info "Creating project directories..."
    
    directories=(
        "data/raw"
        "data/processed"
        "data/exports"
        "logs"
        "config"
        "cache"
        "test-results"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    done
    
    # Create .gitkeep files for empty directories
    for dir in "${directories[@]}"; do
        if [ ! "$(ls -A $dir)" ]; then
            touch "$dir/.gitkeep"
        fi
    done
    
    log_success "Project directories created"
}

# Setup environment variables
setup_environment_variables() {
    log_info "Setting up environment variables..."
    
    ENV_FILE=".env"
    
    if [ ! -f "$ENV_FILE" ]; then
        log_info "Creating .env file..."
        cat > "$ENV_FILE" << EOF
# AI Data Collection Toolkit Environment Variables

# Application Settings
APP_NAME=ai-data-collector
APP_VERSION=1.0.0
DEBUG=false

# Logging Settings
DATA_COLLECTOR_LOG_LEVEL=INFO
LOG_FILE=logs/collector.log

# Storage Settings
DATA_COLLECTOR_OUTPUT_DIR=./data
DATA_COLLECTOR_CONFIG_PATH=./config
CACHE_DIR=./cache

# Database Settings (Optional)
# DATABASE_URL=sqlite:///data/collector.db
# REDIS_URL=redis://localhost:6379/0

# API Keys (Optional)
# OPENAI_API_KEY=your-openai-api-key-here
# HUGGINGFACE_TOKEN=your-huggingface-token-here

# Security Settings
SECRET_KEY=dev-secret-key-change-in-production
ALLOWED_HOSTS=localhost,127.0.0.1

# Performance Settings
MAX_MEMORY_USAGE=1024
WORKER_TIMEOUT=300

# Proxy Settings (Optional)
# HTTP_PROXY=http://proxy.example.com:8080
# HTTPS_PROXY=http://proxy.example.com:8080
# NO_PROXY=localhost,127.0.0.1,.local

EOF
        log_success "Created .env file with default settings"
    else
        log_info ".env file already exists"
    fi
}

# Run tests
run_tests() {
    log_info "Running tests to verify installation..."
    
    # Run basic import test
    if $PYTHON_CMD -c "import ai_data_collector; print('✓ Package import successful')"; then
        log_success "Package import test passed"
    else
        log_error "Package import test failed"
        return 1
    fi
    
    # Run unit tests if available
    if [ -d "tests" ]; then
        log_info "Running unit tests..."
        pytest tests/unit/ -v --tb=short || log_warning "Some unit tests failed"
    fi
    
    # Test CLI
    if ai-data-collector --version &> /dev/null; then
        log_success "CLI test passed"
    else
        log_warning "CLI test failed - command may not be in PATH"
    fi
}

# Print usage information
print_usage() {
    log_info "Setup complete! Here's how to get started:"
    echo
    echo "1. Activate the virtual environment:"
    if [[ "$OS" == "windows" ]]; then
        echo "   source venv/Scripts/activate"
    else
        echo "   source venv/bin/activate"
    fi
    echo
    echo "2. Run the CLI tool:"
    echo "   ai-data-collector --help"
    echo
    echo "3. Try basic scraping:"
    echo "   ai-data-collector scrape https://example.com"
    echo
    echo "4. Run examples:"
    echo "   python examples/basic_scraping.py"
    echo "   python examples/advanced_pipeline.py"
    echo
    echo "5. Run tests:"
    echo "   pytest tests/"
    echo
    echo "6. View documentation:"
    echo "   Open README.md or docs/ directory"
    echo
    log_info "For more information, visit: https://github.com/ROBOTdingDONG/Training-Data-Collection"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    # Add cleanup logic here if needed
}

# Main setup function
main() {
    echo "========================================"
    echo "AI Data Collection Toolkit Setup"
    echo "========================================"
    echo
    
    # Parse command line arguments
    SKIP_OPTIONAL=false
    SKIP_TESTS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-optional)
                SKIP_OPTIONAL=true
                shift
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --skip-optional    Skip installation of optional dependencies"
                echo "  --skip-tests       Skip running tests after setup"
                echo "  --help, -h         Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Trap cleanup on exit
    trap cleanup EXIT
    
    # Run setup steps
    check_os
    check_python
    install_system_dependencies
    setup_virtual_environment
    install_python_dependencies
    
    if [ "$SKIP_OPTIONAL" = false ]; then
        install_optional_dependencies
    else
        log_info "Skipping optional dependencies"
    fi
    
    setup_pre_commit
    setup_directories
    setup_environment_variables
    
    if [ "$SKIP_TESTS" = false ]; then
        run_tests
    else
        log_info "Skipping tests"
    fi
    
    echo
    log_success "Setup completed successfully!"
    echo
    print_usage
}

# Run main function with all arguments
main "$@"
