############################################################################
# Set variables
RESOURCES_PY := $(shell find . -type f -name \*.py -print)

# Reused commands
BLACK=black --line-length 89 $(RESOURCES_PY)
DOCFORMATTER=docformatter --recursive --make-summary-multi-line --pre-summary-newline ${RESOURCES_PY}

default: style checkmigrations test flake8 mypy

############################################################################
# Distribution
.PHONY: build sdist upload clean test docs requirements.txt
build:
	python setup.py build

sdist:
	python setup.py sdist

upload:
	python setup.py sdist bdist_wheel
	twine upload --repository-url https://pypi.org/legacy/ dist/*

clean:
	rm -rfv dist build *.egg-info .coverage coverage reports docs/build \
		debug.log db.sqlite3 .mypy_cache django_chaos_engineering-*

requirements.txt:
	pip-compile --no-index --no-emit-trusted-host --no-annotate \
		--output-file requirements.txt requirements.in

docs:
	sphinx-build docs/ docs/build/

############################################################################
# Test commands
.PHONY: checkmigrations test flake8 mypy messages
checkmigrations:
	python manage.py makemigrations django_chaos_engineering --check

test: $(RESOURCES_PY)
	coverage run manage.py test -v2
	coverage html

flake8:
	flake8

mypy:
	-mypy django_chaos_engineering/ --html-report reports/mypy/

messages: $(RESOURCES_PY)
	python manage.py makemessages

############################################################################
# Style
.PHONY: style black blackcheck docformatter docformattercheck
style: black docformatter

black:
	${BLACK}

blackcheck:
	${BLACK} --check

docformatter:
	${DOCFORMATTER} --in-place

docformattercheck:
	${DOCFORMATTER} --check

.git/hooks/pre-commit: Makefile
	echo 'make blackcheck || exit 1' > $@
	echo 'make docformattercheck || exit 1' >> $@
	chmod +x $@
