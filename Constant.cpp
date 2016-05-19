#include "Constant.h"
#include <string>
Constant::Constant(ConstantType type, int int_val)
{
  this->type = type;
  this->int_val = int_val;
  
}
Constant::Constant(ConstantType type, std::string string_val)
{
    this->type = type;
    this->string_val = string_val;
}
Constant::Constant(ConstantType type, float float_val)
{
    this->type = type;
    this->float_val = float_val;
}
