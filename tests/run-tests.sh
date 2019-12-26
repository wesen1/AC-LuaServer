#!/bin/bash

# Run the unit tests
if ! lua testSuite.lua .luacov-travis; then
  exit 1
fi

# Print the coverage summary
echo ""
sed -ne "/File.*Hits.*Missed.*Coverage/,$ p" luacov.report.out
exit 0
