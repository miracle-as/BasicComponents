#!/bin/sh

pod spec lint BasicComponents.podspec --allow-warnings --sources=https://github.com/pherret/Sugar.git,https://github.com/CocoaPods/Specs.git

pod repo push BasicComponents BasicComponents.podspec --allow-warnings