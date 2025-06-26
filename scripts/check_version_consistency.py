#!/usr/bin/env python3
"""
Version Consistency Checker

This script checks that version numbers are consistent across all project files.
It's used as a pre-commit hook to ensure versions don't get out of sync.
"""

import re
import sys
from pathlib import Path
from typing import Dict, Optional


def extract_version_from_init() -> Optional[str]:
    """
    Extract version from __init__.py file.
    
    Returns:
        Version string or None if not found
    """
    init_file = Path("ai_data_collector/__init__.py")
    
    if not init_file.exists():
        print(f"❌ {init_file} not found")
        return None
    
    content = init_file.read_text(encoding='utf-8')
    
    # Look for __version__ = "x.y.z" pattern
    version_match = re.search(r'^__version__\s*=\s*["\']([^"\']+)["\']', content, re.MULTILINE)
    
    if version_match:
        return version_match.group(1)
    
    print(f"❌ No __version__ found in {init_file}")
    return None


def extract_version_from_pyproject() -> Optional[str]:
    """
    Extract version from pyproject.toml file.
    
    Returns:
        Version string or None if not found
    """
    pyproject_file = Path("pyproject.toml")
    
    if not pyproject_file.exists():
        print(f"❌ {pyproject_file} not found")
        return None
    
    content = pyproject_file.read_text(encoding='utf-8')
    
    # Look for version = "x.y.z" pattern in [project] section
    version_match = re.search(r'^version\s*=\s*["\']([^"\']+)["\']', content, re.MULTILINE)
    
    if version_match:
        return version_match.group(1)
    
    print(f"❌ No version found in {pyproject_file}")
    return None


def extract_version_from_setup() -> Optional[str]:
    """
    Extract version from setup.py file.
    
    Returns:
        Version string or None if not found
    """
    setup_file = Path("setup.py")
    
    if not setup_file.exists():
        # setup.py is optional
        return None
    
    content = setup_file.read_text(encoding='utf-8')
    
    # Look for version= parameter
    version_match = re.search(r'version\s*=\s*["\']([^"\']+)["\']', content)
    
    if version_match:
        return version_match.group(1)
    
    # Look for find_version() call
    if 'find_version()' in content:
        # If using find_version(), it should get version from __init__.py
        return extract_version_from_init()
    
    return None


def extract_version_from_dockerfile() -> Optional[str]:
    """
    Extract version from Dockerfile.
    
    Returns:
        Version string or None if not found
    """
    dockerfile = Path("docker/Dockerfile")
    
    if not dockerfile.exists():
        return None
    
    content = dockerfile.read_text(encoding='utf-8')
    
    # Look for VERSION build arg
    version_match = re.search(r'ARG\s+VERSION\s*=\s*["\']?([^"\'\s]+)', content)
    
    if version_match:
        return version_match.group(1)
    
    return None


def extract_version_from_github_workflow() -> Optional[str]:
    """
    Extract version from GitHub workflow.
    
    Returns:
        Version string or None if not found
    """
    workflow_file = Path(".github/workflows/ci.yml")
    
    if not workflow_file.exists():
        return None
    
    content = workflow_file.read_text(encoding='utf-8')
    
    # Look for version references in environment variables
    version_match = re.search(r'VERSION:\s*["\']?([^"\'\s]+)', content)
    
    if version_match:
        return version_match.group(1)
    
    return None


def validate_version_format(version: str) -> bool:
    """
    Validate that version follows semantic versioning format.
    
    Args:
        version: Version string to validate
        
    Returns:
        True if version format is valid
    """
    # Semantic versioning pattern: MAJOR.MINOR.PATCH with optional pre-release
    semver_pattern = r'^\d+\.\d+\.\d+(?:-[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*)?(?:\+[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*)?$'
    
    return bool(re.match(semver_pattern, version))


def main() -> int:
    """
    Main function to check version consistency.
    
    Returns:
        Exit code (0 for success, 1 for failure)
    """
    print("🔍 Checking version consistency across project files...")
    
    # Extract versions from different files
    versions: Dict[str, Optional[str]] = {
        '__init__.py': extract_version_from_init(),
        'pyproject.toml': extract_version_from_pyproject(),
        'setup.py': extract_version_from_setup(),
        'Dockerfile': extract_version_from_dockerfile(),
        'GitHub workflow': extract_version_from_github_workflow(),
    }
    
    # Filter out None values
    found_versions = {file: version for file, version in versions.items() if version is not None}
    
    if not found_versions:
        print("❌ No version information found in any file")
        return 1
    
    # Check if all found versions are the same
    unique_versions = set(found_versions.values())
    
    if len(unique_versions) > 1:
        print("❌ Version mismatch detected:")
        for file, version in found_versions.items():
            print(f"   {file}: {version}")
        print("\n💡 Please ensure all version numbers are consistent")
        return 1
    
    # Get the common version
    common_version = next(iter(unique_versions))
    
    # Validate version format
    if not validate_version_format(common_version):
        print(f"❌ Invalid version format: {common_version}")
        print("💡 Version should follow semantic versioning (e.g., 1.0.0, 1.0.0-alpha.1)")
        return 1
    
    # Check that version is present in required files
    required_files = ['__init__.py', 'pyproject.toml']
    missing_files = [file for file in required_files if file not in found_versions]
    
    if missing_files:
        print(f"❌ Version missing from required files: {', '.join(missing_files)}")
        return 1
    
    # Success!
    print(f"✅ All versions are consistent: {common_version}")
    print(f"📁 Found in: {', '.join(found_versions.keys())}")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
