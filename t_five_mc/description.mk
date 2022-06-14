# Name: description.mk
# Author: Lucas Schneider
# 07/2020

# Name of all components in priority order
CPNT_LIST := txt_util buffer_tri mux2x1_1b mux2x1 mux4x1 reg reg_file sign_ext alu_control alu fd_mc uc_mc

# Name of the component to be tested
CPNT ?= uc_mc

# Commands to prepare test files
PREPARE_TEST :=