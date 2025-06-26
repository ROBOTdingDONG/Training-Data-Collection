# Contributing to AI Data Collection Toolkit

🎉 Thank you for your interest in contributing to the AI Data Collection Toolkit! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Security](#security)
- [Performance](#performance)
- [Release Process](#release-process)

## Code of Conduct

This project adheres to a code of conduct that promotes a welcoming and inclusive environment. By participating, you are expected to uphold this code.

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive behaviors include:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behaviors include:**
- Harassment, trolling, or discriminatory comments
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate in a professional setting

## Getting Started

### Prerequisites

- **Python 3.8+** (Python 3.11 recommended)
- **Git** for version control
- **Docker** (optional, for containerized development)
- **Node.js** (optional, for documentation tools)

### Quick Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Training-Data-Collection.git
   cd Training-Data-Collection
   ```
3. **Run the setup script**:
   ```bash
   chmod +x scripts/setup_environment.sh
   ./scripts/setup_environment.sh
   ```
4. **Activate the virtual environment**:
   ```bash
   source venv/bin/activate  # Linux/macOS
   # or
   venv\Scripts\activate  # Windows
   ```

## Development Setup

### Manual Setup

If you prefer manual setup or the script doesn't work for your system:

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/macOS
# or venv\Scripts\activate  # Windows

# Upgrade pip and install build tools
pip install --upgrade pip setuptools wheel

# Install dependencies
pip install -r requirements-dev.txt

# Install package in editable mode
pip install -e .

# Install pre-commit hooks
pre-commit install

# Verify installation
ai-data-collector --version
pytest --version
```

### Docker Development

```bash
# Build development container
docker-compose -f docker/docker-compose.yml build ai-data-collector-dev

# Start development environment
docker-compose -f docker/docker-compose.yml run --rm ai-data-collector-dev bash

# Run tests in container
docker-compose -f docker/docker-compose.yml run --rm ai-data-collector-test
```

### Environment Variables

Copy `.env.example` to `.env` and configure as needed:

```bash
cp .env.example .env
# Edit .env with your preferred settings
```

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- 🐛 **Bug Reports**: Help us identify and fix issues
- 🚀 **Feature Requests**: Suggest new functionality
- 💡 **Feature Implementation**: Build new features
- 📚 **Documentation**: Improve docs, examples, and guides
- 🧪 **Testing**: Add tests, improve coverage
- 🔧 **Infrastructure**: CI/CD, Docker, deployment improvements
- 🎨 **Design**: UI/UX improvements for CLI and documentation
- 🔒 **Security**: Security improvements and vulnerability fixes

### Before You Start

1. **Check existing issues** to avoid duplicate work
2. **Create an issue** for significant changes to discuss the approach
3. **Join discussions** on relevant issues to coordinate efforts
4. **Review the roadmap** to understand project direction

## Development Workflow

### Branch Strategy

We use **Git Flow** with the following branches:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Emergency fixes for production
- `release/*`: Release preparation

### Workflow Steps

1. **Create a feature branch**:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write code following our [coding standards](#coding-standards)
   - Add tests for new functionality
   - Update documentation as needed
   - Ensure all tests pass

3. **Commit your changes**:
   ```bash
   # Stage your changes
   git add .
   
   # Commit with descriptive message
   git commit -m "feat: add support for custom data processors
   
   - Implement abstract base class for custom processors
   - Add processor registration system
   - Include comprehensive tests and documentation
   - Fixes #123"
   ```

4. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   # Create pull request on GitHub
   ```

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(scrapers): add Playwright scraper engine

fix(processors): handle encoding issues in text cleaner

docs: update configuration guide with new options

test: add integration tests for data export
```

## Coding Standards

### Python Style Guide

We follow **PEP 8** with these tools:

- **Black**: Code formatting
- **isort**: Import sorting
- **flake8**: Linting
- **mypy**: Type checking
- **pylint**: Advanced linting

### Code Quality Checks

```bash
# Format code
black ai_data_collector/ tests/
isort ai_data_collector/ tests/

# Check linting
flake8 ai_data_collector/ tests/
mypy ai_data_collector/
pylint ai_data_collector/

# Security scan
bandit -r ai_data_collector/
safety check

# Run all checks
./scripts/run_quality_checks.sh
```

### Code Style Guidelines

#### General Principles

- **Clarity over cleverness**: Write code that's easy to understand
- **Consistency**: Follow established patterns in the codebase
- **Documentation**: Use docstrings and comments effectively
- **Error handling**: Handle errors gracefully with proper logging
- **Type hints**: Use type hints for better code documentation

#### Function and Class Design

```python
from typing import Dict, List, Optional, Any
from loguru import logger

class DataProcessor:
    """
    Process scraped data for AI training.
    
    This class provides methods for cleaning, transforming,
    and validating scraped web data.
    
    Args:
        config: Processing configuration object
        
    Example:
        >>> processor = DataProcessor(config)
        >>> cleaned_data = processor.process(raw_data)
    """
    
    def __init__(self, config: ProcessingConfig) -> None:
        self.config = config
        self._setup_processors()
    
    def process(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process a single data item.
        
        Args:
            data: Raw data dictionary to process
            
        Returns:
            Processed data dictionary
            
        Raises:
            ProcessingError: If processing fails
        """
        try:
            return self._apply_processing_pipeline(data)
        except Exception as e:
            logger.error(f"Processing failed: {e}")
            raise ProcessingError(f"Failed to process data: {e}") from e
```

#### Error Handling

```python
# Good: Specific exception handling with logging
try:
    result = risky_operation()
except SpecificError as e:
    logger.warning(f"Operation failed: {e}")
    return default_value
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    raise ProcessingError(f"Operation failed: {e}") from e

# Good: Input validation
def process_url(url: str) -> Dict[str, Any]:
    if not url or not isinstance(url, str):
        raise ValueError("URL must be a non-empty string")
    
    if not validate_url(url):
        raise ValueError(f"Invalid URL format: {url}")
```

#### Configuration and Logging

```python
# Use structured logging
logger.info("Starting data collection", extra={
    "urls_count": len(urls),
    "engine": config.engine,
    "session_id": session.id
})

# Use configuration objects instead of magic numbers
class ScrapingConfig:
    DEFAULT_DELAY = 1.0
    MAX_RETRIES = 3
    TIMEOUT = 30
```

## Testing Guidelines

### Test Structure

```
tests/
├── unit/                 # Unit tests
│   ├── test_scrapers/
│   ├── test_processors/
│   └── test_utils/
├── integration/          # Integration tests
│   ├── test_end_to_end/
│   └── test_pipelines/
├── performance/          # Performance tests
└── conftest.py          # Shared fixtures
```

### Writing Tests

```python
import pytest
from unittest.mock import Mock, patch
from ai_data_collector import DataCollector
from ai_data_collector.exceptions import ScrapingError

class TestDataCollector:
    """Test cases for DataCollector class."""
    
    def test_successful_scraping(self, mock_scraping_config, sample_urls):
        """Test successful data collection from URLs."""
        collector = DataCollector(mock_scraping_config)
        
        with patch.object(collector.scraper, 'scrape') as mock_scrape:
            mock_scrape.return_value = {"url": "https://example.com", "title": "Test"}
            
            results = collector.collect_from_urls(sample_urls)
            
            assert len(results) == len(sample_urls)
            assert all("url" in result for result in results)
            mock_scrape.assert_called()
    
    def test_scraping_failure_handling(self, mock_scraping_config):
        """Test proper handling of scraping failures."""
        collector = DataCollector(mock_scraping_config)
        
        with patch.object(collector.scraper, 'scrape') as mock_scrape:
            mock_scrape.side_effect = ScrapingError("Network error")
            
            results = collector.collect_from_urls(["https://example.com"])
            
            assert len(results) == 0
            assert len(collector.failed_urls) == 1
    
    @pytest.mark.slow
    def test_large_dataset_processing(self, mock_scraping_config):
        """Test processing of large datasets."""
        # Performance test for large datasets
        pass
```

### Test Categories

- **Unit Tests**: Test individual functions and classes in isolation
- **Integration Tests**: Test component interactions
- **Performance Tests**: Benchmark critical paths
- **Security Tests**: Test security features and vulnerability handling
- **End-to-End Tests**: Test complete workflows

### Running Tests

```bash
# Run all tests
pytest

# Run specific test categories
pytest tests/unit/
pytest tests/integration/
pytest -m "not slow"  # Skip slow tests

# Run with coverage
pytest --cov=ai_data_collector --cov-report=html

# Run performance tests
pytest tests/performance/ --benchmark-only
```

## Documentation

### Documentation Types

- **API Documentation**: Docstrings for all public APIs
- **User Guides**: Step-by-step tutorials
- **Examples**: Working code examples
- **Configuration Guides**: Detailed configuration documentation
- **Deployment Guides**: Production deployment instructions

### Writing Documentation

#### Docstring Format

We use **Google-style docstrings**:

```python
def scrape_urls(urls: List[str], config: ScrapingConfig) -> List[Dict[str, Any]]:
    """
    Scrape data from multiple URLs concurrently.
    
    This function scrapes data from the provided URLs using the specified
    configuration. It handles errors gracefully and returns results for
    successful scrapes.
    
    Args:
        urls: List of URLs to scrape. Must be valid HTTP/HTTPS URLs.
        config: Scraping configuration including engine, delays, and limits.
        
    Returns:
        List of dictionaries containing scraped data. Each dictionary
        includes at minimum 'url' and 'scraped_at' fields.
        
    Raises:
        ValueError: If urls list is empty or contains invalid URLs.
        ScrapingError: If scraping configuration is invalid.
        
    Example:
        >>> config = ScrapingConfig(engine="beautifulsoup")
        >>> urls = ["https://example.com", "https://test.com"]
        >>> results = scrape_urls(urls, config)
        >>> print(f"Scraped {len(results)} pages")
        Scraped 2 pages
        
    Note:
        This function respects robots.txt files and implements rate limiting
        to avoid overwhelming target servers.
    """
```

#### README Updates

When adding new features, update the README with:
- Feature description
- Usage examples
- Configuration options
- Any breaking changes

### Building Documentation

```bash
# Install documentation dependencies
pip install -r requirements-dev.txt

# Build documentation
cd docs/
make html

# Serve documentation locally
python -m http.server 8000 -d _build/html
```

## Security

### Security Considerations

When contributing, consider these security aspects:

- **Input Validation**: Validate all external inputs
- **SQL Injection**: Use parameterized queries
- **Path Traversal**: Validate file paths
- **XSS Prevention**: Sanitize any user-controlled output
- **Rate Limiting**: Implement proper rate limiting
- **Authentication**: Secure any authentication mechanisms
- **Dependency Security**: Keep dependencies updated

### Security Testing

```bash
# Run security scans
bandit -r ai_data_collector/
safety check
semgrep --config=auto ai_data_collector/

# Check for vulnerabilities in dependencies
pip-audit
```

### Reporting Security Issues

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please send an email to [security@your-domain.com] with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will respond within 48 hours and provide a timeline for the fix.

## Performance

### Performance Guidelines

- **Profile before optimizing**: Use profiling tools to identify bottlenecks
- **Memory efficiency**: Consider memory usage for large datasets
- **Concurrent processing**: Use appropriate concurrency levels
- **Caching**: Implement caching where appropriate
- **Database queries**: Optimize database interactions

### Performance Testing

```python
@pytest.mark.benchmark
def test_data_processing_performance(benchmark, sample_data):
    """Benchmark data processing performance."""
    processor = DataProcessor(config)
    
    result = benchmark(processor.process_batch, sample_data)
    
    # Performance assertions
    assert len(result) == len(sample_data)
    # Processing should complete within reasonable time
    assert benchmark.stats['mean'] < 0.1  # 100ms per item
```

## Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers updated
- [ ] Security scan completed
- [ ] Performance benchmarks stable
- [ ] Migration guide created (if needed)

### Creating a Release

1. **Prepare release branch**:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b release/v1.1.0
   ```

2. **Update version numbers**:
   - `ai_data_collector/__init__.py`
   - `pyproject.toml`
   - `docker/Dockerfile` (if applicable)

3. **Update CHANGELOG.md**:
   - Move items from "Unreleased" to new version section
   - Add release date
   - Ensure all changes are documented

4. **Create pull request**:
   - From release branch to `main`
   - Include comprehensive testing
   - Require maintainer review

5. **Tag and publish**:
   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

6. **Post-release**:
   - Merge back to `develop`
   - Update Docker images
   - Announce on relevant channels

## Getting Help

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community discussions
- **Email**: Direct contact for sensitive issues
- **Documentation**: Comprehensive guides and API reference

### Maintainer Response Times

- **Security issues**: Within 48 hours
- **Bug reports**: Within 1 week
- **Feature requests**: Within 2 weeks
- **Pull requests**: Within 1 week

### Code Review Process

1. **Automated checks**: All CI checks must pass
2. **Security review**: Automated security scanning
3. **Code review**: At least one maintainer approval required
4. **Testing**: Comprehensive test coverage required
5. **Documentation**: Documentation updates required for new features

---

## Thank You! 🙏

Your contributions make this project better for everyone. Whether you're fixing a typo, adding a feature, or improving documentation, every contribution is valuable and appreciated.

Happy coding! 🚀
