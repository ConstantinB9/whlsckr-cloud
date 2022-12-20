from pathlib import Path
from setuptools import setup, find_packages


def get_requirements():
    """Build the requirements list for this project"""

    with Path("requirements.txt").open("r") as f:
        required = f.read().splitlines()
    return required


setup(
    name="whlsckr",
    author="Constantin Braess",
    version="0.0.1",
    packages=find_packages(),
    install_requires=get_requirements(),
)
