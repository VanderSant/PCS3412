# Name: description.mk
# Author: Lucas Schneider
# 07/2020

# Name of all components in priority order
CPNT_LIST := txt_util fetch mux2x1 reg

# Name of the component to be tested
CPNT ?= fetch

# Commands to prepare test files
PREPARE_TEST :=
