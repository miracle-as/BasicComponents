#!/bin/sh

pod spec lint BasicComponents.podspec --allow-warnings

pod repo push BasicComponents BasicComponents.podspec --allow-warnings