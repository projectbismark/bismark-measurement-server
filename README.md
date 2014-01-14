# BISmark Measurement Server

The software in this repository implements the BISmark Measurement Server, a
service that sources and sinks active measurement traffic from Project BISmark
routers located in project participant homes.

The repository consists of two major components:

## bismark-mserver

The `bismark-mserver` package that contains the scripts that orchestrate the
various measurement tools that run on the measurement servers

## Package build files

The `packages` directory that contains package definition files and build
scripts for supported platforms/distributions. We currently have build
process for packages for fedora 8 and Centos 6.4/6.5 (the M-Lab/PlanetLab platform) 
but we hope to make it possible to build packages for other distributions soon.
