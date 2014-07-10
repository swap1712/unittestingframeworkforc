require_relative 'configuration'
require_relative 'spreadsheetreader'
require_relative 'functionsignature'

##############################################################################################
# This class defines methods to generate AutogeneratedMetadata.h and AutogeneratedTestData.h
# Support for UTestImplementation.c is also planned
##############################################################################################
class ScriptGenerator

  @function_return_type = nil
  @function_name = nil
  @function_argument_types_string = nil
  @function_argument_types_array = nil
  @global_types_array = nil
  @is_ret_type_not_void = nil
  @number_of_test_cases = nil
  @temp_var_types_array = nil
  @temp_var_names_array = nil
  @temp_var_values_array = nil
  @parameters_hashmap = nil
  @globals_hashmap = nil
  @return_values = nil

  COMMA = ','
  SPACE = ' '
  #
  # Class constructor
  #
  def initialize spreadsheet_absolute_path
    reader = SpreadSheetReader.new(spreadsheet_absolute_path)

    parse_function_signature(reader)
    get_number_of_test_cases(reader)
    get_global_types(reader)
    get_temp_var_data(reader)
    get_test_data(reader)

    validate_initializations()

  end

  ######################################################################################
  # Reads the metadata template, replaces tags with proper data and calls
  # write_to function to produce AutogeneratedMetadata.h file
  ######################################################################################
  def generate_metadata

    metadata = File.new(Configuration.metadata_header_filepath, "w")

    # open the metadata file and go over each line to replace tags one by one
    if File.file?(Configuration.metadata_template)
      template = File.open(Configuration.metadata_template, "r")
      lines = template.readlines
      lines.each{|line|

        # replace all the return type tags with actual return type
        line.gsub!(Configuration.return_type_tag, @function_return_type)

        #replace function name tag with actual function name
        line.gsub!(Configuration.func_name_tag, @function_name)

        #replace function arguments tag with comma separated function argument types
        line.gsub!(Configuration.func_argument_types_tag, @function_argument_types_string)

        # replace boolean value tag for return type void? with TRUE or FALSE
        line.gsub!(Configuration.is_ret_type_not_void_tag, @is_ret_type_not_void)

        # replace number of test cases tag with actual number of test cases
        line.gsub!(Configuration.num_test_cases_tag, @number_of_test_cases.to_s)

        # generate macro definitions
        line.gsub!(Configuration.param_type_defines_tag, get_macro_definitions(@function_argument_types_array,Configuration.autogen_params_tag))
        line.gsub!(Configuration.global_type_defines_tag, get_macro_definitions(@global_types_array, Configuration.autogen_globals_tag))

        # replace tags in test data structure with corresponding values
        line.gsub!(Configuration.struct_members_for_params_tag, get_params_declaration_string(@function_argument_types_array))
        line.gsub!(Configuration.struct_members_for_globals_tag, get_globals_as_struct_members(@global_types_array))

        #finally, after all substitutions, write this line to AutogeneratedMetadata.h file
        metadata.syswrite(line)

      }

    else
      puts "Could not open the metadata template file - autogenerated_metadata_template.txt"
    end

  end

  ######################################################################################
  # Reads test data template, replaces tags with proper data and calls
  # write_to function to produce AutogeneratedTestData.h file
  ######################################################################################
  def generate_test_data
    testdata = File.new(Configuration.test_data_header_filepath, "w")
    if File.file?(Configuration.test_data_template)
      template = File.open(Configuration.test_data_template, "r")
      lines = template.readlines
      lines.each{|line|
        line.gsub!(Configuration.temp_test_vars_tag, get_temp_var_definitions)
        line.gsub!(Configuration.test_matrix_data_tag, get_initlized_test_data)
        testdata.syswrite(line)
      }
    else
      puts "Could not open the test data template file - autogenerated_test_data_template.txt"
    end
  end

  ######################################################################################
  # Reads test metadata template and replaces tags with proper code and
  # generates UTestImplementation.c
  ######################################################################################
  def generate_test_code
    testcode = File.new(Configuration.code_implementation_filepath, "w")
    if File.file?(Configuration.test_code_template)
      template = File.open(Configuration.test_code_template,"r")
      lines = template.readlines
      lines.each{ |line|
        line.gsub!(Configuration.param_type_declare_tag, get_params_declaration_string(@function_argument_types_array))
        line.gsub!(Configuration.test_param_init_tag, get_initialized_parameters_string(@function_argument_types_array))
        line.gsub!(Configuration.global_var_init_tag, get_set_global_vars_code_string(@globals_hashmap))
        line.gsub!(Configuration.func_argument_values_tag(), get_csv_for_arguments(@function_argument_types_array))
        testcode.syswrite(line)
      }
    else
      puts "Could not open the test code template file: - autogenerated_code_template.txt"
    end
  end

  ##########################################################################################
  # Populates instance variables related to return type, parameters and
  # name of function
  ##########################################################################################
  def parse_function_signature(reader)

    function_string = reader.get_function_signature
    signature = FunctionSignature.new(function_string)

    @function_return_type = signature.return_type()
    @is_ret_type_not_void = (signature.returns_void?() ? "FALSE":"TRUE")
    @function_name = signature.name()
    @function_argument_types_array = signature.parameters()
    @function_argument_types_string = @function_argument_types_array.join(", ") #[a, b, c] => "a, b, c"
    @function_argument_types_string = (@function_argument_types_string.empty? ? "void" : @function_argument_types_string)
  end

  ##########################################################################################
  # Forwards the number of test cases, as reported by the SpreadsheetReader
  ##########################################################################################
  def get_number_of_test_cases reader
    @number_of_test_cases = reader.get_test_case_count
  end

  ##########################################################################################
  # Forwards the array of global variables, as reported by Spreadsheetreader
  ##########################################################################################
  def get_global_types(reader)
    @global_types_array = reader.get_global_datatypes
  end

  ###########################################################################################
  # Reads temp variable related data from SpreadhseetReader and populates corresponding
  # instance variables
  ###########################################################################################
  def get_temp_var_data(reader)
    @temp_var_names_array = reader.get_temp_test_var_names()
    @temp_var_types_array = reader.get_temp_test_var_datatypes()
    @temp_var_values_array = reader.get_temp_test_var_values()
  end

  ###########################################################################################
  # Reads test data (global vars and params )from SpreadhseetReader and populates
  # corresponding instance variables
  ###########################################################################################
  def get_test_data(reader)
    @parameters_hashmap = reader.get_parameters_values()
    @globals_hashmap = reader.get_global_values()
    @return_values = reader.get_expected_return_values()
  end

  ###########################################################################################
  # Accepts an array of arguments and returns a string
  # representing C style #defines, each separated by
  # system carriage return
  ###########################################################################################
  def get_macro_definitions(types_array, tag)
    token = "# define "+ tag +"\t\t\t\t"
    result = ""
    unless types_array.length <= 0

      types_array.each_index{|index|
        result.concat(token.gsub(Configuration.delimiter, index.to_s).concat(types_array[index])).concat("\n")
      }

    end
    return result
  end

  ###########################################################################################
  # Returns newline separated strings to be used as structure members that represent
  # function arguments
  ###########################################################################################
  def get_params_declaration_string(function_argument_types)
    token =  Configuration.autogen_params_tag+"\t"+"arg"+Configuration.delimiter
    result = ""
    unless function_argument_types.length <= 0
      function_argument_types.each_index{|index|
        result.concat(token.gsub(Configuration.delimiter, index.to_s)).concat(";\n").concat("\t");
      }
    end
    return result
  end

  ###########################################################################################
  # Returns newline separated strings to be used as structure members that represent
  # global variables
  ###########################################################################################
  def get_globals_as_struct_members(global_types_array)
    token = Configuration.autogen_globals_tag+"\t"+"global_typ"+Configuration.delimiter
    result = ""
    global_types_array.each_index{|index|
      unless global_types_array.length <= 0
        global_types_array.each_index{|index|
          result.concat(token.gsub(Configuration.delimiter, index.to_s)).concat(";\n").concat("\t");
        }
      end
    }
    return result
  end

  ###########################################################################################
  # Returns newline separated definition of all temp variables as reported by SpreadsheetREader
  ###########################################################################################
  def get_temp_var_definitions
    result = ""
    @temp_var_names_array.each_index{|index|

      result.concat(@temp_var_types_array[index]).concat("\t")\
      .concat(@temp_var_names_array[index])\
      .concat(" = ")\
      .concat(@temp_var_values_array[index])\
      .concat(";\n")
    }
    return result
  end

  def get_initlized_test_data
    result = ""

    @number_of_test_cases.times do |count|

      result\
      .concat("\n\t{\n\t\t")\
      .concat("&FUNC_UNDER_TEST,\n\t\t")\
      .concat(get_initialized_struct_members(count))\
      .concat("\n\t},\n")
    end

    #remove surplus comma from the last member
    result.slice!(result.rindex(COMMA),COMMA.size)
    return result

  end

  ############################################################################################
  # Returns a newline separated initialization values for all structure members as reported
  # by SpreadsheetReader
  ############################################################################################
  def get_initialized_struct_members(index)
    data = ""

    # all parameter types
    @parameters_hashmap.each_pair{|key, value|
      data\
      .concat(value[index])\
      .concat(",\n\t\t")
    }

    # all global types
    @globals_hashmap.each_pair{|key, value|
      data\
      .concat(value[index])\
      .concat(",\n\t\t")
    }

    #expected return values
    no_return_value = process_return_value(index)

    if no_return_value
      #remove surplus comma from the last member
      data.slice!(data.rindex(COMMA),COMMA.size)
    else
      data\
      .concat(@return_values[index])\
      .concat("\n\t\t")
    end

    return data
  end

  #############################################################################################
  # Called within class constructor to make sure that all instance
  # variables were populated correctly
  #############################################################################################
  def validate_initializations
    #TODO - Write null check / size check logic here
    
    # make sure that there are no nils
    assert {@function_return_type != nil}
    assert {@function_name != nil}
    assert {@function_argument_types_string != nil}
    assert {@function_argument_types_array != nil}
    assert {@global_types_array != nil}
    assert {@is_ret_type_not_void != nil}
    assert {@number_of_test_cases != nil}
    assert {@temp_var_types_array != nil}
    assert {@temp_var_names_array != nil}
    assert {@temp_var_values_array != nil}
    assert {@parameters_hashmap != nil}
    assert {@globals_hashmap != nil}
    assert {@return_values != nil}
    
    #make sure that the table for temporary variables was properly filled  
    assert{@temp_var_types_array.length == @temp_var_names_array.length}
    assert{@temp_var_types_array.length == @temp_var_values_array.length}
      
    #make sure that the table for test matrix was properly filled
    unless @number_of_test_cases == 0
      
      #check that all values are entered for all parameters for each test case
      @parameters_hashmap.each_pair{|key, value|
        assert{@number_of_test_cases == value.length}
      }
      
      # check that all values are entered for all global variables for each test case
      @globals_hashmap.each_pair{|key, value|
        assert{@number_of_test_cases == value.length}
      }      
    end
    
    # check if all return values have been entered
    assert { @number_of_test_cases == @return_values.length }
  end

  #############################################################################################
  # Returns true if return value is void or some other invalid string
  #############################################################################################
  def process_return_value(index)
    return Configuration.invalid_return_values().include?(@return_values[index])
  end
  
  #############################################################################################
  # Returns a string representation of what parameter initialization should look like in the
  # unit test code
  #############################################################################################
  def get_initialized_parameters_string(parameters)
    token = "arg"+Configuration.delimiter+" = st_arr_test_inputs[index].arg"+Configuration.delimiter+";\n"    
    return get_initialization_strings_for(parameters.length, token)
  end
  
  #############################################################################################
  # Returns string representation of logic that should go in the set_global_vars function
  #############################################################################################
  def get_set_global_vars_code_string(globals_map)
    result = ""
    index_tag = "<index>"
    index = -1
    token = Configuration.globals_tag+" = st_arr_test_inputs["+Configuration.delimiter+"].global_typ"+index_tag+";\n\t"
    globals_map.each_pair{|key, value|
      temp = token.gsub(Configuration.globals_tag,key).gsub(Configuration.delimiter, "index").gsub(index_tag, (index+1).to_s)
      result.concat(temp)
      index = index+1;
    }
    return result
  end
  
  ############################################################################################
  # Generic function that accepts a count 'n' and a tag and returns string representation of
  # C style initialization of 'n' varialbles.
  ############################################################################################
  def get_initialization_strings_for(count, pattern)
    result = ""
    count.times{|index|
      result.concat(pattern.gsub(Configuration.delimiter,index.to_s)).concat("\t\t")
    }
    
    return result
  end
  
  #############################################################################################
  # Returns comma separated values, to be used as arguments for string
  #############################################################################################
  def get_csv_for_arguments(arguments)
    result = ""
    token = "arg"+Configuration.delimiter+COMMA+SPACE
    arguments.each_index{|index|
      result.concat(token.gsub(Configuration.delimiter,index.to_s))
    }
    
    return result.chop!.chop!
  end

  ##############################################################################################
  # Private functions
  ##############################################################################################
  private :parse_function_signature
  private :get_number_of_test_cases
  private :get_global_types
  private :get_macro_definitions
  private :get_params_declaration_string
  private :get_globals_as_struct_members
  private :get_temp_var_definitions
  private :get_temp_var_data
  private :get_initlized_test_data
  private :get_initialized_struct_members
  private :validate_initializations
  private :get_initialized_struct_members
  private :process_return_value
  private :get_initialized_parameters_string
  private :get_csv_for_arguments
  private :get_initialization_strings_for
  private :get_csv_for_arguments
  private :get_set_global_vars_code_string

end