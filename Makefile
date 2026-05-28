# ─────────────────────────────────────────────────────────────────────────────
# Flutter project helpers
# ─────────────────────────────────────────────────────────────────────────────

.PHONY: test coverage coverage-open coverage-clean help

# Run all unit tests (no coverage)
test:
	flutter test

# Run tests, generate lcov.info, build HTML report, and print a summary
coverage:
	@echo "▶ Running tests with coverage…"
	@flutter test --coverage
	@echo ""
	@echo "▶ Building HTML report…"
	@genhtml coverage/lcov.info \
		--output-directory coverage/html \
		--title "Driver App" \
		--legend \
		--quiet
	@echo ""
	@echo "▶ Coverage summary:"
	@lcov --summary coverage/lcov.info 2>&1 | grep -E "lines|functions|branches"
	@echo ""
	@echo "HTML report: coverage/html/index.html  (run 'make coverage-open' to view)"

# Open the HTML report in the default browser (macOS)
coverage-open: coverage/html/index.html
	open coverage/html/index.html

coverage/html/index.html:
	$(MAKE) coverage

# Remove all generated coverage artefacts
coverage-clean:
	rm -rf coverage/

help:
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "  test             Run all unit tests"
	@echo "  coverage         Run tests + generate HTML coverage report"
	@echo "  coverage-open    Open HTML report in browser"
	@echo "  coverage-clean   Delete coverage/ directory"
	@echo ""
