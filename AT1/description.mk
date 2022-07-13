# Name: description.mk
# Author: Lucas Schneider
# 07/2020

# Name of all components in priority order
CPNT_LIST := mdc_fd mdc_uc mdc_estrutural

# Name of the component to be tested
CPNT ?= mdc_estrutural

# Commands to prepare test files
PREPARE_TEST :=