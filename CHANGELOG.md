# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0]
### Added
- Infrastructure added to project for make-based compilation and installation of the software on Linux
- Started CHANGELOG.md for versioned alteration tracking
- Segmentation packaging as a Singularity container
  - Also included Make variant to build Segmentation as a Python virtualenv, but TensorFlow via conda has manifested binary compatibility issues many times in our experience
- ThresholdAndSkeletonize on Linux:
  - Fiji/ImageJ-based pipeline with Bash driver script
  - Python scikit-image pipeline
  - README files added for each

## [0.0.1] - initial release
### Added
- Initial import of all source
