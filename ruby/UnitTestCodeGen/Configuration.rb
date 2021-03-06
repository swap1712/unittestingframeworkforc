#
# Class that encapsulates all the configuration parameters
# Important: Tags defined in this file MUST match the corresponding tags
# in .txt templates
#
class Configuration

  #tags in spreadsheet
  @@globals_tag = "<global>"
  @@parameters_tag = "<argument>"
  @@expected_returnvalue_tag = "<expected return value>"

  #tags in templates
  @@return_type_tag = "<RETURN_TYPE>"
  @@is_ret_type_not_void_tag = "<IS_RETURN_TYPE_VOID>"
  @@num_test_cases_tag = "<NUM_TEST_CASES>"
  @@func_argument_types_tag = "<FUNCTION_ARGUMENT_TYPES_CSV>"
  @@func_name_tag = "<FUNCTION_NAME>"
  @@param_type_defines_tag = "<PARAM_TYPE_MACRO_DEFINES>"
  @@global_type_defines_tag = "<GLOBAL_TYPE_MACRO_DEFINES>"
  @@struct_members_for_params_tag = "<PARAM_TYPES_STRUCTURE_MEMBERS_DECLARATIONS>"
  @@struct_members_for_globals_tag = "<GLOBAL_TYPES_STRUCTURE_MEMBERS_DECLARATIONS>"
  @@temp_test_vars_tag = "<TEMP_VARS_DEFINITONS>"
  @@test_matrix_data_tag = "<TEST_DATA_IN_MATRIX_INITIALIZATION>"
  @@param_type_declare_tag = "<PARAM_TYPE_DECLARATIONS>"
  
  #tags in autogenerated_code_template.txt
  @@test_param_init_tag = "<TEST_PARAM_INIT>"
  @@func_argument_values_tag = "<FUNCTION_ARGUMENT_VALUES_CSV>"
  @@global_var_init_tag = "<GLOBAL_VARS_INITIALIZATION>"

  # general tags
  #@@max_test_cases = 1000
  @@metadata_template = "resources/autogenerated_metadata_template.txt"
  @@test_data_template = "resources/autogenerated_test_data_template.txt"
  @@test_code_template = "resources/autogenerated_code_template.txt"
  @@metadata_header = "resources/AutogeneratedMetadata.h"
  @@testdata_header = "resources/AutogeneratedTestData.h"
  @@code_implementation = "resources/UTestImplementation.c"

  # tags in Script generator
  @@delimiter ="<n>"
  @@autogen_params_tag = "PARAM_"+@@delimiter+"_TYPE"
  @@autogen_globals_tag = "GLOBAL_"+@@delimiter+"_TYPE"

  #other configuration values

  #
  # Return value will be considered void, if SpreadsheetReader reports any of these
  # values as expecte return value for a particular test case
  @@invalid_return_values = ["", " ", "\t", "\n", "NULL", "null", "void", "Void"]

  def self.globals_tag
    @@globals_tag
  end

  def self.parameters_tag
    @@parameters_tag
  end

  def self.expected_returnvalue_tag
    @@expected_returnvalue_tag
  end

  def self.max_test_cases
    @@max_test_cases
  end

  def self.metadata_template
    @@metadata_template
  end

  def self.test_data_template
    @@test_data_template
  end

  def self.test_code_template
    @@test_code_template
  end

  def self.code_implementation_template
    @@code_implementation_template
  end

  def self.metadata_header_filepath
    @@metadata_header
  end

  def self.test_data_header_filepath
    @@testdata_header
  end

  def self.code_implementation_filepath
    @@code_implementation
  end

  def self.return_type_tag
    @@return_type_tag
  end

  def self.is_ret_type_not_void_tag
    @@is_ret_type_not_void_tag
  end

  def self.num_test_cases_tag
    @@num_test_cases_tag
  end

  def self.func_argument_types_tag
    @@func_argument_types_tag
  end

  def self.func_name_tag
    @@func_name_tag
  end

  def self.param_type_defines_tag
    @@param_type_defines_tag
  end

  def self.global_type_defines_tag
    @@global_type_defines_tag
  end

  def self.struct_members_for_params_tag
    @@struct_members_for_params_tag
  end

  def self.delimiter
    @@delimiter
  end

  def self.autogen_params_tag
    @@autogen_params_tag
  end

  def self.struct_members_for_globals_tag
    @@struct_members_for_globals_tag
  end

  def self.autogen_globals_tag
    @@autogen_globals_tag
  end

  def self.temp_test_vars_tag
    @@temp_test_vars_tag
  end

  def self.test_matrix_data_tag
    @@test_matrix_data_tag
  end

  def self.invalid_return_values
    @@invalid_return_values
  end

  def self.param_type_declare_tag
    @@param_type_declare_tag
  end
  
  def self.test_param_init_tag
    @@test_param_init_tag
  end
  
  def self.func_argument_values_tag
    @@func_argument_values_tag
  end

  def self.global_var_init_tag
    @@global_var_init_tag
  end
end

