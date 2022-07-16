# Name: description.mk
# Author: Lucas Schneider
# 07/2020

# Name of all components in priority order
CPNT_LIST := txt_util buffer_tri mux2x1_1b mux2x1 mux4x1 mux8x1_1b reg reg_file sign_ext alu_control alu fd_mc uc_mc rom ram t_five_mc

# Name of the component to be tested
CPNT ?= t_five_mc

# Commands to prepare test files
PREPARE_TEST :=