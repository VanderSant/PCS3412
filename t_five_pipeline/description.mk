# Name: description.mk
# Author: Lucas Schneider
# 07/2020

# Name of all components in priority order
CPNT_LIST := txt_util fetch decode mux2x1 reg reg_file sign_ext control

# Name of the component to be tested
CPNT ?= decode

# Commands to prepare test files
PREPARE_TEST :=
